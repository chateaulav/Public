<#
.Synopsis
   Source an OpenStack OpenRC file for use with your current PowerShell session.
.DESCRIPTION
   This script allows you to source an OpenRC file that can be downloaded from the 
   OpenStack Horizon Console.
.PARAMETER LiteralPath
   The OpenRC file you downloaded from the OpenStack dashboard.
.EXAMPLE
   Set-Source -Path project-openrc.sh
   Set-Source project-openrc.sh

   Remove-Source
.LINK
   https://github.com/Chateau-Lav/Public/OpenStack
#>

$ErrorActionPreference = 'SilentlyContinue'
function Set-Source() {
Param(
   [Parameter(Mandatory=$true)]
   [string]$Path
   )
Try {
   if (!($Path)) {
      Write-Host "Please specify an Openstack OpenRC file" -ForegroundColor Red
   }
   Else {
      $variables = ((Select-String -Path $($Path) -Pattern "export OS_(\w.*=)").Matches.Value).Replace("export ","").Replace("=","")

      foreach($var in $variables) {
         [Environment]::SetEnvironmentVariable( $var, $NULL, $([EnvironmentVariableTarget]::Process))
      }

      foreach($var in $variables) {
            $value = ((Select-String -Path $Path -Pattern "export $var") -split "=")[1].replace("`"","")
            [Environment]::SetEnvironmentVariable( $var, $value, $([EnvironmentVariableTarget]::Process))
      }
      
      Write-Host "Please enter your OpenStack Password for project $($env:OS_PROJECT_NAME) as user $($env:OS_USERNAME):"
      $securedValue = Read-Host -AsSecureString
      $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedValue)
      $OS_PASSWORD_INPUT = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
      [Environment]::SetEnvironmentVariable( "OS_PASSWORD", $OS_PASSWORD_INPUT, $([EnvironmentVariableTarget]::Process))
      }
}
Catch {
   Write-Host "There was an Error processing the RC File" -ForegroundColor Red
}
}

function Remove-Source() {
   $variables = (Get-ChildItem env:OS_*).Name

   foreach($var in $variables) {
      [Environment]::SetEnvironmentVariable( $var, $NULL, $([EnvironmentVariableTarget]::Process))
   }
}
