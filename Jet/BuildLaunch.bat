@echo off
setlocal EnableDelayedExpansion
::  For transparency's sake, this script was AI generated.
::  Please keep in mind that no parts of the actual mod were made using AI.
REM ============ Configuration ============
set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
set "SOURCE_FOLDER=BTD5"
set "OUTPUT_ZIP=%~dp0BTD5.jet"
set "DESTINATION=D:\Steam\steamapps\common\BloonsTD5\Assets\BTD5.jet"
set "PASSWORD=Q%%_{6#Px]]"
set "LAUNCH_EXE=BTD5-Win.exe"
REM =======================================

REM Check that 7-Zip exists
if not exist "%SEVENZIP%" (
    echo [ERROR] 7-Zip not found at "%SEVENZIP%"
    echo Edit the SEVENZIP variable at the top of this script.
    exit /b 1
)

REM Check that the source folder exists
if not exist "%SOURCE_FOLDER%\" (
    echo [ERROR] Folder "%SOURCE_FOLDER%" not found in the current directory.
    exit /b 1
)

REM Delete old working archive if it exists
if exist "%OUTPUT_ZIP%" del /f /q "%OUTPUT_ZIP%"

echo Creating "%OUTPUT_ZIP%" ...
pushd "%SOURCE_FOLDER%"
"%SEVENZIP%" a -tzip -mem=ZipCrypto -p"%PASSWORD%" "%OUTPUT_ZIP%" "*"
set "ZIP_RESULT=%errorlevel%"
popd

if not "%ZIP_RESULT%"=="0" (
    echo [ERROR] Failed to create the archive.
    exit /b 1
)

REM Make sure the destination folder exists
for %%I in ("%DESTINATION%") do set "DEST_DIR=%%~dpI"
if not exist "%DEST_DIR%" (
    echo Creating destination folder "%DEST_DIR%" ...
    mkdir "%DEST_DIR%"
    if errorlevel 1 (
        echo [ERROR] Could not create destination folder.
        exit /b 1
    )
)

REM ---- Backup existing BTD5.jet before replacing ----
if exist "%DESTINATION%" (
    REM Derive BTD5 directory: DESTINATION is ...\BloonsTD5\Assets\BTD5.jet
    set "DEST_DIR_NO_TRAIL=!DEST_DIR:~0,-1!"
    for %%I in ("!DEST_DIR_NO_TRAIL!") do set "BTD5_DIR=%%~dpI"
    set "BACKUP_DIR=!BTD5_DIR!Backups"

    if not exist "!BACKUP_DIR!" (
        echo Creating backup folder "!BACKUP_DIR!" ...
        mkdir "!BACKUP_DIR!"
        if errorlevel 1 (
            echo [ERROR] Could not create backup folder.
            exit /b 1
        )
    )

    for %%F in ("%DESTINATION%") do (
        set "DEST_NAME=%%~nF"
        set "DEST_EXT=%%~xF"
    )

    set "BACKUP_DATE="
    for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "(Get-Item -LiteralPath '%DESTINATION%').LastWriteTime.ToString('yyyy-MM-dd_HH-mm-ss')" 2^>nul`) do set "BACKUP_DATE=%%D"
    if not defined BACKUP_DATE set "BACKUP_DATE=unknown-date"

    set "BACKUP_FILE=!BACKUP_DIR!\!DEST_NAME!_!BACKUP_DATE!!DEST_EXT!"
    echo Backing up old archive to "!BACKUP_FILE!" ...
    move /Y "%DESTINATION%" "!BACKUP_FILE!" >nul
    if errorlevel 1 (
        echo [ERROR] Failed to back up existing archive. Aborting.
        exit /b 1
    )
)

REM Move (replace) the archive at the destination
echo Delivering to "%DESTINATION%" ...
move /Y "%OUTPUT_ZIP%" "%DESTINATION%" >nul

if errorlevel 1 (
    echo [ERROR] Failed to move the archive to the destination.
    exit /b 1
)

echo Done. Archive delivered to: %DESTINATION%

REM ---- Derive the game folder from DESTINATION and launch ----
REM DESTINATION is  ...\BloonsTD5\Assets\BTD5.jet
REM We want        ...\BloonsTD5\BTD5-Win.exe
for %%I in ("%DESTINATION%") do set "ASSETS_DIR=%%~dpI"
set "ASSETS_DIR=%ASSETS_DIR:~0,-1%"
for %%I in ("%ASSETS_DIR%") do set "GAME_DIR=%%~dpI"
set "GAME_EXE=%GAME_DIR%%LAUNCH_EXE%"

if not exist "%GAME_EXE%" (
    echo [WARN] Could not find "%GAME_EXE%" - skipping launch.
    exit /b 0
)

echo Launching "%GAME_EXE%" ...
start "" "%GAME_EXE%"

endlocal