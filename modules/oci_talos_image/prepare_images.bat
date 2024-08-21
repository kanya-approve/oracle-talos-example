@echo off

REM Download the file
curl -Ls "https://github.com/siderolabs/talos/releases/download/v1.7.6/oracle-arm64.qcow2.xz" -o oracle-arm64.qcow2.xz

REM Check if xz is installed
where xz >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    REM If xz is found, use it to decompress
    xz -d --keep oracle-arm64.qcow2.xz
) ELSE (
    REM If xz is not found, check for 7z and use it
    where "C:\Program Files\7-Zip\7z.exe" >nul 2>&1
    IF %ERRORLEVEL% EQU 0 (
        "C:\Program Files\7-Zip\7z.exe" e oracle-arm64.qcow2.xz
    ) ELSE (
        echo Neither xz nor 7z found. Please install one of them.
        exit /b 1
    )
)

REM Continue with the rest of the script
copy image_metadata_arm64.json image_metadata.json
tar -cf oracle-arm64.oci oracle-arm64.qcow2 image_metadata.json
del *.qcow2 image_metadata.json
del oracle-arm64.qcow2.xz

echo Operation completed successfully.
