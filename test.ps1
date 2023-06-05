# Define variables
$SiteServer = "SiteServerName"
$SiteCode = "SiteCode"
$OSName = "Windows 11"

# Connect to Configuration Manager site
$Site = Get-WmiObject -Namespace "root\SMS\Site_$SiteCode" -Class "SMS_ProviderLocation" -ComputerName $SiteServer
$SitePath = $Site.SitePath
Set-Location "$SitePath\"

# Get all packages with active deployments
$Packages = Get-CMPackage | Where-Object {$_.PackageID -in (Get-CMDeployment | Select-Object -ExpandProperty PackageID | Get-Unique)}

# Loop through all packages and their programs
foreach ($Package in $Packages) {
    foreach ($Program in $Package.Programs) {
        # Check if specific OS requirements exist
        if ($Program.SupportedOperatingSystems.Count -gt 0) {
            # Check if Windows 11 requirement already exists
            $windows11Exists = $Program.SupportedOperatingSystems -contains $OSName

            if (!$windows11Exists) {
                # Add Windows 11 as an applicable OS requirement
                $Program.SupportedOperatingSystems.Add($OSName)

                # Save changes to program
                Set-CMProgram -InputObject $Program
                Write-Host "Added Windows 11 as an applicable OS requirement for program $($Program.PackageID)\$($Program.ProgramName)"
            }
        }
    }
}

# Get all applications with active deployments
$Apps = Get-CMApplication | Where-Object {$_.PackageID -in (Get-CMDeployment | Select-Object -ExpandProperty PackageID | Get-Unique)}

# Loop through all applications and their deployment types
foreach ($App in $Apps) {
    foreach ($DT in $App.DeploymentTypes) {
        # Check if specific OS requirements exist
        if ($DT.SupportedOperatingSystems.Count -gt 0) {
            # Check if Windows 11 requirement already exists
            $windows11Exists = $DT.SupportedOperatingSystems -contains $OSName

            if (!$windows11Exists) {
                # Add Windows 11 as an applicable OS requirement
                $DT.SupportedOperatingSystems.Add($OSName)

                # Save changes to Deployment Type
                Set-CMApplicationDeploymentType -InputObject $DT
                Write-Host "Added Windows 11 as an applicable OS requirement for deployment type $($DT.DeploymentTypeName) in application $($App.PackageID)"
            }
        }
    }
}
