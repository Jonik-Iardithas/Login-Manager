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
$ButtonSizeB = [System.Drawing.Size]::new(340,30)
$ButtonSizeC = [System.Drawing.Size]::new(100,30)
$ButtonSizeD = [System.Drawing.Size]::new(20,20)
$ButtonColorC = [System.Drawing.Color]::LightCyan
$ButtonColorD = [System.Drawing.Color]::LightSteelBlue
$PanelColor = [System.Drawing.Color]::SteelBlue
$SettingsFile = "$env:LOCALAPPDATA\PowerShellTools\Login-Manager\Settings.ini"
$Global:Chars = 16
$Global:ID = $null
$Global:Result = $null
$Global:Index = $null
$Global:MPW = $null
$Global:Count = [System.TimeSpan]::FromSeconds(900)
$L_Ptr = [System.IntPtr]::new(0)
$S_Ptr = [System.IntPtr]::new(0)
$SyncHash = [HashTable]::Synchronized(@{Counter = $Global:Count})
$RSList = @("Timer")

$Msg_List = @{
    Start         = "Login-Manager gestartet."
    NoLogins      = "Datei `"Logins.json`" konnte nicht gefunden werden und wurde angelegt."
    NoUserData    = "Datei `"UserData.dat`" konnte nicht gefunden werden und wurde angelegt."
    NewRecord     = "Neuer Datensatz eingetragen."
    FailRecord    = "Eintrag fehlgeschlagen. Datensatz unvollständig."
    NewEdit       = "Datensatz geändert."
    FailEdit      = "Änderung fehlgeschlagen. Angaben unvollständig."
    CancelEdit    = "Änderung abgebrochen."
    NewFind       = "Suche erfolgreich."
    NoFind        = "Suche erfolglos."
    NewDelete     = "Datensatz gelöscht."
    CancelDelete  = "Löschvorgang abgebrochen."
    CopyClipboard = "Inhalt in die Zwischenablage kopiert."
    EnterMPW      = "Master-Passwort eingetragen."
    WrongMPW      = "Master-Passwort inkorrekt."
    ShortMPW      = "Das Master-Passwort muss mindestens 16 Zeichen betragen."
    CreatePW      = "Passwort generiert."
    Addendum      = "Datensätze gefunden."
}

$Txt_List = @{
    Form              = "Login-Manager"
    Edit_Form         = "Änderungsbestätigung"
    Del_Form          = "Löschbestätigung"
    MPW_Form          = "Master-Passwort eingeben"
    PW_Generator_Form = "Passwort-Generator"
    Metadata_Form     = "Metadaten"
    lb_URL            = "URL"
    lb_UserName       = "Benutzername"
    lb_Email          = "Email-Adresse"
    lb_Password       = "Passwort"
    lb_Metadata       = "Metadaten"
    lb_Events         = "Ereignisse"
    lb_MPW            = "Master-Passwort"
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
    bt_MPW            = "Master-Passwort"
    bt_Edit_OK        = "Ja"
    bt_Edit_Cancel    = "Nein"
    bt_Del_OK         = "Ja"
    bt_Del_Cancel     = "Nein"
    bt_PW_Create      = "Erstellen"
    bt_PW_Close       = "Schließen"
    bt_Metadata_Close = "Schließen"
    bt_Chars_Minus    = "{0} Zeichen"
    bt_Chars_Plus     = "{0} Zeichen"
}

$Tooltips_List = @{
    Copy  = "Klicken um Inhalt in die Zwischenablage zu kopieren."
    Reset = "Klicken um Timer zurückzusetzen."
}

$MessageBoxes_List = @{
    Initialize_Msg_01 = "Konnte Datei {0} nicht finden."
    Initialize_Msg_02 = "Login-Manager: Fehler"
}

$Icons_List = @{
    Add          = "$env:windir\system32\imageres.dll|246"
    Edit         = "$env:windir\system32\imageres.dll|89"
    Find         = "$env:windir\system32\wmploc.dll|20"
    Prev         = "$env:windir\system32\wmploc.dll|153"
    Del          = "$env:windir\system32\shell32.dll|31"
    Next         = "$env:windir\system32\wmploc.dll|152"
    Enter        = "$env:windir\system32\imageres.dll|101"
    Plain        = "$env:windir\system32\imageres.dll|79"
    Close        = "$env:windir\system32\imageres.dll|93"
    PW_Generator = "$env:windir\system32\imageres.dll|299"
    Metadata     = "$env:windir\system32\imageres.dll|287"
    Exit         = "$env:windir\system32\imageres.dll|84"
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
                [System.Windows.Forms.MessageBox]::Show(($MessageBoxes_List.Initialize_Msg_01 -f $FilePath),$MessageBoxes_List.Initialize_Msg_02,0)
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
                        $Plain = [System.Text.Encoding]::UTF8.GetBytes($Text)
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        $Plain = [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::Parse($Text).Value
                    }

                $Encryptor = $AES.CreateEncryptor()
                $Encrypted = $Encryptor.TransformFinalBlock($Plain, 0, $Plain.Length)
                $Encrypted = $AES.IV + $Encrypted
                $SHA.Dispose()
                $AES.Dispose()

                If ($Format -in 'Text')
                    {
                        return [System.Convert]::ToBase64String($Encrypted)
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        return [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::new($Encrypted).ToString()
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
                $SHA.Dispose()
                $AES.Dispose()

                If ($Format -in 'Text')
                    {
                        return [System.Text.Encoding]::UTF8.GetString($Decrypted).Trim([char]0)
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        return [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::new($Decrypted.Where({$_ -ne [char]0})).ToString()
                    }
            }
    }

# -------------------------------------------------------------

function Verify-MPW ([string]$PW)
    {
        $Data = Get-Content -Path $Paths.UserDataFile -Raw

        If ($Data)
            {
                $UserData = Crypt-Text -Mode Decrypt -Format Hex -Text $Data -Key $PW
                $PWByteArray = [System.Text.Encoding]::UTF8.GetBytes($PW)
                $Sum = ($PWByteArray | Measure-Object -Sum).Sum
                $PWHexString = [System.BitConverter]::ToString($PWByteArray).Replace("-",[string]::Empty)
                $Pos = $Sum % ($UserData.Length - $PWHexString.Length)
                return $UserData.IndexOf($PWHexString) -eq $Pos
            }
        Else
            {
                $Randomizer = [System.Security.Cryptography.RandomNumberGenerator]::Create()
                $Buffer = [byte[]]::new((Get-Random -InputObject @(512..1024)))
                $Randomizer.GetNonZeroBytes($Buffer)
                $UserData = [System.BitConverter]::ToString($Buffer).Replace("-",[string]::Empty)
                $PWByteArray = [System.Text.Encoding]::UTF8.GetBytes($PW)
                $Sum = ($PWByteArray | Measure-Object -Sum).Sum
                $PWHexString = [System.BitConverter]::ToString($PWByteArray).Replace("-",[string]::Empty)
                $Pos = $Sum % $UserData.Length
                $UserData = $UserData.Insert($Pos,$PWHexString)
                $Data = Crypt-Text -Mode Encrypt -Format Hex -Text $UserData -Key $PW
                Set-Content -Value $Data -Path $Paths.UserDataFile -NoNewline
                $Randomizer.Dispose()
                return $true
            }
    }

# -------------------------------------------------------------

function Create-Object ([string]$Name, [string]$Type, [HashTable]$Data, [array]$Events, [string]$Control)
    {
        New-Variable -Name $Name -Value (New-Object -TypeName System.Windows.Forms.$Type) -Scope Global -Force

        ForEach ($k in $Data.Keys) {Invoke-Expression ("`$$Name.$k = " + {$Data.$k})}
        ForEach ($e in $Events)    {Invoke-Expression ("`$$Name.$e")}
        If ($Control)              {Invoke-Expression ("`$$Control.Controls.Add(`$$Name)")}
    }

# -------------------------------------------------------------

function Create-Icons ([string]$Name, [HashTable]$List, [string]$Path)
    {
        ForEach($Key in $List.Keys)
            {
                If (Test-Path -Path ($Path + "Icon_" + $Key.ToString() + ".ico"))
                    {
                        $ht_Icons += @{$Key = [System.Drawing.Image]::FromFile($Path + "Icon_" + $Key.ToString() + ".ico")}
                    }
                ElseIf (Test-Path -Path ($Path + "Icon_" + $Key.ToString() + ".png"))
                    {
                        $ht_Icons += @{$Key = [System.Drawing.Image]::FromFile($Path + "Icon_" + $Key.ToString() + ".png")}
                    }
                Else
                    {
                        $NewIcon = [System.Drawing.Bitmap]::new(40,40)
                        $Painter = [System.Drawing.Graphics]::FromImage($NewIcon)
                        [Win32Functions.WinAPI]::ExtractIconEx($List[$Key].ToString().Split("|")[0], $List[$Key].ToString().Split("|")[-1], [ref]$L_Ptr, [ref]$S_Ptr, 1) | Out-Null
                        $Painter.DrawIcon([System.Drawing.Icon]::FromHandle($L_Ptr),[System.Drawing.Rectangle]::new(0, 0, $NewIcon.Width, $NewIcon.Height))
                        $ht_Icons += @{$Key = $NewIcon}
                        [Win32Functions.WinApi]::DestroyIcon($L_Ptr) | Out-Null
                        [Win32Functions.WinApi]::DestroyIcon($S_Ptr) | Out-Null
                    }
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
                If ($Global:Index -eq $Global:Result.Count) {$Global:Index--}
                $Global:ID = $Global:Result[$Global:Index].ID
                $tb_r_URL.Text = $Global:Result[$Global:Index].URL
                $tb_r_UserName.Text = $Global:Result[$Global:Index].UserName
                $tb_r_Email.Text = $Global:Result[$Global:Index].Email
                $tb_r_Password.Text = $Global:Result[$Global:Index].Password
                $tb_r_Password.UseSystemPasswordChar = $true
                $tb_r_Metadata.Text = $Global:Result[$Global:Index].Metadata
                $lb_Page.Text = [string](($Global:Index + 1), "/", [string]$Global:Result.Count)
                $tb_r_URL.Enabled = $true
                $tb_r_UserName.Enabled = $true
                $tb_r_Email.Enabled = $true
                $tb_r_Password.Enabled = $true
                $tb_r_Metadata.Enabled = $true
                $bt_Del.Enabled = $true

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
                If ($Msg_A) {Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_A -Addd $Msg_List.Addendum}
            }
        Else
            {
                $Global:ID = $null
                $Global:Index = $null
                $tb_r_URL.Text = $Txt_List.tb_r_URL
                $tb_r_UserName.Text = $Txt_List.tb_r_UserName
                $tb_r_Email.Text = $Txt_List.tb_r_Email
                $tb_r_Password.Text = $Txt_List.tb_r_Password
                $tb_r_Password.UseSystemPasswordChar = $false
                $tb_r_Metadata.Text = $Txt_List.tb_r_Metadata
                $lb_Page.Text = "- / -"
                $tb_r_URL.Enabled = $false
                $tb_r_UserName.Enabled = $false
                $tb_r_Email.Enabled = $false
                $tb_r_Password.Enabled = $false
                $tb_r_Metadata.Enabled = $false
                $bt_Del.Enabled = $false
                $bt_Edit.Enabled = $false
                $bt_Prev.Enabled = $false
                $bt_Next.Enabled = $false
                If ($Msg_B) {Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_B -Addd $Msg_List.Addendum}
            }

        $Form.ActiveControl = $pn_Panel
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
# ========== Code =============================================
# =============================================================

$Paths = Initialize-Me -FilePath $SettingsFile

# -------------------------------------------------------------

$ht_Data = @{IsBalloon = $true}

Create-Object -Name Tooltip -Type Tooltip -Data $ht_Data

# -------------------------------------------------------------

Create-Icons -Name Icons -List $Icons_List -Path $Paths.IconFolder

$IconMax = New-Object -TypeName System.Drawing.Size(($Icons.Values.Width | Measure-Object -Maximum).Maximum,($Icons.Values.Height | Measure-Object -Maximum).Maximum)
$ButtonSizeA.Height = $IconMax.Height + 8

# =============================================================
# ========== Form =============================================
# =============================================================

$ht_Data = @{
            ClientSize = [System.Drawing.Size]::new(400,(640 + ($IconMax.Height + 8) * 3))
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
            Text = $Txt_List.Form
            BackColor = $FormColor
            FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
            MaximizeBox = $false
            }

$ar_Events = @(
                {Add_Load(
                    {
                        $this.TopMost = $true
                        $this.ActiveControl = $pn_Panel
                        Write-Msg -TextBox $tb_Events -NL $false -Time $true -Msg $Msg_List.Start
                        If (!(Test-Path -Path $Paths.LoginFile))
                            {
                                New-Item -Path $Paths.LoginFile -Force
                                Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoLogins
                            }
                        Simulate-Timer -SyncHash $SyncHash
                    })}
                {Add_FormClosing(
                    {
                        Set-Clipboard -Value $null

                        $RS = Get-Runspace -Name $RSList
                        ForEach($i in $RS)
                            {
                                $i.Dispose()
                                [System.GC]::Collect()
                            }
                    })}
              )

Create-Object -Name Form -Type Form -Data $ht_Data -Events $ar_Events

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
            Left = 10
            Top = 10
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
            Top = $lb_URL.Bounds.Bottom
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
                    })}
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
            Top = $tb_Password.Bounds.Bottom + 10
            Size = $ButtonSizeA
            Image = $Icons.Add
            ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            'FlatAppearance.BorderSize' = 0
            Cursor = [System.Windows.Forms.Cursors]::Hand
            Enabled = $false
            }

$ar_Events = @(
                {Add_Click(
                    {
                        If (Test-Path -Path $Paths.LoginFile)
                            {
                                If ($tb_Password.TextLength -gt 0 -and ($tb_URL.TextLength -gt 0 -or $tb_UserName.TextLength -gt 0 -or $tb_Email.TextLength -gt 0))
                                    {
                                        $Data = [array](Get-Content -Path $Paths.LoginFile | ConvertFrom-Json)
                                        $Data = [array]($Data | Sort-Object -Property ID)
                                        If ($Data.Count -eq 0) {$New_ID = ('{0:d4}' -f 0)}
                                        Else {$New_ID = ('{0:d4}' -f ([int]($Data[-1].ID) + 1))}
                                        If ($tb_URL.TextLength -eq 0) {$tb_URL.Text = "N/A"}
                                        If ($tb_UserName.TextLength -eq 0) {$tb_UserName.Text = "N/A"}
                                        If ($tb_Email.TextLength -eq 0) {$tb_Email.Text = "N/A"}
                                        If ($tb_Metadata.TextLength -eq 0) {$tb_Metadata.Text = "N/A"}
                                        $Data += @([PSCustomObject]@{
                                                                    ID       = $New_ID
                                                                    URL      = Crypt-Text -Mode Encrypt -Format Text -Text $tb_URL.Text      -Key $Global:MPW
                                                                    UserName = Crypt-Text -Mode Encrypt -Format Text -Text $tb_UserName.Text -Key $Global:MPW
                                                                    Email    = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Email.Text    -Key $Global:MPW
                                                                    Password = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Password.Text -Key $Global:MPW
                                                                    Metadata = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Metadata.Text -Key $Global:MPW
                                                                    })
                                        $Data | ConvertTo-Json -depth 1 | Set-Content -Path $Paths.LoginFile
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
                    })}
              )

Create-Object -Name bt_Add -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Image = $Icons.Edit

$ar_Events = @(
                {Add_Click(
                    {
                        If (Test-Path -Path $Paths.LoginFile)
                            {
                                If ($tb_Password.TextLength -gt 0 -and ($tb_URL.TextLength -gt 0 -or $tb_UserName.TextLength -gt 0 -or $tb_Email.TextLength -gt 0))
                                    {
                                        If ($Edit_Form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
                                            {
                                                $Data = [array](Get-Content -Path $Paths.LoginFile | ConvertFrom-Json)
                                                $Data = [array]($Data | Sort-Object -Property ID)
                                                If ($tb_URL.TextLength -eq 0) {$tb_URL.Text = "N/A"}
                                                If ($tb_UserName.TextLength -eq 0) {$tb_UserName.Text = "N/A"}
                                                If ($tb_Email.TextLength -eq 0) {$tb_Email.Text = "N/A"}
                                                If ($tb_Metadata.TextLength -eq 0) {$tb_Metadata.Text = "N/A"}
                                                $Data[$Data.ID.IndexOf($Global:ID)].URL      = Crypt-Text -Mode Encrypt -Format Text -Text $tb_URL.Text      -Key $Global:MPW
                                                $Data[$Data.ID.IndexOf($Global:ID)].UserName = Crypt-Text -Mode Encrypt -Format Text -Text $tb_UserName.Text -Key $Global:MPW
                                                $Data[$Data.ID.IndexOf($Global:ID)].Email    = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Email.Text    -Key $Global:MPW
                                                $Data[$Data.ID.IndexOf($Global:ID)].Password = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Password.Text -Key $Global:MPW
                                                $Data[$Data.ID.IndexOf($Global:ID)].Metadata = Crypt-Text -Mode Encrypt -Format Text -Text $tb_Metadata.Text -Key $Global:MPW
                                                $Data | ConvertTo-Json -depth 1 | Set-Content -Path $Paths.LoginFile
                                                $Global:Result[$Global:Index].URL      = $tb_URL.Text
                                                $Global:Result[$Global:Index].UserName = $tb_UserName.Text
                                                $Global:Result[$Global:Index].Email    = $tb_Email.Text
                                                $Global:Result[$Global:Index].Password = $tb_Password.Text
                                                $Global:Result[$Global:Index].Metadata = $tb_Metadata.Text
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
                    })}
              )

Create-Object -Name bt_Edit -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
$ht_Data.Image = $Icons.Find

$ar_Events = @(
                {Add_Click(
                    {
                        If (Test-Path -Path $Paths.LoginFile)
                            {
                                $Data = [array](Get-Content -Path $Paths.LoginFile | ConvertFrom-Json)
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

                                $Global:Result = $Data
                                $Global:Index = 0
                                Load-Result -Msg_A $Msg_List.NewFind -Msg_B $Msg_List.NoFind
                                Clear-Boxes
                            }
                        Else
                            {
                                Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoLogins
                            }
                    })}
              )

Create-Object -Name bt_Find -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# =============================================================
# ========== Form: Panels =====================================
# =============================================================

$ht_Data = @{
            Left = 10
            Top = $bt_Add.Bounds.Bottom + 10
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
            Top = $pn_Panel.Bounds.Top + 10
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
                    })}
                {Add_MouseHover(
                    {
                        $Tooltip.SetToolTip($this,$Tooltips_List.Copy)
                    })}
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

Create-Object -Name tb_r_Password -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
            Left = $Form.ClientSize.Width / 2 - 40
            Top = $tb_r_Password.Bounds.Bottom + 3
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
            Top = $pn_Panel.Bounds.Bottom + 15
            Size = $ButtonSizeA
            Image = $Icons.Del
            ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            'FlatAppearance.BorderSize' = 0
            Cursor = [System.Windows.Forms.Cursors]::Hand
            Enabled = $false
            }

$ar_Events = @(
                {Add_Click(
                    {
                        If (Test-Path -Path $Paths.LoginFile)
                            {
                                If ($Del_Form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
                                    {
                                        $Data = [array](Get-Content -Path $Paths.LoginFile | ConvertFrom-Json)
                                        $Data = [array]($Data | Sort-Object -Property ID)
                                        $Data = [array]($Data | Where-Object {$_.ID -ne $Global:ID})
                                        Clear-Content -Path $Paths.LoginFile
                                        $Data | ConvertTo-Json -depth 1 | Set-Content -Path $Paths.LoginFile
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
                    })}
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
                    })}
              )

Create-Object -Name bt_Prev -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width - 30 - $ButtonSizeA.Width
$ht_Data.Image = $Icons.Next

$ar_Events = @(
                {Add_Click(
                    {
                        $Global:Index ++
                        Load-Result
                    })}
              )

Create-Object -Name bt_Next -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data = @{
            Left = $Form.ClientSize.Width / 2 - $ButtonSizeB.Width / 2
            Top = $bt_Next.Bounds.Bottom + 10
            Size = $ButtonSizeB
            Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, $FontStyle)
            Text = $Txt_List.bt_MPW
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

$ar_Events = @({Add_Click({$MPW_Form.ShowDialog()})})

Create-Object -Name bt_MPW -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data = @{
            Left = 30
            Top = $bt_MPW.Bounds.Bottom + 10
            Size = $ButtonSizeA
            Image = $Icons.PW_Generator
            ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            'FlatAppearance.BorderSize' = 0
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

$ar_Events = @({Add_Click({$PW_Generator_Form.ShowDialog()})})

Create-Object -Name bt_PW_Generator -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Image = $Icons.Metadata
$ht_Data += @{Enabled = $false}

$ar_Events = @({Add_Click({$Metadata_Form.ShowDialog()})})

Create-Object -Name bt_Metadata -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Left = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
$ht_Data.Image = $Icons.Exit
$ht_Data.Enabled = $true

$ar_Events = @({Add_Click({$SyncHash.Counter = [System.TimeSpan]::Zero})})

Create-Object -Name bt_Exit -Type Button -Data $ht_Data -Events $ar_Events -Control Form

$Form.CancelButton = $bt_Exit

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
            Left = 10
            Top = $bt_Exit.Bounds.Bottom + 10
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
            Top = $lb_Events.Bounds.Bottom
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
            Top = $tb_Events.Bounds.Bottom + 13
            Font = New-Object -TypeName System.Drawing.Font($FontName, $FontSize, [System.Drawing.FontStyle]::Bold)
            ForeColor = [System.Drawing.Color]::Red
            BackColor = [System.Drawing.Color]::White
            BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

$ar_Events = @(
                {Add_Click(
                    {
                        $SyncHash.Counter = $Global:Count
                    })}
                {Add_MouseHover(
                    {
                        $Tooltip.SetToolTip($this,$Tooltips_List.Reset)
                    })}
                )

Create-Object -Name lb_Counter -Type Label -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$SyncHash.lb_Counter = $lb_Counter

# =============================================================
# ========== MPW_Form =========================================
# =============================================================

$ht_Data = @{
            ClientSize = [System.Drawing.Size]::new(400,120)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
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
                        If (!(Test-Path -Path $Paths.UserDataFile))
                            {
                                New-Item -Path $Paths.UserDataFile -Force
                                Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.NoUserData
                            }
                    })}
                {Add_FormClosed({$Form.TopMost = $true})}
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
            Top = $lb_MPW.Bounds.Bottom
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
                    })}
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
                                    $bt_MPW.Enabled = $false
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
                    })}
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
                    })}
              )

Create-Object -Name bt_MPW_Plain -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Form

# -------------------------------------------------------------

$ht_Data.Left = $MPW_Form.ClientSize.Width - 20 - $ButtonSizeA.Width
$ht_Data.Image = $Icons.Close

$ar_Events = @({Add_Click({$MPW_Form.Close()})})

Create-Object -Name bt_MPW_Close -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Form

# =============================================================
# ========== Edit_Form ========================================
# =============================================================

$ht_Data = @{
            ClientSize = [System.Drawing.Size]::new(450,120)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
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
                    })}
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
            Left = $Edit_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 - 100
            Top = $Edit_Form.ClientSize.Height - $ButtonSizeC.Height - 20
            Size = $ButtonSizeC
            Text = $Txt_List.bt_Edit_OK
            DialogResult = [System.Windows.Forms.DialogResult]::OK
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BackColor = $ButtonColorC
            FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

Create-Object -Name bt_Edit_OK -Type Button -Data $ht_Data -Control Edit_Form

$Edit_Form.AcceptButton = $bt_Edit_OK

# -------------------------------------------------------------

$ht_Data.Left = $Edit_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 + 100
$ht_Data.Text = $Txt_List.bt_Edit_Cancel
$ht_Data.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

Create-Object -Name bt_Edit_Cancel -Type Button -Data $ht_Data -Control Edit_Form

$Edit_Form.CancelButton = $bt_Edit_Cancel

# =============================================================
# ========== Del_Form =========================================
# =============================================================

$ht_Data = @{
            ClientSize = [System.Drawing.Size]::new(450,120)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
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
                    })}
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
            Left = $Del_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 - 100
            Top = $Del_Form.ClientSize.Height - $ButtonSizeC.Height - 20
            Size = $ButtonSizeC
            Text = $Txt_List.bt_Del_OK
            DialogResult = [System.Windows.Forms.DialogResult]::OK
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BackColor = $ButtonColorC
            FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

Create-Object -Name bt_Del_OK -Type Button -Data $ht_Data -Control Del_Form

$Del_Form.AcceptButton = $bt_Del_OK

# -------------------------------------------------------------

$ht_Data.Left = $Del_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 + 100
$ht_Data.Text = $Txt_List.bt_Del_Cancel
$ht_Data.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

Create-Object -Name bt_Del_Cancel -Type Button -Data $ht_Data -Control Del_Form

$Del_Form.CancelButton = $bt_Del_Cancel

# =============================================================
# ========== PW_Generator_Form ================================
# =============================================================

$ht_Data = @{
            ClientSize = [System.Drawing.Size]::new(560,150)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
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
                        $this.ActiveControl = $bt_PW_Create
                        $pn_Exclusions.Hide()
                    })}
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
                    })}
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
                    })}
                {Add_MouseHover(
                    {
                        $Tooltip.SetToolTip($this,$Tooltips_List.Copy)
                    })}
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
                        If ($pn_Exclusions.PointToClient($Point).X -lt 3 -or
                            $pn_Exclusions.PointToClient($Point).Y -lt 3 -or
                            $pn_Exclusions.PointToClient($Point).X -gt $pn_Exclusions.Width -or
                            $pn_Exclusions.PointToClient($Point).Y -gt $pn_Exclusions.Height)
                            {
                                $pn_Exclusions.Hide()
                                $tb_r_Generator.Show()
                                $bt_PW_Create.Show()
                            }
                    })}
              )

Create-Object -Name pn_Exclusions -Type Panel -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== PW_Generator_Form: Buttons =======================
# =============================================================

$ht_Data = @{
            Left = $PW_Generator_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 - 100
            Top = $PW_Generator_Form.ClientSize.Height - $ButtonSizeC.Height - 10
            Size = $ButtonSizeC
            Text = $Txt_List.bt_PW_Create
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BackColor = $ButtonColorC
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
                    })}
              )

Create-Object -Name bt_PW_Create -Type Button -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# -------------------------------------------------------------

$ht_Data.Left = $PW_Generator_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 + 100
$ht_Data.Text = $Txt_List.bt_PW_Close

$ar_Events = @({Add_Click({$PW_Generator_Form.Close()})})

Create-Object -Name bt_PW_Close -Type Button -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== Metadata_Form ====================================
# =============================================================

$ht_Data = @{
            ClientSize = [System.Drawing.Size]::new(400,350)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
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
                    })}
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
            Top = $lb_Metadata.Bounds.Bottom
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
$ht_Data.Top = $tb_Metadata.Bounds.Bottom + 20
$ht_Data.Width = $Metadata_Form.ClientSize.Width - 40
$ht_Data.Cursor = [System.Windows.Forms.Cursors]::Hand
$ht_Data += @{
             Text = $Txt_List.tb_r_Metadata
             ReadOnly = $true
             }

$ar_Events = @(
                {Add_Click(
                    {
                        Set-Clipboard -Value $this.Text
                        Write-Msg -TextBox $tb_Events -NL $true -Time $true -Msg $Msg_List.CopyClipboard
                    })}
                {Add_MouseHover(
                    {
                        $Tooltip.SetToolTip($this,$Tooltips_List.Copy)
                    })}
              )

Create-Object -Name tb_r_Metadata -Type TextBox -Data $ht_data -Events $ar_Events -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: Panels ============================
# =============================================================

$ht_Data = @{
            Left = 10
            Top = $tb_Metadata.Bounds.Bottom + 10
            Width = $Metadata_Form.ClientSize.Width - 20
            Height = 140
            BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
            }

Create-Object -Name pn_Metadata -Type Panel -Data $ht_Data -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: Buttons ===========================
# =============================================================

$ht_Data = @{
            Left = $Metadata_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2
            Top = $Metadata_Form.ClientSize.Height - $ButtonSizeC.Height - 10
            Size = $ButtonSizeC
            Text = $Txt_List.bt_Metadata_Close
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BackColor = $ButtonColorC
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
            Top = $lb_Exclusions.Bounds.Bottom
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
            Top = $lb_Chars.Bounds.Top
            Size = $ButtonSizeD
            Text = "-"
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BackColor = $ButtonColorD
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
                    })}
              )

Create-Object -Name bt_Chars_Minus -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Exclusions

# -------------------------------------------------------------

$ht_Data.Left = $pn_Exclusions.Width - $ButtonSizeD.Width - 100
$ht_Data.Text = "+"

$ar_Events = @(
                {Add_Click(
                    {
                        If ($Global:Chars -lt 64)
                            {
                                $Global:Chars += 16
                                $lb_Chars.Text = $Txt_List.bt_Chars_Plus -f $Global:Chars
                            }
                    })}
              )

Create-Object -Name bt_Chars_Plus -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Exclusions

# =============================================================
# ========== Show Dialog ======================================
# =============================================================

$Form.ShowDialog()