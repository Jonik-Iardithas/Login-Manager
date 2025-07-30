# ========== Initialization ===================================

If (!([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`""
        Exit
    }

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Drawing.FontFamily]::Families | ForEach-Object {$Fonts += @($_)}

# ========== Variables ========================================

$FormSize = [System.Drawing.Size]::new(420,240)
$FormBackColor = [System.Drawing.Color]::Honeydew
$FormForeColor = [System.Drawing.Color]::MidnightBlue
$FontIndex = $Fonts.Name.IndexOf('Verdana')
$FontSize = 9
$FontStyle = [System.Drawing.FontStyle]::Regular
$ButtonSize = [System.Drawing.Size]::new(120,28)
$ButtonBackColor = [System.Drawing.Color]::Bisque
$ButtonForeColor = [System.Drawing.Color]::MidnightBlue
$ButtonHoverColor = [System.Drawing.Color]::LightYellow
$Global:Settings = "$env:LOCALAPPDATA\PowerShellTools\Login-Manager\Settings.ini"
$Global:Desktop = "$env:USERPROFILE\Desktop\Login-Manager.lnk"
$Global:StartMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\PowerShellTools\Login-Manager"

$Txt_List = @{
    Form      = "Uninstaller für Login-Manager"
    Label0    = "Dieser Uninstaller entfernt das Programm Login-Manager und seine Komponenten."
    Label1    = "Deinstallation erfolgreich abgeschlossen!"
    bt_Accept = "Fortfahren"
    bt_Cancel = "Abbruch"
    bt_Exit   = "Beenden"
}

$MB_List = @{
    Ini_01 = "Konnte Datei {0} nicht finden."
    Ini_02 = "Fehler!"
}

# ========== Functions ========================================

function Initialize-Me ([string]$FilePath)
    {
        If (!(Test-Path -Path $FilePath))
            {
                [System.Windows.Forms.MessageBox]::Show(($MB_List.Ini_01 -f $FilePath),$MB_List.Ini_02,0)
                Exit
            }

        $Data = [array](Get-Content -Path $FilePath)

        ForEach ($i in $Data)
            {
                $ht_Result += @{$i.Split("=")[0].Trim() = $i.Split("=")[-1].Trim()}
            }

        return $ht_Result
    }

# -------------------------------------------------------------

function Create-Object ([string]$Name, [string]$Type, [HashTable]$Data, [array]$Events, [string]$Control)
    {
        New-Variable -Name $Name -Value (New-Object -TypeName System.Windows.Forms.$Type) -Scope Global -Force

        ForEach ($k in $Data.Keys)
            {
                Invoke-Expression -Command ("`$$Name.$k = " + {$Data.$k})
            }

        ForEach ($i in $Events)
            {
                Invoke-Expression -Command ("`$$Name.$i")
            }

        If ($Control)
            {
                Invoke-Expression -Command ("`$$Control.Controls.Add(`$$Name)")
            }
    }

# ========== Code =============================================

$Paths = Initialize-Me -FilePath $Global:Settings

# ========== Form =============================================

$ht_Data = @{
            ClientSize = $FormSize
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Text = $Txt_List.Form
            Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSHOME\powershell.exe")
            BackColor = $FormBackColor
            ForeColor = $FormForeColor
            FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
            MaximizeBox = $false
            MinimizeBox = $false
            }

$ar_Events = @({Add_Load({$this.ActiveControl = $bt_Cancel})})

Create-Object -Name Form -Type Form -Data $ht_Data -Events $ar_Events

# ========== Form: Label ======================================

$ht_Data = @{
            Left = 20
            Top = 20
            Width = $Form.ClientSize.Width - 40
            Height = 50
            Text = $Txt_List.Label0
            Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize + 1), $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            }

Create-Object -Name Label -Type Label -Data $ht_Data -Control Form

# ========== Form: Accept-Button ==============================

$ht_Data = @{
            Left = 20
            Top = $Form.ClientSize.Height - $ButtonSize.Height - 10
            Size = $ButtonSize
            FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            'FlatAppearance.MouseOverBackColor' = $ButtonHoverColor
            BackColor = $ButtonBackColor
            ForeColor = $ButtonForeColor
            Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
            Text = $Txt_List.bt_Accept
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            Cursor = [System.Windows.Forms.Cursors]::Hand
            Visible = $true
            }

$ar_Events = @(
                {Add_Click(
                    {
                        If (Test-Path -Path $Global:Settings)
                            {
                                $Parent = Split-Path -Path $Global:Settings -Parent
                                Remove-Item -Path $Parent -Recurse -Force
                                $Parent = Split-Path -Path $Parent -Parent
                                If (!(Get-Item -Path $Parent).GetFileSystemInfos())
                                    {
                                        Remove-Item -Path $Parent -Recurse -Force
                                    }
                            }

                        If (Test-Path -Path $Paths.IconFolder)
                            {
                                $Parent = Split-Path -Path $Paths.IconFolder -Parent
                                Remove-Item -Path $Parent -Recurse -Force
                                $Parent = Split-Path -Path $Parent -Parent
                                If (!(Get-Item -Path $Parent).GetFileSystemInfos())
                                    {
                                        Remove-Item -Path $Parent -Recurse -Force
                                    }
                            }

                        If (Test-Path -Path $Global:Desktop)
                            {
                                Remove-Item -Path $Global:Desktop -Force
                            }

                        If (Test-Path -Path $Global:StartMenu)
                            {
                                Remove-Item -Path $Global:StartMenu -Recurse -Force
                                $Parent = Split-Path -Path $Global:StartMenu -Parent
                                If (!(Get-Item -Path $Parent).GetFileSystemInfos())
                                    {
                                        Remove-Item -Path $Parent -Recurse -Force
                                    }
                            }

                        $Label.Text = $Txt_List.Label1
                        $bt_Accept.Visible = $false
                        $bt_Cancel.Visible = $false
                        $bt_Exit.Visible = $true
                    }
                )}
              )

Create-Object -Name bt_Accept -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# ========== Form: Cancel-Button ==============================

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSize.Width - 20
$ht_Data.Text = $Txt_List.bt_Cancel

$ar_Events = @({Add_Click({$Form.Close()})})

Create-Object -Name bt_Cancel -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# ========== Form: Exit-Button ================================

$ht_Data.Left = $Form.ClientSize.Width / 2 - $ButtonSize.Width / 2
$ht_Data.Text = $Txt_List.bt_Exit
$ht_Data.Visible = $false

Create-Object -Name bt_Exit -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# ========== Start ============================================

$Form.ShowDialog()