// Code generated from specification version 1.0.0: DO NOT EDIT
package cmd

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"github.com/fatih/color"
	"github.com/reubenmiller/go-c8y-cli/pkg/encoding"
	"github.com/reubenmiller/go-c8y-cli/pkg/jsonUtilities"
	"github.com/reubenmiller/go-c8y-cli/pkg/mapbuilder"
	"github.com/reubenmiller/go-c8y/pkg/c8y"
	"github.com/spf13/cobra"
	"github.com/tidwall/pretty"
)

type getManagedObjectChildAssetReferenceCmd struct {
	*baseCmd
}

func newGetManagedObjectChildAssetReferenceCmd() *getManagedObjectChildAssetReferenceCmd {
	ccmd := &getManagedObjectChildAssetReferenceCmd{}

	cmd := &cobra.Command{
		Use:   "getChildAsset",
		Short: "Get managed object child asset reference",
		Long:  ``,
		Example: `
$ c8y inventoryReferences getChildAsset --asset 12345 --reference 12345
Get an existing child asset reference
		`,
		RunE: ccmd.getManagedObjectChildAssetReference,
	}

	cmd.SilenceUsage = true

	cmd.Flags().StringSlice("asset", []string{""}, "Asset id (required)")
	cmd.Flags().StringSlice("reference", []string{""}, "Asset reference id (required)")

	// Required flags
	cmd.MarkFlagRequired("asset")
	cmd.MarkFlagRequired("reference")

	ccmd.baseCmd = newBaseCmd(cmd)

	return ccmd
}

func (n *getManagedObjectChildAssetReferenceCmd) getManagedObjectChildAssetReference(cmd *cobra.Command, args []string) error {

	// query parameters
	queryValue := url.QueryEscape("")
	query := url.Values{}
	if cmd.Flags().Changed("pageSize") {
		if v, err := cmd.Flags().GetInt("pageSize"); err == nil && v > 0 {
			query.Add("pageSize", fmt.Sprintf("%d", v))
		}
	}

	if cmd.Flags().Changed("withTotalPages") {
		if v, err := cmd.Flags().GetBool("withTotalPages"); err == nil && v {
			query.Add("withTotalPages", "true")
		}
	}
	queryValue, err := url.QueryUnescape(query.Encode())

	if err != nil {
		return newSystemError("Invalid query parameter")
	}

	// headers
	headers := http.Header{}

	// form data
	formData := make(map[string]io.Reader)

	// body
	body := mapbuilder.NewMapBuilder()

	// path parameters
	pathParameters := make(map[string]string)
	if cmd.Flags().Changed("asset") {
		assetInputValues, assetValue, err := getFormattedDeviceSlice(cmd, args, "asset")

		if err != nil {
			return newUserError("no matching devices found", assetInputValues, err)
		}

		if len(assetValue) == 0 {
			return newUserError("no matching devices found", assetInputValues)
		}

		for _, item := range assetValue {
			if item != "" {
				pathParameters["asset"] = newIDValue(item).GetID()
			}
		}
	}
	if cmd.Flags().Changed("reference") {
		referenceInputValues, referenceValue, err := getFormattedDeviceSlice(cmd, args, "reference")

		if err != nil {
			return newUserError("no matching devices found", referenceInputValues, err)
		}

		if len(referenceValue) == 0 {
			return newUserError("no matching devices found", referenceInputValues)
		}

		for _, item := range referenceValue {
			if item != "" {
				pathParameters["reference"] = newIDValue(item).GetID()
			}
		}
	}

	path := replacePathParameters("inventory/managedObjects/{asset}/childAssets/{reference}", pathParameters)

	// filter and selectors
	filters := getFilterFlag(cmd, "filter")

	req := c8y.RequestOptions{
		Method:       "GET",
		Path:         path,
		Query:        queryValue,
		Body:         body.GetMap(),
		FormData:     formData,
		Header:       headers,
		IgnoreAccept: false,
		DryRun:       globalFlagDryRun,
	}

	// Common outputfile option
	outputfile := ""
	if v, err := getOutputFileFlag(cmd, "outputFile"); err == nil {
		outputfile = v
	} else {
		return err
	}

	return n.doGetManagedObjectChildAssetReference(req, outputfile, filters)
}

func (n *getManagedObjectChildAssetReferenceCmd) doGetManagedObjectChildAssetReference(req c8y.RequestOptions, outputfile string, filters *JSONFilters) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(globalFlagTimeout)*time.Millisecond)
	defer cancel()
	start := time.Now()
	resp, err := client.SendRequest(
		ctx,
		req,
	)

	Logger.Infof("Response time: %dms", int64(time.Since(start)/time.Millisecond))

	if ctx.Err() != nil {
		Logger.Criticalf("request timed out after %d", globalFlagTimeout)
	}

	if resp != nil {
		Logger.Infof("Response header: %v", resp.Header)
	}

	// write response to file instead of to stdout
	if resp != nil && err == nil && outputfile != "" {
		fullFilePath, err := saveResponseToFile(resp, outputfile)

		if err != nil {
			return newSystemError("write to file failed", err)
		}

		fmt.Printf("%s", fullFilePath)
		return nil
	}

	if resp != nil && err == nil && resp.Header.Get("Content-Type") == "application/octet-stream" && resp.JSONData != nil {
		if encoding.IsUTF16(*resp.JSONData) {
			if utf8, err := encoding.DecodeUTF16([]byte(*resp.JSONData)); err == nil {
				fmt.Printf("%s", utf8)
			} else {
				fmt.Printf("%s", *resp.JSONData)
			}
		} else {
			fmt.Printf("%s", *resp.JSONData)
		}
		return nil
	}

	if err != nil {
		color.Set(color.FgRed, color.Bold)
	}

	if resp != nil && resp.JSONData != nil {
		// estimate size based on utf8 encoding. 1 char is 1 byte
		Logger.Printf("Response Length: %0.1fKB", float64(len(*resp.JSONData)*1)/1024)

		var responseText []byte
		isJSONResponse := jsonUtilities.IsValidJSON([]byte(*resp.JSONData))

		if isJSONResponse && filters != nil && !globalFlagRaw {
			responseText = filters.Apply(*resp.JSONData, "")
		} else {
			responseText = []byte(*resp.JSONData)
		}

		if globalFlagPrettyPrint && isJSONResponse {
			fmt.Printf("%s", pretty.Pretty(responseText))
		} else {
			fmt.Printf("%s", responseText)
		}
	}

	color.Unset()

	if err != nil {
		return newSystemError("command failed", err)
	}
	return nil
}
