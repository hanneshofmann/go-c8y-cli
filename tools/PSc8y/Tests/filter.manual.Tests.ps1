. $PSScriptRoot/imports.ps1

Describe -Name "c8y filter common parameter" {
    BeforeAll {
        $TypeSuffix = New-RandomString
        $Template = "{ type: 'c8yci_$TypeSuffix', ci_filterTest: {} }"
        $ids = New-Object System.Collections.ArrayList
        $Device1 = New-TestDevice -Template $Template
        $Device2 = New-TestDevice -Template $Template
        $null = $ids.AddRange(@($Device1.id, $Device2.id))
    }

    It "filters by wildcards" {
        $output = c8y devices list --fragmentType "ci_filterTest" --filter "type like *$TypeSuffix*" --orderBy "_id asc" | ConvertFrom-Json
        $LASTEXITCODE | Should -Be 0
        $output | Should -ContainInCollection $Device1, $Device2

        $output = c8y devices list --fragmentType "ci_filterTest" --filter "type -like *$TypeSuffix*" --orderBy "_id asc" | ConvertFrom-Json
        $LASTEXITCODE | Should -Be 0
        $output | Should -ContainInCollection $Device1, $Device2
    }

    It "filters by regex" {
        $output = c8y devices list --fragmentType "ci_filterTest" --filter "type match c8yci_.+[a-z0-9]*" --orderBy "_id asc" | ConvertFrom-Json
        $LASTEXITCODE | Should -Be 0
        $output | Should -ContainInCollection $Device1, $Device2

        $output = c8y devices list --fragmentType "ci_filterTest" --filter "type -match c8yci_.+[a-z0-9]*" --orderBy "_id asc" | ConvertFrom-Json
        $LASTEXITCODE | Should -Be 0
        $output | Should -ContainInCollection $Device1, $Device2
    }
    
    AfterAll {
        $ids | Remove-ManagedObject
    }
}
