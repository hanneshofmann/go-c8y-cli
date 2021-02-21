﻿# Code generated from specification version 1.0.0: DO NOT EDIT
Function Update-Agent {
<#
.SYNOPSIS
Update agent

.DESCRIPTION
Update properties of an agent

.EXAMPLE
PS> Update-Agent -Id $agent.id -NewName "MyNewName"

Update agent by id

.EXAMPLE
PS> Update-Agent -Id $agent.name -NewName "MyNewName"

Update agent by name

.EXAMPLE
PS> Update-Agent -Id $agent.name -Data @{ "myValue" = @{ value1 = $true } }

Update agent custom properties


#>
    [cmdletbinding(SupportsShouldProcess = $true,
                   PositionalBinding=$true,
                   HelpUri='',
                   ConfirmImpact = 'High')]
    [Alias()]
    [OutputType([object])]
    Param(
        # Agent ID (required)
        [Parameter(Mandatory = $true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [object[]]
        $Id,

        # Agent name
        [Parameter()]
        [string]
        $NewName
    )
    DynamicParam {
        Get-ClientCommonParameters -Type "Update", "Template" -BoundParameters $PSBoundParameters
    }

    Begin {
        $Parameters = @{}
        if ($PSBoundParameters.ContainsKey("NewName")) {
            $Parameters["newName"] = $NewName
        }

        if ($env:C8Y_DISABLE_INHERITANCE -ne $true) {
            # Inherit preference variables
            Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }

        $c8yargs = New-ClientArgument -Parameters $PSBoundParameters -Command "agents update"
        $ClientOptions = Get-ClientOutputOption $PSBoundParameters
        $TypeOptions = @{
            Type = "application/vnd.com.nsn.cumulocity.customAgent+json"
            ItemType = ""
            BoundParameters = $PSBoundParameters
        }
    }

    Process {
        $Force = if ($PSBoundParameters.ContainsKey("Force")) { $PSBoundParameters["Force"] } else { $False }
        if (!$Force -and !$WhatIfPreference) {
            $items = (PSc8y\Expand-Id $Id)

            $shouldContinue = $PSCmdlet.ShouldProcess(
                (PSc8y\Get-C8ySessionProperty -Name "tenant"),
                (Format-ConfirmationMessage -Name $PSCmdlet.MyInvocation.InvocationName -InputObject $items)
            )
            if (!$shouldContinue) {
                return
            }
        }

        if ($ClientOptions.ConvertToPS) {
            $Id `
            | c8y agents update $c8yargs `
            | ConvertFrom-ClientOutput @TypeOptions
        }
        else {
            $Id `
            | c8y agents update $c8yargs
        }
        
    }

    End {}
}
