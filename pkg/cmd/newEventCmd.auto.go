// Code generated from specification version 1.0.0: DO NOT EDIT
package cmd

import (
	"io"
	"net/http"

	"github.com/reubenmiller/go-c8y-cli/pkg/flags"
	"github.com/reubenmiller/go-c8y-cli/pkg/mapbuilder"
	"github.com/reubenmiller/go-c8y/pkg/c8y"
	"github.com/spf13/cobra"
)

type NewEventCmd struct {
	*baseCmd
}

func NewNewEventCmd() *NewEventCmd {
	ccmd := &NewEventCmd{}
	cmd := &cobra.Command{
		Use:   "create",
		Short: "Create event",
		Long:  `Create a new event for a device`,
		Example: `
$ c8y events create --device mydevice --type c8y_TestAlarm --time "-0s" --text "Test alarm" --severity MAJOR
Create a new event for a device
        `,
		PreRunE: validateCreateMode,
		RunE:    ccmd.RunE,
	}

	cmd.SilenceUsage = true

	cmd.Flags().StringSlice("device", []string{""}, "The ManagedObject which is the source of this event. (required) (accepts pipeline)")
	cmd.Flags().String("time", "0s", "Time of the event. Defaults to current timestamp.")
	cmd.Flags().String("type", "", "Identifies the type of this event.")
	cmd.Flags().String("text", "", "Text description of the event.")
	addDataFlag(cmd)
	addProcessingModeFlag(cmd)

	flags.WithOptions(
		cmd,
		flags.WithExtendedPipelineSupport("device", "source.id", true, "deviceId", "source.id", "id"),
	)

	// Required flags

	ccmd.baseCmd = newBaseCmd(cmd)

	return ccmd
}

func (n *NewEventCmd) RunE(cmd *cobra.Command, args []string) error {
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
	)
	if err != nil {
		return newUserError(err)
	}

	queryValue, err := query.GetQueryUnescape(true)

	if err != nil {
		return newSystemError("Invalid query parameter")
	}

	// headers
	headers := http.Header{}
	err = flags.WithHeaders(
		cmd,
		headers,
		inputIterators,
		flags.WithProcessingModeValue(),
	)
	if err != nil {
		return newUserError(err)
	}

	// form data
	formData := make(map[string]io.Reader)
	err = flags.WithFormDataOptions(
		cmd,
		formData,
		inputIterators,
	)
	if err != nil {
		return newUserError(err)
	}

	// body
	body := mapbuilder.NewInitializedMapBuilder()
	err = flags.WithBody(
		cmd,
		body,
		inputIterators,
		WithDataValue(),
		WithDeviceByNameFirstMatch(args, "device", "source.id"),
		flags.WithRelativeTimestamp("time", "time", ""),
		flags.WithStringValue("type", "type"),
		flags.WithStringValue("text", "text"),
		WithTemplateValue(),
		WithTemplateVariablesValue(),
		flags.WithRequiredProperties("type", "text", "time"),
	)
	if err != nil {
		return newUserError(err)
	}

	// path parameters
	path := flags.NewStringTemplate("event/events")
	err = flags.WithPathParameters(
		cmd,
		path,
		inputIterators,
	)
	if err != nil {
		return err
	}

	req := c8y.RequestOptions{
		Method:       "POST",
		Path:         path.GetTemplate(),
		Query:        queryValue,
		Body:         body,
		FormData:     formData,
		Header:       headers,
		IgnoreAccept: globalFlagIgnoreAccept,
		DryRun:       globalFlagDryRun,
	}

	return processRequestAndResponseWithWorkers(cmd, &req, inputIterators)
}
