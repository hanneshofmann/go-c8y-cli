﻿# Code generated from specification version 1.0.0: DO NOT EDIT
Function Update-RetentionRule {
<#
.SYNOPSIS
Update retention rule

.EXAMPLE
PS> Update-RetentionRule -Id $RetentionRule.id -DataType MEASUREMENT -FragmentType "custom_FragmentType"
Update a retention rule

.EXAMPLE
PS> Get-RetentionRule -Id $RetentionRule.id | Update-RetentionRule -DataType MEASUREMENT -FragmentType "custom_FragmentType"
Update a retention rule (using pipeline)


#>
    [cmdletbinding(SupportsShouldProcess = $true,
                   PositionalBinding=$true,
                   HelpUri='',
                   ConfirmImpact = 'High')]
    [Alias()]
    [OutputType([object])]
    Param(
        # Retention rule id (required)
        [Parameter(Mandatory = $true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $Id,

        # RetentionRule will be applied to this type of documents, possible values [ALARM, AUDIT, EVENT, MEASUREMENT, OPERATION, *]. (required)
        [Parameter(Mandatory = $true)]
        [ValidateSet('ALARM','AUDIT','EVENT','MEASUREMENT','OPERATION','*')]
        [string]
        $DataType,

        # RetentionRule will be applied to documents with fragmentType.
        [Parameter()]
        [string]
        $FragmentType,

        # RetentionRule will be applied to documents with type.
        [Parameter()]
        [string]
        $Type,

        # RetentionRule will be applied to documents with source.
        [Parameter()]
        [string]
        $Source,

        # Maximum age of document in days.
        [Parameter()]
        [long]
        $MaximumAge,

        # Whether the rule is editable. Can be updated only by management tenant.
        [Parameter()]
        [switch]
        $Editable,

        # Data
        [Parameter()]
        [object]
        $Data,

        # Include raw response including pagination information
        [Parameter()]
        [switch]
        $Raw,

        # Outputfile
        [Parameter()]
        [string]
        $OutputFile,

        # NoProxy
        [Parameter()]
        [switch]
        $NoProxy,

        # Session path
        [Parameter()]
        [string]
        $Session,

        # TimeoutSec timeout in seconds before a request will be aborted
        [Parameter()]
        [double]
        $TimeoutSec,

        # Don't prompt for confirmation
        [Parameter()]
        [switch]
        $Force
    )

    Begin {
        $Parameters = @{}
        if ($PSBoundParameters.ContainsKey("DataType")) {
            $Parameters["dataType"] = $DataType
        }
        if ($PSBoundParameters.ContainsKey("FragmentType")) {
            $Parameters["fragmentType"] = $FragmentType
        }
        if ($PSBoundParameters.ContainsKey("Type")) {
            $Parameters["type"] = $Type
        }
        if ($PSBoundParameters.ContainsKey("Source")) {
            $Parameters["source"] = $Source
        }
        if ($PSBoundParameters.ContainsKey("MaximumAge")) {
            $Parameters["maximumAge"] = $MaximumAge
        }
        if ($PSBoundParameters.ContainsKey("Editable")) {
            $Parameters["editable"] = $Editable
        }
        if ($PSBoundParameters.ContainsKey("Data")) {
            $Parameters["data"] = ConvertTo-JsonArgument $Data
        }
        if ($PSBoundParameters.ContainsKey("OutputFile")) {
            $Parameters["outputFile"] = $OutputFile
        }
        if ($PSBoundParameters.ContainsKey("NoProxy")) {
            $Parameters["noProxy"] = $NoProxy
        }
        if ($PSBoundParameters.ContainsKey("Session")) {
            $Parameters["session"] = $Session
        }
        if ($PSBoundParameters.ContainsKey("TimeoutSec")) {
            $Parameters["timeout"] = $TimeoutSec * 1000
        }

    }

    Process {
        foreach ($item in (PSc8y\Expand-Id $Id)) {
            if ($item) {
                $Parameters["id"] = if ($item.id) { $item.id } else { $item }
            }

            if (!$Force -and
                !$WhatIfPreference -and
                !$PSCmdlet.ShouldProcess(
                    (PSc8y\Get-C8ySessionProperty -Name "tenant"),
                    (Format-ConfirmationMessage -Name $PSCmdlet.MyInvocation.InvocationName -InputObject $item)
                )) {
                continue
            }

            Invoke-ClientCommand `
                -Noun "retentionRules" `
                -Verb "update" `
                -Parameters $Parameters `
                -Type "application/vnd.com.nsn.cumulocity.retentionRule+json" `
                -ItemType "" `
                -ResultProperty "" `
                -Raw:$Raw
        }
    }

    End {}
}
