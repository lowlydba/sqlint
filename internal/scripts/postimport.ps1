# Place all code that should be run after functions are imported here


Set-PSFConfig -FullName "SqlLint.ScriptDomAssembly.Path" -Value $null -Validation string -Initialize -Description "Path to the TSQL Script Dom dll" -Default
Get-PSFConfig -FullName "SqlLint.ScriptDomAssembly.Path" | Register-PSFConfig 