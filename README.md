# Indent

Indent text. Requires Powershell 5.1+, which should be built into Windows.

> [!NOTE]
> Read the comment in the source file (Indent.psm1) for documentation.

## Installation

It is recommended that you run the following first to allow scripts to be run:

```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Or if you want this to apply to every user, execute below in an administrator
Powershell instance:

```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### Install as a module

This is considered a legacy method, but is compatible with all environments.

To skip confirmation prompts for all future installations:

```ps1
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
```

Then,

```ps1
Install-Module -Name Indent # user installation
# or
Install-Module -Name Indent -Scope AllUsers # system installation; needs elevation
```

To update the module:

```ps1
Update-Module -Name Indent
```

### Install as a resource

This method is faster and more modern, but requires Powershell 7.4+.

To skip confirmation prompts for all future installations:

```ps1
Set-PSResourceRepository -Name PSGallery -Trusted
```

Then,

```ps1
Install-PSResource -Name Indent # user installation
# or
Install-PSResource -Name Indent -Scope AllUsers # system installation; needs elevation
```

To update the resource:

```ps1
Update-PSResource -Name Indent
```

## Usage

```ps1
Import-Module -Name Indent # Make the Indent function and IndentFilter filter available
Write-Output @"
w  
   
x
 y

z z 
"@ > a.txt
Get-Content a.txt | Indent -Count 3 -TrimInput > b.txt
# write each whitespace-only line in a.txt as an empty line and each other line indented by
# three spaces into b.txt
Get-Content b.txt | IndentFilter > a.txt
# Indent each non-empty line in b.txt by two spaces and output into a.txt
Get-Content b.txt # literal output below
#   w
#
#   x
#    y
#
#   z z
Get-Content a.txt # literal output below
#     w
#
#     x
#      y
#
#     z z
```
