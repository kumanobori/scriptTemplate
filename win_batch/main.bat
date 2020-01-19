@echo off
@echo -------------------------------------

REM バッチファイルのある場所をカレントにする
cd /d %~dp0

REM 起動時刻でYYYYMMDD_HHMMSS文字列を生成、ログファイル名に組み込む
SET HOUR_ORG=%time:~0,2%
SET HOUR_ZERO_PADDING=%HOUR_ORG: =0%
SET START_TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%HOUR_ZERO_PADDING%%time:~3,2%%time:~6,2%
SET LOGFILE=batch_%START_TIMESTAMP%.log

REM 開始メッセージを、画面とログファイル両方に出す。
call :logInfo "start."
call :logInfo "start." >> %LOGFILE% 2>&1



REM 処理をここに書く
call :logInfo "処理" >> %LOGFILE% 2>&1
call :logDebug "処理" >> %LOGFILE% 2>&1
call :logError "処理" >> %LOGFILE% 2>&1
REM 処理をここに書く



REM ログファイルの情報を画面だけに出す
call :logInfo "log file is %LOGFILE%"

REM 終了メッセージを、画面とログファイル両方に出す。
call :logInfo "end."
call :logInfo "end." >> %LOGFILE% 2>&1

@echo -------------------------------------
@pause
exit /b

REM ========================
REM ログ出力用サブルーチン
REM ========================
:logDebug
    call :log [DEBUG] %1
    exit /b
:logInfo
    call :log [INFO] %1
    exit /b
:logError
    call :log [ERROR] %1
    exit /b
:log
    echo %date%_%time:~0,8% %1 %~2
    exit /b
