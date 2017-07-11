[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [string]$ServerName,

    [Parameter(Mandatory=$true)]
    [string]$SqlUser,

    [Parameter(Mandatory=$true)]
    [string]$SqlPassword
)

begin
{
    $installPath = "$pwd\Install"
    if (!(Test-Path $installPath))
    {
        New-Item $installPath -ItemType Directory > $null

        $sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $targetNugetExe = "$installPath\nuget.exe"
        Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
        Set-Alias nuget $targetNugetExe -Scope Global

        Write-Host "Downloading Microsoft Azure SQL Database: Elastic Database Client Library"
        nuget install Microsoft.Azure.SqlDatabase.ElasticScale.Client -Source https://api.nuget.org/v3/index.json -OutputDirectory packages > $null
    }

    $assemblies = Get-ChildItem -Path $installPath -Include "*.dll" -Recurse

    foreach($assembly in $assemblies)
    {
        Write-Host "Adding the library $($assembly.Name)"
        Add-Type -Path $assembly.FullName
    }
}

process
{
    $shardMapDatabase = "ElasticScaleDatabase_ShardMapManager"

    $shardMapConnectionString = "Server=$ServerName;Database=$shardMapDatabase;User Id=$SqlUser;Password=$SqlPassword;"

    $createShardMapDatabaseSql = @"
IF NOT EXISTS (SELECT * FROM sys.databases WHERE [name] = 'ElasticScaleDatabase_ShardMapManager')
    CREATE DATABASE [ElasticScaleDatabase_ShardMapManager]
"@
    
    Invoke-Sqlcmd -ServerInstance $ServerName -Username $SqlUser -Password $SqlPassword -Query $createShardMapDatabaseSql

    $lazyLoad = [Microsoft.Azure.SqlDatabase.ElasticScale.ShardManagement.ShardMapManagerLoadPolicy]::Lazy
    $shardMapManager = $null

    $shardMapManagerExists = [Microsoft.Azure.SqlDatabase.ElasticScale.ShardManagement.ShardMapManagerFactory]::TryGetSqlShardMapManager($shardMapConnectionString, $lazyLoad, [ref] $shardMapManager)

    if(!$shardMapManagerExists)
    {
        Write-Host "Does not exist!"
    }
}

end
{

}