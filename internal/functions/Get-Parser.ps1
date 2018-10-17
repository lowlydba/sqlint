function Get-Parser {
    [CmdletBinding()]
    Param (
		[Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [System.IO.FileInfo]
            $ScriptDomAssembly)

    If (Test-Path $ScriptDomAssembly) {
        try {
            Add-Type -Path $ScriptDomAssembly
            $ParserNameSpace = "Microsoft.SqlServer.TransactSql.ScriptDom.TSql140Parser"
            $UseQuotedIdentifier = $true
            $Parser = New-Object $ParserNameSpace($UseQuotedIdentifier)
            Write-PSFMessage -Level "Debug" -Message "Created parser object."
        } catch {
            Stop-PSFFunction -Message "Couldn't load version 14 ScriptDom Assembly." -EnableException:$true
        }
        return $Parser
    }
    Else {
        Stop-PSFFunction -Message "Cannot load ScriptDOM assembly from provided path." -EnableException:$true
    }
}