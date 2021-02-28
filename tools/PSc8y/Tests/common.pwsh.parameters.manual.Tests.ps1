. $PSScriptRoot/imports.ps1

Describe -Name "Common parameters" {

    BeforeAll {
        $ids = New-Object System.Collections.ArrayList
        $names = New-Object System.Collections.ArrayList
    }

    Context "NoAccept" {   
        It "NoAccept should not return an object when using POST" {
            $options = @{
                Name = New-RandomString -Prefix "testdevice"
                NoAccept = $true
            }
            [void]$names.Add($options.Name)
            $output = PSc8y\New-Device @options
            $LASTEXITCODE | Should -Be 0
            $output | Should -BeNullOrEmpty
        }
    }

    Context "Flatten" {   
        It "Flattens the output json" {
            $options = @{
                Flatten = $true
            }
            $output = PSc8y\Get-ApplicationCollection @options
            $LASTEXITCODE | Should -Be 0
            $output | Should -Not -BeNullOrEmpty
            $output.id | Should -Not -BeNullOrEmpty
            $output."owner.tenant.id" | Should -Not -BeNullOrEmpty
        }
    }

    AfterAll {
        $ids | Remove-ManagedObject
        $names | ForEach-Object {
            Get-Device -Id $_ | Remove-ManagedObject
        } 
    }
}
