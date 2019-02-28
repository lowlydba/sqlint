#requires -Modules @{ModuleName="Pester"; ModuleVersion = "4.4.0"}

Describe "Check Invoke-SlCheck" {	
	Set-Content -Path "$TestDrive\test.sql" -value "select * from table1 where id = NULL
                                    Delete from table2 where id <> NULL
                                    Delete from table2 where id is not NULL
                                    
                                    if(name = NULL)
                                    SELECT 'Hai' from table3"
    
    $ScriptDomAssembly = "..\internal\bin\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
    $Parser = Get-Parser -ScriptDomAssembly $ScriptDomAssembly
    $Reader = New-Object System.IO.StreamReader("$TestDrive\test.sql")
    $Errors = $null     
    $TSQLFragment = [Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragment]  
    $TSQLFragment = $Parser.Parse($Reader, [ref] $Errors)        
    $Reader.Close();
    $Reader.Dispose();      
    $TSQLFragmentVistor = New-Object GetFragmentVisitor
    $TSQLFragment.Accept($TSQLFragmentVistor);
    $SQLVistor.DumpStatistics();   
    
 	It "Properly reads in the file without erroring" {
 	    $TSQLFragment.Errors.Count | Should -Be 0 -Because "we cannot run scripts that do not parse"
 	}


     It "Check-Invoke-SlCheck returns correct error count" {
     $TSQLFragment.Errors.Count | Should -Be 0 -Because "Error count should match"
     }

    #  It "Get-Statement returns correct statement count" {
    #  $Statements = Get-Statement -Batch $TSQLFragment.Batches[0]    
    #  $Statements.count | Should -Be 0 -Because "we cannot run scripts that do not parse"
    #  }

#     It "Get-Statement reads IF/ELSE correctly" {

# }
}