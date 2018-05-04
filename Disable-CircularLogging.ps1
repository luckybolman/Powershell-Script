Function Disable-CircularLogging
{
    <#
    .SYNOPSIS
    Disables circular logging on a given mailbox database.

    .DESCRIPTION
    Disables circular logging on a given mailbox database.

    .PARAMETER DatabaseName
    The name of one or more mailbox databases.

    .EXAMPLE
    Disable-CircularLogging -DatabaseName (Get-MailboxDatabase)

    .NOTES
    Raymond Jette

    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'One or more mailbox databases.'
        )]
        [ValidateScript({Get-MailboxDatabase $_})]
        [String[]]$DatabaseName
    )
    BEGIN { }

    PROCESS {
        Write-Verbose -Message 'Looping DatabaseName'
        foreach ($db in $DatabaseName) {
            Write-Verbose -Message 'Current database: $db'
            try {
                if ((Get-MailboxDatabase $db).CircularLoggingEnabled) {
                    Write-Verbose -Message "Circular logging is enabled on $db"
                    if ($PSCmdlet.ShouldProcess($db)) {
                        Write-Verbose -Message 'Disabling circular logging...'
                        Set-MailboxDatabase $db -CircularLoggingEnabled:$false
                        Write-Verbose -Message 'Dismounting database $db'
                        Dismount-Database $db -Confirm:$false
                        Start-Sleep -Seconds 2
                        Write-Verbose -Message 'Mounting database $db'
                        Mount-Database $db -Confirm:$false
                    }
                } else {write-warning -message "Circular logging is already disabled on $db."}
            } catch {$_.exception.message}
        }
    }
} # Disable-CircularLogging