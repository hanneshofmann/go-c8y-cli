﻿. $PSScriptRoot/imports.ps1

Describe -Name "Remove-UserFromGroup" {
    BeforeEach {
        $User = New-TestUser
        $Group = Get-GroupByName -Name "business"
        Add-UserToGroup -Group $Group.id -User $User.id

    }

    It "Add a user to a user group" {
        $Response = PSc8y\Remove-UserFromGroup -Group $Group.id -User $User.id
        $LASTEXITCODE | Should -Be 0
    }


    AfterEach {
        Remove-User -Id $User.id

    }
}

