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


# Import the SCCM module
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

# Set the site code and server
$SiteCode = "<YourSiteCode>"
$SiteServer = "<YourSiteServer>"

# Connect to the SCCM site
cd "X:\"
Set-Location "$SiteCode`:"
$ProviderMachine = Get-Item ($SiteCode + ':')

# Get all programs with active deployments
$programs = Get-CMProgram | Where-Object { $_.PackageID -ne $null }
$deployments = @()

foreach ($program in $programs) {
    $deployments += Get-CMDeployment -PackageID $program.PackageID | Where-Object { $_.PackageID -ne $null }
}

# Add Windows 11 as a supported operating system if not already set
foreach ($deployment in $deployments) {
    $program = $programs | Where-Object { $_.PackageID -eq $deployment.PackageID }

    $programProperties = $ProviderMachine.GetChildItems("SMS_Program.PackageID='$($program.PackageID)'")

    # Check if the program has any supported operating systems
    if ($programProperties.SupportedOperatingSystems -eq $null) {
        # Add Windows 11 as a supported operating system
        $programProperties.SupportedOperatingSystems = "Windows 11"
        $programProperties.Put()
        Write-Output "Added Windows 11 support to Program: $($program.Name)"
    } else {
        # Check if Windows 11 is already listed as a supported operating system
        $supportedOperatingSystems = $programProperties.SupportedOperatingSystems -split ";"
        if ($supportedOperatingSystems -notcontains "Windows 11") {
            # Add Windows 11 as a supported operating system
            $programProperties.SupportedOperatingSystems += ";Windows 11"
            $programProperties.Put()
            Write-Output "Added Windows 11 support to Program: $($program.Name)"
        }
    }
}
