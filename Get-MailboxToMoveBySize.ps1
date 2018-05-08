Function Get-MailboxToMoveBySize 
{
    <#
    .SYNOPSIS
    Returns a collection of mailboxes that should be moved to reach the desired size.

    .DESCRIPTION
    Returns a collection of mailboxes that should be moved to reach the size give by Size in MB.
    
    .EXAMPLE
    Get-MailboxToMoveBySize -Database db00 -Size 100

    .EXAMPLE
    Get the mailboxes to move.  Exclude any mailboxes that are currenlty being moved.  Then move the
    mailboxes to the given target database

    (Get-MailboxToMoveBySize -Database db00 -Size 112000 -Filter ((Get-MoveRequest).DisplayName)).DisplayName | New-MoveRequest -BadItemLimit 50 -TargetDatabase db01
    
    .NOTES
    Raymond Jette

    #>
    [CmdletBinding()]
    param (
        # Database
        [parameter(
            mandatory=$true,
            HelpMessage='The database you will be moving from'
        )]
        [string]$Database,

        # Size
        [parameter(
            mandatory=$true,
            HelpMessage='The size, in MB, that you would like to move from database'
        )]
        [int64]$Size,

        # Filter
        [String[]]$Filter
    )

    if (-not (Get-Command -Name Get-Mailbox -ErrorAction 'SilentlyContinue')) {
        throw 'Exchange cmdlets not available.'
    }

    $mailboxStats = Get-MailboxStatistics -Database $Database -ErrorAction 'SilentlyContinue' | 
        Select-Object DisplayName, @{Name="SizeMB";Expression={[math]::round( [int64]$_.TotalItemSize.ToString().TrimEnd(' bytes)').Split('(')[1] / 1MB)}} |
        Sort-Object -Property SizeMB -descending

    $mailboxStats | ForEach-Object { 

        if (($_.SizeMB -gt 0) -and  ($_.SizeMB -le $Size) ) {
            If (  ($Filter -NotContains $_.DisplayName ) ) { 
                $_
                $Size -= $_.SizeMB
            }
        }
    }  
} # Get-MailboxToMoveBySize