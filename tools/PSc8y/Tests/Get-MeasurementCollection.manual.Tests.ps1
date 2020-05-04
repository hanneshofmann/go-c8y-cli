﻿. $PSScriptRoot/imports.ps1

Describe -Name "Get-MeasurementCollection" {
    BeforeEach {
        $Device = PSc8y\New-TestDevice;
        $Measurement = New-TestMeasurement `
            -Device $Device.id `
            -ValueFragmentType "c8y_cargo" `
            -ValueFragmentSeries "sensor1" `
            -Value 1.234 `
            -Unit "kg";

    }

    It "Get a list of measurements in csv format" {
        $Response = PSc8y\Get-MeasurementCollection -Device $Device.id -Csv
        $Response | Should -Not -BeNullOrEmpty
        $Response | Should -BeOfType string
        $Rows = $Response | ConvertFrom-Csv -Delimiter ","
        $Rows | Should -HaveCount 1
    }

    It "Get a list of measurements in Excel format" {
        $Response = PSc8y\Get-MeasurementCollection -Device $Device.id -Excel
        $Response | Should -Not -BeNullOrEmpty

        # TODO: How to test if it is a valid excel data
    }

    It "Get a list of measurements using imperial units" {
        $Response = PSc8y\Get-MeasurementCollection -Device $Device.id -Unit "imperial"
        $Response | Should -Not -BeNullOrEmpty
        $Response | Should -HaveCount 1
        $Response.c8y_cargo.sensor1.unit | Should -BeExactly "lb"
    }

    AfterEach {
        PSc8y\Remove-ManagedObject -Id $Device.id

    }
}
