function Indent {
    <#
    .SYNOPSIS
        Indents each line of a string or text input.
    .DESCRIPTION
        The Indent function adds the specified indentation to every line in a multi-line string.
        It processes input from the pipeline and supports custom indent strings and counts.
        Empty lines can be optionally indented or left as-is.
    .PARAMETER s
        The string to indent. Accepts pipeline input and can be empty.
    .PARAMETER Count
        The number of indent units to add to each line; default 2. Must be positive.
    .PARAMETER Indent
        The string to use as one indent unit. Default is a single space " ".
        Can be any string (e.g., "`t" for tabs, "  " for two spaces, ">" for arrows).
    .PARAMETER IndentEmptyLines
        If specified, empty lines will also receive indentation.
        By default, empty lines are returned as-is without indentation.
    .PARAMETER TrimInput
        If specified, leading and trailing whitespace is removed from each input string
        before processing.
    .EXAMPLE
        # indent inputs with a single tab character after trimming whitespace from the right of each
        "xy", " yz", "", "zx  " | Indent -Count 1 -Indent "	" -TrimInput
        
        # output (literal):
        #	xy
        #	 yz
        #
        #	zx
    .INPUTS
        System.String. You can (and most likely will) pipe strings to this function.
    .OUTPUTS
        System.String. Returns indented string lines.
    .LINK
        https://github.com/jonathandung/Indent
    .LINK
        https://www.powershellgallery.com/packages/Indent
    .LINK
        https://jonathandung.github.io/Indent
    .NOTES        
        This function uses System.IO.StringReader for efficient line-by-line processing.
        Each line is processed individually to handle large strings efficiently.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][AllowEmptyString()][string]$s,
        [Parameter(Position = 1)][ValidateRange(1, [int]::MaxValue)][int]$Count = 2,
        [Parameter()][ValidateNotNullOrEmpty()][string]$Indent = " ",
        [Parameter()][switch]$IndentEmptyLines,
        [Parameter()][switch]$TrimInput
    )
    begin {$i = $Indent * $Count}
    process {
        if ($TrimInput) {$s = $s.TrimEnd()}
        if ($s -eq "") {
            if ($IndentEmptyLines) {$i}
            return
        }
        $r = [System.IO.StringReader]::new($s)
        while ($null -ne ($l = $r.ReadLine())) {
            if ($IndentEmptyLines -or $l -ne "") {"$i$l"}
        }
    }
}
filter IndentFilter {
    <#
    .SYNOPSIS
        Indents each line of the pipeline input by two spaces.
    .DESCRIPTION
        This filter version is faster than the function version, but only applies to the above call pattern.
    .EXAMPLE
        echo "1`n2`n3" | IndentFilter
        # is equivalent to:
        echo "1`n2`n3" | Indent
    .LINK
        https://github.com/jonathandung/Indent
    .LINK
        https://www.powershellgallery.com/packages/Indent
    .LINK
        https://jonathandung.github.io/Indent
    #>
    if ($_ -eq "") {""} else {"  $_"}
}