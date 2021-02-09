package cmd

import (
	"encoding/json"
	"errors"
	"os"
	"reflect"
	"strings"
	"sync/atomic"

	"github.com/reubenmiller/go-c8y-cli/pkg/flags"
	"github.com/reubenmiller/go-c8y-cli/pkg/iterator"
	"github.com/reubenmiller/go-c8y/pkg/c8y"
)

// NewRelativeTimeIterator returns a relative time iterator which can generate timestamps based on time.Now when the value is retrieved
func NewRelativeTimeIterator(relative string) *iterator.FuncIterator {
	next := func(i int64) (string, error) {
		return tryGetTimestamp(relative)
	}
	return iterator.NewFuncIterator(next, 0)
}

// NewRequestIterator returns an iterator that can be used to send multiple requests until the give iterators in the path/body are exhausted
func NewRequestIterator(r c8y.RequestOptions, path iterator.Iterator, query iterator.Iterator, body interface{}) *RequestIterator {
	reqIter := &RequestIterator{
		Request: r,
		Path:    path,
		Query:   query,
		Body:    body,
	}
	return reqIter
}

// RequestIterator iterates through a c8y rest request with given request options and path iterators
type RequestIterator struct {
	Request        c8y.RequestOptions
	Path           iterator.Iterator
	Query          iterator.Iterator
	InputIterators flags.RequestInputIterators
	Body           interface{}
	done           int32
}

// HasNext returns true if there the iterator is finished
func (r *RequestIterator) HasNext() bool {
	return atomic.LoadInt32(&r.done) > 0
}

func (r *RequestIterator) setDone() {
	atomic.AddInt32(&r.done, 1)
}

// GetNext return the next request. If error is io.EOF then the iterator is finished
func (r *RequestIterator) GetNext() (*c8y.RequestOptions, error) {

	// TODO: is shallow copy ok here?
	req := &c8y.RequestOptions{
		Host:             r.Request.Host,
		Method:           r.Request.Method,
		Path:             r.Request.Path,
		Query:            r.Request.Query,
		Body:             r.Request.Body,
		FormData:         r.Request.FormData,
		ContentType:      r.Request.ContentType,
		Accept:           r.Request.Accept,
		Header:           r.Request.Header,
		ResponseData:     r.Request.ResponseData,
		NoAuthentication: r.Request.NoAuthentication,
		IgnoreAccept:     r.Request.IgnoreAccept,
		DryRun:           globalFlagDryRun,
	}

	// apply path iterator
	if r.Path != nil && !reflect.ValueOf(r.Path).IsNil() {
		path, _, err := r.Path.GetNext()

		if err != nil {
			if !errors.Is(err, ErrNoMatchesFound) {
				r.setDone()
			}
			return nil, err
		}

		req.Path = string(path)
	}

	// apply query iterator
	// note: reflection is needed as a simple nil check does not work for interfaces!
	if r.Query != nil && !reflect.ValueOf(r.Query).IsNil() {
		q, _, err := r.Query.GetNext()
		if err != nil {
			if !errors.Is(err, ErrNoMatchesFound) {
				r.setDone()
			}
			return nil, err
		}
		req.Query = string(q)
	}

	// apply body iterator
	if r.Body != nil && !reflect.ValueOf(r.Body).IsNil() && (strings.EqualFold(req.Method, "POST") || strings.EqualFold(req.Method, "PUT")) {
		// iterator body. Any validation will be run here
		switch v := r.Body.(type) {
		case *os.File:
			req.Body = v
		default:
			bodyContents, err := json.Marshal(r.Body)

			if err != nil {
				if !errors.Is(err, ErrNoMatchesFound) {
					r.setDone()
				}
				return nil, err
			}

			// TODO: Find more efficient way rather than converting to and from json
			bodyValue := make(map[string]interface{})

			// Note: UnmarshalJSON does not support large numbers by default, so
			// 		 c8y.DecodeJSONBytes should be used instead!
			if err := c8y.DecodeJSONBytes(bodyContents, &bodyValue); err != nil {
				r.setDone()
				return nil, err
			}
			req.Body = bodyValue
		}
	}
	return req, nil
}
