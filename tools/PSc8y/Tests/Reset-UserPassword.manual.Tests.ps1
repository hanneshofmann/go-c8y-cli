. $PSScriptRoot/imports.ps1

Describe -Name "Reset-UserPassword" {
    BeforeEach {
        $User = PSc8y\New-TestUser
    }

    It "Resets a user's password by sending a reset email to the user" {
        $output = PSc8y\Reset-UserPassword -Id $User.id -Dry -DryFormat json
        $LASTEXITCODE | Should -Be 0

        $request = $output | Out-String | ConvertFrom-Json
        $request.body | Should -MatchObject @{
            sendPasswordResetEmail = $true
        }
    }

    It "Resets a user's password by setting a manual password" {
        $pass = New-RandomPassword
        $output = PSc8y\Reset-UserPassword -Id $User.id -NewPassword $pass -Dry -DryFormat json
        $LASTEXITCODE | Should -Be 0

        $request = $output | Out-String | ConvertFrom-Json
        $request.body | Should -MatchObject @{
            password = $pass
            sendPasswordResetEmail = $false
        }
    }

    AfterEach {
        PSc8y\Remove-User -Id $User.id
    }
}
