Function Get-Exchange2010ServiceHealth
{
    #Requires -RunAsAdministrator
    <#
    .SYNOPSIS
    Checks the service status on one or more Exchange servers.

    .DESCRIPTION
    Checks the service status on one or more Exchange servers.

    .PARAMETER ComputerName
    One or more Exchange servers to get the service status for.  If this parameter is not
    specified the default is to include all discovered Exchange Servers in the organization.

    .EXAMPLE
    Returns the service status on all Exchange 2010 Servers in the organization.

    Get-Exchange2010ServiceHealth

    .EXAMPLE
    Returns the service status on Exchange 2010 server 'exch-00'

    Get-Exchange2010ServiceHealth -ComputerName 'exch-00'

    .INPUTS
    system.string.  The computer name parameter takes system.string objects from the pipeline.

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Raymond Jette
    5/12/2018

    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param (
        # ComputerName
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'One or more Exchange Servers.')]
        [String[]]$ComputerName
    )

    BEGIN {

        # If the Exchange cmdles are not available throw and message and exist.
        if (-not (Get-Command -Name Get-Mailbox -ErrorAction 'SilentlyContinue')) {Throw 'Exchange cmdlets are not avaialble.'}

        # Setup a hash table that contains the Exchange roles as keys and the services required by those roles as values. -legacy
        $ExchangeServices = @{
            'clientAccess' = @('MSExchangeADTopology','MSExchangeAB','MSExchangeFDS','MSExchangeFBA','MSExchangeMailboxReplication',
            'MSExchangeProtectionServiceHost','MSExchangeRPC','MSExchangeServiceHost')

            'edgeTransport' = @('ADAM_MSExchange','MSExchangeEdgeCredential','MSExchangeTransport','MSExchangeServiceHost')

            'hubTransport' = @('MSExchangeServiceHost','MSExchangeADTopology','MSExchangeProtectedServiceHost','MSExchangeTransport')

            'mailbox' = @('MSExchangeServiceHost','ExchangeADTopology','MSExchangeIS','MSExchangeMailSubmission','MSExchangeMailboxAssistant'
            'MSExchangeRepl','MSExchangeSearch','MSExchangeSA','MSExchangeThrottling')

            'unifiedMessaging' = @('MSExchangeServiceHost','MSExchangeADTopology','MSExchangeFDS','MSSpeechService','MSExchangeUM')
        }

        # If an Exchange server was not specified populate ComputerName with all Exchange servers in the organization.
        if (-not ($PSBoundParameters['ComputerName'])) {
            $ComputerName = (Get-ExchangeServer -ErrorAction 'Stop' -ErrorVariable 'errGetExchangeServer').Name
        }

        # Splatting, used by the Get-WmiObject cammed later to return all services on a given Exchange server
        $wmiQueryParams = @{ErrorAction = 'Stop'; Class = 'win32_service'}
    }
    PROCESS {

        foreach ($Computer in $ComputerName) {
            
            if (Test-Connection -Count 2 -ComputerName $Computer -Quiet) {

                # Gets a list of services for the current computer using WMI.
                $query = Get-WmiObject -ComputerName $Computer @wmiQueryParams

                # Create a collection of roles running on the current Exchange server.
                $roleString = (Get-ExchangeServer -Identity $Computer).ServerRole -split ',' -replace ' ',''

                # loop through the roles collection
                foreach ($role in $roleString) {

                    # Loop though each service in the $ExchangeServices hash table 
                    foreach ($service in ($ExchangeServices.Item($role))) {
                        
                        # Loop though each serive returned by wmi
                        foreach ($wmiService in $query) {

                            # The service from the hash table is the same as the current service from wmi
                            if ($service -eq $wmiService.name) {

                                # Create a PSCustomObject that will be return
                                [PSCustomObject]@{
                                    ComputerName = $Computer
                                    Role = $role
                                    Service = $service
                                    Status = $wmiService.Status
                                    State = $wmiService.State
                                }
                            }
                        }
                    }
                }
            } else { write-warning -message "Exchange Server, $Computer, does not appear to be active and will be skipped." }
        }
    }
} # Get-Exchange2010ServiceHealth