﻿# =============================================================
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
$ButtonSizeA = New-Object System.Drawing.Size(80,40)
$ButtonSizeB = New-Object System.Drawing.Size(340,30)
$ButtonSizeC = New-Object System.Drawing.Size(100,30)
$ButtonSizeD = New-Object System.Drawing.Size(20,20)
$ButtonColorC = [System.Drawing.Color]::LightCyan
$ButtonColorD = [System.Drawing.Color]::LightSteelBlue
$PanelColor = [System.Drawing.Color]::SteelBlue
$SettingsFile = "$env:LOCALAPPDATA\PowerShellTools\Login-Manager\Settings.ini"
$Global:Chars = 16
$Global:ID = $null
$Global:Result = $null
$Global:Index = $null
$Global:MPW = $null
$L_Ptr = [System.IntPtr]::new(0)
$S_Ptr = [System.IntPtr]::new(0)

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
                [System.Windows.Forms.MessageBox]::Show("Konnte Datei `"$FilePath`" nicht finden.","Login-Manager: Fehler",0)
                Exit
            }

        $Data = [array](Get-Content -Path $FilePath)

        ForEach ($i in $Data) {$ht_Result += @{$i.Split("=")[0].Trim(" ") = $i.Split("=")[-1].Trim(" ")}}

        return $ht_Result
    }

# -------------------------------------------------------------

function Crypt-Text ([string]$Mode, [string]$Format, [string]$Text, [string]$Key)
    {
        $SHA = New-Object System.Security.Cryptography.SHA256Managed
        $AES = New-Object System.Security.Cryptography.AesManaged
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

                If ($Format -in 'Text')
                    {
                        return [System.Text.Encoding]::UTF8.GetString($Decrypted).Trim([char]0)
                    }
                ElseIf ($Format -in 'Hex')
                    {
                        return [System.Runtime.Remoting.Metadata.W3cXsd2001.SoapHexBinary]::new($Decrypted).ToString().Trim("0")
                    }
            }

        $SHA.Dispose()
        $AES.Dispose()
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
                $Buffer = New-Object byte[] (Get-Random -Maximum 1024 -Minimum 512)
                $Randomizer.GetBytes($Buffer)
                $UserData = [System.BitConverter]::ToString($Buffer).Replace("-",[string]::Empty)
                $PWByteArray = [System.Text.Encoding]::UTF8.GetBytes($PW)
                $Sum = ($PWByteArray | Measure-Object -Sum).Sum
                $PWHexString = [System.BitConverter]::ToString($PWByteArray).Replace("-",[string]::Empty)
                $Pos = $Sum % $UserData.Length
                $UserData = $UserData.Insert($Pos,$PWHexString)
                $Data = Crypt-Text -Mode Encrypt -Format Hex -Text $UserData -Key $PW
                Set-Content -Value $Data -Path $Paths.UserDataFile -NoNewline
                return $true
            }
    }

# -------------------------------------------------------------

function Create-Object ([string]$Name, [string]$Type, [HashTable]$Data, [array]$Events, [string]$Control)
    {
        New-Variable -Name $Name -Value (New-Object System.Windows.Forms.$Type) -Scope Global -Force

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
                $tb_r_URL.Text = "[URL]"
                $tb_r_UserName.Text = "[Benutzername]"
                $tb_r_Email.Text = "[Emailadresse]"
                $tb_r_Password.Text = "[Passwort]"
                $tb_r_Password.UseSystemPasswordChar = $false
                $tb_r_Metadata.Text = "[Metadaten]"
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

Create-Object -Name Tooltip -Type Tooltip
$Tooltip.IsBalloon = $true

# -------------------------------------------------------------

Create-Icons -Name Icons -List $Icons_List -Path $Paths.IconFolder

$IconMax = New-Object -TypeName System.Drawing.Size(($Icons.Values.Width | Measure-Object -Maximum).Maximum,($Icons.Values.Height | Measure-Object -Maximum).Maximum)
$ButtonSizeA.Height = $IconMax.Height + 8

# =============================================================
# ========== Form =============================================
# =============================================================

$ht_Data = @{
            ClientSize = [System.Drawing.Size]::new(400,(600 + ($IconMax.Height + 8) * 3))
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
            Text = "Login-Manager"
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
                    })}
                {Add_FormClosing({Set-Clipboard -Value $null})}
              )

Create-Object -Name Form -Type Form -Data $ht_Data -Events $ar_Events

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,10)
            Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - 20),20)
            Text = "URL"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
            }

Create-Object -Name lb_URL -Type Label -Data $ht_Data -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 50
$ht_Data.Text = "Benutzername"

Create-Object -Name lb_UserName -Type Label -Data $ht_Data -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 50
$ht_Data.Text = "Emailadresse"

Create-Object -Name lb_Email -Type Label -Data $ht_Data -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 50
$ht_Data.Text = "Passwort"

Create-Object -Name lb_Password -Type Label -Data $ht_Data -Control Form

# =============================================================
# ========== Form: TextBoxes ==================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,($lb_URL.Bounds.Bottom))
            Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - 20),20)
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
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

$ht_Data.Location.Y += 50

Create-Object -Name tb_UserName -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 50

Create-Object -Name tb_Email -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 50

Create-Object -Name tb_Password -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# =============================================================
# ========== Form: Buttons ====================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(30,($tb_Password.Bounds.Bottom + 10))
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

$ht_Data.Location.X = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
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

$ht_Data.Location.X = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
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
            Location = New-Object System.Drawing.Point(10,($bt_Add.Bounds.Bottom + 10))
            Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - 20),140)
            BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
            }

Create-Object -Name pn_Panel -Type Panel -Data $ht_Data -Control Form

# =============================================================
# ========== Form: TextBoxes ==================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(20,($pn_Panel.Bounds.Top + 10))
            Size = New-Object System.Drawing.Size(($pn_Panel.ClientSize.Width - 20),20)
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
            BackColor = $TextBoxColor
            Cursor = [System.Windows.Forms.Cursors]::Hand
            Text = "[URL]"
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
                        $Tooltip.SetToolTip($this,"Klicken um Inhalt in die Zwischenablage zu kopieren.")
                    })}
              )

Create-Object -Name tb_r_URL -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 30
$ht_Data.Text = "[Benutzername]"

Create-Object -Name tb_r_UserName -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 30
$ht_Data.Text = "[Emailadresse]"

Create-Object -Name tb_r_Email -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Location.Y += 30
$ht_Data.Text = "[Passwort]"

Create-Object -Name tb_r_Password -Type TextBox -Data $ht_Data -Events $ar_Events -Control Form

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(($Form.ClientSize.Width / 2 - 40),($tb_r_Password.Bounds.Bottom + 3))
            Size = New-Object System.Drawing.Size(80,26)
            Text = "- / -"
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            }

Create-Object -Name lb_Page -Type Label -Data $ht_Data -Control Form

$pn_Panel.SendToBack()

# =============================================================
# ========== Form: Buttons ====================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point((($Form.ClientSize.Width / 2) - ($ButtonSizeA.Width / 2)),($pn_Panel.Bounds.Bottom + 15))
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

$ht_Data.Location.X = 30
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

$ht_Data.Location.X = $Form.ClientSize.Width - 30 - $ButtonSizeA.Width
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
            Location = New-Object System.Drawing.Point((($Form.ClientSize.Width / 2) - ($ButtonSizeB.Width / 2)),($bt_Next.Bounds.Bottom + 10))
            Size = $ButtonSizeB
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            Text = "Master-Passwort"
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

$ar_Events = @({Add_Click({$MPW_Form.ShowDialog()})})

Create-Object -Name bt_MPW -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data = @{
            Location = New-Object System.Drawing.Point(30,($bt_MPW.Bounds.Bottom + 10))
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

$ht_Data.Location.X = $Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
$ht_Data.Image = $Icons.Metadata
$ht_Data += @{Enabled = $false}

$ar_Events = @({Add_Click({$Metadata_Form.ShowDialog()})})

Create-Object -Name bt_Metadata -Type Button -Data $ht_Data -Events $ar_Events -Control Form

# -------------------------------------------------------------

$ht_Data.Location.X = $Form.ClientSize.Width - $ButtonSizeA.Width - 30
$ht_Data.Image = $Icons.Exit
$ht_Data.Enabled = $true

Create-Object -Name bt_Exit -Type Button -Data $ht_Data -Control Form

$Form.CancelButton = $bt_Exit

# =============================================================
# ========== Form: Labels =====================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,($bt_Exit.Bounds.Bottom + 10))
            Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - 20),20)
            Text = "Ereignisse"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
            }

Create-Object -Name lb_Events -Type Label -Data $ht_Data -Control Form

# =============================================================
# ========== Form: TextBoxes ==================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,$lb_Events.Bounds.Bottom)
            Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - 20),($Form.ClientSize.Height - $lb_Events.Bounds.Bottom - 10))
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
            BackColor = $TextBoxColor
            Cursor = [System.Windows.Forms.Cursors]::IBeam
            Multiline = $true
            ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
            WordWrap = $true
            ReadOnly = $true
            }

Create-Object -Name tb_Events -Type TextBox -Data $ht_Data -Control Form

# =============================================================
# ========== MPW_Form =========================================
# =============================================================

$ht_Data = @{
            ClientSize = New-Object System.Drawing.Size(400,120)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
            Text = "Master-Passwort eingeben"
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

# =============================================================
# ========== MPW_Form: Labels =================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,10)
            Size = New-Object System.Drawing.Size(($MPW_Form.ClientSize.Width - 20),20)
            Text = "Master-Passwort"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
            }

Create-Object -Name lb_MPW -Type Label -Data $ht_Data -Control MPW_Form

# =============================================================
# ========== MPW_Form: TextBoxes ==============================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,$lb_MPW.Bounds.Bottom)
            Size = New-Object System.Drawing.Size(($MPW_Form.ClientSize.Width - 20),20)
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
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
            Location = New-Object System.Drawing.Point(20,(($MPW_Form.ClientSize.Height - $ButtonSizeA.Height) - 14))
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

$ht_Data.Location.X = $MPW_Form.ClientSize.Width / 2 - $ButtonSizeA.Width / 2
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

$ht_Data.Location.X = $MPW_Form.ClientSize.Width - 20 - $ButtonSizeA.Width
$ht_Data.Image = $Icons.Close

$ar_Events = @({Add_Click({$MPW_Form.Close()})})

Create-Object -Name bt_MPW_Close -Type Button -Data $ht_Data -Events $ar_Events -Control MPW_Form

# =============================================================
# ========== Edit_Form ========================================
# =============================================================

$ht_Data = @{
            ClientSize = New-Object System.Drawing.Size(450,120)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
            Text = "Änderungsbestätigung"
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

# =============================================================
# ========== Edit_Form: Labels =================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,20)
            Size = New-Object System.Drawing.Size(($Edit_Form.ClientSize.Width - 20),20)
            Text = "Datensatz wird überschrieben. Fortfahren?"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            }

Create-Object -Name lb_Edit -Type Label -Data $ht_Data -Control Edit_Form

# =============================================================
# ========== Edit_Form: Buttons ================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point((($Edit_Form.ClientSize.Width / 2) - ($ButtonSizeC.Width / 2) - 100), ($Edit_Form.ClientSize.Height - $ButtonSizeC.Height - 20))
            Size = $ButtonSizeC
            Text = "Ja"
            DialogResult = [System.Windows.Forms.DialogResult]::OK
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BackColor = $ButtonColorC
            FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

Create-Object -Name bt_Edit_OK -Type Button -Data $ht_Data -Control Edit_Form

$Edit_Form.AcceptButton = $bt_Edit_OK

# -------------------------------------------------------------

$ht_Data.Location.X = $Edit_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 + 100
$ht_Data.Text = "Nein"
$ht_Data.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

Create-Object -Name bt_Edit_Cancel -Type Button -Data $ht_Data -Control Edit_Form

$Edit_Form.CancelButton = $bt_Edit_Cancel

# =============================================================
# ========== Del_Form =========================================
# =============================================================

$ht_Data = @{
            ClientSize = New-Object System.Drawing.Size(450,120)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
            Text = "Löschbestätigung"
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

# =============================================================
# ========== Del_Form: Labels =================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,20)
            Size = New-Object System.Drawing.Size(($Del_Form.ClientSize.Width - 20),20)
            Text = "Datensatz wird unwiderruflich gelöscht. Fortfahren?"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            }

Create-Object -Name lb_Del -Type Label -Data $ht_Data -Control Del_Form

# =============================================================
# ========== Del_Form: Buttons ================================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point((($Del_Form.ClientSize.Width / 2) - ($ButtonSizeC.Width / 2) - 100), ($Del_Form.ClientSize.Height - $ButtonSizeC.Height - 20))
            Size = $ButtonSizeC
            Text = "Ja"
            DialogResult = [System.Windows.Forms.DialogResult]::OK
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BackColor = $ButtonColorC
            FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
            Cursor = [System.Windows.Forms.Cursors]::Hand
            }

Create-Object -Name bt_Del_OK -Type Button -Data $ht_Data -Control Del_Form

$Del_Form.AcceptButton = $bt_Del_OK

# -------------------------------------------------------------

$ht_Data.Location.X = $Del_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 + 100
$ht_Data.Text = "Nein"
$ht_Data.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

Create-Object -Name bt_Del_Cancel -Type Button -Data $ht_Data -Control Del_Form

$Del_Form.CancelButton = $bt_Del_Cancel

# =============================================================
# ========== PW_Generator_Form ================================
# =============================================================

$ht_Data = @{
            ClientSize = New-Object System.Drawing.Size(560,150)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
            Text = "Passwort-Generator"
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

# =============================================================
# ========== PW_Generator_Form: Labels ========================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(($PW_Generator_Form.ClientSize.Width / 2 - 60),10)
            Size = New-Object System.Drawing.Size(120,22)
            Text = "Konfiguration"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
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
            Location = New-Object System.Drawing.Point(10,($PW_Generator_Form.ClientSize.Height / 2 - 15))
            Size = New-Object System.Drawing.Size(($PW_Generator_Form.ClientSize.Width - 20),20)
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
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
                        $Tooltip.SetToolTip($this,"Klicken um Inhalt in die Zwischenablage zu kopieren.")
                    })}
              )

Create-Object -Name tb_r_Generator -Type TextBox -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== PW_Generator_Form: Panels ========================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(($PW_Generator_Form.ClientSize.Width / 2 - 180),20)
            Size = New-Object System.Drawing.Size(360,120)
            BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
            BackColor = $PanelColor
            }

$ar_Events = @(
                {Add_MouseLeave(
                    {
                        $Point = New-Object System.Drawing.Point(([System.Windows.Forms.Cursor]::Position.X + 3),([System.Windows.Forms.Cursor]::Position.Y + 3))
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
            Location = New-Object System.Drawing.Point((($PW_Generator_Form.ClientSize.Width / 2) - ($ButtonSizeC.Width / 2) - 100),($PW_Generator_Form.ClientSize.Height - $ButtonSizeC.Height - 10))
            Size = $ButtonSizeC
            Text = "Erstellen"
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
                                $RND = Get-Random -Minimum 33 -Maximum 126
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

$ht_Data.Location.X = $PW_Generator_Form.ClientSize.Width / 2 - $ButtonSizeC.Width / 2 + 100
$ht_Data.Text = "Schließen"

$ar_Events = @({Add_Click({$PW_Generator_Form.Close()})})

Create-Object -Name bt_PW_Close -Type Button -Data $ht_Data -Events $ar_Events -Control PW_Generator_Form

# =============================================================
# ========== Metadata_Form ====================================
# =============================================================

$ht_Data = @{
            ClientSize = New-Object System.Drawing.Size(400,350)
            StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            Icon = $Paths.IconFolder + "Login-Manager.ico"
            Text = "Metadaten"
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

# =============================================================
# ========== Metadata_Form: Labels ============================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,10)
            Size = New-Object System.Drawing.Size(($Metadata_Form.ClientSize.Width - 20),20)
            Text = "Metadaten"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
            }

Create-Object -Name lb_Metadata -Type Label -Data $ht_Data -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: TextBoxes =========================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,$lb_Metadata.Bounds.Bottom)
            Size = New-Object System.Drawing.Size(($Metadata_Form.ClientSize.Width - 20),120)
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
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

$ht_Data.Location = New-Object System.Drawing.Point(20,($tb_Metadata.Bounds.Bottom + 20))
$ht_Data.Size = New-Object System.Drawing.Size(($Metadata_Form.ClientSize.Width - 40),120)
$ht_Data.Cursor = [System.Windows.Forms.Cursors]::Hand
$ht_Data += @{
             Text = "[Metadaten]"
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
                        $Tooltip.SetToolTip($this,"Klicken um Inhalt in die Zwischenablage zu kopieren.")
                    })}
              )

Create-Object -Name tb_r_Metadata -Type TextBox -Data $ht_data -Events $ar_Events -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: Panels ============================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(10,($tb_Metadata.Bounds.Bottom + 10))
            Size = New-Object System.Drawing.Size(($Metadata_Form.ClientSize.Width - 20),140)
            BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
            }

Create-Object -Name pn_Metadata -Type Panel -Data $ht_Data -Control Metadata_Form

# =============================================================
# ========== Metadata_Form: Buttons ===========================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point((($Metadata_Form.ClientSize.Width / 2) - ($ButtonSizeC.Width / 2)),($Metadata_Form.ClientSize.Height - $ButtonSizeC.Height - 10))
            Size = $ButtonSizeC
            Text = "Schließen"
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
            Location = New-Object System.Drawing.Point(($pn_Exclusions.Width / 2 - 50),20)
            Size = New-Object System.Drawing.Size(100,20)
            Text = "Ausschlüsse"
            Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
            TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            BorderStyle = [System.Windows.Forms.BorderStyle]::None
            }

Create-Object -Name lb_Exclusions -Type Label -Data $ht_Data -Control pn_Exclusions

# -------------------------------------------------------------

$ht_Data.Location.Y += 60
$ht_Data.Text = "$Global:Chars Zeichen"

Create-Object -Name lb_Chars -Type Label -Data $ht_Data -Control pn_Exclusions

# =============================================================
# ========== pn_Exclusions: TextBoxes =========================
# =============================================================

$ht_Data = @{
            Location = New-Object System.Drawing.Point(($pn_Exclusions.Width / 2 - 170),$lb_Exclusions.Bounds.Bottom)
            Size = New-Object System.Drawing.Size(340,20)
            Font = New-Object System.Drawing.Font($FontName, ($FontSize - 1), $FontStyle)
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
            Location = New-Object System.Drawing.Point(100,$lb_Chars.Bounds.Top)
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
                                $lb_Chars.Text = "$Global:Chars Zeichen"
                            }
                    })}
              )

Create-Object -Name bt_Chars_Minus -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Exclusions

# -------------------------------------------------------------

$ht_Data.Location.X = $pn_Exclusions.Width - $ButtonSizeD.Width - 100
$ht_Data.Text = "+"

$ar_Events = @(
                {Add_Click(
                    {
                        If ($Global:Chars -lt 64)
                            {
                                $Global:Chars += 16
                                $lb_Chars.Text = "$Global:Chars Zeichen"
                            }
                    })}
              )

Create-Object -Name bt_Chars_Plus -Type Button -Data $ht_Data -Events $ar_Events -Control pn_Exclusions

# =============================================================
# ========== Show Dialog ======================================
# =============================================================

$Form.ShowDialog()