Function Test-IsLaggedDatabaseCopy
{
    <#
    .SYNOPSIS
    Returns true if the give Exchange database is a lagged copy.
    
    .DESCRIPTION
    Returns true if the given Exchange database is a lagged copy.

    .PARAMETER DatabaseName
    This is the database to best tested to see if it's a lagged replica.

    .PARAMETER MailboxServer
    The mailbox server that hosts the database copy to be tested.

    .EXAMPLE
    Tests if db1 on mbx1 is a lagged mailbox database copy

    Test-IsLaggedDatabaseCopy -MailboxServer mbx1 -DatabaseName db1
    False
    
    .INPUTS
    None.  Test-IsLaggedDatabaseCopy does not accept objects from the pipeline.

    .OUTPUTS
    Bool

    .NOTES
    #>
    [OutputType([Bool])]
    [CmdletBinding()]
    param (
        # DatabaseName
        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$DatabaseName,

        # MailboxServer
        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$MailboxServer
    )
    Set-StrictMode -Version 2.0
    
    $GetMailboxDatabaseParams = @{Status = $true; Identity = $DatabaseName}

    try {

        $dbCopy = (Get-MailboxDatabase @GetMailboxDatabaseParams).ReplayLagTimes.Where({$_ -like "*$MailboxServer*"}).Split(',')[1] -Replace ']'

         if (-not ($dbCopy -like ' 00:00:00')) { $true } else { $false }

    } catch { write-error -message $PSItem.Exception.Message }

} # Test-IsLaggedDatabaseCopy