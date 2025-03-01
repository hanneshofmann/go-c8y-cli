. $PSScriptRoot/../imports.ps1

Describe -Name "c8y template" {
    Context "Template" {
        It "template should preservce double quotes" {
            $output = c8y template execute --template '{\"email\": \"he ll@ex ample.com\"}'
            $LASTEXITCODE | Should -Be 0
            $body = $output | ConvertFrom-Json
            $body.email | Should -MatchExactly "he ll@ex ample.com"
        }

        It "provides relative time functions" {
            $output = c8y template execute --template "{now: _.Now(), randomNow: _.Now('-' + _.Int(10,60) + 'd'), nowRelative: _.Now('-1h'), nowNano: _.NowNano(), nowNanoRelative: _.NowNano('-10d')}"
            $LASTEXITCODE | Should -Be 0
            $data = $output | ConvertFrom-Json
            Get-Date $data.now | Should -Not -BeNullOrEmpty
            Get-Date $data.randomNow | Should -Not -BeNullOrEmpty
            Get-Date $data.nowRelative | Should -Not -BeNullOrEmpty
            Get-Date $data.nowNano | Should -Not -BeNullOrEmpty
            Get-Date $data.nowNanoRelative | Should -Not -BeNullOrEmpty
        }

        It "provides random number generators" {
            $output = c8y template execute --template "{int: _.Int(), int2: _.Int(-20), int3: _.Int(-50,-59), float: _.Float(), float2: _.Float(10), float3: _.Float(40, 45)}"
            $LASTEXITCODE | Should -Be 0
            $data = $output | ConvertFrom-Json
            $data.int | Should -BeGreaterOrEqual 0
            $data.int | Should -BeLessThan 100

            $data.int2 | Should -BeGreaterOrEqual -20
            $data.int2 | Should -BeLessThan 0

            $data.int3 | Should -BeGreaterOrEqual -59
            $data.int3 | Should -BeLessThan -50

            $data.float | Should -BeGreaterOrEqual 0
            $data.float | Should -BeLessThan 1

            $data.float2 | Should -BeGreaterOrEqual 0
            $data.float2 | Should -BeLessThan 10

            $data.float3 | Should -BeGreaterOrEqual 40
            $data.float3 | Should -BeLessThan 45
        }

        It "combines explicit arguments with data and templates parameters" {
            $inputdata = @{self = "https://example.com"} | ConvertTo-Json -Compress
            $output = $inputdata | c8y operations create `
                --device "12345" `
                --data 'other="1"' `
                --template "{c8y_DownloadConfigFile: {url: input.value['self']}}" `
                --dry `
                --debug `
                --dryFormat json

            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                c8y_DownloadConfigFile = @{
                    url = "https://example.com"
                }
                deviceId = "12345"
                other = 1
            }
        }

        It "uses piped input inside the template" {
            $inputdata = @{deviceId = "1111"} | ConvertTo-Json -Compress
            $output = $inputdata `
            | c8y util show --select "tempID:deviceId" `
            | c8y operations create `
                --template "{deviceId: input.value.tempID}" `
                --dry `
                --dryFormat json

            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                deviceId = "1111"
            }
        }

        It "provides a function to get the path and query from a full url" {
            $output = "https://example.com/test/me?value=test&value=1" `
            | c8y template execute --template "{input:: input.value, name: _.GetURLPath(input.value)}" `
            | ConvertFrom-Json

            $output.name | Should -BeExactly "/test/me?value=test&value=1"
        }

        It "provides a function to get the scheme and hostname from a full url" {
            $output = "https://example.com/test/me?value=test&value=1" `
            | c8y template execute --template "{input:: input.value, name: _.GetURLHost(input.value)}" `
            | ConvertFrom-Json

            $output.name | Should -BeExactly "https://example.com"
        }

        It "provides a function to get an optional value" {
            $inputdata = @{
                nestedProp = @{
                    othervalue = 1
                }
            }
            
            $output = ConvertTo-Json $inputdata -Compress |
                c8y devices update --id 0 --dry --dryFormat json --template "_.Get('nestedProp', input.value, {dummy: 2})"
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                nestedProp = @{
                    othervalue = 1
                }
            }
        }

        It "provides a function to get an optional value and returns a default value if not present" {
            $inputdata = @{
                nestedProp = @{
                    othervalue = 1
                }
            }
            
            $output = ConvertTo-Json $inputdata -Compress |
                c8y devices update --id 0 --dry --dryFormat json --template "_.Get('nestedProp2', input.value, {dummy: 2})"
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                nestedProp2 = @{
                    dummy = 2
                }
            }
        }
    }

    Context "Merge function" {
        It "merges values" -TestCases @(
            @{
                InputValue = @{
                    nestedProp = [ordered]@{
                        inputList = @("existingValue")
                        othervalue = "somevalue"
                    }
                }
                Template = "_.Merge('nestedProp', input.value, {inputList+: ['newValue']})"
                Expect = @{
                    nestedProp = [ordered]@{
                        inputList = @("existingValue", "newValue")
                        othervalue = "somevalue"
                    }
                }
            },
            @{
                InputValue = @{}
                Template = "_.Merge('nestedProp', input.value, {inputList+: ['newValue']})"
                Expect = @{
                    nestedProp = @{
                        inputList = @("newValue")
                    }
                }
            },
            @{
                Because = "Merge array when array is immediate key"
                InputValue = @{c8y_SupportedOperations = @()}
                Template = "_.Merge('c8y_SupportedOperations', input.value, ['newValue'])"
                Expect = @{c8y_SupportedOperations = @("newValue")}
            },
            @{
                Because = "Merge array when existing value does not exist"
                InputValue = @{}
                Template = "_.Merge('c8y_SupportedOperations', input.value, ['newValue'])"
                Expect = @{c8y_SupportedOperations = @("newValue")}
            },
            @{
                Because = "Removes a nested fragment"
                InputValue = @{c8y_Model=@{serialNumber="123456789"; otherValue="example"}}
                Template = "_.Merge('c8y_Model', input.value, {otherValue:: null})"
                Expect = @{c8y_Model=@{serialNumber="123456789"}}
            }
        ) {
            Param(
                [object] $InputValue,
                [object] $Template,
                [object] $Expect,
                [string] $Because
            )            
            $output = ConvertTo-Json $InputValue -Compress |
                c8y devices update --id 0 --dry --dryFormat json --template $Template
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject $Expect -Because:$Because
        }
    }

    Context "Order of processing" {
        It "explicit arguments override values from data and templates" -TestCases @(
            @{deviceId = "9999"},
            "9999"
        )  {
            Param([string]$option)

            $inputdata = $option | ConvertTo-Json -Compress
            $output = $inputdata | c8y operations create `
                --device "1111" `
                --data 'deviceId=\"2222\"' `
                --template "{deviceId: '3333'}" `
                --dry `
                --dryFormat json
    
            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                deviceId = "1111"
            }
        }

        It "explicit arguments override values from data and templates" {
            $inputdata = "9999" | ConvertTo-Json -Compress
            $output = $inputdata | c8y operations create `
                --device "1111" `
                --template "{deviceId: '3333'}" `
                --dry `
                --dryFormat json
    
            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                deviceId = "1111"
            }
        }
    
        It "piped arguments override data values" {
            $inputdata = @{deviceId = "9999"} | ConvertTo-Json -Compress
            $output = $inputdata | c8y operations create `
                --data 'deviceId=\"2222\"' `
                --template "{deviceId: '3333'}" `
                --dry `
                --dryFormat json
    
            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                deviceId = "9999"
            }
        }
    
    
        It "piped arguments overide template variables" {
            $inputdata = @{deviceId = "9999"} | ConvertTo-Json -Compress
            $output = $inputdata | c8y operations create `
                --template "{deviceId: '3333'}" `
                --dry `
                --dryFormat json
    
            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                deviceId = "9999"
            }
        }
    
        It "provides a generic way to remap pipes values to property that will not be picked up" {
            $inputdata = @{deviceId = "1111"} | ConvertTo-Json -Compress
            $output = $inputdata `
            | c8y util show --select "tempID:deviceId" `
            | c8y operations create `
                --template "{deviceId: '3333'}" `
                --dry `
                --dryFormat json
    
            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json
            $request.body | Should -MatchObject @{
                deviceId = "3333"
            }
        }

        It "Overrides a piped value with an explicit argument" {
            $output = "name01" | c8y applications create $commonArgs --name "mynewapp" --template "{key: self.name + '-key'}" --type "MICROSERVICE" --dry --dryFormat json
            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json

            $request.path | Should -BeExactly "/application/applications"
            $request.body | Should -MatchObject @{
                key = "mynewapp-key"
                name = "mynewapp"
                type = "MICROSERVICE"
            }
        }

        It "Provides piped strings to template" {
            $output = "11", "12" | c8y devices create --template "{ jobIndex: input.index, jobValue: input.value }" --dry --dryFormat json
            $LASTEXITCODE | Should -BeExactly 0
            $requests = $output | ConvertFrom-Json
            $requests | Should -HaveCount 2

            $requests[0] | Should -MatchObject @{method = "POST"; path = "/inventory/managedObjects"} -Property method, path
            $requests[1] | Should -MatchObject @{method = "POST"; path = "/inventory/managedObjects"} -Property method, path
            $requests[0].body | Should -MatchObject @{c8y_IsDevice=@{}; jobIndex=1; jobValue="11"; name="11"}
            $requests[1].body | Should -MatchObject @{c8y_IsDevice=@{}; jobIndex=2; jobValue="12"; name="12"}

            $requests[0].body.name | Should -BeOfType [string]
            $requests[0].body.jobIndex | Should -BeOfType [long]
            $requests[0].body.jobValue | Should -BeOfType [string]
        }

        It "Accepts json complex value (override using argument)" {
            $pipedInput = ConvertTo-Json -Compress -InputObject @{
                requiredRoles = @(
                    "EXAMPLE_ROLE_1",
                    "EXAMPLE_ROLE_2"
                )
            }
            $output = $pipedInput | c8y applications create --dry --dryFormat json --name "mynewapp" --template "input.value + { key: self.name + '-key'}" --type MICROSERVICE
            $LASTEXITCODE | Should -Be 0
            $request = $output | ConvertFrom-Json

            $request.path | Should -BeExactly "/application/applications"
            $request.body | Should -MatchObject @{
                key = "mynewapp-key"
                name = "mynewapp"
                requiredRoles = @(
                    "EXAMPLE_ROLE_1",
                    "EXAMPLE_ROLE_2"
                )
                type = "MICROSERVICE"
            }
        }
    }
}
