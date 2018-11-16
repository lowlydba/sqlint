function Invoke-SlCheck {
    [CmdletBinding()]
    Param (
		[Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [System.IO.FileInfo]
            $File,
        [Parameter(
            Mandatory = $false)]
            [System.IO.FileInfo]
            $ScriptDomAssembly = "$PSSCriptRoot\..\internal\bin\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
    )

    begin {
        #Load assembly file and create parser
        $StoredScriptDomAssembly = Get-PSFConfigValue -FullName "SqlLint.ScriptDomAssembly.Path"
        If ($null -eq $ScriptDomAssembly -and $null -eq $StoredScriptDomAssembly) {
            $ScriptDomAssembly = Read-Host "Path to ScriptDom Assembly"
            Set-PSFConfig -FullName "SqlLint.ScriptDomAssembly.Path" -Value $ScriptDomAssembly
        }
        ElseIf ($null -ne $ScriptDomAssembly) {
            Set-PSFConfig -FullName "SqlLint.ScriptDomAssembly.Path" -Value $ScriptDomAssembly
        }
        ElseIf ($null -ne $StoredScriptDomAssembly) {
            $ScriptDomAssembly = $StoredScriptDomAssembly
        }
        $Parser = Get-Parser -ScriptDomAssembly $ScriptDomAssembly
    }
    process {
        $FileExtension = [System.IO.Path]::GetExtension($File)
        If ($FileExtension -ne ".sql") {
            Write-PSFMessage -Level "Warning" -Message "Not a sql file, skipping $($File.Name)."
        }
        Else {
            try {
                Write-PSFMessage -Level "Verbose" -Message "Parsing $($File.Name) ..."
                $Reader = New-Object System.IO.StreamReader($File.FullName)
                $Errors = $null
                $ScriptObject = $Parser.Parse($Reader, [ref] $Errors)
                $Reader.Dispose()
            }
            catch {
                If ($Reader) {
                    $Reader.Dispose()
                }
                Stop-PSFFunction -Message "$($_.Exception.Message)"
                Stop-PSFFunction -Message "Unable to parse $($File.Name)" -EnableException:$true
            }

            #Create custom object for each script
            $ScriptObject = [PSCustomObject] @{
                PSTypeName     = "Parser.DOM.Script"
                ScriptName     = $File.Name
                ScriptFilePath = $File.FullName
                Fragment       = $ScriptObject
                Errors         = $Errors
            }

            Invoke-Pester -Script @{Path = "$PSScriptRoot/../tests/Parse.Test.ps1"; Parameters = @{ScriptObject = $ScriptObject}} #-Tag "Parse"
        }
    }
    end {

    }
}
