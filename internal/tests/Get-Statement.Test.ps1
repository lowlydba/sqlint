


Describe "Check Invoke-SlCheck" {
	$testPath = "TestDrive:\test.txt"
	Set-Content $testPath -value "select * from table1 where id = NULL
                                    Delete from table2 where id <> NULL
                                    Delete from table2 where id is not NULL
                                    
                                    if(name == NULL)
                                    Print 'hai'"
    
    $ScriptObject = Invoke-SlCheck -File $testPath

	It "Properly reads in the file without erroring" {
	    $ScriptObject.ScriptName | Should -Exist 
	}
}

Describe "Check-Invoke-SlCheck returns correct error count" {

}

Describe "Get-Statement returns correct statement count" {

}

Describe "Get-Statement reads IF/ELSE correctly" {

}