Function Test-IsActivationBlocked 
{
    <#
    .SYNOPSIS
    Returns true if the given database copy has it's activation blocked.

    .DESCRIPTION
    Retruns true if the given database copy has it's activation blocked.

    .PARAMETER DatabaseName
    The name of the mailbox database copy to  check if it's activation is blocked.

    .PARAMETER MailboxServer
    The name of the mailbox server that contains the database copy.

    .EXAMPLE
    Test if database copy db0 on the mailbox server mbx-00 has it's activation blocked.

    Test-IsActivationBlocked -DatabaseName db0 -MailboxServer mbx-00

    .INPUTS
    None.  Test-IsActivationBlocked does not take objects from the pipeline.

    .OUTPUTS
    Bool

    .NOTES
    Raymond Jette

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

    If ( (Get-MailboxDatabaseCopyStatus -Identity $DatabaseName\$MailboxServer).ActivationSuspended -eq $true ) {$true} Else {$false}

} # Test-IsActivationBlocked