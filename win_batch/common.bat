REM ‹N“®‚ÅYYYYMMDD_HHMMSS•¶š—ñ‚ğ¶¬
SET HOUR_ORG=%time:~0,2%
SET HOUR_ZERO_PADDING=%HOUR_ORG: =0%
SET START_TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%HOUR_ZERO_PADDING%%time:~3,2%%time:~6,2%


:getCurrentYmdhis
    echo %date% %time:~0,8%
    exit /b

