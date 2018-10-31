#requires -Modules @{ModuleName="Pester"; ModuleVersion = "4.4.0"} 

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    $ScriptObject
)

Describe "Parse" -Tag "Parse" {
    Context "valid parsing" {
        If ($ScriptObject.Errors.Count -eq 0) {
            It "should parse without errors" {
                $ScriptObject.Errors.Count | Should -Be 0 -Because "we cannot run scripts that do not parse"
            }
        }
        Else {
            ForEach ($err in $ScriptObject.Errors) {
                $ErrorMessage = $err.Message
                $ErrorLine = $err.Line
                It "should not have an error message" {
                    $ErrorMessage | Should -Be $null -Because "an error should not exist on line $ErrorLine"                
                }
            }
        }
    }
}

Describe "Grant" -Tag "Security" {
    Context "Checking for grant statements" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch 
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType().BaseType).Name
                It "substatement should not be a security statement" {
                    $StatementType | Should -Not -Be "SecurityStatement" -Because "permission changes are not allowed in scripts."
                }
            }
        }
    }
}

Describe "delete without where" -Tag "Best practice" {
    Context "Checking for delete statement without where clause" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch 
            ForEach ($Statement in $Statements.Statement) {
                $WhereClause = $Statement.DeleteSpecification.WhereClause
                It "Where clause should not be null" {
                    $WhereClause | Should -Not -Be $null -Because "We don't want to delete the whole table; If we do, use TRUNCATE instead."
                }
            }
        }
    }
}

