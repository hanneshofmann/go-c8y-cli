. $PSScriptRoot/imports.ps1

Describe -Tag "Session" -Name "Create-Completions" {

    BeforeEach {
        $originalSetting = $env:C8Y_SESSION
        $env:C8Y_SESSION = ""
    }

    It "Create bash completions" {
        $output = c8y completion bash
        $LASTEXITCODE | Should -Be 0
        $output | Should -Not -BeNullOrEmpty
    }

    It "Create zsh completions" {
        $output = c8y completion zsh
        $LASTEXITCODE | Should -Be 0
        $output | Should -Not -BeNullOrEmpty
    }

    It "Create powershell completions" {
        $output = c8y completion powershell
        $LASTEXITCODE | Should -Be 0
        $output | Should -Not -BeNullOrEmpty
    }

    AfterEach {
        $env:C8Y_SESSION = $originalSetting
    }
}
