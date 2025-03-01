
# Roadmap

## current todo

### Caching

* [x] Add cache management commands 
  * [x] c8y cache delete
  * [x] c8y cache renew
* [x] Add global parameter to support cache and cacheTTL
* [x] Option to cache specific api requests (i.e. GET, PUT, POST, DELETE)
* [x] Settings management (c8y settings update )
* [ ] Preload cache, how to calculate cache file location?
* [x] Add powershell global parameters

## Bugs

* Subscription tests are flakey

## c8y (golang)

* [x] Support common parameters
  * [x] pageSize
  * [x] withTotalPages
* [x] Add required parameters
* [x] Piped arguments
* [x] Set defaults for certain variables. i.e. Tenant
* [x] Commands
  * [x] Devices list --type unitType
* [x] Expansion
  * [x] applications
  * [x] devices
* [x] Flag parsing
* [x] Suppress logging when not in verbose mode
  * [x] Datetime (relative and fixed)
* [x] New / Import / export cumulocity sessions
  * [x] Create new session
  * [x] Import a session from file
* [x] Generate powershell commands from templates
* [x] Result parsing
  * [x] client side filtering. e.g. c8y applications list --filter "name=*test*"
* [x] Add response size to log
* [x] Support more filtering possibilities
  * [x] Wildcard
  * [x] Regex
* [x] Add option to not loop over the piped variable. Required for Get-AuditRecordCollection when receiving a piped alarm|operation|event etc.
* [x] Add examples
* [x] Generate tests automatically
* [x] Add "file" argument type
* [x] ~~Review "set" argument type~~
* [x] Lookups
  * [x] Add role lookup, which converts a name to a self link. required for Add-RoleToUser
  * [x] Add user lookup
  * [x] Add user self reference lookup
  * [x] Add user group lookup
* [x] Add outFile flag
  * [x] Update all download file commands
* [x] Generic download file cmd
* [x] Generic rest cmd
  * [x] If the response is not json, then return it as is (i.e. like the --raw switch)
* [x] Adding timeout argument
* [x] Add upload flag
  * [x] Update all upload files
* [x] Add request response time to log
* [x] Handle headerParameters in spec
* [x] Add ignore proxy switch
* [x] Allow spec to define static values if of type switch (on headerParameters)
* [x] Fix New-ApplicationBinary test. Create a example microservice (something small hopefully)
* [x] Manual realtime commands (for alarms, events, measurements, etc.)
  * [x] c8y measurements subscribe --device * --series <filter> --output csv
  * [x] c8y alarms subscribe --device * (if *, then don't do anything, use as is) otherwise find device
  * [x] c8y events subscribe --device *
  * [x] c8y operations subscribe --device *
  * [x] c8y realtime subscribe --channel /measurements/* --device
  * [x] c8y subscribe to all realtime notifications
* [x] Add version to c8y binary, i.e. 'c8y version' should print out the current version. It should match the Cumulocity version numbers?
* [x] Add upload flag to generic function
* [x] New-Microservice (manual application)
* [x] Get microservice, delete microservice, update microservice? get credentials?
* [x] Handle proxy/no proxy support for realtime notifications (websockets)

* [x] Allow file upload to include additional "type" property
* [x] Add tab completion for template files?
* [x] Add automatic path resolver in golang to find the template by just the file name
* [x] Use default values for time (i.e. createNewMeasurement --time "0s")
* [ ] Microservice aliases using my-app://health


## PSc8y (Powershell)

* [x] Support common parameters
  * [x] PageSize
  * [x] WithTotalPages
  * [x] Raw
  * [x] Force
  * [ ] Without Accept header (for performance improvements)
* [x] Validate set
* [x] Add types (using cumulocity types) and default columns
  * [x] Get-AlarmCollection.ps1
  * [x] Get-ApplicationCollection.ps1
  * [x] Get-ApplicationReferenceCollection.ps1
  * [x] Get-AuditRecordCollection.ps1
  * [x] Get-BinaryCollection.ps1
  * [x] Get-EventCollection.ps1
  * [x] Get-ExternalIDCollection.ps1
  * [x] Get-UserGroupCollection.ps1
  * [x] Get-MeasurementCollection.ps1
  * [x] Get-OperationCollection.ps1
  * [x] Get-RetentionRuleCollection.ps1
  * [x] Get-RoleReferenceCollectionFromGroup.ps1
  * [x] Get-RoleReferenceCollectionFromUser.ps1
  * [x] Get-SystemOptionCollection.ps1
  * [x] Get-TenantCollection.ps1
  * [x] Get-TenantOptionCollection.ps1
  * [x] Get-TenantStatisticsCollection.ps1
  * [x] Get-UserCollection.ps1
  * [x] Update-AlarmCollection.ps1
* [x] Parameter types
  * [x] File
  * [x] Data
    * [x] hashtable
    * [x] ~~manual json or json shortform~~
  * [x] device expansion (if given an id, don't do a lookup)
  * [x] application
* [x] Support for ShouldProcess prompt
  * [x] Support device name lookup in the message?
* [x] Add tests
  * [x] How to automatic generate Pester tests
* [x] Use session default values (C8Y_TENANT for tenant path/query variables)
* [x] Change all Pester test files to use utf8 with BOM!! This is because Pester does not interpret the encoding of utf8 (no bom) files correctly, thus causing some encoding issues when testing!
Manual commands
* [x] Skip the tests which fail due to lack of access to a management tenant
    * [x] Add auto skip to the autogenerated tests
* [x] Restructure powershell module location in repo
* [x] Figure how to best package the c8y binary file/s with the powershell module
* [x] Adding encoding tests
* [x] Add aliases for all the commands, i.e. Get-ApplicationCollection -> apps, Get-DeviceCollection -> devices
* [x] Add device commands. New-Device, Update-Device, Remove-Device, Get-DeviceCollection (already exists)

* [ ] Client side filtering of results for those that don't support server side filters
  * [ ] Application
    * [ ] Name
* [ ] Remove child devices and child references by wildcard. Only delete matching children

## Packaging

* [x] Package c8y binary with the powershell app
* [x] Publish c8y binaries to github
* [x] Publish powershell module to PSGallery

* Installation problem with Windows 10. Requires PowerShellGet minimum version 2.2.3! Which is not installed by default on Windows 10 PS 5.1
    Maybe add recommendation that powershell 6 (core) should be used, also with an updated PowerShellGet
    https://www.thomasmaurer.ch/2019/03/how-to-install-and-update-powershell-6/

    ```sh
    Install-Module PowerShellGet -Repository PSGallery -Force
    Install-Module PowerShellGet -MinimumVersion 2.2.3
    ```

## Docs

* [x] Write github pages with a tutorial
* [x] General concepts
    * [x] Dates
    * [x] Lookups
* [x] Setup
    * [x] Install binary

* [ ] Add/Remove child devices
* [ ] users (add, skip send email, or static password)
* [ ] managed objects
* [x] aliases
* [x] custom requests
* [x] Extending modules
* [ ] notifications

# Future

### Phase 2

* [x] Implement --all switch for collections to iterate through all results (max results)
* [ ] Make options case insensitive
* [ ] Look over devices where []device type is used (parallel tasks?) Probably need a new template

### Phase 3

* [ ] Cumulocity sessions
  * [ ] Store session credentials securely
  * [ ] Set credentials from a microservice subscription
