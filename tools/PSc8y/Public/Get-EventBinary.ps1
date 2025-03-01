﻿# Code generated from specification version 1.0.0: DO NOT EDIT
Function Get-EventBinary {
<#
.SYNOPSIS
Get event binary

.DESCRIPTION
Get the binary associated with an event

.LINK
https://reubenmiller.github.io/go-c8y-cli/docs/cli/c8y/events_downloadBinary

.EXAMPLE
PS> Get-EventBinary -Id $Event.id -OutputFileRaw ./eventbinary.txt

Download a binary related to an event


#>
    [cmdletbinding(PositionalBinding=$true,
                   HelpUri='')]
    [Alias()]
    [OutputType([object])]
    Param(
        # Event id (required)
        [Parameter(Mandatory = $true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [object[]]
        $Id
    )
    DynamicParam {
        Get-ClientCommonParameters -Type "Get"
    }

    Begin {

        if ($env:C8Y_DISABLE_INHERITANCE -ne $true) {
            # Inherit preference variables
            Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }

        $c8yargs = New-ClientArgument -Parameters $PSBoundParameters -Command "events downloadBinary"
        $ClientOptions = Get-ClientOutputOption $PSBoundParameters
        $TypeOptions = @{
            Type = "*/*"
            ItemType = ""
            BoundParameters = $PSBoundParameters
        }
    }

    Process {

        if ($ClientOptions.ConvertToPS) {
            $Id `
            | Group-ClientRequests `
            | c8y events downloadBinary $c8yargs `
            | ConvertFrom-ClientOutput @TypeOptions
        }
        else {
            $Id `
            | Group-ClientRequests `
            | c8y events downloadBinary $c8yargs
        }
        
    }

    End {}
}
