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
        if (-not (Get-Command -Name Get-Mailbox)) {Throw 'Exchange cmdlets are not avaialble.'}

        # Setup a hash table that contains the Exchange roles as keys and the services required by those roles as values. -legacy
        $ExchangeServices = @{
            'clientAccess' = @('MSExchangeADTopology','MSExchangeAB','MSExchangeFDS','MSExchangeFBA','MSExchangeMailboxReplication',
            'MSExchangeProtectionServiceHost','MSExchangeRPC','MSExchangeServiceHost')

            'edgeTransport' = @('ADAM_MSExchange','MSExchangeEdgeCredential','MSExchangeTransport','MSExchangeServiceHost')

            'hubTransport' = @('MSExchangeServiceHost','MSExchangeADTopology','MSExchangeProtectedServiceHost','MSExchangeTransport')

            'mailbox' = @('MSExchangeServiceHost','ExchangeADTopology','MSExchangeIS','MSExchangeMailSubmission','MSExchangeMailboxAssistant'
            'MSExchangeRepl','MSExchangeSearch','MSExchangeSA','MSExchangeThrottling')
##########
            'unifiedMessaging' = @('MSExchangeServiceHost','MSExchangeADTopology','MSExchangeFDS','MSSpeechService','MSExchangeUM')
        }

        # Setup a hash table that contains the Exchange roles as keys and a hash table as values of services required by the roles as keys and null values
        $clientAccessServices = @{
            'MSExchangeADTopology' = $null; 'MSExchangeAB' = $null; 'MSExchangeFDS' = $null; 'MSExchangeFBA' = $null; 'MSExchangeServiceHost' = $null
            'MSExchangeMailboxReplication' = $null; 'MSExchangeProtectionServiceHost' = $null; 'MSExchangeRPC' = $null; 
        }
        $mailboxService = @{
            'MSExchangeServiceHost' = $null; 'ExchangeADTopology' = $null; 'MSExchangeIS' = $null; 'MSExchangeMailSubmission' = $null; 'MSExchangeMailboxAssistant' = $null;
            'MSExchangeRepl' = $null; 'MSExchangeSearch' = $null; 'MSExchangeSA' = $null; 'MSExchangeThrottling' = $null
        }
        $edgeTransportServices = @{
            'ADAM_MSExchange' = $null; 'MSExchangeEdgeCredential' = $null; 'MSExchangeTransport' = $null; 'MSExchangeServiceHost' = $null
        }
        $hubTransportServices = @{ 
            'MSExchangeServiceHost' = $null; 'MSExchangeADTopology' = $null; 'MSExchangeProtectedServiceHost' = $null; 'SMExchangeTransport' = $null
        }
        $unifiedMessagingServices = @{ 
            'MSExchangeServiceHost' = $null; 'MSExchangeADTopology' = $null; 'MSExchangeFDS' = $null; 'MSSpeechService' = $null; 'MSExchangeUM' = $null 
        }
        $ExchangeServicesNew = @{
            'clientAccess' = $clientAccessServices
            'edgeTransport' = $mailboxService
            'hubTransport' = $edgeTransportServices
            'mailbox' = $mailboxService
            'unifiedMessaging' = $unifiedMessagingServices
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
                # loop though each Exchange server role string for the current computer

                $query = Get-WmiObject -ComputerName $Computer @wmiQueryParams

                foreach ($roleString in ((Get-ExchangeServer -Identity $Computer).ServerRole )) {
                    
                    # Create a collection of roles running on the Exchange server from the role string
                    if ($roleString -like "*,*") { $roles = $roleString -split ',' -replace ' ','' } else { $roles = $roleString }

        #           # loop through the roles collection
                    foreach ($role in $roles) {

                        ########
                      # The role is contained in the ExchangeServices hashtable


                    #    if ($ExchangeServices.$role) {
                            
                            # Return a list of all services  on the currnet Exchange server using the win32_service cliass
                #  # ###   # $query = Get-WmiObject -ComputerName $Computer @wmiQueryParams

                            # Loop though each service in the $ExchangeServices hash table 
                            foreach ($service in ($ExchangeServices.Item($role))) {
                                
                                # Loop though each serive returned by wmi
                                foreach ($wmiService in $query) {

                                    # The service from the hash table is the same as the current service from wmi
                                    if ($service -eq $wmiService.name) {

                                        # if need some code somewhere that sayes if the mailbox server is in a dag
                                        # then add the cluster service to the list as well
                                        # this check need to occure in the correct place to work right.

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
                    #    } else { write-warning 'Failed to look up role: $role' }
                    }
                }
            } else { write-warning -message "Exchange Server, $Computer, does not appear to be active and will be skipped." }
        }
    }
} # Get-Exchange2010ServiceHealth