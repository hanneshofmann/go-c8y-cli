---
category: assert
title: c8y inventory assert exists
---
Assert existance of a managed object

### Synopsis

Assert that a managed objects exists or not and pass input untouched

If the assertion is true, then the input value (stdin or an explicit argument value) will be passed untouched to stdout.
This is useful if you want to filter a list of managed objects by whether they exist or not in the platform, and use the results
in some downstream command (in the pipeline)

By default, a failed assertion will not set the exit code to a non-zero value. If you want a non-zero exit code
in such as case then use the --strict option.


```
c8y inventory assert exists [flags]
```

### Examples

```
$ c8y inventory assert exists --id 1234
# => 1234 (if the ID exists)
# => <no response> (if the ID does not exist)
# Assert the managed object exists

$ echo "1111" | c8y inventory assert exists
# Pass the piped input only on if the ids exists as a managed object

$ echo -e "1111\n2222" | c8y inventory assert exists --not
# Only select the managed object ids which do not exist

$ echo 1 | c8y inventory assert exists --strict
# Return non-zero exit code if a managed object id=1 does not exist

```

### Options

```
      --duration string   Timeout duration. i.e. 30s or 1m (1 minute) (default "30s")
  -h, --help              help for exists
      --id string         Inventory id (required) (accepts pipeline)
      --interval string   Interval to check on the status, i.e. 10s or 1min (default "5s")
      --not               Negate the match
      --retries int       Number of retries before giving up per id
      --strict            Strict mode, fail if no match is found
```

### Options inherited from parent commands

```
      --abortOnErrors int          Abort batch when reaching specified number of errors (default 10)
      --allowEmptyPipe             Don't fail when piped input is empty (stdin)
      --cache                      Enable cached responses
      --cacheTTL string            Cache time-to-live (TTL) as a duration, i.e. 60s, 2m (default "60s")
  -c, --compact                    Compact instead of pretty-printed output when using json output. Pretty print is the default if output is the terminal
      --confirm                    Prompt for confirmation
      --confirmText string         Custom confirmation text
      --currentPage int            Current page which should be returned
      --customQueryParam strings   add custom URL query parameters. i.e. --customQueryParam 'withCustomOption=true,myOtherOption=myvalue'
      --debug                      Set very verbose log messages
      --delay string               delay after each request, i.e. 5ms, 1.2s (default "0ms")
      --delayBefore string         delay before each request, i.e. 5ms, 1.2s (default "0ms")
      --dry                        Dry run. Don't send any data to the server
      --dryFormat string           Dry run output format. i.e. json, dump, markdown or curl (default "markdown")
      --examples                   Show examples for the current command
      --filter strings             Apply a client side filter to response before returning it to the user
      --flatten                    flatten json output by replacing nested json properties with properties where their names are represented by dot notation
  -f, --force                      Do not prompt for confirmation. Ignored when using --confirm
  -H, --header strings             custom headers. i.e. --header "Accept: value, AnotherHeader: myvalue"
      --includeAll                 Include all results by iterating through each page
  -k, --insecure                   Allow insecure server connections when using SSL
  -l, --logMessage string          Add custom message to the activity log
      --maxJobs int                Maximum number of jobs. 0 = unlimited (use with caution!)
      --noAccept                   Ignore Accept header will remove the Accept header from requests, however PUT and POST requests will only see the effect
      --noCache                    Force disabling of cached responses (overwrites cache setting)
  -M, --noColor                    Don't use colors when displaying log entries on the console
      --noLog                      Disables the activity log for the current command
      --noProxy                    Ignore the proxy settings
  -n, --nullInput                  Don't read the input (stdin). Useful if using in shell for/while loops
  -o, --output string              Output format i.e. table, json, csv, csvheader (default "table")
      --outputFile string          Save JSON output to file (after select/view)
      --outputFileRaw string       Save raw response to file (before select/view)
  -p, --pageSize int               Maximum results per page (default 5)
      --progress                   Show progress bar. This will also disable any other verbose output
      --proxy string               Proxy setting, i.e. http://10.0.0.1:8080
  -r, --raw                        Show raw response. This mode will force output=json and view=off
      --select stringArray         Comma separated list of properties to return. wildcards and globstar accepted, i.e. --select 'id,name,type,**.serialNumber'
      --session string             Session configuration
  -P, --sessionPassword string     Override session password
  -U, --sessionUsername string     Override session username. i.e. peter or t1234/peter (with tenant)
      --silentExit                 Silent status codes do not affect the exit code
      --silentStatusCodes string   Status codes which will not print out an error message
      --timeout string             Request timeout duration, i.e. 60s, 2m (default "60s")
      --totalPages int             Total number of pages to get
  -v, --verbose                    Verbose logging
      --view string                Use views when displaying data on the terminal. Disable using --view off (default "auto")
      --withError                  Errors will be printed on stdout instead of stderr
  -t, --withTotalPages             Request Cumulocity to include the total pages in the response statitics under .statistics.totalPages
      --workers int                Number of workers (default 1)
```

