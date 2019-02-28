Class GetFragmentVisitor : Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragmentVisitor
{
    $SELECTcount = 0; 
    $INSERTcount = 0; 
    $UPDATEcount = 0; 
    $DELETEcount = 0;

    #To get full text for later use
   [string] GetNodeTokenText([Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragment] $TSqlFragment) 
        {   
            $stringbuilder = New-Object -TypeName "System.Text.StringBuilder";
                    for ($counter = $TSqlFragment.FirstTokenIndex; $counter -lt $TSqlFragment.LastTokenIndex+1;$counter++) 
                        { 
                                $stringbuilder.Append($TSqlFragment.ScriptTokenStream[$counter].Text); 
                        }                    

            return $stringbuilder.ToString(); 
        }
    
    
    ExplicitVisit([Microsoft.SqlServer.TransactSql.ScriptDom.SelectStatement] $node)
    {
        $script:SELECTcount++;
    }    

    ExplicitVisit([Microsoft.SqlServer.TransactSql.ScriptDom.DeleteStatement] $node)
    {
        $script:DELETEcount++;
    }    

    ExplicitVisit([Microsoft.SqlServer.TransactSql.ScriptDom.UpdateStatement] $node)
    {
        $script:UPDATEcount++;
    }        


    DumpStatistics()
    {
       Write-verbose "select count $($script:SELECTcount) Insert Count $($script:INSERTcount) Update count $($script:UPDATEcount) Delete count $($script:DELETEcount)"
    }

}

