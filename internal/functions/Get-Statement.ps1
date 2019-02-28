function Get-IndividualStatement {
    Param (
        [Parameter(Mandatory = $true)]
        $Statements
    )
    #Iterate through all statements
    ForEach ($Statement in $statements) {
        $StatementObject = [PSCustomObject]@{
            Statement = $Statement
        }
        $StatementList += $StatementObject
    }
    return $StatementList
}

function Get-Statement {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory = $true)]
            $Batch)
    begin {
        $StatementTypes = @('IfStatement','WhileStatement','BeginEndBlockStatement','DeclareVariableStatement','CreateProcedureStatement')
        if ($null -eq $checkflag)
        {
            $Statements = @()
            $NestedStatements = @()
            $NestedStatements = $Batch.Statements
        }
    }
    process {
        ForEach ($Statement in $NestedStatements) {
            $Type = $Statement.GetType().Name
            # Handle IF Statements
            If ($Type -eq "IfStatement") {
                # Add THEN statements
                If ($Statement.ThenStatement.StatementList) {
                    ForEach ($su in $Statement.ThenStatement.StatementList.Statements) {
                        $Statements += Get-IndividualStatement -Statements $su
                    }
                }
                Else {
                    $Statements += Get-IndividualStatement -Statements $Statement.ThenStatement
                }
                If ($null -ne ($Statement.ElseStatement)){
                    # Add ELSE statements
                    If ($Statement.ElseStatement.StatementList) {
                        ForEach ($su in $Statement.ElseStatement.StatementList.Statements) {
                            $Statements += Get-IndividualStatement -Statements $su
                        }
                    }
                    Else {
                        $Statements += Get-IndividualStatement -Statements $Statement.ElseStatement
                    }
                }
            }
            #Handle BEGIN END Statements # Handle WHILE Statements
            ElseIf (($Type -eq "WhileStatement") -or ($Type -eq "BeginEndBlockStatement")) {

                If ($Statement.StatementList) {
                    ForEach ($su in $Statement.StatementList.Statements) {
                        $Statements += Get-IndividualStatement -Statements $su
                    }
                }
                else {
                    $Statements += Get-IndividualStatement -Statements $Statement.Statement
                }
            }

            # Handle stored proc contents
            ElseIf ($Type -eq "CreateProcedureStatement") {
                $Statements += $Statement
                If ($Statement.StatementList) {
                    ForEach ($su in $Statement.StatementList.Statements) {
                            $Statements += Get-IndividualStatement -Statements $su2
                        }
                    }
                }
            #DeclareVariable Statement
            ElseIf ($Type -eq "DeclareVariableStatement") {
                    ForEach ($su in $Statement.Declarations) {
                        $Statements += Get-IndividualStatement -Statements $su
                    }
            }
            #Normal Statement
            Else {
                $Statements += Get-IndividualStatement -Statements $Statement
            }
        }
        $checkflag = $null
        $NestedStatements = @()

        ForEach ($Statement in $Statements | Where-Object Statement -ne 'CreateProcedureStatement') {
            If ($StatementTypes -contains $Statement.Statement.GetType().Name) {
                $checkflag = 1
                $NestedStatements += $Statement.Statement
            }
        }
        $Statements = $Statements | Where-Object {$_.Statement -notin $NestedStatements}
        if($NestedStatements.Length -ne 0)
        {
            $Statements += Get-Statement -Batch $NestedStatements
        }
    }
    end {
        return $Statements
    }
}