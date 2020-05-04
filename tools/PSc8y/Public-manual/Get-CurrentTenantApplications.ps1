﻿Function Get-CurrentTenantApplications {
<#
.SYNOPSIS
Get the list of applications that are subscribed on the current tenant

.EXAMPLE
Get-CurrentTenantApplications

Get a list of applications in the current tenant

.LINK
Get-CurrentApplication

#>
    [cmdletbinding()]
    Param()

    $data = Get-CurrentTenant
    $data.applications.references.application `
        | Select-Object `
        | Add-PowershellType "application/vnd.com.nsn.cumulocity.application+json"
}
