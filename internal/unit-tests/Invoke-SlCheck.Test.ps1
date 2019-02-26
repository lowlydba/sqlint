#requires -Modules @{ModuleName="Pester"; ModuleVersion = "4.4.0"}

Describe "Parse" -Tag "Parse" {
    Context "valid parsing" {
        $Script = Join-Path $TestDrive "test.sql"
        Set-Content $Script "SELECT 1"
        $ScriptObject = Invoke-SlCheck -File $Script -Quiet
            It "should parse without errors" {
                $ScriptObject.Errors.Count | Should -Be 0 -Because "we cannot run scripts that do not parse"
            }

        # Else {
        #     ForEach ($err in $ScriptObject.Errors) {
        #         $ErrorMessage = $err.Message
        #         $ErrorLine = $err.Line
        #         It "should not have an error message" {
        #             $ErrorMessage | Should -Be $null -Because "an error should not exist on line $ErrorLine"
        #         }
        #     }
        # }
    }
}