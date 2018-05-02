Function Get-DatabaseCopyLagTimes 
{
    <#
    .SYNOPSIS
    Returns a PSCustomObject contaning information relating to lagged database copies.

    .DESCRIPTION
    Returns a PSCustomObject contaning information relating to lagged database copies.

    .PARAMETER DatabaseName
    The name of the database.  Accepts pipeline input.

    .PARAMETER MailboxServer
    The name of the mailbox server.

    .EXAMPLE
    Get-DatabaseCopyLagTimes -DatabaseName (Get-MailboxDatabase) -MailboxServer mtsrv-exmbx002 | Out-Gridview

    .INPUTS
    String.  The DatabaseName parameter takes a string from the pipeline.

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
            mandatory = $true, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The name of one or more databases.'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [String[]]$DatabaseName,

        # MailboxServer
        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$MailboxServer
    )
    BEGIN {

        $GetMailboxDatabaseParams = @{Status = $true; ErrorAction = 'SilentlyContinue'}

    }

    PROCESS {

        foreach ($Database in $DatabaseName) {

            $dbQuery = Get-MailboxDatabase -Identity $Database @GetMailboxDatabaseParams
            if ($dbQuery) {

                $ap = ($dbQuery.ActivationPreference | Where-Object {$_ -like "*$MailboxServer*"}).split(',')[1] -Replace ']' -Replace ' '
                $ReplayLagTimes = ($dbQuery.ReplayLagTimes | Where-Object {$_ -like "*$MailboxServer*"}).split(',')[1] -Replace ']' -Replace ' '
                $TruncationLagTimes = ($dbQuery.TruncationLagTimes | Where-Object {$_ -like "*$MailboxServer*"}).split(',')[1] -Replace ']' -Replace ' '

                [PSCustomObject]@{
                    Database = $dbQuery.name
                    MailboxServer = $MailboxServer
                    AP = $ap
                    ReplayLagTimes = $ReplayLagTimes
                    TruncationLagTimes = $TruncationLagTimes
                    ActivationBlocked = Test-IsActivationBlocked -Database $Database -MailboxServer $MailboxServer 
                }

            } else { write-warning -message 'No databases were found' }
        }
    }
}