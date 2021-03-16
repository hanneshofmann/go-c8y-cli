﻿Function New-TestDevice {
<# 
.SYNOPSIS
Create a new test device representation in Cumulocity

.DESCRIPTION
Create a new test device with a randomized name. Useful when performing mockups or prototyping.

The agent will have both the `c8y_IsDevice` fragments set.

.EXAMPLE
New-TestDevice

Create a test device

.EXAMPLE
1..10 | Foreach-Object { New-TestDevice -Force }

Create 10 test devices all with unique names

.EXAMPLE
1..10 | Foreach-Object { New-TestDevice -AsAgent -Force }

Create 10 test devices (with agent functionality) all with unique names

#>
    [cmdletbinding()]
    Param(
        # Device name prefix which is added before the randomized string
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string] $Name
    )
    DynamicParam {
        Get-ClientCommonParameters -Type "Create", "TemplateVars"
    }

    Begin {
        $c8yargs = New-ClientArgument -Parameters $PSBoundParameters -Command "devices create"
        $ClientOptions = Get-ClientOutputOption $PSBoundParameters
        $TypeOptions = @{
            Type = "application/vnd.com.nsn.cumulocity.customDevice+json"
            ItemType = ""
            BoundParameters = $PSBoundParameters
        }
        [void] $c8yargs.AddRange(@(
            "--template",
            "test.device.jsonnet"
        ))
    }

    Process {
        if ($Name) {
            if ($ClientOptions.ConvertToPS) {
                $Name `
                | Group-ClientRequests `
                | c8y devices create $c8yargs `
                | ConvertFrom-ClientOutput @TypeOptions
            }
            else {
                $Name `
                | Group-ClientRequests `
                | c8y devices create $c8yargs
            }
        } else {
            if ($ClientOptions.ConvertToPS) {
                c8y devices create $c8yargs `
                | ConvertFrom-ClientOutput @TypeOptions
            }
            else {
                c8y devices create $c8yargs
            }
        }
    }
}
