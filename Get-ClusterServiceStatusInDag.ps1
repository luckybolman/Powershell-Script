Function Get-ClusterServiceStatusInDag
{
    <#
    .SYNOPSIS
    Gets all mailbox database servers in the database availability group and returns an object contaning the name and status of the 
    cluster service.

    .DESCRIPTION
    Gets all mailbox database servers in the database availability group and returns an object contaning the name and status of the 
    cluster service.

    .EXAMPLE
    Get-ClusterServiceStatusInDag

    .INPUTS
    None.  Get-ClusterServiceStatusInDag does not have any parameters.

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Raymond Jette

    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param ()

    if (-not (Get-Command Get-Mailbox -ErrorAction 'SilentlyContinue')) {
        throw 'Exchange cmdlets not available.'
    }

    foreach ($dag in (Get-DatabaseAvailabilityGroup)) {
        
        foreach ($server in ((Get-DatabaseAvailabilityGroup).Servers)) {

            $GetWmiObjectParams = @{class = 'win32_service'; ComputerName = $server}
            $query = Get-WmiObject @GetWmiObjectParams | Where-Object { $PSItem.Name -eq 'ClusSvc' } 

            [PSCustomObject]@{
                Server = $server
                MemberOf = $dag
                Service = $query.State 
            }
        }
    }
} # Get-ClusterServiceStatusInDag