@echo off
@echo -------------------------------------

REM �o�b�`�t�@�C���̂���ꏊ���J�����g�ɂ���
cd /d %~dp0

REM �N��������YYYYMMDD_HHMMSS������𐶐��A���O�t�@�C�����ɑg�ݍ���
SET HOUR_ORG=%time:~0,2%
SET HOUR_ZERO_PADDING=%HOUR_ORG: =0%
SET START_TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%HOUR_ZERO_PADDING%%time:~3,2%%time:~6,2%
SET LOGFILE=batch_%START_TIMESTAMP%.log

REM �J�n���b�Z�[�W���A��ʂƃ��O�t�@�C�������ɏo���B
call :logInfo "start."
call :logInfo "start." >> %LOGFILE% 2>&1



REM �����������ɏ���
call :logInfo "����" >> %LOGFILE% 2>&1
call :logDebug "����" >> %LOGFILE% 2>&1
call :logError "����" >> %LOGFILE% 2>&1
REM �����������ɏ���



REM ���O�t�@�C���̏�����ʂ����ɏo��
call :logInfo "log file is %LOGFILE%"

REM �I�����b�Z�[�W���A��ʂƃ��O�t�@�C�������ɏo���B
call :logInfo "end."
call :logInfo "end." >> %LOGFILE% 2>&1

@echo -------------------------------------
@pause
exit /b

REM ========================
REM ���O�o�͗p�T�u���[�`��
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
