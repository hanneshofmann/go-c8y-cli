// Code generated from specification version 1.0.0: DO NOT EDIT
package cmd

import (
	"io"
	"net/http"
	"net/url"

	"github.com/reubenmiller/go-c8y-cli/pkg/flags"
	"github.com/reubenmiller/go-c8y-cli/pkg/mapbuilder"
	"github.com/reubenmiller/go-c8y/pkg/c8y"
	"github.com/spf13/cobra"
)

type EnableApplicationOnTenantCmd struct {
	*baseCmd
}

func NewEnableApplicationOnTenantCmd() *EnableApplicationOnTenantCmd {
	ccmd := &EnableApplicationOnTenantCmd{}
	cmd := &cobra.Command{
		Use:   "enableApplication",
		Short: "Enable application on tenant",
		Long:  ``,
		Example: `
$ c8y tenants enableApplication --tenant "mycompany" --application "myMicroservice"
Enable an application of a tenant by name
        `,
		PreRunE: validateCreateMode,
		RunE:    ccmd.RunE,
	}

	cmd.SilenceUsage = true

	cmd.Flags().String("tenant", "", "Tenant id. Defaults to current tenant (based on credentials)")
	cmd.Flags().String("application", "", "Application id (required) (accepts pipeline)")
	addProcessingModeFlag(cmd)

	flags.WithOptions(
		cmd,
		flags.WithPipelineSupport("application"),
	)

	// Required flags

	ccmd.baseCmd = newBaseCmd(cmd)

	return ccmd
}

func (n *EnableApplicationOnTenantCmd) RunE(cmd *cobra.Command, args []string) error {
	var err error
	// query parameters
	queryValue := url.QueryEscape("")
	query := url.Values{}

	err = flags.WithQueryParameters(
		cmd,
		query,
	)
	if err != nil {
		return newUserError(err)
	}

	queryValue, err = url.QueryUnescape(query.Encode())

	if err != nil {
		return newSystemError("Invalid query parameter")
	}

	// headers
	headers := http.Header{}
	err = flags.WithHeaders(
		cmd,
		headers,
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
	)
	if err != nil {
		return newUserError(err)
	}

	// body
	body := mapbuilder.NewInitializedMapBuilder()
	err = flags.WithBody(
		cmd,
		body,
		WithDataValue(),
		WithApplicationByNameFirstMatch(args, "application", "application.id"),
		WithTemplateValue(),
		WithTemplateVariablesValue(),
	)
	if err != nil {
		return newUserError(err)
	}

	if err := body.Validate(); err != nil {
		return newUserError("Body validation error. ", err)
	}

	// path parameters
	pathParameters := make(map[string]string)
	err = flags.WithPathParameters(
		cmd,
		pathParameters,
		flags.WithStringDefaultValue(client.TenantName, "tenant", "tenant"),
	)

	path := replacePathParameters("/tenant/tenants/{tenant}/applications", pathParameters)

	req := c8y.RequestOptions{
		Method:       "POST",
		Path:         path,
		Query:        queryValue,
		Body:         body,
		FormData:     formData,
		Header:       headers,
		IgnoreAccept: false,
		DryRun:       globalFlagDryRun,
	}

	pipeOption := PipeOption{
		Name:              "application",
		Property:          "application.id",
		Required:          true,
		ResolveByNameType: "application",
	}
	return processRequestAndResponseWithWorkers(cmd, &req, pipeOption)
}
