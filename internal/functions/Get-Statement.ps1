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
            If ($Type -eq "IfStatement") {
                $StatementObject = [PSCustomObject]@{
                    Statement = $Statement
                }
                $Statements += $StatementObject
                ForEach ($su in $Statement.ThenStatement.StatementList.Statements) {
                    $StatementObject = [PSCustomObject]@{
                        Statement     = $su
                    }
                    $Statements += $StatementObject
                }
            }
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