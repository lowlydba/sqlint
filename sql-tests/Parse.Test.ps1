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
    Context "Checking UPDATE has WHERE" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                If ($StatementType -eq "UpdateStatement") {
                    $Skip = $false
                    $WhereClause = $Statement.UpdateSpecification.WhereClause
                }
                Else {
                    $Skip = $true
                }
                It "Statement with UPDATE has a WHERE." -Skip:$Skip {
                    $WhereClause | Should -Not -Be $null -Because "a WHERE clause should exist on the statement on line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }
    Context "Checking SELECT with Star" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                If ($StatementType -eq "SelectStatement") {
                    $Skip = $false
                    $SelectStar = $Statement.QueryExpression.SelectElements[0].GetType().Name
                }
                Else {
                    $Skip = $true
                }
                It "Statement with SELECT (*)" -Skip:$Skip {
                    $SelectStar | Should -Not -Be "SelectStarExpression" -Because "a SELECT statement should have the columns specified on line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }
    Context "Checking SELECT TOP without ORDERBY" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                $SelectTOP = $Statement.QueryExpression.TopRowFilter
                If ($StatementType -eq "SelectStatement" -and $SelectTOP -ne $null) {
                    $Skip = $false
                    $SelectOrderBy = $Statement.QueryExpression.OrderByClause
                }
                Else {
                    $Skip = $true
                }
                It "Statement TOP without ORDERBY" -Skip:$Skip {
                    $SelectOrderBy | Should -Not -Be $null -Because "a SELECT TOP statement should have ORDERBY Clause specified on line $($Statement.StartLine), column $($Statement.StartColumn)"

                }
            }
        }
    }
    Context "Checking SELECT TOP 100 PERCENT" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                $SelectTOPPercent = $Statement.QueryExpression.TopRowFilter
                If ($StatementType -eq "SelectStatement" -and $SelectTOPPercent.percent -eq $true) {
                    $Skip = $false
                    $SelectTOP100PERCENT = $SelectTOPPercent.Expression.Value
                }
                Else {
                    $Skip = $true
                }
                It "Statement TOP 100 PERCENT" -Skip:$Skip {
                    $SelectTOP100PERCENT | Should -Not -Be "100" -Because "a SELECT TOP 100 PERCENT statement has no effect specified on line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }
    Context "Checking SELECT with Identity" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                If ($StatementType -eq "SelectStatement") {
                    ForEach($Element in $Statement.QueryExpression.SelectElements)
                    {
                        if($Element.Expression.Name -like "@@*identity")
                        {
                            $SelectIdentity = $Element.Expression.Name
                            $Skip = $false
                        }
                    }
                }
                Else {
                    $Skip = $true
                }
                It "Statement with SELECT Identity" -Skip:$Skip {
                    $SelectIdentity | Should -Not -Be '@@Identity' -Because "a SELECT statement should avoid identity specified on line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }

    Context "Checking NVARCHAR / VARCHAR without length" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {
            $Statements = Get-Statement -Batch $Batch
            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                If ($StatementType -eq "DeclareVariableElement" -and $Statement.DataType.SqlDataTypeOption.ToString() -like "*VarChar") {
                    $Skip = $false
                    $ElementLength = $Statement.DataType.Parameters[0]
                }
                Else {
                    $Skip = $true
                }
                It "Variable NVARCHAR / VARCHAR without length" -Skip:$Skip {
                    $ElementLength | Should -Not -Be $NULL -Because "a length for NVARCHAR / VARCHAR should be specified on line $($Statement.StartLine), column $($Statement.StartColumn)"
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
                    $StoredProcName | Should -Not -BeLike "sp_*" -Because "that is bad naming. Line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }

    Context "ISNULL condition check" {
        ForEach ($Batch in $ScriptObject.Fragment.Batches) {

            $Statements = Get-Statement -Batch $Batch
            ForEach($Statement in $Batch.Statements)
            {
                IF(($Statement.GetType()).Name -eq 'IfStatement')
                {
                    $Statements += Get-IndividualStatement -Statements $Statement
                }

            }

            ForEach ($Statement in $Statements.Statement) {
                $StatementType = ($Statement.GetType()).Name
                If ($StatementType -in ('SelectStatement','DeleteStatement','UpdateStatement','IfStatement')) {
                    $Skip = $false
                    $stringbuilder = New-Object -TypeName "System.Text.StringBuilder";
                    for ($counter = $Statement.FirstTokenIndex; $counter -lt $Statement.LastTokenIndex+1;$counter++)
                        {
                                $stringbuilder.Append($Batch.ScriptTokenStream[$counter].Text.TRIMSTART().TRIMEND());
                        }
                }
                Else {
                    $Skip = $true
                }
                It "Statements with '<> ==' NULL conditions" -Skip:$Skip {
                    $stringbuilder | Should -Not -BeLike "*=NULL*" -Because "that is bad coding. Line $($Statement.StartLine), column $($Statement.StartColumn)"
                    $stringbuilder | Should -Not -BeLike "*<>NULL*" -Because "that is bad coding. Line $($Statement.StartLine), column $($Statement.StartColumn)"
                }
            }
        }
    }
}

