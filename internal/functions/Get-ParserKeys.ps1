function Get-ParserKeys {
    $ParserKeys = @()

    $ParserKeys += New-Object Parserkey ("SelectStatement","Queryexpression.Fromclause.Tablereferences.Schemaobject")
    $ParserKeys += New-Object Parserkey ("InsertStatement","InsertSpecification.Target.SchemaObject")
    $ParserKeys += New-Object Parserkey ("UpdateStatement","UpdateSpecification.Target.SchemaObject")
    $ParserKeys += New-Object Parserkey ("DeleteStatement","DeleteSpecification.Target.SchemaObject")
    $ParserKeys += New-Object Parserkey ("AlterTableAddTableElementStatement","SchemaObjectName")
    $ParserKeys += New-Object Parserkey ("AlterTableDropTableElementStatement","SchemaObjectName")
    $ParserKeys += New-Object Parserkey ("DropIndexStatement","DropIndexClauses.Object")
    $ParserKeys += New-Object Parserkey ("CreateIndexStatement","OnName")
    $ParserKeys += New-Object Parserkey ("CreateProcedureStatement","ProcedureReference.Name")
    $ParserKeys += New-Object Parserkey ("CreateTableStatement","SchemaObjectName")
    $ParserKeys += New-Object Parserkey ("DropProcedureStatement","Objects")
    $ParserKeys += New-Object Parserkey ("DropTableStatement","Objects")

    return $ParserKeys
}