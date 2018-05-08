Function Get-CircularLoggingStatus
{
    <#
    .SYNOPSIS
    Returns true if circular logging is enabled on a given mailbox database and false otherwise.

    .DESCRIPTION
    Returns true if circular logging is enabled on a given mailbox database and false otherwise.

    .PARAMETER DatabaseName
    The name of one or more Exchange databases to check the circular logging status on.

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .INPUTS
    System.String.  The DatabaseName accepts objects from the pipeline.

    .EXAMPLE
    Get-CircularLoggingStatus -DatabaseName (Get-MailboxDatabase)
    
    Name        Circ. Logging
    -------     -------------
    db0         Enabled
    db1         Enabled
    db2         Enabled
    db3         Disabled
    db4         Enabled
    db5         Disabled

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
            ValueFromPipelineByPropertyName = $true
        )]
        [String[]]$DatabaseName

    )

    BEGIN {

        if (-not (Get-Command Get-Mailbox -ErrorAction 'SilentlyContinue')) {
            throw 'Exchange cmdlets are not available.'
        }
    }

    PROCESS {

        foreach ($Database in $DatabaseName) {

           try {

                write-verbose -message "Current Database: $database"
                write-verbose -message 'Checking circular logging status...'
                $status = (Get-MailboxDatabase $database).CircularLoggingEnabled

                if ($status) {

                    write-verbose -message "Circular logging is enabled on database $database"
                    $status = 'Enabled'
                
                } else {

                    write-verbose -message "Circular logging is disabled on database $database"
                    $status = 'Disabled'
                }

                [PSCustomObject]@{
                    Name = $Database
                    'CircularLogging' = $status
                }

            } catch { $PSItem.Exception.Message }
        }
    }

} # Get-CircularLoggingStatus