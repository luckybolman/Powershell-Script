Function Connect-Exchange
{
    <#
    .SYNOPSIS
    Creates a connection to a remote Exchange server importing the cmdlets into the local session.

    .DESCRIPTION
    Creats a connection to a remote Exchange server importing the cmdlets into the local session

    .PARAMETER ExchangeServer
    The Exchange server to connect.

    .PARAMETER Credential
    Specify alternate credentials.

    .PARAMETER ConnectionUri
    The connection uri to create the connection.  A default value of 'http://<exch-server>/Powershell' is used if unspecified.

    .EXAMPLE
    $session = Connect-Exchange -ExchangeServer exch-mbx-00
    ... do something ...
    Remove-PSSession -Id $session.id

    .EXAMPLE
    $session = Connect-Exchange -ExchangeServer exch-mbx-00 -Credential (Get-Credential)

    .OUTPUTS
    [System.Management.Automation.Runspaces.PSSession]

    .LINK
    https://blogs.technet.microsoft.com/ptsblog/2011/09/02/single-seat-administration-of-exchange-2010-using-powershell-implicit-remoting/

    .NOTES
    Raymond Jette


    #>
    [Cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            HelpMessage='An Exchange server to connect to.'
        )]
        [ValidateScript({
            Test-Connection -ComputerName $_ -Quiet -Count 1
        })]
        [String]$ExchangeServer,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [ValidateNotNullOrEmpty()]
        [String]$ConnectionUri = "http://$($ExchangeServer)/Powershell"
    )
    try {
        $sessionParams = @{
            ConfigurationName = 'Microsoft.Exchange'
            ConnectionUri     = $ConnectionUri
            ErrorAction       = 'Stop'
        }
        if ($PSBoundParameters['Credential']) {
            $sessionParams.Add('Credential', $Credential)
        }

        # Create a session object.
        Write-Verbose -Message 'Creating a new session for psremoting...'
        $session = New-PSSession @sessionParams
    
        # import the session object
        Write-Verbose -Message 'Importing the session...'
        Import-PSSession -AllowClobber $session -DisableNameChecking

        # Return the session object

        $session

    } catch { $_.Exception.Message }
}