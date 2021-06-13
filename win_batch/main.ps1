# 管理者権限でない場合、現在のスクリプトを管理者権限で実行する
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    echo "not administrator"
    Start-Process powershell.exe "-File `"$MyInvocation.MyCommand.path`"" -Verb RunAs $Args
    exit
}


echo "administrator"
pause
