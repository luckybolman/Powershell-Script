Function Get-SoftDeletedMailbox
{
    <#
    .SYNOPSIS
    Returns an object for each soft deleted mailbox found.

    .DESCRIPTION
    Retrusn an object for each soft deleted mailbox found.

    .PARAMETER DatabaseName
    The name of one or more Exchange databases.  This parameter takes values from the pipeline.

    .INPUTS
    [String[]].  The DatabaseName takes a collection of strings from the pipeline.

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Raymond Jette

    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param (
        # DatabaseName
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'One or more Exchange mailbox database names'
        )]
        [ValidateScript({$PSItem | Get-MailboxDatabase})]
        [Alias('Database', 'Name')]
        [String[]]$DatabaseName
    )

    PROCESS {

        foreach ($database in $DatabaseName) {

            try {

                foreach ($mailbox in (Get-MailboxStatistics -Database $database -ErrorAction 'Stop')) {

                    if ($mailbox.DisconnectReason -eq 'SoftDeleted') {

                        [PSCustomObject]@{
                            Name = $mailbox.DisplayName
                            DisconnectDate = $mailbox.DisconnectDate
                            ItemCount = $mailbox.ItemCount
                            TotalItemSize = $mailbox.TotalItemSize
                        }
                    }
                }

            } catch { $_.exception.message }
        }
    }
} # Get-SoftDeletedMailbox