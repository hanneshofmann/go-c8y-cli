// Code generated from specification version 1.0.0: DO NOT EDIT
package enable

import (
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

// EnableCmd command
type EnableCmd struct {
	*subcommand.SubCommand

	factory *cmdutil.Factory
}

// NewEnableCmd creates a command to subscribe to microservice
func NewEnableCmd(f *cmdutil.Factory) *EnableCmd {
	ccmd := &EnableCmd{
		factory: f,
	}
	cmd := &cobra.Command{
		Use:   "enable",
		Short: "subscribe to microservice",
		Long: `Enabling (subscribing) a microservice will activate the application in the tenant
`,
		Example: heredoc.Doc(`
$ c8y microservices enable --id 12345
Enable (subscribe) to a microservice

$ c8y microservices enable --id report-agent
Enable (subscribe) to a microservice by name
        `),
		PreRunE: func(cmd *cobra.Command, args []string) error {
			return f.CreateModeEnabled()
		},
		RunE: ccmd.RunE,
	}

	cmd.SilenceUsage = true

	cmd.Flags().String("tenant", "", "Tenant id")
	cmd.Flags().String("id", "", "Microservice id (required) (accepts pipeline)")

	completion.WithOptions(
		cmd,
		completion.WithTenantID("tenant", func() (*c8y.Client, error) { return ccmd.factory.Client() }),
		completion.WithMicroservice("id", func() (*c8y.Client, error) { return ccmd.factory.Client() }),
	)

	flags.WithOptions(
		cmd,
		flags.WithProcessingMode(),

		flags.WithExtendedPipelineSupport("id", "application.id", true),
	)

	// Required flags

	ccmd.SubCommand = subcommand.NewSubCommand(cmd)

	return ccmd
}

// RunE executes the command
func (n *EnableCmd) RunE(cmd *cobra.Command, args []string) error {
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
		flags.WithProcessingModeValue(),
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
		flags.WithDataFlagValue(),
		c8yfetcher.WithMicroserviceByNameFirstMatch(client, args, "id", "application.id"),
		cmdutil.WithTemplateValue(cfg),
		flags.WithTemplateVariablesValue(),
	)
	if err != nil {
		return cmderrors.NewUserError(err)
	}

	// path parameters
	path := flags.NewStringTemplate("/tenant/tenants/{tenant}/applications")
	err = flags.WithPathParameters(
		cmd,
		path,
		inputIterators,
		flags.WithStringDefaultValue(client.TenantName, "tenant", "tenant"),
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
		IgnoreAccept: cfg.IgnoreAcceptHeader(),
		DryRun:       cfg.ShouldUseDryRun(cmd.CommandPath()),
	}

	return n.factory.RunWithWorkers(client, cmd, &req, inputIterators)
}
