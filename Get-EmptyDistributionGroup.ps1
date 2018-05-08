Function Get-EmptyDistributionGroup
{
    <#
    .SYNOPSIS
    Returns empty distribution groups from Exchange.

    .DESCRIPTION
    Returns emtpy distribution groups from Exchange.  An empty distribution gorup is one which has 0 members.

    .EXAMPLE
    Get-EmptyDistributionGroup

    .INPUTS 
    None.

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Raymond Jette

    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param ()
    
    if (-not (Get-Command -Name Get-Mailbox -ErrorAction 'SilentlyContinue')) {
        throw 'Exchange cmdlets are not available.'
    }
    
    $distGroupParams = @{ResultSize = 'Unlimited'; ErrorAction = 'Stop'}
    foreach ($distGroup in (Get-DistributionGroup @distGroupParams)) {

        If (-Not (Get-DistributionGroupMember -Identity $distGroup.Name)) {

            [PSCustomObject]@{
                DisplayName = $distGroup.DisplayName
                Identity = $distGroup.Identity
                GroupType = $distGroup.GroupType
                PrimarySmtp = $distGroup.PrimarySmtpAddress
            }
        }
    }
} # Get-EmptyDistributionGroup