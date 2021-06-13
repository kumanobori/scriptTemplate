# カレントディレクトリをスクリプトのあるディレクトリに変更する
# （スクリプトがそれを前提としていないなら不要）
Set-Location -Path $PSScriptRoot
. .\common.ps1 "log"

logDebug "start"

# 管理者権限でない場合、現在のスクリプトを管理者権限で実行して自分は終了
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    $commandPath = $PSCommandPath
    logDebug ("not admin. restart as admin:" + $commandPath)
    
    # 引数を、管理者権限実行用に作り直す
    # 引数が、クォートされた空白を含む文字列である場合を想定。
    # そこまで考えないでいいなら、Start-Process の $argsToAdminProcess の代わりに$Argsを入れても問題ない。
    $argsToAdminProcess = ""
    $Args.ForEach{
        logDebug ("not admin: args: " + $PSItem)
        $argsToAdminProcess += " `"$PSItem`""
    }

    # 実行
    Start-Process powershell.exe "-File `"$commandPath`" $argsToAdminProcess"  -Verb RunAs
    # デバッグ用。Pauseしないといけない理由は特にない。
    Pause
    exit
}



logDebug "admin"

# 管理権限実行に渡ってきた引数を確認する
$Args.ForEach{
    logDebug ("admin: args: " + $PSItem)
}

# デバッグ用。Pauseしないといけない理由は特にない。
Pause
