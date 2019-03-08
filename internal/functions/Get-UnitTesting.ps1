#requires -Modules @{ModuleName="Pester"; ModuleVersion = "4.4.0"}

Describe "Check Invoke-SlCheck" {	
	Set-Content -Path "$TestDrive\test.sql" -value "select * from table1 where id = NULL
                                    Delete from table2 where id <> NULL
                                    Delete from table2 where id is not NULL
                                    
                                    if(name = NULL)
                                    SELECT 'Hai' from table3"
        
    $ScriptObject = Invoke-SlCheck -File "$TestDrive\test.sql"      
    # $ScriptDomAssembly = "..\internal\bin\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
    # $Parser = Get-Parser -ScriptDomAssembly $ScriptDomAssembly
    # $Reader = New-Object System.IO.StreamReader("$TestDrive\test.sql")
    # $Errors = $null     
    # $TSQLFragment = [Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragment]  
    # $TSQLFragment = $Parser.Parse($Reader, [ref] $Errors)        
    # $Reader.Close();
    # $Reader.Dispose();      
    # $TSQLFragmentVistor = New-Object GetFragmentVisitor
    # $TSQLFragment.Accept($TSQLFragmentVistor);
    # $SQLVistor.DumpStatistics(); 
    $statementcount=0
    Foreach($su in $ScriptObject.Fragment.Batches)
    {
        $statement = Get-Statement -Batch $su
        $statementcount =+ $statement.count;

    }
    
 	It "Properly reads in the file without erroring" {
 	    $ScriptObject.Errors.Count | Should -be 0 -Because "we cannot run scripts that do not parse"
     }
     
    It "Get-Statement returns correct statement count" {     
     $statementcount | Should -Be 4 -Because "Check statement counts"
     }   

     It "Check-Invoke-SlCheck returns correct error count" {
        $ScriptObject.Errors.Count | Should -Be 0 -Because "Correct Error count"
    }
}   
    
    Describe "Get-Statement reads IF/ELSE correctly" {
    
    }