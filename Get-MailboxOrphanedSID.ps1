Function Get-MailboxOrphanedSID
{
    <#
    .SYNOPSIS
    Can be used to locate mailboxes with orphaned SIDs.

    .DESCRIPTION
    Can be used to locate mailboxes with orphaned SIDs.

    .EXAMPLE
    Get-MailboxOrphanedSID

    .INPUTS
    None.  Get-MailboxOrphanedSID does not have any parameters.

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Raymond Jette

    #>
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param ()

    Set-StrictMode -Version 2.0
    
    if (-not (Get-Command -Name Get-Mailbox -ErrorAction 'SilentlyContinue')) {
        throw 'Exchange cmdlets are not available.'
    }
    
    foreach ($mailbox in (Get-Mailbox -ResultSize Unlimited)) {
    
        $sid = @()
        foreach ($permission in (Get-MailboxPermission -identity $mailbox.SamAccountName)) {

            if (($permission.user.tostring() -like "S-*-*") -and ($permission.IsInherited -eq $false)) {

                $sid += $permission.user.tostring()
            }
        }

        if ($sid) {

            [PSCustomObject]@{
                Mailbox = ($Mailbox.Identity -split '/')[-1]
                SIDs = $sid
            }
        }
    }
} # Get-MailboxOrphanedSID