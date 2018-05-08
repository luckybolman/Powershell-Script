Function Get-MailboxDatabaseDiskSpaceInfo {
    <#
    .SYNOPSIS
    Returns information about database disk space.

    .DESCRIPTION
    Returns information about database disk space.
    
    .EXAMPLE
    Get-MailboxDatabaseDiskSpaceInfo -Database db01

    Name    EdbSize    WhiteSpace
    ----    -------    ----------
    db01    204.88     23.91
    
    .EXAMPLE
    (Get-MailboxDatabaseDiskSpaceInfo -Database (Get-MailboxDatabase)).ToGB()

    Name    EdbSize    WhiteSpace
    ----    -------    ----------
    db00    189.44     6.02
    db01    204.88     23.91
    db02    201.83     1.03
    db04    203.01     2.04

    .NOTES
    Raymond Jette

    #>
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias('Name','DatabaseName')]
        [String[]]$Database 
    )
    BEGIN {

        if (-not (Get-Command -Name Get-Mailbox -ErrorAction 'SilentlyContinue')) {
            throw 'Exchange cmdlets are not available.'
        }

        $defaultDisplaySet = 'Name','EdbSize','WhiteSpace'
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

    }
    PROCESS {

        Write-Verbose -Message 'Looping through databases in Database'
        ForEach ($db in $Database) {
            Write-Verbose -Message "Current database: $db"
            $dbinfo = Get-MailboxDatabase $db -Status
            [int64]$EdbSize = "$([regex]::match($dbinfo.DatabaseSize, '(\()(.*)(\))').Groups[2].Value)" -Replace ' bytes', ''
            [int64]$WhiteSpace = "$([regex]::match($dbinfo.AvailableNewMailboxSpace, '(\()(.*)(\))').Groups[2].Value)" -Replace ' bytes', ''

            $return = [PSCustomObject]@{
                PSTypeName = 'DatabaseSpace'
                Name = $db
                EdbSize = $EdbSize
                WhiteSpace = $WhiteSpace
                EdbPath = $dbinfo.EdbFilePath
                LogPath = $dbinfo.LogFolderPath
            }
            $sizeKB = {
                $this.EdbSize =  [math]::round($this.EdbSize / 1KB,2)
                $this.WhiteSpace = [math]::round($this.WhiteSpace / 1KB,2)
                $this
            }
            $sizeMB = {
                $this.EdbSize = [math]::round($this.EdbSize / 1MB)
                $this.WhiteSpace = [math]::round($this.WhiteSpace / 1MB)
                $this
            }
            $sizeGB = {
                $this.EdbSize = [math]::round($this.EdbSize / 1GB,2)
                $this.WhiteSpace = [math]::round($this.WhiteSpace / 1GB,2)
                $this
            }
            $return | Add-Member -Membertype ScriptMethod -Name ToKB -Value $sizeKB
            $return | Add-Member -MemberType ScriptMethod -Name ToMB -Value $sizeMB
            $return | Add-Member -MemberType Scriptmethod -Name ToGB -Value $sizeGB
            $return | Add-Member MemberSet PSStandardMembers $PSStandardMembers -PassThru
        }
    }
} # Get-MailboxDatabaseDiskSpaceInfo