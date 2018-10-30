function Get-Statement {
    [CmdletBinding()]
    Param (
		[Parameter(
            Mandatory = $true)]
            $Batch)
    begin {
        $Statements = @()
    }
    process {
        ForEach ($Statement in $Batch.Statements) {
            $Type = $Statement.GetType().Name
            # Handle IF Statements
            If ($Type -eq "IfStatement") {
                # Add predicate statement 
                $StatementObject = [PSCustomObject]@{
                    Statement = $Statement.Predicate
                }
                $Statements += $StatementObject

                # Add statements within IF clause
                ForEach ($su in $Statement.ThenStatement.StatementList.Statements) {
                    $StatementObject = [PSCustomObject]@{
                        Statement     = $su
                    }
                    $Statements += $StatementObject
                }
            }
            # Handle WHILE Statements
            ElseIf ($Type -eq "WhileStatement") {
                # Add predicate statement
                $StatementObject = [PSCustomObject]@{
                    Statement = $Statement.Predicate
                }
                $Statements += $StatementObject
                
                # Add statements within loop
                ForEach ($su in $Statement.Statement.StatementList.Statements) {
                    $StatementObject = [PSCustomObject]@{
                        Statement     = $su
                    }
                    $Statements += $StatementObject
                }

            }
            #Normal Statement
            Else {
                $StatementObject = [PSCustomObject]@{
                    Statement     = $statement
                }
                $Statements += $StatementObject
            }
        }
    }
    end {
        return $Statements
    }
}