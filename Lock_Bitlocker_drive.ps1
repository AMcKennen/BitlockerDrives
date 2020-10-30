#<#
param([switch]$Elevated)
function Read_Admin_Status {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Read_Admin_Status) -eq $false)  {
if ($elevated)
{
# could not elevate, quit
}
else {
Start-Process powershell.exe -Verb RunAs -ArgumentList (' -ExecutionPolicy Bypass -noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
exit
}

#   _   _   _   _     _   _   _   _     _   _   _   _  
#  / \ / \ / \ / \   / \ / \ / \ / \   / \ / \ / \ / \ 
# ( X | A | M | L ) ( C | O | D | E ) ( H | E | R | E )
#  \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ 

$inputXML = @"
<Window x:Class="BitlockWPF.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:BitlockWPF"
        mc:Ignorable="d"
        Title="Bitlocker" Height="175" Width="424" WindowStyle="ToolWindow" MinWidth="500" MinHeight="200">
    <Grid Margin="10,10,10,10">
        <Grid.RowDefinitions>
            <RowDefinition Height="2*"/>
            <RowDefinition/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="2*"/>
        </Grid.ColumnDefinitions>
        <DataGrid x:Name="DataGrid" Grid.Column="1"/>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="3*"/>
                <RowDefinition/>
            </Grid.RowDefinitions>
            <PasswordBox x:Name="PasswordBox" HorizontalAlignment="Stretch" Grid.Row="1" VerticalAlignment="Stretch" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" Margin="10,2,10,2"/>
            <Viewbox>
                <Label x:Name="Label_Lock" Content="" FontFamily="Webdings"/>
            </Viewbox>
        </Grid>
        <Button x:Name="Button_LockUnlock" Content="Lock / Unlock drive" HorizontalAlignment="Stretch" Grid.Row="1" VerticalAlignment="Stretch" IsCancel="True" Margin="10,10,10,10"/>
        <Grid Grid.Column="1" Grid.Row="1">
            <Grid.ColumnDefinitions>
                <ColumnDefinition/>
                <ColumnDefinition/>
            </Grid.ColumnDefinitions>
            <Button x:Name="Button_OpenDriveLocation" Content="Open drive location" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="10,10,10,10"/>
            <Button x:Name="Button_Refresh" Content="Refresh" Grid.Column="1" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Margin="10,10,10,10"/>
        </Grid>

    </Grid>
</Window>
"@

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[xml]$XAML = $inputXML
#Read XAML

    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{#if it broke some other way :D
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        }

#   _   _   _   _   _     _   _   _   _     _   _   _   _   _   _   _     _   _     _   _   _   _   _   _   _   _   _   _  
#  / \ / \ / \ / \ / \   / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \   / \ / \   / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ 
# ( S | t | o | r | e ) ( F | o | r | m ) ( O | b | j | e | c | t | s ) ( I | n ) ( P | o | w | e | r | S | h | e | l | l )
#  \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ 

$xaml.SelectNodes("//*[@Name]") | ForEach-Object{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

Get-FormVariables

#____    ____  ___      .______       __       ___      .______    __       _______     _______.
#\   \  /   / /   \     |   _  \     |  |     /   \     |   _  \  |  |     |   ____|   /       |
# \   \/   / /  ^  \    |  |_)  |    |  |    /  ^  \    |  |_)  | |  |     |  |__     |   (----`
#  \      / /  /_\  \   |      /     |  |   /  /_\  \   |   _  <  |  |     |   __|     \   \    
#   \    / /  _____  \  |  |\  \----.|  |  /  _____  \  |  |_)  | |  `----.|  |____.----)   |   
#    \__/ /__/     \__\ | _| `._____||__| /__/     \__\ |______/  |_______||_______|_______/    
                                                                                               

# _______  __    __  .__   __.   ______ .___________. __    ______   .__   __.      _______.
#|   ____||  |  |  | |  \ |  |  /      ||           ||  |  /  __  \  |  \ |  |     /       |
#|  |__   |  |  |  | |   \|  | |  ,----'`---|  |----`|  | |  |  |  | |   \|  |    |   (----`
#|   __|  |  |  |  | |  . `  | |  |         |  |     |  | |  |  |  | |  . `  |     \   \    
#|  |     |  `--'  | |  |\   | |  `----.    |  |     |  | |  `--'  | |  |\   | .----)   |   
#|__|      \______/  |__| \__|  \______|    |__|     |__|  \______/  |__| \__| |_______/    

function Create_Bitlocker_Datatable()
{
    ###Creating a new DataTable###
    $DataTable = New-Object System.Data.DataTable
   
    ##Creating Columns for DataTable##
    $col1 = New-Object System.Data.DataColumn(“ColumnName1”)
    $col2 = New-Object System.Data.DataColumn(“ColumnName2”)
    $col3 = New-Object System.Data.DataColumn(“ColumnName3”)
           
    ###Adding Columns for DataTable###
    $DataTable.columns.Add($col1)
    $DataTable.columns.Add($col2)
    $DataTable.columns.Add($col3)
       
    return ,$DataTable
}
Function ListBitlockerDrive
{
    Begin
    {
        $BitlockerVolumes= Get-BitLockerVolume
        $ColumnBitlockerVolume  = New-Object System.Data.DataColumn("Bitlocker Volume:")
        $ColumnBitlockerRoothPath  = New-Object System.Data.DataColumn("Drive Location:")
        $ColumnBitlockerMountPoint  = New-Object System.Data.DataColumn("Mount Point:")
        $ColumnBitlockerLockStatus  = New-Object System.Data.DataColumn("Status:")
    }
    Process
    {
        $VolumeIndex=0
        $DataTable = [System.Collections.ArrayList]@()
        foreach ($Volume in $BitlockerVolumes) 
        {
            $BitlockerVolumesMountPoint=$Volume.MountPoint
            $BitlockerVolumesMetadataVersion=$Volume.MetadataVersion
            $BitlockerVolumeLockStatus = $Volume.LockStatus
            #An unsigned integer that indicates the metadata version of the volume.
            #0 The operating system is unknown.
            #1 Windows Vista format, meaning that the volume was protected with BitLocker on a computer running Windows Vista.
            #2 Windows 7 format, meaning that the volume was protected with BitLocker on a computer running Windows 7 or the metadata format was upgraded by using the UpgradeVolume method.
            if ($BitlockerVolumesMetadataVersion -ne 0)
            {
                $VolumeIndex++ #Increment the index so with can enumerate the drives found.
                $DriveRootPath=(Get-WmiObject Win32_Volume |Where-Object -Property DeviceID -eq $BitlockerVolumesMountPoint).name # Get rooth location of the drive.
                #Add a row to DataTable

                $row = $dTable.NewRow()
                $row["Bitlocker Volume:"] = $VolumeIndex
                $row["Drive Location:"] = $DriveRootPath
                $row["Mount Point:"] = 
                $row["Status:"] =  
                $dTable.rows.Add($row)

            }

            $DataTable.add($BitlockerVolume)
        }
    }
    End
    {
        $DataTable
    }
}

Function ToggleBitlockerDrive
{
    <#
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )
    #>
    Begin
    {
        $BitlockerVolumes= Get-BitLockerVolume
    }
    Process
    {
        ForEach($Volume in $BitlockerVolumes)
        {
            $ProtectionStatus=$Volume.ProtectionStatus
            $LockStatus=$Volume.LockStatus
            try
            {
                if (($ProtectionStatus -eq "Unknown") -or ($ProtectionStatus -eq "On")) 
                {
                    if ($LockStatus -eq "Unlock") 
                    {
                        #$title    = $BannerLock
                        <#
                        $question = "Lock the drive mount to " +$MountPoint + "?"
                        $choices  = '&Yes', '&No'

                        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
                        if ($decision -eq 0) 
                        {
                            Lock-BitLocker -MountPoint $MountPoint -ForceDismount
                            #$ShowFolder = $true
                        } else 
                        {
                            #$ShowFolder= $false
                        }
                        #>
                    }
                    if ($LockStatus -eq "Locked") 
                    {
                        <#
                        Write-Host $BannerUnlock
                        $SecureString = Read-Host 'Enter Bitlocker Password!' -AsSecureString
                        Unlock-BitLocker -MountPoint $MountPoint -Password $SecureString | Out-Null
                        #$ShowFolder = $false
                        #>
                    }
                }
            }
            catch
            {
                Write-Error -Message "$_ went wrong on $Volume"
            }
        }
    }
    End
    {
    }
}


# ___________    ____  _______ .__   __. .___________.    _______.
#|   ____\   \  /   / |   ____||  \ |  | |           |   /       |
#|  |__   \   \/   /  |  |__   |   \|  | `---|  |----`  |   (----`
#|   __|   \      /   |   __|  |  . `  |     |  |        \   \    
#|  |____   \    /    |  |____ |  |\   |     |  |    .----)   |   
#|_______|   \__/     |_______||__| \__|     |__|    |_______/    
                                                                 
$WPFButton_LockUnlock.Add_Click(
    {

    }
)

$WPFButton_OpenDriveLocation.Add_Click(
    {

    }
)

$WPFButton_Refresh.Add_Click(
    {

        #$WPFDataGrid
        $BitlockerDrives = ListBitlockerDrive
        Write-Host $BitlockerDrives |Format-List
        #$WPFDataGrid.ItemsSource = $BitlockerDrives 

    
    }
)

$Form.ShowDialog()

#LockBitlockerDrive |Out-Null
#explorer "C:\14K16"
#stop-process -Id $PID