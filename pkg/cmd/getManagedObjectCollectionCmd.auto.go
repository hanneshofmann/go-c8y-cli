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

// GetManagedObjectCollectionCmd command
type GetManagedObjectCollectionCmd struct {
	*baseCmd
}

// NewGetManagedObjectCollectionCmd creates a command to Get managed object collection
func NewGetManagedObjectCollectionCmd() *GetManagedObjectCollectionCmd {
	ccmd := &GetManagedObjectCollectionCmd{}
	cmd := &cobra.Command{
		Use:   "list",
		Short: "Get managed object collection",
		Long:  `Get a collection of managedObjects based on filter parameters`,
		Example: heredoc.Doc(`
$ c8y inventory list
Get a list of managed objects

$ c8y inventory list --ids 1111,2222
Get a list of managed objects by ids
        `),
		PreRunE: nil,
		RunE:    ccmd.RunE,
	}

	cmd.SilenceUsage = true

	cmd.Flags().StringSlice("ids", []string{""}, "List of ids.")
	cmd.Flags().String("type", "", "ManagedObject type.")
	cmd.Flags().String("fragmentType", "", "ManagedObject fragment type.")
	cmd.Flags().String("text", "", "managed objects containing a text value starting with the given text (placeholder {text}). Text value is any alphanumeric string starting with a latin letter (A-Z or a-z).")
	cmd.Flags().Bool("withParents", false, "include a flat list of all parents and grandparents of the given object")
	cmd.Flags().Bool("skipChildrenNames", false, "Don't include the child devices names in the response. This can improve the API response because the names don't need to be retrieved")

	completion.WithOptions(
		cmd,
	)

	flags.WithOptions(
		cmd,
		flags.WithExtendedPipelineSupport("", "", false),
		flags.WithCollectionProperty("managedObjects"),
	)

	// Required flags

	ccmd.baseCmd = newBaseCmd(cmd)

	return ccmd
}

// RunE executes the command
func (n *GetManagedObjectCollectionCmd) RunE(cmd *cobra.Command, args []string) error {
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
		flags.WithStringSliceCSV("ids", "ids", ""),
		flags.WithStringValue("type", "type"),
		flags.WithStringValue("fragmentType", "fragmentType"),
		flags.WithStringValue("text", "text"),
		flags.WithBoolValue("withParents", "withParents", ""),
		flags.WithBoolValue("skipChildrenNames", "skipChildrenNames", ""),
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
	path := flags.NewStringTemplate("inventory/managedObjects")
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
