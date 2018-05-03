
Function Get-DuplicateAlias
{
    <#
    .SYNOPSIS
    Gets duplicate aliases from Exchange server.

    .DESCRIPTION
    Gets duplicate aliases from Exchange server.

    .EXAMPLE
    Get-ExchDuplicateAlias

    .INPUTS
    None.  Get-DuplicateAlias does not have any parameters.

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Raymond Jette

    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param( )

    $AliasSeen = @{}
    $return = @()

    Write-Verbose -Message 'Looping through mailboxes...'
    ForEach ($mailbox in (Get-Mailbox -ResultSize 'Unlimited')) {
        $CurrentAlias = $mailbox.Alias
        Write-Verbose -Message "Current alias: $CurrentAlias"

        Write-Verbose -Message 'Checking for duplicate aliases'
        if ($AliasSeen.Contains("$CurrentAlias")) {
            Write-Verbose -Message 'A duplicate was found.'
            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -MemberType NoteProperty -Name 'DuplicateAlias' -Value ($mailbox.Alias)
            $return += $object
        } 
        else {
            Write-Verbose -Message 'A duplicate was not found.'
            $AliasSeen.Add($CurrentAlias, $mailbox.DisplayName)
        }
    }
    $return | Sort-Object -Property 'DuplicateAlias' -Unique

} # Get-DuplicateAlias