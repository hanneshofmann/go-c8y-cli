// Code generated from specification version 1.0.0: DO NOT EDIT
package cmd

import (
	"fmt"
	"io"
	"net/http"

	"github.com/MakeNowJust/heredoc/v2"
	"github.com/reubenmiller/go-c8y-cli/pkg/cmderrors"
	"github.com/reubenmiller/go-c8y-cli/pkg/completion"
	"github.com/reubenmiller/go-c8y-cli/pkg/flags"
	"github.com/reubenmiller/go-c8y-cli/pkg/mapbuilder"
	"github.com/reubenmiller/go-c8y/pkg/c8y"
	"github.com/spf13/cobra"
)

// GetMeasurementSeriesCmd command
type GetMeasurementSeriesCmd struct {
	*baseCmd
}

// NewGetMeasurementSeriesCmd creates a command to Get measurement series
func NewGetMeasurementSeriesCmd() *GetMeasurementSeriesCmd {
	ccmd := &GetMeasurementSeriesCmd{}
	cmd := &cobra.Command{
		Use:   "getSeries",
		Short: "Get measurement series",
		Long:  `Get a collection of measurements based on filter parameters`,
		Example: heredoc.Doc(`
$ c8y measurements getSeries -source 12345 --series nx_WEA_29_Delta.MDL10FG001 --series nx_WEA_29_Delta.ST9 --dateFrom "-10min" --dateTo "0s"
Get a list of series [nx_WEA_29_Delta.MDL10FG001] and [nx_WEA_29_Delta.ST9] for device 12345
        `),
		PreRunE: nil,
		RunE:    ccmd.RunE,
	}

	cmd.SilenceUsage = true

	cmd.Flags().StringSlice("device", []string{""}, "Device ID (accepts pipeline)")
	cmd.Flags().StringSlice("series", []string{""}, "measurement type and series name, e.g. c8y_AccelerationMeasurement.acceleration")
	cmd.Flags().String("aggregationType", "", "Fragment name from measurement.")
	cmd.Flags().String("dateFrom", "-7d", "Start date or date and time of measurement occurrence. Defaults to last 7 days")
	cmd.Flags().String("dateTo", "0s", "End date or date and time of measurement occurrence. Defaults to the current time")

	completion.WithOptions(
		cmd,
		completion.WithValidateSet("aggregationType", "DAILY", "HOURLY", "MINUTELY"),
	)

	flags.WithOptions(
		cmd,
		flags.WithExtendedPipelineSupport("device", "source", false, "deviceId", "source.id", "managedObject.id", "id"),
		flags.WithCollectionProperty("-"),
	)

	// Required flags

	ccmd.baseCmd = newBaseCmd(cmd)

	return ccmd
}

// RunE executes the command
func (n *GetMeasurementSeriesCmd) RunE(cmd *cobra.Command, args []string) error {
	var err error
	inputIterators, err := flags.NewRequestInputIterators(cmd)
	if err != nil {
		return err
	}

	// query parameters
	query := flags.NewQueryTemplate()
	err = flags.WithQueryParameters(
		cmd,
		query,
		inputIterators,
		WithDeviceByNameFirstMatch(args, "device", "source"),
		flags.WithStringSliceValues("series", "series", ""),
		flags.WithStringValue("aggregationType", "aggregationType"),
		flags.WithRelativeTimestamp("dateFrom", "dateFrom", ""),
		flags.WithRelativeTimestamp("dateTo", "dateTo", ""),
	)
	if err != nil {
		return cmderrors.NewUserError(err)
	}
	commonOptions, err := getCommonOptions(cmd)
	if err != nil {
		return cmderrors.NewUserError(fmt.Sprintf("Failed to get common options. err=%s", err))
	}
	commonOptions.AddQueryParameters(query)

	queryValue, err := query.GetQueryUnescape(true)

	if err != nil {
		return cmderrors.NewSystemError("Invalid query parameter")
	}

	// headers
	headers := http.Header{}
	err = flags.WithHeaders(
		cmd,
		headers,
		inputIterators,
	)
	if err != nil {
		return cmderrors.NewUserError(err)
	}

	// form data
	formData := make(map[string]io.Reader)
	err = flags.WithFormDataOptions(
		cmd,
		formData,
		inputIterators,
	)
	if err != nil {
		return cmderrors.NewUserError(err)
	}

	// body
	body := mapbuilder.NewInitializedMapBuilder()
	err = flags.WithBody(
		cmd,
		body,
		inputIterators,
	)
	if err != nil {
		return cmderrors.NewUserError(err)
	}

	// path parameters
	path := flags.NewStringTemplate("measurement/measurements/series")
	err = flags.WithPathParameters(
		cmd,
		path,
		inputIterators,
	)
	if err != nil {
		return err
	}

	req := c8y.RequestOptions{
		Method:       "GET",
		Path:         path.GetTemplate(),
		Query:        queryValue,
		Body:         body,
		FormData:     formData,
		Header:       headers,
		IgnoreAccept: cliConfig.IgnoreAcceptHeader(),
		DryRun:       cliConfig.DryRun(),
	}

	return processRequestAndResponseWithWorkers(cmd, &req, inputIterators)
}
