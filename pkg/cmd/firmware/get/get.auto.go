// Code generated from specification version 1.0.0: DO NOT EDIT
package get

import (
	"fmt"
	"io"
	"net/http"

	"github.com/MakeNowJust/heredoc/v2"
	"github.com/reubenmiller/go-c8y-cli/pkg/c8yfetcher"
	"github.com/reubenmiller/go-c8y-cli/pkg/cmd/subcommand"
	"github.com/reubenmiller/go-c8y-cli/pkg/cmderrors"
	"github.com/reubenmiller/go-c8y-cli/pkg/cmdutil"
	"github.com/reubenmiller/go-c8y-cli/pkg/completion"
	"github.com/reubenmiller/go-c8y-cli/pkg/flags"
	"github.com/reubenmiller/go-c8y-cli/pkg/mapbuilder"
	"github.com/reubenmiller/go-c8y/pkg/c8y"
	"github.com/spf13/cobra"
)

// GetCmd command
type GetCmd struct {
	*subcommand.SubCommand

	factory *cmdutil.Factory
}

// NewGetCmd creates a command to Get firmware
func NewGetCmd(f *cmdutil.Factory) *GetCmd {
	ccmd := &GetCmd{
		factory: f,
	}
	cmd := &cobra.Command{
		Use:   "get",
		Short: "Get firmware",
		Long:  `Get an existing firmware package (managedObject)`,
		Example: heredoc.Doc(`
$ c8y firmware get --id 12345
Get a firmware package

$ echo 12345 | c8y firmware get
Get a firmware package (using pipeline)
        `),
		PreRunE: func(cmd *cobra.Command, args []string) error {
			return nil
		},
		RunE: ccmd.RunE,
	}

	cmd.SilenceUsage = true

	cmd.Flags().StringSlice("id", []string{""}, "Firmware package (managedObject) id (required) (accepts pipeline)")

	completion.WithOptions(
		cmd,
		completion.WithFirmware("id", func() (*c8y.Client, error) { return ccmd.factory.Client() }),
	)

	flags.WithOptions(
		cmd,

		flags.WithExtendedPipelineSupport("id", "id", true, "additionParents.references.0.managedObject.id", "id"),
	)

	// Required flags

	ccmd.SubCommand = subcommand.NewSubCommand(cmd)

	return ccmd
}

// RunE executes the command
func (n *GetCmd) RunE(cmd *cobra.Command, args []string) error {
	cfg, err := n.factory.Config()
	if err != nil {
		return err
	}
	client, err := n.factory.Client()
	if err != nil {
		return err
	}
	inputIterators, err := cmdutil.NewRequestInputIterators(cmd, cfg)
	if err != nil {
		return err
	}

	// query parameters
	query := flags.NewQueryTemplate()
	err = flags.WithQueryParameters(
		cmd,
		query,
		inputIterators,
		flags.WithCustomStringSlice(func() ([]string, error) { return cfg.GetQueryParameters(), nil }, "custom"),
	)
	if err != nil {
		return cmderrors.NewUserError(err)
	}
	commonOptions, err := cfg.GetOutputCommonOptions(cmd)
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
		flags.WithCustomStringSlice(func() ([]string, error) { return cfg.GetHeader(), nil }, "header"),
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
	path := flags.NewStringTemplate("inventory/managedObjects/{id}")
	err = flags.WithPathParameters(
		cmd,
		path,
		inputIterators,
		c8yfetcher.WithFirmwareByNameFirstMatch(client, args, "id", "id"),
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
		IgnoreAccept: cfg.IgnoreAcceptHeader(),
		DryRun:       cfg.ShouldUseDryRun(cmd.CommandPath()),
	}

	return n.factory.RunWithWorkers(client, cmd, &req, inputIterators)
}
