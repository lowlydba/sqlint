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

Describe "Security" -Tag "Security" {
    Context "Checking for security statements" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType().BaseType).Name
                It "Statement should not be a security statement." {
                    $StatementType | Should -Not -Be "SecurityStatement" -Because "security statement should not exist on line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }
}

Describe "Best Practices" -Tag "BestPractice" {
    Context "Checking DELETE has WHERE" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                If ($StatementType -eq "DeleteStatement") {
                    $Skip = $false
                    $WhereClause = $Statement.DeleteSpecification.WhereClause
                }
                Else {
                    $Skip = $true
                }
                It "Statement with DELETE has a WHERE." -Skip:$Skip {
                    $WhereClause | Should -Not -Be $null -Because "a WHERE clause should exist on the statement on line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }
    Context "sp prefix for stored procedures" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements) {
                $StatementType = ($Statement.GetType()).Name
                If ($StatementType -eq "CreateProcedureStatement") {
                    $Skip = $false
                    $StoredProcName = $Statement.ProcedureReference.Name.BaseIdentifier.Value
                }
                Else {
                    $Skip = $true
                }
                It "Stored procedure with sp_ prefix" -Skip:$Skip {
                    $StoredProcName | Should -Not -BeLike "sp_*" -Because "that is bad naming.  $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }
}


    #Context All objects should include schema name
    #Context Select * should not be used
    #Context Update without WHERE should not exist
    #TOP without ORDER BY
    # TOP 100 %
    # == NULL or <> NULL
    # Use of @@IDENTITY
    # NVARCHAR / VARCHAR without length