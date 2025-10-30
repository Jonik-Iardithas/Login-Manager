# ========== Initialization ===================================

If (!([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`""
        Exit
    }

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()

# ========== Variables ========================================

$FormSize = [System.Drawing.Size]::new(420,240)
$FormBackColor = [System.Drawing.Color]::Honeydew
$FormForeColor = [System.Drawing.Color]::MidnightBlue
$Fonts = [System.Drawing.FontFamily]::Families
$FontIndex = $Fonts.Name.IndexOf('Verdana')
$FontSize = 9
$FontStyle = [System.Drawing.FontStyle]::Regular
$ButtonSize = [System.Drawing.Size]::new(120,28)
$ButtonBackColor = [System.Drawing.Color]::Bisque
$ButtonForeColor = [System.Drawing.Color]::MidnightBlue
$ButtonHoverColor = [System.Drawing.Color]::LightYellow
$TextBoxBackColor = [System.Drawing.Color]::LightGoldenrodYellow
$TextBoxForeColor = [System.Drawing.Color]::RoyalBlue
$Global:Settings = "$env:LOCALAPPDATA\PowerShellTools\Login-Manager\Settings.ini"
$Global:AppDir = "$env:LOCALAPPDATA\PowerShellTools\Login-Manager"
$Global:Archive = "$PSScriptRoot\Login-Manager.zip"
$Global:Icons = "$PSScriptRoot\Login-Manager - Icons_Custom.zip"
$Global:Path = "$env:ProgramFiles\PowerShellTools\Login-Manager"
$Global:Desktop = "$env:USERPROFILE\Desktop\Login-Manager.lnk"
$Global:StartMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\PowerShellTools\Login-Manager\Login-Manager.lnk"
$Global:Uninstall = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\PowerShellTools\Login-Manager\Uninstall (Login-Manager).lnk"

$Global:Content = @(
    "[Paths]"
    ";**Paths to Files and Folders"
    "LoginFile = $Global:AppDir\Logins.json"
    "UserDataFile = $Global:AppDir\UserData.dat"
    "IconFolder = $Global:Path\Icons\"
    [string]::Empty
    "[Options]"
    ";**(Standard or Toolbar)"
    "Layout = Standard"
    "Seconds = 900"
)

$Txt_List = @{
    Form       = "Installer für Login-Manager"
    LabelA0    = "Dieser Installer bereitet das Programm Login-Manager für die Installation vor."
    LabelA1    = "Einstellungen"
    LabelA2    = "Installation erfolgreich abgeschlossen!"
    LabelB     = "Installationsverzeichnis"
    clb_Box    = @("Desktop-Verknüpfung erstellen", "Startmenü-Eintrag erstellen", "Optionale Icons installieren")
    bt_Accept0 = "Fortfahren"
    bt_Accept1 = "Installieren"
    bt_Cancel0 = "Abbruch"
    bt_Cancel1 = "Zurück"
    bt_Exit    = "Beenden"
    Folder     = "Bitte Ordner wählen."
}

$TT_List = @{
    ChangeFolder = "Klicken um Ordner zu wechseln."
}

$MB_List = @{
    Ini_01 = "Konnte Datei {0} nicht finden."
    Ini_02 = "Fehler!"
}

# ========== Functions ========================================

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

# -------------------------------------------------------------

function Create-Shortcut ([string]$Path, [HashTable]$Data, [bool]$RunAs)
    {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($Path)

        ForEach ($k in $Data.Keys)
            {
                $Shortcut.$k = $Data.$k
            }

        $Shortcut.Save()

        If ($RunAs)
            {
                $Bytes = [System.IO.File]::ReadAllBytes($Path)
                $Bytes[21] = $Bytes[21] -bor [System.Convert]::ToByte(100000,2)
                [System.IO.File]::WriteAllBytes($Path, $Bytes)
            }
    }

# ========== Self-Test ========================================

If (!(Test-Path -Path $Global:Archive))
    {
        [System.Windows.Forms.MessageBox]::Show(($MB_List.Ini_01 -f $Global:Archive),$MB_List.Ini_02,0)
        Exit
    }

# ========== Tooltips =========================================

$ht_Data = @{IsBalloon = $true}

Create-Object -Name Tooltip -Type Tooltip -Data $ht_Data

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

$ar_Events = @(
    {Add_Load(
        {
            $this.ActiveControl = $bt_Cancel

            For($i = 0; $i -lt $clb_Box.Items.Count; $i++)
                {
                    $clb_Box.SetItemChecked($i,$true)
                }

            If (!(Test-Path $Global:Icons))
                {
                    $clb_Box.SetItemCheckState(2,[System.Windows.Forms.CheckState]::Indeterminate)
                    $clb_Box.Add_ItemCheck(
                        {
                            If ($_.Index -eq 2)
                                {
                                    $_.NewValue = [System.Windows.Forms.CheckState]::Indeterminate
                                }
                        })
                }
        }
    )}
)

Create-Object -Name Form -Type Form -Data $ht_Data -Events $ar_Events

# ========== Form: LabelA =====================================

$ht_Data = @{
    Left = 20
    Top = 20
    Width = $Form.ClientSize.Width - 40
    Height = 50
    Text = $Txt_List.LabelA0
    Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize + 1), $FontStyle)
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    Visible = $true
}

Create-Object -Name LabelA -Type Label -Data $ht_Data -Control Form

# ========== Form: LabelB =====================================

$ht_Data.Top = 120
$ht_Data.Height = 20
$ht_Data.Text = $Txt_List.LabelB
$ht_Data.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
$ht_Data.Visible = $false

Create-Object -Name LabelB -Type Label -Data $ht_Data -Control Form

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
    Text = $Txt_List.bt_Accept0
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    Cursor = [System.Windows.Forms.Cursors]::Hand
    Visible = $true
}

$ar_Events = @(
    {Add_Click(
        {
            If ($this.Text -eq $Txt_List.bt_Accept0)
                {
                    $LabelA.Text = $Txt_List.LabelA1
                    $LabelA.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize , $FontStyle)
                    $LabelA.Height = 20
                    $clb_Box.Visible = $true
                    $LabelB.Visible = $true
                    $tb_Path.Visible = $true
                    $this.Text = $Txt_List.bt_Accept1
                    $bt_Cancel.Text = $Txt_List.bt_Cancel1
                }
            ElseIf ($this.Text -eq $Txt_List.bt_Accept1)
                {
                    New-Item -Path "$Global:Path\Icons" -ItemType Directory -ErrorAction SilentlyContinue
                    New-Item -Path (Split-Path -Path $Global:Settings -Parent) -ItemType Directory -ErrorAction SilentlyContinue

                    Set-Content -Value $Global:Content -Path $Global:Settings -Force

                    Expand-Archive -Path $Global:Archive -DestinationPath $Global:Path -Force

                    If ($clb_Box.GetItemCheckState(0) -eq [System.Windows.Forms.CheckState]::Checked)
                        {
                            $ht_Data = @{
                                TargetPath = "$PSHOME\powershell.exe"
                                Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Global:Path\Login-Manager.ps1`""
                                WorkingDirectory = $Global:Path
                                IconLocation = "$Global:Path\Icons\Login-Manager.ico"
                            }

                            Create-Shortcut -Path $Global:Desktop -Data $ht_Data -RunAs $true
                        }

                    If ($clb_Box.GetItemCheckState(1) -eq [System.Windows.Forms.CheckState]::Checked)
                        {
                            New-Item -Path (Split-Path -Path $Global:StartMenu -Parent) -ItemType Directory -ErrorAction SilentlyContinue

                            $ht_Data = @{
                                TargetPath = "$PSHOME\powershell.exe"
                                Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Global:Path\Login-Manager.ps1`""
                                WorkingDirectory = $Global:Path
                                IconLocation = "$Global:Path\Icons\Login-Manager.ico"
                            }

                            Create-Shortcut -Path $Global:StartMenu -Data $ht_Data -RunAs $true

                            $ht_Data.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Global:Path\Uninstall.ps1`""
                            $ht_Data.IconLocation = "$env:SystemRoot\System32\imageres.dll,311"

                            Create-Shortcut -Path $Global:Uninstall -Data $ht_Data -RunAs $true
                        }

                    If ($clb_Box.GetItemCheckState(2) -eq [System.Windows.Forms.CheckState]::Checked)
                        {
                            Expand-Archive -Path $Global:Icons -DestinationPath "$Global:Path\Icons" -Force
                        }

                    $LabelA.Text = $Txt_List.LabelA2
                    $LabelA.Height = 50
                    $LabelA.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize + 1) , $FontStyle)                
                    $LabelB.Visible = $false
                    $bt_Accept.Visible = $false
                    $bt_Cancel.Visible = $false
                    $clb_Box.Visible = $false
                    $tb_Path.Visible = $false
                    $bt_Exit.Visible = $true
                }
        }
    )}
)

Create-Object -Name bt_Accept -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# ========== Form: Cancel-Button ==============================

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSize.Width - 20
$ht_Data.Text = $Txt_List.bt_Cancel0

$ar_Events = @(
    {Add_Click(
        {
            If ($this.Text -eq $Txt_List.bt_Cancel0)
                {
                    $Form.Close()
                }
            ElseIf ($this.Text -eq $Txt_List.bt_Cancel1)
                {
                    $LabelA.Text = $Txt_List.LabelA0
                    $LabelA.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize + 1) , $FontStyle)
                    $LabelA.Height = 50
                    $clb_Box.Visible = $false
                    $LabelB.Visible = $false
                    $tb_Path.Visible = $false
                    $bt_Accept.Text = $Txt_List.bt_Accept0
                    $this.Text = $Txt_List.bt_Cancel0
                }
        }
    )}
)

Create-Object -Name bt_Cancel -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# ========== Form: Exit-Button ================================

$ht_Data.Left = $Form.ClientSize.Width / 2 - $ButtonSize.Width / 2
$ht_Data.Text = $Txt_List.bt_Exit
$ht_Data.Visible = $false

$ar_Events = @({Add_Click({$Form.Close()})})

Create-Object -Name bt_Exit -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# ========== Form: CheckedListBox =============================

$ht_Data = @{
    Left = 40
    Top = 50
    Width = $Form.ClientSize.Width - 80
    Height = 60
    BackColor = $FormBackColor
    ForeColor = $TextBoxForeColor
    Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize - 1), $FontStyle)
    BorderStyle = [System.Windows.Forms.BorderStyle]::None
    CheckOnClick = $true
    Visible = $false
}

$ar_Events = @({Items.AddRange($Txt_List.clb_Box)})

Create-Object -Name clb_Box -Type CheckedListBox -Data $ht_Data -Events $ar_Events -Control Form

# ========== Form: TextBoxes ==================================

$ht_Data = @{
    Left = 20
    Top = 150
    Width = $Form.ClientSize.Width - 40
    Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
    Text = $Global:Path
    BackColor = $TextBoxBackColor
    ForeColor = $TextBoxForeColor
    Cursor = [System.Windows.Forms.Cursors]::Hand
    BorderStyle = [System.Windows.Forms.BorderStyle]::None
    ReadOnly = $true
    Visible = $false
}

$ar_Events = @(
    {Add_MouseHover({$Tooltip.SetToolTip($this,$TT_List.ChangeFolder)})}
    {Add_Click(
        {
            $Folder = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
            $Folder.Description = $Txt_List.Folder
            $Folder.RootFolder = 'MyComputer'

            If ($Folder.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $Global:Path = $Folder.SelectedPath
                    $this.Text = $Global:Path
                    $Global:Content = @(
                        "[Paths]"
                        ";**Paths to Files and Folders"
                        "LoginFile = $Global:AppDir\Logins.json"
                        "UserDataFile = $Global:AppDir\UserData.dat"
                        "IconFolder = $Global:Path\Icons\"
                        [string]::Empty
                        "[Options]"
                        ";**(Standard or Toolbar)"
                        "Layout = Standard"
                        "Seconds = 900"
                    )
                }
        }
    )}
)

Create-Object -Name tb_Path -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# ========== Start ============================================

$Form.ShowDialog()