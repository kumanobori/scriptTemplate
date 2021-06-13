# 開始日時取得
$startDate = Get-Date
$startYmdHms = $startDate.ToString("yyyyMMddHHmmss")

# $LOGPATH = $PSScriptRoot+ "\" + $Args[0] + "_" + $startYmdHms + ".log"
$LOGPATH = "c:\data\log.txt"

# ログファイルモード
$LOG_FILE_MODE = $true

# バッチに適用するログレベル
$LOG_LEVEL = 1

# ログレベル定数
$LOG_LEVEL_TRACE = 1
$LOG_LEVEL_DEBUG = 2
$LOG_LEVEL_INFO = 3
$LOG_LEVEL_WARN = 4
$LOG_LEVEL_ERROR = 5
$LOG_LEVEL_NONE = 6

# ログレベルに対応する動作
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'
$InformationPreference = 'Continue'
$WarningPreference = 'Continue'
$ErrorActionPreference = 'Continue'

# ログ出力関数
function log([int] $level, [string] $funcName, [string] $prefix, [string] $message) {
    if($level -lt $LOG_LEVEL) {
        return
    }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss "
    
    if ($LOG_FILE_MODE) {
        echo ("{0}{1}{2}" -f $timestamp, $prefix, $message) >> $LOGPATH
    } else {
        & $funcName ("{0}{1}{2}" -f $timestamp, $prefix, $message)
    }
}

function logError([string] $message) {
    log $LOG_LEVEL_ERROR "Write-Error" "[ERROR] " $message
}
function logWarn([string] $message) {
    log $LOG_LEVEL_WARN "Write-Warning" "[WARN] " $message
}
function logInfo([string] $message) {
    # log $LOG_LEVEL_INFO "Write-Information" "[INFO] " $message
    log $LOG_LEVEL_INFO "Write-Host" "[INFO] " $message
}
function logDebug([string] $message) {
    # log $LOG_LEVEL_DEBUG "Write-Debug" "[DEBUG] " $message
    log $LOG_LEVEL_DEBUG "Write-Host" "[DEBUG] " $message
}
function logTrace([string] $message) {
    # log $LOG_LEVEL_TRACE "Write-Verbose" "[TRACE]" $message
    log $LOG_LEVEL_TRACE "Write-Host" "[TRACE] " $message
}
