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

# ========== Constants ========================================

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
$Global:Content = @("LoginFile = $Global:AppDir\Logins.json", "UserDataFile = $Global:AppDir\UserData.dat", "IconFolder = $Global:Path\Icons\")

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

$MB_list = @{
    Ini_01 = "Konnte Datei {0} nicht finden."
    Ini_02 = "Fehler!"
}

# ========== Self-Test ========================================

If (!(Test-Path -Path $Global:Archive))
    {
        [System.Windows.Forms.MessageBox]::Show(($MB_list.Ini_01 -f $Global:Archive),$MB_list.Ini_02,0)
        Exit
    }

# ========== Tooltips =========================================

$Tooltip = New-Object -TypeName System.Windows.Forms.ToolTip
$Tooltip.IsBalloon = $true

# ========== Form =============================================

$Form = New-Object -TypeName System.Windows.Forms.Form
$Form.ClientSize = $FormSize
$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Form.Text = $Txt_List.Form
$Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSHOME\powershell.exe")
$Form.BackColor = $FormBackColor
$Form.ForeColor = $FormForeColor
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.Add_Load({$this.ActiveControl = $bt_Cancel})

# ========== Form: LabelA =====================================

$LabelA = New-Object -TypeName System.Windows.Forms.Label
$LabelA.Left = 20
$LabelA.Top = 20
$LabelA.Width = $Form.ClientSize.Width - 40
$LabelA.Height = 50
$LabelA.Text = $Txt_List.LabelA0
$LabelA.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize + 1), $FontStyle)
$LabelA.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

# ========== Form: LabelB =====================================

$LabelB = New-Object -TypeName System.Windows.Forms.Label
$LabelB.Left = 20
$LabelB.Width = $Form.ClientSize.Width - 40
$LabelB.Height = 20
$LabelB.Text = $Txt_List.LabelB
$LabelB.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
$LabelB.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$LabelB.Visible = $false

# ========== Accept-Button ====================================

$bt_Accept = New-Object -TypeName System.Windows.Forms.Button
$bt_Accept.Left = 20
$bt_Accept.Top = $Form.ClientSize.Height - $ButtonSize.Height - 10
$bt_Accept.Size = $ButtonSize
$bt_Accept.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$bt_Accept.FlatAppearance.MouseOverBackColor = $ButtonHoverColor
$bt_Accept.BackColor = $ButtonBackColor
$bt_Accept.ForeColor = $ButtonForeColor
$bt_Accept.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
$bt_Accept.Text = $Txt_List.bt_Accept0
$bt_Accept.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$bt_Accept.Cursor = [System.Windows.Forms.Cursors]::Hand
$bt_Accept.Add_Click(
    {
        If ($this.Text -eq $Txt_List.bt_Accept0)
            {
                $LabelA.Text = $Txt_List.LabelA1
                $LabelA.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize , $FontStyle)
                $LabelA.Height = 20
                $clb_Box.Top = $LabelA.Bounds.Bottom + 10
                $clb_Box.Visible = $true
                $LabelB.Top = $clb_Box.Bounds.Bottom + 10
                $LabelB.Visible = $true
                $tb_Path.Top = $LabelB.Bounds.Bottom + 10
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
                        $WshShell = New-Object -ComObject WScript.Shell
                        $Shortcut = $WshShell.CreateShortcut($Global:Desktop)
                        $Shortcut.TargetPath = "$PSHOME\powershell.exe"
                        $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Global:Path\Login-Manager.ps1`""
                        $Shortcut.WorkingDirectory = $Global:Path
                        $Shortcut.IconLocation = "$Global:Path\Icons\Login-Manager.ico"
                        $Shortcut.Save()
                        $Bytes = [System.IO.File]::ReadAllBytes($Global:Desktop)
                        $Bytes[21] = $bytes[21] -bor [System.Convert]::ToByte(100000,2)
                        [System.IO.File]::WriteAllBytes($Global:Desktop, $Bytes)
                    }

                If ($clb_Box.GetItemCheckState(1) -eq [System.Windows.Forms.CheckState]::Checked)
                    {
                        New-Item -Path (Split-Path -Path $Global:StartMenu -Parent) -ItemType Directory -ErrorAction SilentlyContinue

                        $WshShell = New-Object -ComObject WScript.Shell
                        $Shortcut = $WshShell.CreateShortcut($Global:StartMenu)
                        $Shortcut.TargetPath = "$PSHOME\powershell.exe"
                        $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Global:Path\Login-Manager.ps1`""
                        $Shortcut.WorkingDirectory = $Global:Path
                        $Shortcut.IconLocation = "$Global:Path\Icons\Login-Manager.ico"
                        $Shortcut.Save()
                        $Bytes = [System.IO.File]::ReadAllBytes($Global:StartMenu)
                        $Bytes[21] = $bytes[21] -bor [System.Convert]::ToByte(100000,2)
                        [System.IO.File]::WriteAllBytes($Global:StartMenu, $Bytes)

                        $Shortcut = $WshShell.CreateShortcut($Global:Uninstall)
                        $Shortcut.TargetPath = "$PSHOME\powershell.exe"
                        $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Global:Path\Uninstall.ps1`""
                        $Shortcut.WorkingDirectory = $Global:Path
                        $Shortcut.IconLocation = "$env:SystemRoot\System32\imageres.dll,311"
                        $Shortcut.Save()
                        $Bytes = [System.IO.File]::ReadAllBytes($Global:Uninstall)
                        $Bytes[21] = $bytes[21] -bor [System.Convert]::ToByte(100000,2)
                        [System.IO.File]::WriteAllBytes($Global:Uninstall, $Bytes)
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
)

# ========== Cancel-Button ====================================

$bt_Cancel = New-Object -TypeName System.Windows.Forms.Button
$bt_Cancel.Left = $Form.ClientSize.Width - $ButtonSize.Width - 20
$bt_Cancel.Top = $Form.ClientSize.Height - $ButtonSize.Height - 10
$bt_Cancel.Size = $ButtonSize
$bt_Cancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$bt_Cancel.FlatAppearance.MouseOverBackColor = $ButtonHoverColor
$bt_Cancel.BackColor = $ButtonBackColor
$bt_Cancel.ForeColor = $ButtonForeColor
$bt_Cancel.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
$bt_Cancel.Text = $Txt_List.bt_Cancel0
$bt_Cancel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$bt_Cancel.Cursor = [System.Windows.Forms.Cursors]::Hand
$bt_Cancel.Add_Click(
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
)

# ========== Exit-Button ======================================

$bt_Exit = New-Object -TypeName System.Windows.Forms.Button
$bt_Exit.Left = $Form.ClientSize.Width / 2 - $ButtonSize.Width / 2
$bt_Exit.Top = $Form.ClientSize.Height - $ButtonSize.Height - 10
$bt_Exit.Size = $ButtonSize
$bt_Exit.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$bt_Exit.FlatAppearance.MouseOverBackColor = $ButtonHoverColor
$bt_Exit.BackColor = $ButtonBackColor
$bt_Exit.ForeColor = $ButtonForeColor
$bt_Exit.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
$bt_Exit.Text = $Txt_List.bt_Exit
$bt_Exit.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$bt_Exit.Cursor = [System.Windows.Forms.Cursors]::Hand
$bt_Exit.Visible = $false
$bt_Exit.Add_Click(
    {
        $Form.Close()
    }
)

# ========== Form: CheckedListBox =============================

$clb_Box = New-Object -TypeName System.Windows.Forms.CheckedListBox
$clb_Box.Left = 40
$clb_Box.Width = $Form.ClientSize.Width - 80
$clb_Box.Height = 60
$clb_Box.BackColor = $FormBackColor
$clb_Box.ForeColor = $TextBoxForeColor
$clb_Box.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize - 1), $FontStyle)
$clb_Box.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$clb_Box.CheckOnClick = $true
$clb_Box.Visible = $false
$clb_Box.Items.AddRange($Txt_List.clb_Box)

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

# ========== Form: TextBoxes ==================================

$tb_Path = New-Object -TypeName System.Windows.Forms.TextBox
$tb_Path.Left = 20
$tb_Path.Width = $Form.ClientSize.Width - 40
$tb_Path.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, $FontSize, $FontStyle)
$tb_Path.Text = $Global:Path
$tb_Path.BackColor = $TextBoxBackColor
$tb_Path.ForeColor = $TextBoxForeColor
$tb_Path.Cursor = [System.Windows.Forms.Cursors]::Hand
$tb_Path.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$tb_Path.ReadOnly = $true
$tb_Path.Visible = $false
$tb_Path.Add_MouseHover(
    {
        $Tooltip.SetToolTip($this,$TT_List.ChangeFolder)
    }
)
$tb_Path.Add_Click(
    {
        $Folder = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
        $Folder.Description = $Txt_List.Folder
        $Folder.RootFolder = 'MyComputer'

        If ($Folder.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
            {
                $Global:Path = $Folder.SelectedPath
                $this.Text = $Global:Path
                $Global:Content = @("LoginFile = $Global:AppDir\Logins.json", "UserDataFile = $Global:AppDir\UserData.dat", "IconFolder = $Global:Path\Icons\")
            }
    }
)

# ========== Add-Controls =====================================

$Form.Controls.AddRange(@($LabelA, $LabelB, $bt_Accept, $bt_Cancel, $bt_Exit, $clb_Box, $tb_Path))

# ========== Start ============================================

$Form.ShowDialog()