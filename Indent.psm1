using namespace System.Text.RegularExpressions
function Indent {
    <#
    .SYNOPSIS
        Indents each line of a string or text input.
    .DESCRIPTION
        The Indent advanced function adds the specified indentation to every line in a
        possibly multiline string.
        It processes input from the pipeline and supports custom indent strings.
        Empty lines can be optionally indented, but are kept by default.
    .PARAMETER s
        The string to indent. Accepts pipeline input. Can be empty.
    .PARAMETER Count
        The number of indent units to add to each line; default 2. Must be positive.
    .PARAMETER Indent
        The string to use as one indent unit. Default is a single space " ".
        Can be any string (e.g., "`t" for tabs, "  " for two spaces, ">" for arrows).
    .PARAMETER RegexThreshold
        The length threshold for using regular expression processing. Default 16384.
        If the input string is shorter than this threshold, regex replacement is used;
        otherwise, line-by-line processing is used to avoid memory overhead.
    .PARAMETER IndentEmptyLines
        If specified, empty lines will also receive indentation.
        By default, empty lines are outputted as is.
    .PARAMETER TrimInput
        If specified, trailing whitespace is removed from each input string before
        processing.
    .EXAMPLE
        "xy", " yz", "", "zx  `nz" | Indent -Count 1 -Indent "	" -TrimInput
        # indent inputs with a single tab character after trimming whitespace from the
        # right of each (`n in the last string is a newline character)
        # literal output below:
        #	xy
        #	 yz
        #
        #	zx
        #	z
    .INPUTS
        System.String. You can (and most likely will) pipe strings to this function.
    .OUTPUTS
        System.String. Returns indented string lines.
    .LINK
        https://github.com/jonathandung/Indent
    .LINK
        https://www.powershellgallery.com/packages/Indent/1.3.1
    .LINK
        https://jonathandung.github.io/Indent
    .NOTES        
        This function makes use of System.IO.StringReader to achieve efficient
        line-by-line processing and avoid memory overhead.
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName
        )][AllowEmptyString()][string]$s,
        [Parameter(Position = 1)][ValidateRange(1, [int]::MaxValue)][int]$Count = 2,
        [ValidateRange(1, [int]::MaxValue)][int]$RegexThreshold = 16384,
        [ValidateNotNullOrEmpty()][string]$Indent = " ",
        [switch]$IndentEmptyLines,
        [switch]$TrimInput
    )
    begin {
        $i = $Indent * $Count
        if ($IndentEmptyLines) {$p, $e = '^', $i} else {$p, $e = '^(?=.)', ""}
        $p = [Regex]::new($p, [RegexOptions]::Compiled -bor [RegexOptions]::Multiline)
    }
    process {
        if ($TrimInput) {$s = $s.TrimEnd()}
        if ("" -eq $s) {return $e}
        if ($s.Length -lt $RegexThreshold) {return $p.Replace($s, $i)}
        if ($IndentEmptyLines) {Stream $s | ForEach-Object {"$i$_"}}
        else {Stream $s | ForEach-Object {if ($_ -eq "") {""} else {"$i$_"}}}
    }
}
function Stream {
    # private helper
    param([string]$s)
    $r = [System.IO.StringReader]::new($s)
    while ($null -ne ($l = $r.ReadLine())) {$l}
}
filter IndentFilter {
    <#
    .SYNOPSIS
        Indents each pipeline input by two spaces as if it were a single line.
    .DESCRIPTION
        This filter version is faster than the function version, but only applies to
        the above call pattern.
        Unlike Indent, it only applies the indentation to the first line and does not
        split multiline strings into individual lines automatically.
        Thus, it is only useful for Cmdlets that stream lines, which are still
        numerous.
    .EXAMPLE
        "1", "2", "3" | Indent
        # is equivalent to:
        "1", "2", "3" | IndentFilter
        # both of which output (literal except pounds):
        #  1
        #  2
        #  3
    .LINK
        https://github.com/jonathandung/Indent
    .LINK
        https://www.powershellgallery.com/packages/Indent/1.3.1
    .LINK
        https://jonathandung.github.io/Indent
    #>
    if ($_ -eq "") {""} else {"  $_"}
}
function IndentLines {
    <#
    .SYNOPSIS
        Indents each line of a string by two spaces, maintaining blank lines.
    .DESCRIPTION
        This function indents each line of the input string by two spaces. It is faster
        but less flexible than Indent, and slower but more flexible than IndentFilter,
        which treats even multiline strings as individual lines.
    .EXAMPLE
        IndentLines "1`n2`n3"
        # outputs:
        #  1
        #  2
        #  3
    .LINK
        https://github.com/jonathandung/Indent
    .LINK
        https://www.powershellgallery.com/packages/Indent/1.3.1
    .LINK
        https://jonathandung.github.io/Indent
    .NOTES        
        This function makes use of System.IO.StringReader to achieve efficient
        line-by-line processing and avoid memory overhead.
    #>
    param([string]$s)
    Stream $s | IndentFilter
}
