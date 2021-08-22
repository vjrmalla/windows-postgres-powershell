<powershell>
<#
.SYNOPSIS
	This script installs pgAdmin and psql for postgreSQL 13.4.
#>
#region function Write-Log
function Write-Log
{
    [CmdletBinding()]
    Param (
		[string]$Message,
        [string]$LogFilePath
    )
    [datetime]$DateTimeNow = Get-Date;
    [string]$LogTime = $DateTimeNow.ToString('HH\:mm\:ss.fff');
    [string]$LogDate = $DateTimeNow.ToString('MM-dd-yyyy');
    [string]$DateTime = $LogDate + $LogTime;
    $DateTime + ' ' + $Message | Out-File -FilePath $LogFilePath -Append -NoClobber -Force -Encoding 'UTF8' -ErrorAction 'Stop';
}
#endregion
[string]$installerPath = "C:\temp\postgresql";
[string]$pgInstallPath="$env:ProgramFiles\PostgreSQL\13";
[string]$LogFilePath = "$installerPath\postgres_installation.log";
Write-Log -Message 'Creating a directory for PostgreSQL software' -LogFilePath $LogFilePath;
New-Item -ItemType Directory -Force -Path $installerPath;
Write-Log -Message 'PostgreSQL download started' -LogFilePath $LogFilePath;
# download pg installer
Invoke-WebRequest http://get.enterprisedb.com/postgresql/postgresql-13.4-1-windows-x64.exe -OutFile $installerPath\postgresql-13.4-1.exe;
Write-Log -Message 'PostgreSQL download completed' -LogFilePath $LogFilePath;
Write-Log -Message 'PostgreSQL installation started' -LogFilePath $LogFilePath;
try {
    # Installing pg installer
    Write-Host "Installing PostgreSQL";
    $process = Start-Process $installerPath\postgresql-13.4-1.exe -ArgumentList "--mode unattended", "--unattendedmodeui none", "--enable-components pgAdmin,commandlinetools", "--disable-components server,stackbuilder", "--prefix `"$pgInstallPath`"" -PassThru -Wait;
    [string]$CurrentEnvPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine);
    # Add postgreSQL bin in PATH
    Write-Host $process.ExitCode
    if ($process.ExitCode -eq 0)
    {
        Write-Log -Message 'Installation completed' -LogFilePath $LogFilePath;
        Remove-Item -path "$installerPath\postgresql-13.4-1.exe";
        if ($CurrentEnvPath -notlike "*$pgInstallPath\bin*")
        {
            [Environment]::SetEnvironmentVariable(
            "Path",
            [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";"+ "$pgInstallPath\bin",
            [EnvironmentVariableTarget]::Machine)
        }
    }
    else
    {
        Write-Log -Message 'Installation not completed. Please investigate.' -LogFilePath $LogFilePath;
    }
}
catch
{
    Write-Error $_.Exception.Message;
    break;
}
Write-Log -Message 'Installation completed' -LogFilePath $LogFilePath;
Write-Host "PostgreSQL installation completed";
</powershell>