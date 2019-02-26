# sqlint
Static code analyzer / parser for transact-sql

# Architecture

The primary function `Invoke-SlCheck` sets up the SQL Server parser, reads the files passed in, and then performs Pester tests contained in `/sql-tests` to make sure they adhere to best practices. If the file doesn't parse, it never makes it to the testing phase.

## SQL Tests

The majority of these tests call the `Get-Statement` function to analyze each individual statement contained within a script, so that the tests can be written generically and skipped if doesn't apply. For example, the test to check if a `DELETE` statement has no `WHERE` clause will be skipped unless the 1$StatementType1 returned is `DeleteStatement`.