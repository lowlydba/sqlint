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
        $Statements = @()
    }
    process {
        ForEach ($Statement in $Batch.Statements) {
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
                        $Statements += Get-IndividualStatement -Statements $Statement.ElseStatement.StatementList.Statements
                    }
                    Else {
                        $Statements += Get-IndividualStatement -Statements $Statement.ElseStatement
                    }
                }
            }
            #Handle BEGIN END Statements
            ElseIf ($Type -eq "BeginEndBlockStatement") {
                
                If ($Statement.StatementList) {
                    ForEach ($su in $Statement.StatementList.Statements) {
                        $Statements += Get-IndividualStatement -Statements $su
                    }
                }
                else {
                    $Statements += Get-IndividualStatement -Statements $Statement
                }
            }            
            # Handle WHILE Statements
            ElseIf ($Type -eq "WhileStatement") {
                
                # Add statements within loop
                If ($Statement.Statement.StatementList) {
                    ForEach ($su in $Statement.Statement.StatementList.Statements) {
                        $StatementObject = [PSCustomObject]@{
                            Statement     = $su
                        }
                        $Statements += $StatementObject
                    }
                }
                Else {
                    $StatementObject = [PSCustomObject]@{
                        Statement     = $Statement.Statement
                    }
                    $Statements += $StatementObject
                }
            }
            # Handle stored proc contents
            ElseIf ($Type -eq "CreateProcedureStatement") {
                $Statements += $Statement
                If ($Statement.StatementList) {
                    ForEach ($su in $Statement.StatementList.Statements) {
                        ForEach ($su2 in $su.StatementList.Statements) {
                            $Statements += Get-IndividualStatement -Statements $su2
                        }
                    }
                }
              <#  Else {
                    $StatementObject = [PSCustomObject]@{
                        Statement     = $Statement.Statement
                    }
                    $Statements += $StatementObject
                }#>
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
    }
    end {
        return $Statements
    }
}