Function Convert-ImceaxNdrToX500 {
    <#
    .SYNOPSIS
    Converts the IMCEAX- address in an NDR into an X500 address.

    .DESCRIPTION
    Converts the IMCEAX- address in an NDR into an X500 address.

    .PARAMETER IMCEAX
    The IMCEAX string contained in the NDR

    .INPUTS
    None.  Convert-ImceaxNdrToX500 does not take objects from the pipeline.

    .OUTPUTS
    System.String

    .NOTES
    Raymond Jette

    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    Param( 
        [Parameter(mandatory)]
        [ValidatePattern('IMCEAEX-*')]
        [String]$IMCEAX
    )
    $x500 = $IMCEAX -replace '_','/' -replace '\+20',' ' -replace '\+28','(' `
        -replace '\+29', ')' -replace 'IMCEAEX-','' -replace '@.*','' -replace '\+2E','.' `
        -replace '\+40','@' 

    $x500
}