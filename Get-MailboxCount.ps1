Function Get-MailboxCount
{
    <#
    .SYNOPSIS
    Returns the number of mailboxes that exist in a given mailbox database.
    
    .DESCRIPTION
    Returns the number of mailboxes that exist in a given mailbox database.
    
    .PARAMETER DatabaseName
    The name of one of more mailbox databases.

    .EXAMPLE
    Get-MailboxCount -Database 'db01', 'db02'

    .EXAMPLE
    Get-MailboxCount -Database (Get-MailboxDatabase)

    DatabaseName   MailboxesOnDb
    ------------   -------------
    db0            20
    db1            32
    db2            48
    db3            27
    db4            18
    
    .NOTES
    Raymond Jette

    #>
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Name')]
        [String[]]$DatabaseName
    )

    BEGIN {

        Set-StrictMode -Version 2.0

        if (-not (Get-Command -Name Get-Mailbox -ErrorAction 'SilentlyContinue')) {
            throw 'Exchange cmdlets are not available.'
        }
    }

    PROCESS {

        Try {

            Write-Verbose -Message 'Looping though databases...'
            foreach ($db in $DatabaseName) {

                Write-Verbose "Current database: $db"
                If ($query = (Get-Mailbox -Database $db)) {

                    [PSCustomObject]@{
                        DatabaseName  = $db
                        MbxCount = $query.count
                    }
                }
            }
        }
        Catch {$_.Exception.Message}
    }
} # Get-MailboxCount