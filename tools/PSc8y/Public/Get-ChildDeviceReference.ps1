﻿# Code generated from specification version 1.0.0: DO NOT EDIT
Function Get-ChildDeviceReference {
<#
.SYNOPSIS
Get child device reference

.DESCRIPTION
Get managed object child device reference

.LINK
https://reubenmiller.github.io/go-c8y-cli/docs/cli/c8y/devices_getChild

.EXAMPLE
PS> Get-ChildDeviceReference -Device $Agent.id -Reference $Ref.id

Get an existing child device reference


#>
    [cmdletbinding(PositionalBinding=$true,
                   HelpUri='')]
    [Alias()]
    [OutputType([object])]
    Param(
        # ManagedObject id (required)
        [Parameter(Mandatory = $true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [object[]]
        $Device,

        # Device reference id (required)
        [Parameter(Mandatory = $true)]
        [object[]]
        $Reference
    )
    DynamicParam {
        Get-ClientCommonParameters -Type "Get"
    }

    Begin {

        if ($env:C8Y_DISABLE_INHERITANCE -ne $true) {
            # Inherit preference variables
            Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }

        $c8yargs = New-ClientArgument -Parameters $PSBoundParameters -Command "devices getChild"
        $ClientOptions = Get-ClientOutputOption $PSBoundParameters
        $TypeOptions = @{
            Type = "application/vnd.com.nsn.cumulocity.managedObjectReference+json"
            ItemType = ""
            BoundParameters = $PSBoundParameters
        }
    }

    Process {

        if ($ClientOptions.ConvertToPS) {
            $Device `
            | Group-ClientRequests `
            | c8y devices getChild $c8yargs `
            | ConvertFrom-ClientOutput @TypeOptions
        }
        else {
            $Device `
            | Group-ClientRequests `
            | c8y devices getChild $c8yargs
        }
        
    }

    End {}
}
