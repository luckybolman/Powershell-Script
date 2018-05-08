Function Get-DisabledMailboxInGal
{
    <#
    .SYNOPSIS
    Returns a mailbox if the following conditions are true:
    - the Active Directory account is disabled
    - the mailbox is present in the GAL

    .DESCRIPTION
    Returns a mailbox if the following conditions are true:
    - the Active Directory account is disabled
    - the mailbox is present in the GAL

    .EXAMPLE
    Get-DisabledMailboxInGal

    .INPUTS
    None.

    .OUTPUTS
    None.

    .NOTES
    Raymond Jette

    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param ()

    if (-not (Get-Command Get-Mailbox -ErrorAction 'SilentlyContinue')) {
        throw 'The Exchange cmdlets are not available.'
    }

    $FilterBlock = {
        (HiddenFromAddressListsEnabled -eq $false) -and
        (ExchangeUserAccountControl -eq 'AccountDisabled') -and
        (ResourceType -ne 'Room')
    }

    $GetMailboxParams = @{
        ResultSize    = 'Unlimited'
        ErrorAction   = 'Stop'
        Filter        = $FilterBlock
    }

    try {

        if (Get-Command Get-Mailbox -ErrorAction 'SilentlyContinue') {

            foreach ($item in (Get-Mailbox @GetMailboxParams)) {

                [PSCustomObject]@{
                    Name = $item.Name
                    Alias = $item.Alias
                }
            }
        } else { Write-Error -Message "The Get-Mailbox cmdlet is not available.  Make sure Exchange cmdlets are available." }

    } catch { $PSItem.Exception.Message }
}