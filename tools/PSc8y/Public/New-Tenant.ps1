﻿# Code generated from specification version 1.0.0: DO NOT EDIT
Function New-Tenant {
<#
.SYNOPSIS
New tenant

.DESCRIPTION
New tenant

.EXAMPLE
PS> New-Tenant -Company "mycompany" -Domain "mycompany" -AdminName "admin" -Password "mys3curep9d8"

Create a new tenant (from the management tenant)


#>
    [cmdletbinding(SupportsShouldProcess = $true,
                   PositionalBinding=$true,
                   HelpUri='',
                   ConfirmImpact = 'High')]
    [Alias()]
    [OutputType([object])]
    Param(
        # Company name. Maximum 256 characters (required)
        [Parameter(Mandatory = $true)]
        [string]
        $Company,

        # Domain name to be used for the tenant. Maximum 256 characters (required)
        [Parameter(Mandatory = $true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [object[]]
        $Domain,

        # Username of the tenant administrator
        [Parameter()]
        [string]
        $AdminName,

        # Password of the tenant administrator
        [Parameter()]
        [string]
        $AdminPass,

        # A contact name, for example an administrator, of the tenant
        [Parameter()]
        [string]
        $ContactName,

        # An international contact phone number
        [Parameter()]
        [string]
        $ContactPhone,

        # The tenant ID. This should be left bank unless you know what you are doing. Will be auto-generated if not present.
        [Parameter()]
        [string]
        $TenantId
    )
    DynamicParam {
        Get-ClientCommonParameters -Type "Create", "Template" -BoundParameters $PSBoundParameters
    }

    Begin {
        $Parameters = @{}
        if ($PSBoundParameters.ContainsKey("Company")) {
            $Parameters["company"] = $Company
        }
        if ($PSBoundParameters.ContainsKey("AdminName")) {
            $Parameters["adminName"] = $AdminName
        }
        if ($PSBoundParameters.ContainsKey("AdminPass")) {
            $Parameters["adminPass"] = $AdminPass
        }
        if ($PSBoundParameters.ContainsKey("ContactName")) {
            $Parameters["contactName"] = $ContactName
        }
        if ($PSBoundParameters.ContainsKey("ContactPhone")) {
            $Parameters["contactPhone"] = $ContactPhone
        }
        if ($PSBoundParameters.ContainsKey("TenantId")) {
            $Parameters["tenantId"] = $TenantId
        }

        if ($env:C8Y_DISABLE_INHERITANCE -ne $true) {
            # Inherit preference variables
            Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }

        $c8yargs = New-ClientArgument -Parameters $PSBoundParameters -Command "tenants create"
        $ClientOptions = Get-ClientOutputOption $PSBoundParameters
        $TypeOptions = @{
            Type = "application/vnd.com.nsn.cumulocity.tenant+json"
            ItemType = ""
            BoundParameters = $PSBoundParameters
        }
    }

    Process {
        $Force = if ($PSBoundParameters.ContainsKey("Force")) { $PSBoundParameters["Force"] } else { $False }
        if (!$Force -and !$WhatIfPreference) {
            $items = (PSc8y\Expand-Id $Domain)

            $shouldContinue = $PSCmdlet.ShouldProcess(
                (PSc8y\Get-C8ySessionProperty -Name "tenant"),
                (Format-ConfirmationMessage -Name $PSCmdlet.MyInvocation.InvocationName -InputObject $items)
            )
            if (!$shouldContinue) {
                return
            }
        }

        if ($ClientOptions.ConvertToPS) {
            $Domain `
            | c8y tenants create $c8yargs `
            | ConvertFrom-ClientOutput @TypeOptions
        }
        else {
            $Domain `
            | c8y tenants create $c8yargs
        }
        
    }

    End {}
}
