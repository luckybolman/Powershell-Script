Function Enable-CircularLogging
{
    <#
    .SYNOPSIS
    Enables circular logging on the given database.

    .DESCRIPTION
    Enables circular logging on the given database.
    
    .PARAMETER DatabaseName
    The name of one or more databases.  Accepts pipeline input.

    .EXAMPLE
    Enable-CircularLogging -Database (Get-MailboxDatabase)
    
    .NOTES
    Raymond Jette

    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'The name of one or more mailbox databases.'
        )]
        [ValidateScript({Get-MailboxDatabase $_})]
        [String[]]$DatabaseName
    )
    BEGIN { }

    PROCESS {   
        Write-Verbose -Message 'Looping thorugh DatabaseName'
        foreach ($db in $Databasename) {
            Write-Verbose -Message 'Currrent db: $Database'
            try {
                # If circular logging is not enabled enable it
                if (-not ((Get-MailboxDatabase $db).CircularLoggingEnabled)) {
                    Write-Verbose -Message 'Circular logging is not eabled.'
                    if ($PSCmdlet.ShouldProcess($db)) {

                        Write-Verbose -Message "Enabling Circular Logging..."
                        Set-MailboxDatabase $db -CircularLoggingEnabled:$true

                        Write-Verbose -Message 'Dismounting database...'
                        Dismount-Database $db -Confirm:$false

                        Start-Sleep -Seconds 2
                        Write-Verbose -Message 'Mounting database...'
                        Mount-Database $db -Confirm:$false
                    }
                } else {write-warning -message "Circular logging is already enabled on $db."}

            } catch {$_.exception.message}
        }
    }
} # Enable-CircularLogging