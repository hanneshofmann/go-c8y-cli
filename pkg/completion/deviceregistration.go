package completion

import (
	"context"
	"fmt"

	"github.com/reubenmiller/go-c8y/pkg/c8y"
	"github.com/spf13/cobra"
)

// WithDeviceRegistrationRequest device registration request completion
func WithDeviceRegistrationRequest(flagName string, clientFunc func() (*c8y.Client, error)) Option {
	return func(cmd *cobra.Command) *cobra.Command {
		_ = cmd.RegisterFlagCompletionFunc(flagName, func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
			client, err := clientFunc()
			if err != nil {
				return []string{err.Error()}, cobra.ShellCompDirectiveDefault
			}

			pattern := "*" + toComplete + "*"
			items, _, err := client.DeviceCredentials.GetNewDeviceRequests(
				context.Background(),
				&c8y.NewDeviceRequestOptions{
					PaginationOptions: *c8y.NewPaginationOptions(100),
				},
			)

			if err != nil {
				values := []string{fmt.Sprintf("error. %s", err)}
				return values, cobra.ShellCompDirectiveError
			}
			values := []string{}

			for _, item := range items.NewDeviceRequests {
				if toComplete == "" || MatchString(pattern, item.ID) {
					values = append(values, fmt.Sprintf("%s\t%s | creationTime: %s", item.ID, item.Status, item.CreationTime))
				}
			}
			return values, cobra.ShellCompDirectiveNoFileComp
		})
		return cmd
	}
}
