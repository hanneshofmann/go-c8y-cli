package inventory

import (
	cmdCreate "github.com/reubenmiller/go-c8y-cli/pkg/cmd/inventory/create"
	cmdDelete "github.com/reubenmiller/go-c8y-cli/pkg/cmd/inventory/delete"
	cmdFindByText "github.com/reubenmiller/go-c8y-cli/pkg/cmd/inventory/findbytext"
	cmdGet "github.com/reubenmiller/go-c8y-cli/pkg/cmd/inventory/get"
	cmdList "github.com/reubenmiller/go-c8y-cli/pkg/cmd/inventory/list"
	cmdUpdate "github.com/reubenmiller/go-c8y-cli/pkg/cmd/inventory/update"
	"github.com/reubenmiller/go-c8y-cli/pkg/cmd/subcommand"
	"github.com/reubenmiller/go-c8y-cli/pkg/cmdutil"
	"github.com/spf13/cobra"
)

type SubCmdInventory struct {
	*subcommand.SubCommand
}

func NewSubCommand(f *cmdutil.Factory) *SubCmdInventory {
	ccmd := &SubCmdInventory{}

	cmd := &cobra.Command{
		Use:   "inventory",
		Short: "Cumulocity managed objects",
		Long:  `REST endpoint to interact with Cumulocity managed objects`,
	}

	// Subcommands
	cmd.AddCommand(cmdList.NewListCmd(f).GetCommand())
	cmd.AddCommand(cmdFindByText.NewFindByTextCmd(f).GetCommand())
	cmd.AddCommand(cmdCreate.NewCreateCmd(f).GetCommand())
	cmd.AddCommand(cmdGet.NewGetCmd(f).GetCommand())
	cmd.AddCommand(cmdUpdate.NewUpdateCmd(f).GetCommand())
	cmd.AddCommand(cmdDelete.NewDeleteCmd(f).GetCommand())

	ccmd.SubCommand = subcommand.NewSubCommand(cmd)

	return ccmd
}
