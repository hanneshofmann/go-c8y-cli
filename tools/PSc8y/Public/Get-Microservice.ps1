﻿# Code generated from specification version 1.0.0: DO NOT EDIT
Function Get-Microservice {
<#
.SYNOPSIS
Get microservice

.DESCRIPTION
Get an existing microservice by id or name

.EXAMPLE
PS> Get-Microservice -Id $App.id

Get an microservice by id

.EXAMPLE
PS> Get-Microservice -Id $App.name

Get an microservice by name


#>
    [cmdletbinding(SupportsShouldProcess = $true,
                   PositionalBinding=$true,
                   HelpUri='',
                   ConfirmImpact = 'None')]
    [Alias()]
    [OutputType([object])]
    Param(
        # Microservice id (required)
        [Parameter(Mandatory = $true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [object[]]
        $Id
    )
    DynamicParam {
        Get-ClientCommonParameters -Type "Get" -BoundParameters $PSBoundParameters
    }

    Begin {
        $Parameters = @{}

        if ($env:C8Y_DISABLE_INHERITANCE -ne $true) {
            # Inherit preference variables
            Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }

        $c8yargs = New-ClientArgument -Parameters $PSBoundParameters -Command "microservices get"
        $ClientOptions = Get-ClientOutputOption $PSBoundParameters
        $TypeOptions = @{
            Type = "application/vnd.com.nsn.cumulocity.application+json"
            ItemType = ""
            BoundParameters = $PSBoundParameters
        }
    }

    Process {

        if ($ClientOptions.ConvertToPS) {
            $Id `
            | c8y microservices get $c8yargs `
            | ConvertFrom-ClientOutput @TypeOptions
        }
        else {
            $Id `
            | c8y microservices get $c8yargs
        }
        
    }

    End {}
}
