. $PSScriptRoot/imports.ps1 -ErrorAction SilentlyContinue -SkipSessionTest

Describe -Tag "Template" -Name "Invoke-Template" {

    It "executes a jsonnet template from a string" {
        $Template = @"
{
    name: 'testName',
    value: 1 + 2,
}
"@

        $resp = Invoke-Template -Template $Template
        $LASTEXITCODE | Should -BeExactly 0

        $resp | Should -Not -BeNullOrEmpty

        $obj = $resp | ConvertFrom-Json

        $obj.name | Should -BeExactly "testName"
        $obj.value | Should -BeExactly 3
    }

    It "executes a jsonnet template with input values" {
        $Template = @"
{
    name: var('name', 'testName'),
    value: 1 + 2,
}
"@

        $resp = Invoke-Template -Template $Template -TemplateVars "name=myName2"
        $LASTEXITCODE | Should -BeExactly 0

        $resp | Should -Not -BeNullOrEmpty

        $obj = $resp | ConvertFrom-Json

        $obj.name | Should -BeExactly "myName2"
        $obj.value | Should -BeExactly 3
    }

    It "executes a jsonnet template using pipeline input" {
        $Template = @"
{
    type: self.name + '_' + _.Int(100),
    value: 1 + 2,
}
"@
        $InputData = @(
            @{ name = "name" },
            @{ name = "name2" }
        )
        $templateOutput = $InputData | Invoke-Template -Template $Template | ConvertFrom-Json
        $LASTEXITCODE | Should -BeExactly 0

        $templateOutput | Should -Not -BeNullOrEmpty
        $templateOutput | Should -HaveCount 2

        $templateOutput[0].name | Should -BeExactly "name"
        $templateOutput[0].type | Should -Match "^name_\d+$"
        $templateOutput[0].value | Should -BeExactly 3

        $templateOutput[1].name | Should -BeExactly "name2"
        $templateOutput[1].type | Should -Match "^name2_\d+$"
        $templateOutput[1].value | Should -BeExactly 3
    }

    It "throws an error if no template is provided" {
        $output = "{test: 1}" | c8y template execute
        $LASTEXITCODE | Should -Be 100
        $output | Should -BeNullOrEmpty

        $output = c8y template execute
        $LASTEXITCODE | Should -Be 100
        $output | Should -BeNullOrEmpty

        $output = c8y template execute --template "{test: 1}"
        $LASTEXITCODE | Should -Be 0
        $output | Should -Not -BeNullOrEmpty
        
        $output = "{test: 1}" | c8y template execute --template "input.value"
        $LASTEXITCODE | Should -Be 0
        $output | Should -Not -BeNullOrEmpty
    }
}
