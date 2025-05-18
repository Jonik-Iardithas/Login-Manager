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
$Global:Settings = "$env:LOCALAPPDATA\PowerShellTools\Login-Manager"
$Global:Path = "$PSScriptRoot\Login-Manager.ps1"
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

$MB_list = @{
    Ini_01 = "Konnte Datei {0} nicht finden."
    Ini_02 = "Fehler!"
}

# ========== Self-Test ========================================

If (!(Test-Path -Path $Global:Path))
    {
        [System.Windows.Forms.MessageBox]::Show(($MB_list.Ini_01 -f $Global:Path),$MB_list.Ini_02,0)
        Exit
    }

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

# ========== Form: Label ======================================

$Label = New-Object -TypeName System.Windows.Forms.Label
$Label.Left = 20
$Label.Top = 20
$Label.Width = $Form.ClientSize.Width - 40
$Label.Height = 50
$Label.Text = $Txt_List.Label0
$Label.Font = New-Object -TypeName System.Drawing.Font($Fonts[$FontIndex].Name, ($FontSize + 1), $FontStyle)
$Label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

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
$bt_Accept.Text = $Txt_List.bt_Accept
$bt_Accept.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$bt_Accept.Cursor = [System.Windows.Forms.Cursors]::Hand
$bt_Accept.Add_Click(
    {
        If (Test-Path -Path $Global:Settings)
            {
                Remove-Item -Path $Global:Settings -Recurse -Force
                $Parent = Split-Path -Path $Global:Settings -Parent
                If (!(Get-Item -Path $Parent).GetFileSystemInfos())
                    {
                        Remove-Item -Path $Parent -Recurse -Force
                    }
            }

        If (Test-Path -Path $Global:Path)
            {
                $Parent = Split-Path -Path $Global:Path -Parent
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
$bt_Cancel.Text = $Txt_List.bt_Cancel
$bt_Cancel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$bt_Cancel.Cursor = [System.Windows.Forms.Cursors]::Hand
$bt_Cancel.Add_Click(
    {
        $Form.Close()
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

# ========== Add-Controls =====================================

$Form.Controls.AddRange(@($Label, $bt_Accept, $bt_Cancel, $bt_Exit))

# ========== Start ============================================

$Form.ShowDialog()