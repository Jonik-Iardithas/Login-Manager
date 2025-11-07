# =============================================================
# ========== Initialization ===================================
# =============================================================

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()

# =============================================================
# ========== Constants & Variables ============================
# =============================================================

$FontName = "Verdana"
$FontSize = 9
$FontStyle = [System.Drawing.FontStyle]::Regular
$FormColor = [System.Drawing.Color]::LightSteelBlue
$TextBoxColor = [System.Drawing.Color]::Ivory
$ButtonSizeA = [System.Drawing.Size]::new(80,40)
$ButtonSizeB = [System.Drawing.Size]::new(100,30)
$ButtonSizeC = [System.Drawing.Size]::new(20,20)
$ButtonSizeD = [System.Drawing.Size]::new(32,26)
$ButtonColorA = [System.Drawing.Color]::LightSteelBlue
$ButtonColorB = [System.Drawing.Color]::LightCyan
$ButtonColorC = [System.Drawing.Color]::LightSteelBlue
$ButtonColorD = [System.Drawing.Color]::SlateGray
$PanelColor = [System.Drawing.Color]::SteelBlue
$DivideColor = [System.Drawing.Color]::LightBlue
$ToolbarColor = [System.Drawing.Color]::SlateGray
$ToolbarIconsNum = 6
$ToolbarPadding = 28
$ToolbarBorderCorrection = 2
$SettingsFile = "$env:LOCALAPPDATA\PowerShellTools\Login-Manager\Settings.ini"
$Global:Chars = 16
$Global:ID = $null
$Global:Result = $null
$Global:Index = $null
$Global:MPW = $null
$SyncHash = [HashTable]::Synchronized(@{})
$RSList = @("Timer")

$Msg_List = @{
    Start          = "Login-Manager gestartet."
    NoLogins       = "Datei `"Logins.json`" konnte nicht gefunden werden und wurde angelegt."
    NoUserData     = "Datei `"UserData.dat`" konnte nicht gefunden werden und wurde angelegt."
    NewRecord      = "Neuer Datensatz eingetragen."
    FailRecord     = "Eintrag fehlgeschlagen. Datensatz unvollständig."
    NewEdit        = "Datensatz geändert."
    FailEdit       = "Änderung fehlgeschlagen. Angaben unvollständig."
    CancelEdit     = "Änderung abgebrochen."
    NewFind        = "Suche erfolgreich."
    NoFind         = "Suche erfolglos."
    NewDelete      = "Datensatz gelöscht."
    CancelDelete   = "Löschvorgang abgebrochen."
    CopyClipboard  = "Inhalt in die Zwischenablage kopiert."
    EnterMPW       = "Master-Passwort eingetragen."
    WrongMPW       = "Master-Passwort inkorrekt."
    ShortMPW       = "Das Master-Passwort muss mindestens 16 Zeichen betragen."
    EnterChangeMPW = "Master-Passwort erfolgreich geändert!"
    WrongChangeMPW = "Altes Master-Passwort inkorrekt."
    ShortChangeMPW = "Die Master-Passwörter müssen mindestens 16 Zeichen betragen."
    CreatePW       = "Passwort generiert."
    Addendum       = "Datensätze gefunden."
}

$Txt_List = @{
    Form              = "Login-Manager"
    Edit_Form         = "Änderungsbestätigung"
    Del_Form          = "Löschbestätigung"
    MPW_Form          = "Master-Passwort eingeben"
    MPW_Change_Form   = "Master-Passwort ändern"
    PW_Generator_Form = "Passwort-Generator"
    Metadata_Form     = "Metadaten"
    lb_URL            = "URL"
    lb_UserName       = "Benutzername"
    lb_Email          = "Email-Adresse"
    lb_Password       = "Passwort"
    lb_Metadata       = "Metadaten"
    lb_Events         = "Ereignisse"
    lb_MPW            = "Master-Passwort"
    lb_MPW_Change_Old = "Altes Master-Passwort"
    lb_MPW_Change_New = "Neues Master-Passwort"
    lb_Edit           = "Datensatz wird überschrieben. Fortfahren?"
    lb_Del            = "Datensatz wird unwiderruflich gelöscht. Fortfahren?"
    lb_Config         = "Konfiguration"
    lb_Exclusions     = "Ausschlüsse"
    lb_Chars          = "{0} Zeichen"
    tb_r_URL          = "[URL]"
    tb_r_UserName     = "[Benutzername]"
    tb_r_Email        = "[Email-Adresse]"
    tb_r_Password     = "[Passwort]"
    tb_r_Metadata     = "[Metadaten]"
    bt_Edit_OK        = "Ja"
    bt_Edit_Cancel    = "Nein"
    bt_Del_OK         = "Ja"
    bt_Del_Cancel     = "Nein"
    bt_PW_Create      = "Erstellen"
    bt_PW_Close       = "Schließen"
    bt_Metadata_Close = "Schließen"
    bt_Chars_Minus    = "{0} Zeichen"
    bt_Chars_Plus     = "{0} Zeichen"
    CMI_Logins        = "Datei `"Logins.json`" öffnen"
    CMI_UserData      = "Datei `"UserData.dat`" öffnen"
    CMI_Settings      = "Datei `"Settings.ini`" öffnen"
}

$TT_List = @{
    Copy  = "Klicken um Inhalt in die Zwischenablage zu kopieren."
    Reset = "Klicken um Timer zurückzusetzen."
}

$MB_List = @{
    Ini_01 = "Konnte Datei {0} nicht finden."
    Ini_02 = "Login-Manager: Fehler"
}

$Icons_List = @{
    Add             = "$env:windir\system32\imageres.dll,246,32,32"
    Edit            = "$env:windir\system32\imageres.dll,89,32,32"
    Find            = "$env:windir\system32\wmploc.dll,20,32,32"
    Prev            = "$env:windir\system32\wmploc.dll,153,32,32"
    Del             = "$env:windir\system32\shell32.dll,31,32,32"
    Next            = "$env:windir\system32\wmploc.dll,152,32,32"
    Enter           = "$env:windir\system32\imageres.dll,101,32,32"
    Plain           = "$env:windir\system32\imageres.dll,79,32,32"
    Close           = "$env:windir\system32\imageres.dll,93,32,32"
    PW_Generator    = "$env:windir\system32\imageres.dll,299,32,32"
    MPW             = "$env:windir\system32\imageres.dll,54,32,32"
    MPW_Change      = "$env:windir\system32\imageres.dll,320,32,32"
    Open            = "$env:windir\system32\imageres.dll,203,32,32"
    Metadata        = "$env:windir\system32\imageres.dll,287,32,32"
    Exit            = "$env:windir\system32\imageres.dll,259,32,32"
    Open_TB         = "$env:windir\system32\imageres.dll,203,20,20"
    MPW_TB          = "$env:windir\system32\imageres.dll,54,20,20"
    PW_Generator_TB = "$env:windir\system32\imageres.dll,299,20,20"
    Metadata_TB     = "$env:windir\system32\imageres.dll,287,20,20"
    MPW_Change_TB   = "$env:windir\system32\imageres.dll,320,20,20"
    Reset_TB        = "$env:windir\system32\shell32.dll,239,20,20"
    CMI_Open        = "$env:windir\system32\shell32.dll,70,20,20"
}

# =============================================================
# ========== Win32Functions ===================================
# =============================================================

$Member = @'
    [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern int ExtractIconEx(string lpszFile, int nIconIndex, out IntPtr phiconLarge, out IntPtr phiconSmall, int nIcons);

    [DllImport("User32.dll", EntryPoint = "DestroyIcon")]
    public static extern bool DestroyIcon(IntPtr hIcon);
'@

Add-Type -MemberDefinition $Member -Name WinAPI -Namespace Win32Functions

# =============================================================
# ========== Functions ========================================
# =============================================================

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
                If ($i.Contains("="))
                    {
                        $ht_Result += @{$i.Split("=")[0].Trim() = $i.Split("=")[-1].Trim()}
                    }
            }

        return $ht_Result
    }

# -------------------------------------------------------------

function Simulate-Timer ([HashTable]$SyncHash)
    {
        $Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Name = "Timer"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("SyncHash", $SyncHash)
        
        $PSInstance = [System.Management.Automation.PowerShell]::Create().AddScript(
            {
                While ($SyncHash.Counter.TotalSeconds -ge 0) {
                        $SyncHash.lb_Counter.Text = "{0:D2}:{1:D2}" -f $SyncHash.Counter.Minutes, $SyncHash.Counter.Seconds
                        $SyncHash.Counter = $SyncHash.Counter.Subtract([System.TimeSpan]::FromSeconds(1))
                        Start-Sleep -Seconds 1
                    }

                $SyncHash.Keys | Where-Object {$SyncHash.$_.GetType().Name -in "Form"} | ForEach-Object {If ($SyncHash.$_.Visible) {$SyncHash.$_.Activate(); $SyncHash.$_.Close()}}

                (Get-Process -Id $PID).CloseMainWindow()
            })

        $PSInstance.Runspace = $Runspace
        $PSInstance.BeginInvoke()
    }

# -------------------------------------------------------------

function Crypt-Text ([string]$Mode, [string]$Format, [string]$Text, [string]$Key)
    {
        $SHA = New-Object -TypeName System.Security.Cryptography.SHA256Managed
        $AES = New-Object -TypeName System.Security.Cryptography.AesManaged
        $AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AES.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
        $AES.BlockSize = 128
        $AES.KeySize = 256
        $AES.Key = $SHA.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))

        If ($Mode -in 'Encrypt')
            {
                If ($Format -in 'Text')
                    {
                        $NonZeroEnd = [char](Get-Random -InputObject @(33..126))
                        $Plain = [System.Text.Encoding]::UTF8.GetBytes($Text + $NonZeroEnd)
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        $NonZeroEnd = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::new((Get-Random -InputObject (@(0..255) | Where-Object {$_ % 16}))).ToString()
                        $Plain = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::Parse($Text + $NonZeroEnd).Value
                    }

                $Encryptor = $AES.CreateEncryptor()
                $Encrypted = $Encryptor.TransformFinalBlock($Plain, 0, $Plain.Length)
                $Encrypted = $AES.IV + $Encrypted

                If ($Format -in 'Text')
                    {
                        $Output = [System.Convert]::ToBase64String($Encrypted)
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        $Output = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::new($Encrypted).ToString()
                    }
            }
        ElseIf ($Mode -in 'Decrypt')
            {
                If ($Format -in 'Text')
                    {
                        $Cipher = [System.Convert]::FromBase64String($Text)
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        $Cipher = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::Parse($Text).Value
                    }

                $AES.IV = $Cipher[0..15]
                $Decryptor = $AES.CreateDecryptor()
                $Decrypted = $Decryptor.TransformFinalBlock($Cipher, 16, $Cipher.Length - 16)

                If ($Format -in 'Text')
                    {
                        $Output = [System.Text.Encoding]::UTF8.GetString($Decrypted).TrimEnd([char]0)
                        $Output = $Output.Substring(0,($Output.Length - 1))
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        $Output = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::new($Decrypted).ToString().TrimEnd("0")
                        $Output = $Output.Substring(0,($Output.Length - 2))
                    }
            }

        $SHA.Dispose()
        $AES.Dispose()

        return $Output
    }

# -------------------------------------------------------------

function Verify-MPW ([string]$PW)
    {
        $SHA = New-Object -TypeName System.Security.Cryptography.SHA256Managed

        $Data = Get-Content -Path $Ini.UserDataFile -Raw

        If ($Data)
            {
                $UserData = Crypt-Text -Mode Decrypt -Format Hex -Text $Data -Key $PW
                $PWByteArray = $SHA.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($PW))
                $Sum = ($PWByteArray | Measure-Object -Sum).Sum
                $PWHexString = [System.BitConverter]::ToString($PWByteArray).Replace("-",[string]::Empty)
                $Pos = $Sum % ($UserData.Length - $PWHexString.Length)
            }
        Else
            {
                $Randomizer = [System.Security.Cryptography.RandomNumberGenerator]::Create()
                $Buffer = [byte[]]::new((Get-Random -InputObject @(512..1024)))
                $Randomizer.GetBytes($Buffer)
                $UserData = [System.BitConverter]::ToString($Buffer).Replace("-",[string]::Empty)
                $PWByteArray = $SHA.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($PW))
                $Sum = ($PWByteArray | Measure-Object -Sum).Sum
                $PWHexString = [System.BitConverter]::ToString($PWByteArray).Replace("-",[string]::Empty)
                $Pos = $Sum % $UserData.Length
                $UserData = $UserData.Insert($Pos,$PWHexString)
                $Data = Crypt-Text -Mode Encrypt -Format Hex -Text $UserData -Key $PW
                Set-Content -Value $Data -Path $Ini.UserDataFile -NoNewline
                $Randomizer.Dispose()
            }

        $SHA.Dispose()

        return $UserData.IndexOf($PWHexString) -eq $Pos
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

# -------------------------------------------------------------

function Create-Icons ([string]$Name, [HashTable]$List, [string]$Path)
    {
        $L_Ptr = [System.IntPtr]::new(0)
        $S_Ptr = [System.IntPtr]::new(0)

        ForEach($Key in $List.Keys)
            {
                $Size = [System.Drawing.Size]::new($List[$Key].ToString().Split(",")[-2], $List[$Key].ToString().Split(",")[-1])

                If (Test-Path -Path ($Path + "Icon_" + $Key.ToString() + ".ico"))
                    {
                        $Image = [System.Drawing.Image]::FromFile($Path + "Icon_" + $Key.ToString() + ".ico")
                    }
                ElseIf (Test-Path -Path ($Path + "Icon_" + $Key.ToString() + ".png"))
                    {
                        $Image = [System.Drawing.Image]::FromFile($Path + "Icon_" + $Key.ToString() + ".png")
                    }
                ElseIf (Test-Path -Path $List[$Key].ToString().Split(",")[0])
                    {
                        [Win32Functions.WinAPI]::ExtractIconEx($List[$Key].ToString().Split(",")[0], $List[$Key].ToString().Split(",")[1], [ref]$L_Ptr, [ref]$S_Ptr, 1) | Out-Null

                        If ($Size.Width -le 20 -and $Size.Height -le 20)
                            {
                                $Image = ([System.Drawing.Icon]::FromHandle($S_Ptr)).Clone()
                            }
                        Else
                            {
                                $Image = ([System.Drawing.Icon]::FromHandle($L_Ptr)).Clone()
                            }

                        [Win32Functions.WinApi]::DestroyIcon($L_Ptr) | Out-Null
                        [Win32Functions.WinApi]::DestroyIcon($S_Ptr) | Out-Null
                    }
                Else
                    {
                        $Image = [System.Drawing.Bitmap]::new(40,40)
                        $Pen = [System.Drawing.Pen]::new([System.Drawing.Color]::Red,5)
                        $Rect = [System.Drawing.Rectangle]::new(6,6,28,28)
                        $Point1 = [System.Drawing.Point]::new(5,35)
                        $Point2 = [System.Drawing.Point]::new(35,5)
                        $Graphics = [System.Drawing.Graphics]::FromImage($Image)
                        $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                        $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                        $Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                        $Graphics.DrawEllipse($Pen, $Rect)
                        $Graphics.DrawLine($Pen, $Point1, $Point2)
                    }

                $Icon = [System.Drawing.Bitmap]::new($Size.Width, $Size.Height)
                $Graphics = [System.Drawing.Graphics]::FromImage($Icon)
                $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $Graphics.DrawImage($Image, [System.Drawing.Rectangle]::new(0, 0, $Icon.Width, $Icon.Height))
                $ht_Icons += @{$Key = $Icon}
            }

        New-Variable -Name $Name -Value $ht_Icons -Scope Global -Force
    }

# -------------------------------------------------------------

function Write-Msg ([object]$TextBox, [bool]$NL, [bool]$Time, [string]$Msg, [string]$Addd)
    {
        If ($NL)
            {
                $NLTime = [System.Environment]::NewLine
            }

        If ($Time)
            {
                $NLTime += [string](Get-Date -Format "HH:mm:ss") + " "
            }

        If ($Addd)
            {
                $Msg += " " + [string]$Global:Result.Count + " " + $Addd
            }

        $TextBox.AppendText($NLTime + $Msg)
    }

# -------------------------------------------------------------

function Load-Result ([string]$Msg_A, [string]$Msg_B)
    {
        If ($Global:Result)
            {
                If ($Global:Index -eq $Global:Result.Count)
                    {
                        $Global:Index--
                    }

                $Global:ID = $Global:Result[$Global:Index].ID

                $tb_r_URL.Text      = Crypt-Text -Mode Decrypt -Format Text -Text ($Global:Result[$Global:Index].URL)      -Key $Global:MPW
                $tb_r_UserName.Text = Crypt-Text -Mode Decrypt -Format Text -Text ($Global:Result[$Global:Index].UserName) -Key $Global:MPW
                $tb_r_Email.Text    = Crypt-Text -Mode Decrypt -Format Text -Text ($Global:Result[$Global:Index].Email)    -Key $Global:MPW
                $tb_r_Password.Text = $Global:Result[$Global:Index].Password.Substring(0,16)
                $tb_r_Metadata.Text = Crypt-Text -Mode Decrypt -Format Text -Text ($Global:Result[$Global:Index].Metadata) -Key $Global:MPW

                $lb_Page.Text       = [string](($Global:Index + 1), "/", $Global:Result.Count)

                $tb_r_Password.UseSystemPasswordChar = $true

                $tb_r_URL.Enabled      = $true
                $tb_r_UserName.Enabled = $true
                $tb_r_Email.Enabled    = $true
                $tb_r_Password.Enabled = $true
                $tb_r_Metadata.Enabled = $true

                $bt_Del.Enabled        = $true

                If ($Global:Index -eq 0)
                    {
                        $bt_Prev.Enabled = $false

                        If ($Global:Result.Count -gt 1)
                            {
                                $bt_Next.Enabled = $true
                            }
                        Else
                            {
                                $bt_Next.Enabled = $false
                            }
                    }
                ElseIf ($Global:Index -eq ($Global:Result.Count - 1))
                    {
                        $bt_Prev.Enabled = $true
                        $bt_Next.Enabled = $false
                    }
                Else
                    {
                        $bt_Prev.Enabled = $true
                        $bt_Next.Enabled = $true
                    }

                If ($Msg_A)
                    {
                        Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_A -Addd $Msg_List.Addendum
                    }
            }
        Else
            {
                $Global:ID    = $null
                $Global:Index = $null

                $tb_r_URL.Text      = $Txt_List.tb_r_URL
                $tb_r_UserName.Text = $Txt_List.tb_r_UserName
                $tb_r_Email.Text    = $Txt_List.tb_r_Email
                $tb_r_Password.Text = $Txt_List.tb_r_Password
                $tb_r_Metadata.Text = $Txt_List.tb_r_Metadata

                $lb_Page.Text       = "- / -"

                $tb_r_Password.UseSystemPasswordChar = $false

                $tb_r_URL.Enabled      = $false
                $tb_r_UserName.Enabled = $false
                $tb_r_Email.Enabled    = $false
                $tb_r_Password.Enabled = $false
                $tb_r_Metadata.Enabled = $false

                $bt_Del.Enabled        = $false
                $bt_Edit.Enabled       = $false
                $bt_Prev.Enabled       = $false
                $bt_Next.Enabled       = $false

                If ($Msg_B)
                    {
                        Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_B -Addd $Msg_List.Addendum
                    }
            }

        $Form.ActiveControl = $null
    }

# -------------------------------------------------------------

function Clear-Boxes ()
    {
        $tb_URL.Clear()
        $tb_UserName.Clear()
        $tb_Email.Clear()
        $tb_Password.Clear()
        $tb_Metadata.Clear()
    }

# =============================================================
# ========== Settings.ini =====================================
# =============================================================

$Ini = Initialize-Me -FilePath $SettingsFile

# -------------------------------------------------------------

$SyncHash.Counter = [System.TimeSpan]::FromSeconds([int]$Ini.Seconds)

# -------------------------------------------------------------

$ht_Data = @{IsBalloon = $true}

Create-Object -Name Tooltip -Type Tooltip -Data $ht_Data

# -------------------------------------------------------------

Create-Icons -Name Icons -List $Icons_List -Path $Ini.IconFolder

# =============================================================
# ========== Form =============================================
# =============================================================

$ht_Data = @{
    ClientSize = [System.Drawing.Size]::new(400,800)
    StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    Icon = $Ini.IconFolder + "Login-Manager.ico"
    Text = $Txt_List.Form
    BackColor = $FormColor
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    KeyPreview = $true
    MaximizeBox = $false
}

$ar_Events = @(
    {Add_Load(
        {
            $this.TopMost = $true
            $this.ClientSize = [System.Drawing.Size]::new(400, ($this.Controls | ForEach-Object {$_.Bottom} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 12)

            Write-Msg -TextBox $tb_Events -NL $false -Time $true -Msg $Msg_List.Start

            If (!(Test-Path -Path $Ini.LoginFile))
                {
                    New-Item -Path $Ini.LoginFile -Force
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoLogins
                }
        }
    )}
    {Add_FormClosing(
        {
            Remove-Variable -Name MPW -Scope Global -Force
            Set-Clipboard -Value $null

            $RS = Get-Runspace -Name $RSList
            ForEach($i in $RS)
                {
                    $i.Dispose()
                    [System.GC]::Collect()
                }
        }
    )}
    {Add_Activated({$this.ActiveControl = $null})}
)

Create-Object -Name Form -Type Form -Data $ht_Data -Events $ar_Events

# =============================================================
# ========== Form: Panels =====================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = 10
    Width = $Form.ClientSize.Width - 20
    Height = 33
    BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    BackColor = $ToolbarColor
    Visible = If ($Ini.Layout -eq "Standard") {$false} ElseIf ($Ini.Layout -eq "Toolbar") {$true} Else {$false}
}

Create-Object -Name pn_Toolbar -Type Panel -Data $ht_Data -Control Form

# =============================================================
# ========== OpenFilesContextMenu =============================
# =============================================================

$ht_Data = @{
    Text = $Txt_List.CMI_Logins
    Image = $Icons.CMI_Open
}

$ar_Events = @(
    {Add_Click(
        {
            If (Test-Path -Path $Ini.LoginFile)
                {
                    Invoke-Item -Path $Ini.LoginFile
                }
        }
    )}
)

Create-Object -Name CMI_Logins -Type ToolStripMenuItem -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$ht_Data.Text = $Txt_List.CMI_Settings

$ar_Events = @(
    {Add_Click(
        {
            If (Test-Path -Path $SettingsFile)
                {
                    Invoke-Item -Path $SettingsFile
                }
        }
    )}
)

Create-Object -Name CMI_Settings -Type ToolStripMenuItem -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$ht_Data.Text = $Txt_List.CMI_UserData

$ar_Events = @(
    {Add_Click(
        {
            If (Test-Path -Path $Ini.UserDataFile)
                {
                    Invoke-Item -Path $Ini.UserDataFile
                }
        }
    )}
)

Create-Object -Name CMI_UserData -Type ToolStripMenuItem -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$ht_Data = @{Cursor = [System.Windows.Forms.Cursors]::Hand}

$ar_Events = @({Items.AddRange(@($CMI_Logins, $CMI_Settings, $CMI_UserData))})

Create-Object -Name OpenFilesContextMenu -Type ContextMenuStrip -Data $ht_Data -Events $ar_Events

# =============================================================
# ========== Form: Buttons ====================================
# =============================================================

$ht_Data = @{
    Left = ($pn_Toolbar.Width - $ToolbarPadding * 2) / ($ToolbarIconsNum - 1) * 0 - $ButtonSizeD.Width / 2 + $ToolbarPadding - $ToolbarBorderCorrection
    Top = 1
    Size = $ButtonSizeD
    Image = $Icons.Open_TB
    ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorD
    FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    'FlatAppearance.BorderSize' = 0
    Cursor = [System.Windows.Forms.Cursors]::Hand
    ContextMenuStrip = $OpenFilesContextMenu
    Visible = If ($Ini.Layout -eq "Standard") {$false} ElseIf ($Ini.Layout -eq "Toolbar") {$true} Else {$false}
}

$ar_Events = @(
    {Add_Click(
        {
            If ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left)
                {
                    $Point = [System.Drawing.Point]::new([System.Windows.Forms.Cursor]::Position.X, [System.Windows.Forms.Cursor]::Position.Y)
                    $this.ContextMenuStrip.Show($this, $this.PointToClient($Point))
                }
        }
    )}
)

Create-Object -Name bt_Open_TB -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Toolbar

# -------------------------------------------------------------

$ht_Data.Left = ($pn_Toolbar.Width - $ToolbarPadding * 2) / ($ToolbarIconsNum - 1) * 1 - $ButtonSizeD.Width / 2 + $ToolbarPadding - $ToolbarBorderCorrection
$ht_Data.Image = $Icons.MPW_TB
$ht_Data.ContextMenuStrip = $null

$ar_Events = @({Add_Click({$MPW_Form.ShowDialog()})})

Create-Object -Name bt_MPW_TB -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Toolbar

# -------------------------------------------------------------

$ht_Data.Left = ($pn_Toolbar.Width - $ToolbarPadding * 2) / ($ToolbarIconsNum - 1) * 2 - $ButtonSizeD.Width / 2 + $ToolbarPadding - $ToolbarBorderCorrection
$ht_Data.Image = $Icons.PW_Generator_TB

$ar_Events = @({Add_Click({$PW_Generator_Form.ShowDialog()})})

Create-Object -Name bt_PW_Generator_TB -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Toolbar

# -------------------------------------------------------------

$ht_Data.Left = ($pn_Toolbar.Width - $ToolbarPadding * 2) / ($ToolbarIconsNum - 1) * 3 - $ButtonSizeD.Width / 2 + $ToolbarPadding - $ToolbarBorderCorrection
$ht_Data.Image = $Icons.Metadata_TB
$ht_Data.Enabled = $false

$ar_Events = @({Add_Click({$Metadata_Form.ShowDialog()})})

Create-Object -Name bt_Metadata_TB -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Toolbar

# -------------------------------------------------------------

$ht_Data.Left = ($pn_Toolbar.Width - $ToolbarPadding * 2) / ($ToolbarIconsNum - 1) * 4 - $ButtonSizeD.Width / 2 + $ToolbarPadding - $ToolbarBorderCorrection
$ht_Data.Image = $Icons.MPW_Change_TB

$ar_Events = @({Add_Click({$MPW_Change_Form.ShowDialog()})})

Create-Object -Name bt_MPW_Change_TB -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Toolbar

# -------------------------------------------------------------

$ht_Data.Left = ($pn_Toolbar.Width - $ToolbarPadding * 2) / ($ToolbarIconsNum - 1) * 5 - $ButtonSizeD.Width / 2 + $ToolbarPadding - $ToolbarBorderCorrection
$ht_Data.Image = $Icons.Reset_TB
$ht_Data.Enabled = $true

$ar_Events = @({Add_Click({$SyncHash.Counter = [System.TimeSpan]::FromSeconds([int]$Ini.Seconds)})})

Create-Object -Name bt_Reset_TB -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Toolbar

# -------------------------------------------------------------

$pn_Toolbar.SendToBack()

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = If ($Ini.Layout -eq "Standard") {10} ElseIf ($Ini.Layout -eq "Toolbar") {$pn_Toolbar.Bottom + 10} Else {10}
    Width = $Form.ClientSize.Width - 20
    Height = 20
    Text = $Txt_List.lb_URL
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
}

Create-Object -Name lb_URL -Type Label -Data $ht_Data -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 50
$ht_Data.Text = $Txt_List.lb_UserName

Create-Object -Name lb_UserName -Type Label -Data $ht_Data -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 50
$ht_Data.Text = $Txt_List.lb_Email

Create-Object -Name lb_Email -Type Label -Data $ht_Data -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 50
$ht_Data.Text = $Txt_List.lb_Password

Create-Object -Name lb_Password -Type Label -Data $ht_Data -Control Form

# =============================================================
# ========== Form: TextBoxes ==================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $lb_URL.Bottom
    Width = $Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::IBeam
    Enabled = $false
    MaxLength = 1024
}

$ar_Events = @(
    {Add_Click({$this.SelectAll()})}
    {Add_Enter({$this.SelectAll()})}
    {Add_TextChanged(
        {
            If ($tb_URL.TextLength -gt 0 -or $tb_UserName.TextLength -gt 0 -or $tb_Email.TextLength -gt 0 -or $tb_Password.TextLength -gt 0)
                {
                    $bt_Add.Enabled = $true
                    $bt_Find.Enabled = $true

                    If ($Global:Result)
                        {
                            $bt_Edit.Enabled = $true
                        }
                    Else
                        {
                            $bt_Edit.Enabled = $false
                        }
                }
            Else
                {
                    $bt_Add.Enabled = $false
                    $bt_Edit.Enabled = $false
                    $bt_Find.Enabled = $false
                }
        }
    )}
    {Add_KeyDown(
        {
            If ($_.KeyCode -eq "Enter")
                {
                    $bt_Find.PerformClick()
                }
        }
    )}
)

Create-Object -Name tb_URL -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 50

Create-Object -Name tb_UserName -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 50

Create-Object -Name tb_Email -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 50

Create-Object -Name tb_Password -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# =============================================================
# ========== Form: Buttons ====================================
# =============================================================

$ht_Data = @{
    Left = 30
    Top = $tb_Password.Bottom + 10
    Size = $ButtonSizeA
    Image = $Icons.Add
    ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorA
    FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    'FlatAppearance.BorderSize' = 0
    Cursor = [System.Windows.Forms.Cursors]::Hand
    Enabled = $false
}

$ar_Events = @(
    {Add_Click(
        {
            If (Test-Path -Path $Ini.LoginFile)
                {
                    If ($tb_Password.TextLength -gt 0 -and ($tb_URL.TextLength -gt 0 -or $tb_UserName.TextLength -gt 0 -or $tb_Email.TextLength -gt 0))
                        {
                            $Data = [array](Get-Content -Path $Ini.LoginFile | ConvertFrom-Json)
                            $Data = [array]($Data | Sort-Object -Property ID)
                            If ($Data.Count -eq 0) {$New_ID = ('{0:d4}' -f 0)}
                            Else {$New_ID = ('{0:d4}' -f ([int]($Data[-1].ID) + 1))}
                            If ($tb_URL.TextLength      -eq 0) {$tb_URL.Text      = "N/A"}
                            If ($tb_UserName.TextLength -eq 0) {$tb_UserName.Text = "N/A"}
                            If ($tb_Email.TextLength    -eq 0) {$tb_Email.Text    = "N/A"}
                            If ($tb_Metadata.TextLength -eq 0) {$tb_Metadata.Text = "N/A"}
                            $Data += @([PSCustomObject]@{
                                ID       = $New_ID
                                URL      = Crypt-Text -Mode Encrypt -Format Text -Text $tb_URL.Text      -Key $Global:MPW
                                UserName = Crypt-Text -Mode Encrypt -Format Text -Text $tb_UserName.Text -Key $Global:MPW
                                Email    = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Email.Text    -Key $Global:MPW
                                Password = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Password.Text -Key $Global:MPW
                                Metadata = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Metadata.Text -Key $Global:MPW
                            })
                            $Data | ConvertTo-Json -depth 1 | Set-Content -Path $Ini.LoginFile
                            Clear-Boxes
                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NewRecord
                        }
                    Else
                        {
                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.FailRecord
                        }
                }
            Else
                {
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoLogins
                }
        }
    )}
)

Create-Object -Name bt_Add -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Image = $Icons.Edit

$ar_Events = @(
    {Add_Click(
        {
            If (Test-Path -Path $Ini.LoginFile)
                {
                    If ($tb_Password.TextLength -gt 0 -and ($tb_URL.TextLength -gt 0 -or $tb_UserName.TextLength -gt 0 -or $tb_Email.TextLength -gt 0))
                        {
                            If ($Edit_Form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
                                {
                                    $Data = [array](Get-Content -Path $Ini.LoginFile | ConvertFrom-Json)
                                    $Data = [array]($Data | Sort-Object -Property ID)
                                    If ($tb_URL.TextLength      -eq 0) {$tb_URL.Text      = "N/A"}
                                    If ($tb_UserName.TextLength -eq 0) {$tb_UserName.Text = "N/A"}
                                    If ($tb_Email.TextLength    -eq 0) {$tb_Email.Text    = "N/A"}
                                    If ($tb_Metadata.TextLength -eq 0) {$tb_Metadata.Text = "N/A"}
                                    $Data[$Data.ID.IndexOf($Global:ID)].URL      = Crypt-Text -Mode Encrypt -Format Text -Text $tb_URL.Text      -Key $Global:MPW
                                    $Data[$Data.ID.IndexOf($Global:ID)].UserName = Crypt-Text -Mode Encrypt -Format Text -Text $tb_UserName.Text -Key $Global:MPW
                                    $Data[$Data.ID.IndexOf($Global:ID)].Email    = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Email.Text    -Key $Global:MPW
                                    $Data[$Data.ID.IndexOf($Global:ID)].Password = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Password.Text -Key $Global:MPW
                                    $Data[$Data.ID.IndexOf($Global:ID)].Metadata = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Metadata.Text -Key $Global:MPW
                                    $Data | ConvertTo-Json -depth 1 | Set-Content -Path $Ini.LoginFile
                                    $Global:Result[$Global:Index].URL      = $Data[$Data.ID.IndexOf($Global:ID)].URL
                                    $Global:Result[$Global:Index].UserName = $Data[$Data.ID.IndexOf($Global:ID)].UserName
                                    $Global:Result[$Global:Index].Email    = $Data[$Data.ID.IndexOf($Global:ID)].Email
                                    $Global:Result[$Global:Index].Password = $Data[$Data.ID.IndexOf($Global:ID)].Password
                                    $Global:Result[$Global:Index].Metadata = $Data[$Data.ID.IndexOf($Global:ID)].Metadata
                                    Load-Result -Msg_A $Msg_List.NewEdit -Msg_B $Msg_List.NewEdit
                                    Clear-Boxes
                                }
                            Else
                                {
                                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CancelEdit
                                }
                        }
                    Else
                        {
                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.FailEdit
                        }
                }
            Else
                {
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoLogins
                }
        }
    )}
)

Create-Object -Name bt_Edit -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
$ht_Data.Image = $Icons.Find

$ar_Events = @(
    {Add_Click(
        {
            If (Test-Path -Path $Ini.LoginFile)
                {
                    $Data = [array](Get-Content -Path $Ini.LoginFile | ConvertFrom-Json)
                    $Data = [array]($Data | Sort-Object -Property ID)

                    For($i = 0; $i -lt $Data.Count; $i++)
                        {
                            $Data[$i].URL      = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].URL      -Key $Global:MPW
                            $Data[$i].UserName = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].UserName -Key $Global:MPW
                            $Data[$i].Email    = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].Email    -Key $Global:MPW
                            $Data[$i].Password = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].Password -Key $Global:MPW
                            $Data[$i].Metadata = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].Metadata -Key $Global:MPW
                        }

                    If ($tb_URL.TextLength      -gt 0) { $Data = [array]($Data | Where-Object {$_.URL      -match [regex]::Escape($tb_URL.Text)     }) }
                    If ($tb_UserName.TextLength -gt 0) { $Data = [array]($Data | Where-Object {$_.UserName -match [regex]::Escape($tb_UserName.Text)}) }
                    If ($tb_Email.TextLength    -gt 0) { $Data = [array]($Data | Where-Object {$_.Email    -match [regex]::Escape($tb_Email.Text)   }) }
                    If ($tb_Password.TextLength -gt 0) { $Data = [array]($Data | Where-Object {$_.Password -match [regex]::Escape($tb_Password.Text)}) }

                    $All = [array](Get-Content -Path $Ini.LoginFile | ConvertFrom-Json)
                    $All = [array]($All | Sort-Object -Property ID)

                    $Global:Result = [array]($All | Where-Object {$_.ID -in $Data.ID})
                    $Global:Index = 0

                    Load-Result -Msg_A $Msg_List.NewFind -Msg_B $Msg_List.NoFind
                    Clear-Boxes
                }
            Else
                {
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoLogins
                }
        }
    )}
)

Create-Object -Name bt_Find -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# =============================================================
# ========== Form: Panels =====================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $bt_Add.Bottom + 10
    Width = $Form.ClientSize.Width - 20
    Height = 140
    BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
}

Create-Object -Name pn_Panel -Type Panel -Data $ht_Data -Control Form

# =============================================================
# ========== Form: TextBoxes ==================================
# =============================================================

$ht_Data = @{
    Left = 20
    Top = $pn_Panel.Top + 10
    Width = $pn_Panel.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::Hand
    Text = $Txt_List.tb_r_URL
    TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
    Enabled = $false
    ReadOnly = $true
}

$ar_Events = @(
    {Add_Click(
        {
            Set-Clipboard -Value $this.Text
            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CopyClipboard
        }
    )}
    {Add_MouseHover(
        {
            $Tooltip.SetToolTip($this,$TT_List.Copy)
        }
    )}
)

Create-Object -Name tb_r_URL -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 30
$ht_Data.Text = $Txt_List.tb_r_UserName

Create-Object -Name tb_r_UserName -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 30
$ht_Data.Text = $Txt_List.tb_r_Email

Create-Object -Name tb_r_Email -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Top += 30
$ht_Data.Text = $Txt_List.tb_r_Password

$ar_Events[0] = {Add_Click(
    {
        Set-Clipboard -Value (Crypt-Text -Mode Decrypt -Format Text -Text $Global:Result[$Global:Index].Password -Key $Global:MPW)
        Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CopyClipboard
    }
)}

Create-Object -Name tb_r_Password -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
    Left = $Form.ClientSize.Width / 2 - 40
    Top = $tb_r_Password.Bottom + 3
    Width = 80
    Height = 26
    Text = "- / -"
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
}

Create-Object -Name lb_Page -Type Label -Data $ht_Data -Control Form

# -------------------------------------------------------------

$pn_Panel.SendToBack()

# =============================================================
# ========== Form: Buttons ====================================
# =============================================================

$ht_Data = @{
    Left = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
    Top = $pn_Panel.Bottom + 15
    Size = $ButtonSizeA
    Image = $Icons.Del
    ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorA
    FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    'FlatAppearance.BorderSize' = 0
    Cursor = [System.Windows.Forms.Cursors]::Hand
    Enabled = $false
}

$ar_Events = @(
    {Add_Click(
        {
            If (Test-Path -Path $Ini.LoginFile)
                {
                    If ($Del_Form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
                        {
                            $Data = [array](Get-Content -Path $Ini.LoginFile | ConvertFrom-Json)
                            $Data = [array]($Data | Sort-Object -Property ID)
                            $Data = [array]($Data | Where-Object {$_.ID -ne $Global:ID})
                            Clear-Content -Path $Ini.LoginFile -Force
                            $Data | ConvertTo-Json -depth 1 | Set-Content -Path $Ini.LoginFile
                            $Global:Result = [array]($Global:Result | Where-Object {$_.ID -ne $Global:ID})

                            Load-Result -Msg_A $Msg_List.NewDelete -Msg_B $Msg_List.NewDelete
                        }
                    Else
                        {
                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CancelDelete
                        }
                }
            Else
                {
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoLogins
                }
        }
    )}
)

Create-Object -Name bt_Del -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = 30
$ht_Data.Image = $Icons.Prev

$ar_Events = @(
    {Add_Click(
        {
            $Global:Index --
            Load-Result
        }
    )}
)

Create-Object -Name bt_Prev -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
$ht_Data.Image = $Icons.Next

$ar_Events = @(
    {Add_Click(
        {
            $Global:Index ++
            Load-Result
        }
    )}
)

Create-Object -Name bt_Next -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Top = $bt_Del.Bottom + 10
$ht_Data.Image = $Icons.MPW
$ht_Data.BackColor = $DivideColor
$ht_Data.Enabled = $true
$ht_Data.Visible = If ($Ini.Layout -eq "Standard") {$true} ElseIf ($Ini.Layout -eq "Toolbar") {$false} Else {$true}

$ar_Events = @({Add_Click({$MPW_Form.ShowDialog()})})

Create-Object -Name bt_MPW -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = 30
$ht_Data.Image = $Icons.PW_Generator

$ar_Events = @({Add_Click({$PW_Generator_Form.ShowDialog()})})

Create-Object -Name bt_PW_Generator -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
$ht_Data.Image = $Icons.MPW_Change
$ht_Data.Enabled = $false

$ar_Events = @({Add_Click({$MPW_Change_Form.ShowDialog()})})

Create-Object -Name bt_MPW_Change -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Top = $bt_MPW.Bottom + 10
$ht_Data.Image = $Icons.Metadata
$ht_Data.BackColor = $ButtonColorA

$ar_Events = @({Add_Click({$Metadata_Form.ShowDialog()})})

Create-Object -Name bt_Metadata -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = 30
$ht_Data.Image = $Icons.Open
$ht_Data.Enabled = $true
$ht_Data.ContextMenuStrip = $OpenFilesContextMenu

$ar_Events = @(
    {Add_Click(
        {
            If ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left)
                {
                    $Point = [System.Drawing.Point]::new([System.Windows.Forms.Cursor]::Position.X, [System.Windows.Forms.Cursor]::Position.Y)
                    $this.ContextMenuStrip.Show($this, $this.PointToClient($Point))
                }
        }
    )}
)

Create-Object -Name bt_Open -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
$ht_Data.Image = $Icons.Exit
$ht_Data.ContextMenuStrip = $null

Create-Object -Name bt_Exit -Type Button -Data $ht_Data -Control Form

# -------------------------------------------------------------

$Form.CancelButton = $bt_Exit

# =============================================================
# ========== Form: Panels =====================================
# =============================================================

$ht_Data = @{
    Left = 0
    Top = $bt_Del.Bottom + 7
    Width = $Form.ClientSize.Width
    Height = $Icons.MPW.Height + 14
    BorderStyle = [System.Windows.Forms.BorderStyle]::None
    BackColor = $DivideColor
    Visible = If ($Ini.Layout -eq "Standard") {$true} ElseIf ($Ini.Layout -eq "Toolbar") {$false} Else {$true}
}

Create-Object -Name pn_Divide -Type Panel -Data $ht_Data -Control Form

# -------------------------------------------------------------

$pn_Divide.SendToBack()

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = If ($Ini.Layout -eq "Standard") {$bt_Metadata.Bottom + 10} ElseIf ($Ini.Layout -eq "Toolbar") {$bt_Del.Bottom + 10} Else {$bt_Metadata.Bottom + 10}
    Width = $Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_Events
    TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
}

Create-Object -Name lb_Events -Type Label -Data $ht_Data -Control Form

# =============================================================
# ========== Form: TextBoxes ==================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $lb_Events.Bottom
    Width = $Form.ClientSize.Width - 20
    Height = 130
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::IBeam
    Multiline = $true
    ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    WordWrap = $true
    ReadOnly = $true
}

Create-Object -Name tb_Events -Type TextBox -Data $ht_Data -Control Form

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
    Width = 120
    Height = 22
    Left = ($Form.ClientSize.Width - 120) / 2
    Top = $tb_Events.Bottom + 10
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, [System.Drawing.FontStyle]::Bold)
    Text = "{0:D2}:{1:D2}" -f $SyncHash.Counter.Minutes, $SyncHash.Counter.Seconds
    ForeColor = [System.Drawing.Color]::Red
    BackColor = [System.Drawing.Color]::White
    BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    Cursor = If ($Ini.Layout -eq "Standard") {[System.Windows.Forms.Cursors]::Hand} ElseIf ($Ini.Layout -eq "Toolbar") {[System.Windows.Forms.Cursors]::Default} Else {[System.Windows.Forms.Cursors]::Hand}
}

$ar_Events = @(
    {Add_Click(
        {
            If ($Ini.Layout -eq "Standard") {$SyncHash.Counter = [System.TimeSpan]::FromSeconds([int]$Ini.Seconds)}
        }
    )}
    {Add_MouseHover(
        {
            If ($Ini.Layout -eq "Standard") {$Tooltip.SetToolTip($this,$TT_List.Reset)}
        }
    )}
)

Create-Object -Name lb_Counter -Type Label -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$SyncHash.lb_Counter = $lb_Counter

# =============================================================
# ========== MPW_Form =========================================
# =============================================================

$ht_Data = @{
    ClientSize = [System.Drawing.Size]::new(400,120)
    StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    Icon = $Ini.IconFolder + "Login-Manager.ico"
    Text = $Txt_List.MPW_Form
    BackColor = $FormColor
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    KeyPreview = $true
    MaximizeBox = $false
    MinimizeBox = $false
    ShowInTaskbar = $false
}

$ar_Events = @(
    {Add_Load(
        {
            $Form.TopMost = $false
            $this.TopMost = $true
            $this.ActiveControl = $tb_MPW

            If (!(Test-Path -Path $Ini.UserDataFile))
                {
                    New-Item -Path $Ini.UserDataFile -Force
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoUserData
                }
        }
    )}
    {Add_FormClosed(
        {
            $tb_MPW.Text = [string]::Empty
            $tb_MPW.UseSystemPasswordChar = $true
            $Form.TopMost = $true
        }
    )}
)

Create-Object -Name MPW_Form -Type Form -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$SyncHash.MPW_Form = $MPW_Form

# =============================================================
# ========== MPW_Form: Labels =================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = 10
    Width = $MPW_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_MPW
    TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
}

Create-Object -Name lb_MPW -Type Label -Data $ht_Data -Control MPW_Form

# =============================================================
# ========== MPW_Form: TextBoxes ==============================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $lb_MPW.Bottom
    Width = $MPW_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::IBeam
    UseSystemPasswordChar = $true
    MaxLength = 256
}

$ar_Events = @(
    {Add_KeyDown(
        {
            If ($_.KeyCode -eq "Enter")
                {
                    $bt_MPW_Enter.PerformClick()
                }
            ElseIf ($_.KeyCode -eq "Escape")
                {
                    $bt_MPW_Close.PerformClick()
                }
        }
    )}
)

Create-Object -Name tb_MPW -Type TextBox -Data $ht_Data -Events $ar_Events -Control MPW_Form

# =============================================================
# ========== MPW_Form: Buttons ================================
# =============================================================

$ht_Data = @{
    Left = 20
    Top = $MPW_Form.ClientSize.Height - $ButtonSizeA.Height - 14
    Size = $ButtonSizeA
    Image = $Icons.Enter
    ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    'FlatAppearance.BorderSize' = 0
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

$ar_Events = @(
    {Add_Click(
        {
            If ($tb_MPW.TextLength -ge 16)
                {
                    If (Verify-MPW -PW $tb_MPW.Text)
                        {
                            $Global:MPW = $tb_MPW.Text
                            $tb_URL.Enabled = $true
                            $tb_UserName.Enabled = $true
                            $tb_Email.Enabled = $true
                            $tb_Password.Enabled = $true
                            $tb_Metadata.Enabled = $true
                            $bt_Metadata.Enabled = $true
                            $bt_Metadata_TB.Enabled = $true
                            $bt_MPW_Change.Enabled = $true
                            $bt_MPW_Change_TB.Enabled = $true
                            $bt_MPW.Enabled = $false
                            $bt_MPW_TB.Enabled = $false
                            Simulate-Timer -SyncHash $SyncHash
                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.EnterMPW
                            $MPW_Form.Close()
                        }
                    Else
                        {
                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.WrongMPW
                        }
                }
            Else
                {
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.ShortMPW
                }
        }
    )}
)

Create-Object -Name bt_MPW_Enter -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Form

# -------------------------------------------------------------

$ht_Data.Left = $MPW_Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Image = $Icons.Plain

$ar_Events = @(
    {Add_Click(
        {
            $tb_MPW.UseSystemPasswordChar = !($tb_MPW.UseSystemPasswordChar)
            $MPW_Form.ActiveControl = $tb_MPW
            $tb_MPW.DeselectAll()
        }
    )}
)

Create-Object -Name bt_MPW_Plain -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Form

# -------------------------------------------------------------

$ht_Data.Left = $MPW_Form.ClientSize.Width - 20 - $ButtonSizeA.Width
$ht_Data.Image = $Icons.Close

$ar_Events = @({Add_Click({$MPW_Form.Close()})})

Create-Object -Name bt_MPW_Close -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Form

# =============================================================
# ========== MPW_Change_Form ==================================
# =============================================================

$ht_Data = @{
    ClientSize = [System.Drawing.Size]::new(400,180)
    StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    Icon = $Ini.IconFolder + "Login-Manager.ico"
    Text = $Txt_List.MPW_Change_Form
    BackColor = $FormColor
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    KeyPreview = $true
    MaximizeBox = $false
    MinimizeBox = $false
    ShowInTaskbar = $false
}

$ar_Events = @(
    {Add_Load(
        {
            $Form.TopMost = $false
            $this.TopMost = $true
            $this.ActiveControl = $tb_MPW_Change_Old
        }
    )}
    {Add_FormClosed(
        {
            $tb_MPW_Change_Old.Text = [string]::Empty
            $tb_MPW_Change_Old.UseSystemPasswordChar = $true
            $tb_MPW_Change_New.Text = [string]::Empty
            $tb_MPW_Change_New.UseSystemPasswordChar = $true
            $Form.TopMost = $true
        }
    )}
)

Create-Object -Name MPW_Change_Form -Type Form -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$SyncHash.MPW_Change_Form = $MPW_Change_Form

# =============================================================
# ========== MPW_Change_Form: Labels ==========================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = 10
    Width = $MPW_Change_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_MPW_Change_Old
    TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
}

Create-Object -Name lb_MPW_Change_Old -Type Label -Data $ht_Data -Control MPW_Change_Form

# -------------------------------------------------------------

$ht_Data.Top = 70
$ht_Data.Text = $Txt_List.lb_MPW_Change_New

Create-Object -Name lb_MPW_Change_New -Type Label -Data $ht_Data -Control MPW_Change_Form

# =============================================================
# ========== MPW_Change_Form: TextBoxes =======================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $lb_MPW_Change_Old.Bottom
    Width = $MPW_Change_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::IBeam
    UseSystemPasswordChar = $true
    MaxLength = 256
}

$ar_Events = @(
    {Add_KeyDown(
        {
            If ($_.KeyCode -eq "Enter")
                {
                    $bt_MPW_Change_Enter.PerformClick()
                }
            ElseIf ($_.KeyCode -eq "Escape")
                {
                    $bt_MPW_Change_Close.PerformClick()
                }
        }
    )}
)

Create-Object -Name tb_MPW_Change_Old -Type TextBox -Data $ht_Data -Events $ar_Events -Control MPW_Change_Form

# -------------------------------------------------------------

$ht_Data.Top = $lb_MPW_Change_New.Bottom

Create-Object -Name tb_MPW_Change_New -Type TextBox -Data $ht_Data -Events $ar_Events -Control MPW_Change_Form

# =============================================================
# ========== MPW_Change_Form: Buttons =========================
# =============================================================

$ht_Data = @{
    Left = 20
    Top = $MPW_Change_Form.ClientSize.Height - $ButtonSizeA.Height - 14
    Size = $ButtonSizeA
    Image = $Icons.Enter
    ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    'FlatAppearance.BorderSize' = 0
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

$ar_Events = @(
    {Add_Click(
        {
            If ($tb_MPW_Change_Old.TextLength -ge 16 -and $tb_MPW_Change_New.TextLength -ge 16)
                {
                    If (Verify-MPW -PW $tb_MPW_Change_Old.Text)
                        {
                            $Global:MPW = $tb_MPW_Change_Old.Text

                            $Data = [array](Get-Content -Path $Ini.LoginFile | ConvertFrom-Json)
                            $Data = [array]($Data | Sort-Object -Property ID)

                            For($i = 0; $i -lt $Data.Count; $i++)
                                {
                                    $Data[$i].URL      = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].URL      -Key $Global:MPW
                                    $Data[$i].UserName = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].UserName -Key $Global:MPW
                                    $Data[$i].Email    = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].Email    -Key $Global:MPW
                                    $Data[$i].Password = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].Password -Key $Global:MPW
                                    $Data[$i].Metadata = Crypt-Text -Mode Decrypt -Format Text -Text $Data[$i].Metadata -Key $Global:MPW
                                }

                            New-Item -Path $Ini.UserDataFile -Force
                            Verify-MPW -PW $tb_MPW_Change_New.Text

                            $Global:MPW = $tb_MPW_Change_New.Text

                            For($i = 0; $i -lt $Data.Count; $i++)
                                {
                                    $Data[$i].URL      = Crypt-Text -Mode Encrypt -Format Text -Text $Data[$i].URL      -Key $Global:MPW
                                    $Data[$i].UserName = Crypt-Text -Mode Encrypt -Format Text -Text $Data[$i].UserName -Key $Global:MPW
                                    $Data[$i].Email    = Crypt-Text -Mode Encrypt -Format Text -Text $Data[$i].Email    -Key $Global:MPW
                                    $Data[$i].Password = Crypt-Text -Mode Encrypt -Format Text -Text $Data[$i].Password -Key $Global:MPW
                                    $Data[$i].Metadata = Crypt-Text -Mode Encrypt -Format Text -Text $Data[$i].Metadata -Key $Global:MPW
                                }

                            $Data | ConvertTo-Json -depth 1 | Set-Content -Path $Ini.LoginFile

                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.EnterChangeMPW

                            $MPW_Change_Form.Close()
                        }
                    Else
                        {
                            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.WrongChangeMPW
                        }
                }
            Else
                {
                    Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.ShortChangeMPW
                }
        }
    )}
)

Create-Object -Name bt_MPW_Change_Enter -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Change_Form

# -------------------------------------------------------------

$ht_Data.Left = $MPW_Change_Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Image = $Icons.Plain

$ar_Events = @(
    {Add_Click(
        {
            $tb_MPW_Change_Old.UseSystemPasswordChar = !($tb_MPW_Change_Old.UseSystemPasswordChar)
            $tb_MPW_Change_New.UseSystemPasswordChar = !($tb_MPW_Change_New.UseSystemPasswordChar)
            $tb_MPW_Change_Old.DeselectAll()
            $tb_MPW_Change_New.DeselectAll()
            $MPW_Change_Form.ActiveControl = $null
        }
    )}
)

Create-Object -Name bt_MPW_Change_Plain -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Change_Form

# -------------------------------------------------------------

$ht_Data.Left = $MPW_Change_Form.ClientSize.Width - 20 - $ButtonSizeA.Width
$ht_Data.Image = $Icons.Close

$ar_Events = @({Add_Click({$MPW_Change_Form.Close()})})

Create-Object -Name bt_MPW_Change_Close -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Change_Form

# =============================================================
# ========== Edit_Form ========================================
# =============================================================

$ht_Data = @{
    ClientSize = [System.Drawing.Size]::new(450,120)
    StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    Icon = $Ini.IconFolder + "Login-Manager.ico"
    Text = $Txt_List.Edit_Form
    BackColor = $FormColor
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    MaximizeBox = $false
    MinimizeBox = $false
    ShowInTaskbar = $false
}

$ar_Events = @(
    {Add_Load(
        {
            $Form.TopMost = $false
            $this.TopMost = $true
            $this.ActiveControl = $bt_Edit_Cancel
        }
    )}
    {Add_FormClosed({$Form.TopMost = $true})}
)

Create-Object -Name Edit_Form -Type Form -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$SyncHash.Edit_Form = $Edit_Form

# =============================================================
# ========== Edit_Form: Labels =================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = 20
    Width = $Edit_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_Edit
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
}

Create-Object -Name lb_Edit -Type Label -Data $ht_Data -Control Edit_Form

# =============================================================
# ========== Edit_Form: Buttons ================================
# =============================================================

$ht_Data = @{
    Left = $Edit_Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2 - 100
    Top = $Edit_Form.ClientSize.Height - $ButtonSizeB.Height - 20
    Size = $ButtonSizeB
    Text = $Txt_List.bt_Edit_OK
    DialogResult = [System.Windows.Forms.DialogResult]::OK
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorB
    FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

Create-Object -Name bt_Edit_OK -Type Button -Data $ht_Data -Control Edit_Form

$Edit_Form.AcceptButton = $bt_Edit_OK

# -------------------------------------------------------------

$ht_Data.Left = $Edit_Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2 + 100
$ht_Data.Text = $Txt_List.bt_Edit_Cancel
$ht_Data.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

Create-Object -Name bt_Edit_Cancel -Type Button -Data $ht_Data -Control Edit_Form

$Edit_Form.CancelButton = $bt_Edit_Cancel

# =============================================================
# ========== Del_Form =========================================
# =============================================================

$ht_Data = @{
    ClientSize = [System.Drawing.Size]::new(450,120)
    StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    Icon = $Ini.IconFolder + "Login-Manager.ico"
    Text = $Txt_List.Del_Form
    BackColor = $FormColor
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    MaximizeBox = $false
    MinimizeBox = $false
    ShowInTaskbar = $false
}

$ar_Events = @(
    {Add_Load(
        {
            $Form.TopMost = $false
            $this.TopMost = $true
            $this.ActiveControl = $bt_Del_Cancel
        }
    )}
    {Add_FormClosed({$Form.TopMost = $true})}
)

Create-Object -Name Del_Form -Type Form -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$SyncHash.Del_Form = $Del_Form

# =============================================================
# ========== Del_Form: Labels =================================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = 20
    Width = $Del_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_Del
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
}

Create-Object -Name lb_Del -Type Label -Data $ht_Data -Control Del_Form

# =============================================================
# ========== Del_Form: Buttons ================================
# =============================================================

$ht_Data = @{
    Left = $Del_Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2 - 100
    Top = $Del_Form.ClientSize.Height - $ButtonSizeB.Height - 20
    Size = $ButtonSizeB
    Text = $Txt_List.bt_Del_OK
    DialogResult = [System.Windows.Forms.DialogResult]::OK
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorB
    FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

Create-Object -Name bt_Del_OK -Type Button -Data $ht_Data -Control Del_Form

$Del_Form.AcceptButton = $bt_Del_OK

# -------------------------------------------------------------

$ht_Data.Left = $Del_Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2 + 100
$ht_Data.Text = $Txt_List.bt_Del_Cancel
$ht_Data.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

Create-Object -Name bt_Del_Cancel -Type Button -Data $ht_Data -Control Del_Form

$Del_Form.CancelButton = $bt_Del_Cancel

# =============================================================
# ========== PW_Generator_Form ================================
# =============================================================

$ht_Data = @{
    ClientSize = [System.Drawing.Size]::new(560,150)
    StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    Icon = $Ini.IconFolder + "Login-Manager.ico"
    Text = $Txt_List.PW_Generator_Form
    BackColor = $FormColor
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    MaximizeBox = $false
    MinimizeBox = $false
    ShowInTaskbar = $false
}

$ar_Events = @(
    {Add_Load(
        {
            $Form.TopMost = $false
            $this.TopMost = $true
            $this.ActiveControl = $bt_PW_Close
            $pn_Exclusions.Hide()
        }
    )}
    {Add_FormClosed({$Form.TopMost = $true})}
)

Create-Object -Name PW_Generator_Form -Type Form -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$SyncHash.PW_Generator_Form = $PW_Generator_Form

# =============================================================
# ========== PW_Generator_Form: Labels ========================
# =============================================================

$ht_Data = @{
    Left = $PW_Generator_Form.ClientSize.Width / 2 - 60
    Top = 10
    Width = 120
    Height = 22
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_Config
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

$ar_Events = @(
    {Add_MouseHover(
        {
            $pn_Exclusions.Show()
            $tb_r_Generator.Hide()
            $bt_PW_Create.Hide()
            $bt_PW_Close.Hide()
            $this.Parent.ActiveControl = $null
        }
    )}
)

Create-Object -Name lb_Config -Type Label -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== PW_Generator_Form: TextBoxes =====================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $PW_Generator_Form.ClientSize.Height / 2 - 15
    Width = $PW_Generator_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::Hand
    ReadOnly = $true
    Enabled = $false
}

$ar_Events = @(
    {Add_Click(
        {
            Set-Clipboard -Value $this.Text
            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CopyClipboard
        }
    )}
    {Add_MouseHover(
        {
            $Tooltip.SetToolTip($this,$TT_List.Copy)
        }
    )}
)

Create-Object -Name tb_r_Generator -Type TextBox -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== PW_Generator_Form: Panels ========================
# =============================================================

$ht_Data = @{
    Left = $PW_Generator_Form.ClientSize.Width / 2 - 180
    Top = 20
    Width = 360
    Height = 120
    BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    BackColor = $PanelColor
}

$ar_Events = @(
    {Add_MouseLeave(
        {
            $Point = New-Object -TypeName System.Drawing.Point(([System.Windows.Forms.Cursor]::Position.X + 3),([System.Windows.Forms.Cursor]::Position.Y + 3))
            If ($this.PointToClient($Point).X -lt 3 -or
                $this.PointToClient($Point).Y -lt 3 -or
                $this.PointToClient($Point).X -gt $this.Width -or
                $this.PointToClient($Point).Y -gt $this.Height)
                {
                    $this.Hide()
                    $tb_r_Generator.Show()
                    $bt_PW_Create.Show()
                    $bt_PW_Close.Show()
                    $this.Parent.ActiveControl = $null
                }
        }
    )}
)

Create-Object -Name pn_Exclusions -Type Panel -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== PW_Generator_Form: Buttons =======================
# =============================================================

$ht_Data = @{
    Left = $PW_Generator_Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2 - 100
    Top = $PW_Generator_Form.ClientSize.Height - $ButtonSizeB.Height - 10
    Size = $ButtonSizeB
    Text = $Txt_List.bt_PW_Create
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorB
    FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

$ar_Events = @(
    {Add_Click(
        {
            $ar_Exclude = [System.Text.Encoding]::ASCII.GetBytes($tb_Exclusions.Text)
            $Str = [string]::Empty

            Do {
                $RND = Get-Random -InputObject @(33..126)
                If ($ar_Exclude -notcontains $RND)
                    {
                        $Str += [System.Text.Encoding]::ASCII.GetChars($RND)
                    }
                }
            Until ($Str.Length -eq $Global:Chars)

            $tb_r_Generator.Enabled = $true
            $tb_r_Generator.Text = $Str
            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CreatePW
        }
    )}
)

Create-Object -Name bt_PW_Create -Type Button -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# -------------------------------------------------------------

$ht_Data.Left = $PW_Generator_Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2 + 100
$ht_Data.Text = $Txt_List.bt_PW_Close

$ar_Events = @({Add_Click({$PW_Generator_Form.Close()})})

Create-Object -Name bt_PW_Close -Type Button -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== Metadata_Form ====================================
# =============================================================

$ht_Data = @{
    ClientSize = [System.Drawing.Size]::new(400,350)
    StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    Icon = $Ini.IconFolder + "Login-Manager.ico"
    Text = $Txt_List.Metadata_Form
    BackColor = $FormColor
    FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    MaximizeBox = $false
    MinimizeBox = $false
    ShowInTaskbar = $false
}

$ar_Events = @(
    {Add_Load(
        {
            $Form.TopMost = $false
            $this.TopMost = $true
            $this.ActiveControl = $tb_Metadata
        }
    )}
    {Add_FormClosed({$Form.TopMost = $true})}
)

Create-Object -Name Metadata_Form -Type Form -Data $ht_Data -Events $ar_Events

# -------------------------------------------------------------

$SyncHash.Metadata_Form = $Metadata_Form

# =============================================================
# ========== Metadata_Form: Labels ============================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = 10
    Width = $Metadata_Form.ClientSize.Width - 20
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_Metadata
    TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
}

Create-Object -Name lb_Metadata -Type Label -Data $ht_Data -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: TextBoxes =========================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $lb_Metadata.Bottom
    Width = $Metadata_Form.ClientSize.Width - 20
    Height = 120
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::IBeam
    Multiline = $true
    ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    WordWrap = $true
    Enabled = $false
    MaxLength = 2048
}

Create-Object -Name tb_Metadata -Type TextBox -Data $ht_Data -Control Metadata_Form

# -------------------------------------------------------------

$ht_Data.Left = 20
$ht_Data.Top = $tb_Metadata.Bottom + 20
$ht_Data.Width = $Metadata_Form.ClientSize.Width - 40
$ht_Data.Cursor = [System.Windows.Forms.Cursors]::Hand
$ht_Data.Text = $Txt_List.tb_r_Metadata
$ht_Data.ReadOnly = $true

$ar_Events = @(
    {Add_Click(
        {
            Set-Clipboard -Value $this.Text
            Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CopyClipboard
        }
    )}
    {Add_MouseHover(
        {
            $Tooltip.SetToolTip($this,$TT_List.Copy)
        }
    )}
)

Create-Object -Name tb_r_Metadata -Type TextBox -Data $ht_data -Events $ar_Events -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: Panels ============================
# =============================================================

$ht_Data = @{
    Left = 10
    Top = $tb_Metadata.Bottom + 10
    Width = $Metadata_Form.ClientSize.Width - 20
    Height = 140
    BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
}

Create-Object -Name pn_Metadata -Type Panel -Data $ht_Data -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: Buttons ===========================
# =============================================================

$ht_Data = @{
    Left = $Metadata_Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2
    Top = $Metadata_Form.ClientSize.Height - $ButtonSizeB.Height - 10
    Size = $ButtonSizeB
    Text = $Txt_List.bt_Metadata_Close
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorB
    FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

$ar_Events = @({Add_Click({$Metadata_Form.Close()})})

Create-Object -Name bt_Metadata_Close -Type Button -Data $ht_Data -Events $ar_Events -Control Metadata_Form

# =============================================================
# ========== pn_Exclusions: Labels ============================
# =============================================================

$ht_Data = @{
    Left = $pn_Exclusions.Width / 2 - 50
    Top = 20
    Width = 100
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
    Text = $Txt_List.lb_Exclusions
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BorderStyle = [System.Windows.Forms.BorderStyle]::None
}

Create-Object -Name lb_Exclusions -Type Label -Data $ht_Data -Control pn_Exclusions

# -------------------------------------------------------------

$ht_Data.Top += 60
$ht_Data.Text = $Txt_List.lb_Chars -f $Global:Chars

Create-Object -Name lb_Chars -Type Label -Data $ht_Data -Control pn_Exclusions

# =============================================================
# ========== pn_Exclusions: TextBoxes =========================
# =============================================================

$ht_Data = @{
    Left = $pn_Exclusions.Width / 2 - 170
    Top = $lb_Exclusions.Bottom
    Width = 340
    Height = 20
    Font = New-Object -TypeName System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
    BackColor = $TextBoxColor
    Cursor = [System.Windows.Forms.Cursors]::IBeam
    TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
    Text = '"%[\]^_`|'
    MaxLength = 32
}

Create-Object -Name tb_Exclusions -Type TextBox -Data $ht_Data -Control pn_Exclusions

# =============================================================
# ========== pn_Exclusions: Buttons ===========================
# =============================================================

$ht_Data = @{
    Left = 100
    Top = $lb_Chars.Top
    Size = $ButtonSizeC
    Text = "-"
    TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    BackColor = $ButtonColorC
    FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
    Cursor = [System.Windows.Forms.Cursors]::Hand
}

$ar_Events = @(
    {Add_Click(
        {
            If ($Global:Chars -gt 16)
                {
                    $Global:Chars -= 16
                    $lb_Chars.Text = $Txt_List.bt_Chars_Minus -f $Global:Chars
                }
        }
    )}
)

Create-Object -Name bt_Chars_Minus -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Exclusions

# -------------------------------------------------------------

$ht_Data.Left = $pn_Exclusions.Width - $ButtonSizeC.Width - 100
$ht_Data.Text = "+"

$ar_Events = @(
    {Add_Click(
        {
            If ($Global:Chars -lt 64)
                {
                    $Global:Chars += 16
                    $lb_Chars.Text = $Txt_List.bt_Chars_Plus -f $Global:Chars
                }
        }
    )}
)

Create-Object -Name bt_Chars_Plus -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Exclusions

# =============================================================
# ========== Start ============================================
# =============================================================

$Form.ShowDialog()