﻿. $PSScriptRoot/imports.ps1

Describe -Name "Watch-Operation" {
    BeforeEach {
        $Device = New-TestAgent
        Start-Sleep -Seconds 5

        # Create background task which creates operations
        $importpath = (Resolve-Path "$PSScriptRoot/imports.ps1").ProviderPath
        $JobArgs = @(
            $importpath,
            $env:C8Y_SESSION,
            $Device.id
        )
        $Job = Start-Job -Name "watch-operation-data" -Debug -ArgumentList $JobArgs -ScriptBlock {
            $env:C8Y_SESSION = $args[1]
            . $args[0]
            Start-Sleep -Seconds 2
            $DeviceID = $args[2]
            @(1..60) | ForEach-Object {
                New-TestOperation -Device $DeviceID -Force
                Start-Sleep -Milliseconds 1000
            }
        }
    }

    It "Watch operations for a time period" {
        $StartTime = Get-Date
        [array] $Response = PSc8y\Watch-Operation -Device $Device.id -Duration "60s" | ForEach-Object {
            $_ | Add-Member -MemberType NoteProperty -Name "PSc8yTimestamp" -Value (Get-Date) -PassThru
        }

        $LASTEXITCODE | Should -Be 0
        $Response.Count | Should -BeGreaterOrEqual 2
        $Duration = (Get-Date) - $StartTime
        $Duration.TotalSeconds | Should -BeGreaterOrEqual 10

        ($Response[-1].PSc8yTimestamp - $Response[0].PSc8yTimestamp).TotalSeconds |
            Should -BeGreaterThan 2 -Because "Values should be sent to pipeline as soon as they arrive"
    }

    It "Watch operations for a number of operations" {
        $Response = PSc8y\Watch-Operation -Device $Device.id -Count 2
        $LASTEXITCODE | Should -Be 0
        $Response | Should -HaveCount 2
    }

    It "Watch operations for all devices and stop after receiving x messages" {
        $Response = PSc8y\Watch-Operation -Count 2
        $LASTEXITCODE | Should -Be 0
        $Response | Should -HaveCount 2
    }

    AfterEach {
        Stop-Job -Job $Job
        Remove-Job -Id $Job.Id
        PSc8y\Remove-ManagedObject -Id $Device.id

    }
}
