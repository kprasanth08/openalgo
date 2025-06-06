@echo off
setlocal EnableDelayedExpansion

echo Creating portable Docker image for OpenAlgo...

:: Set version to latest
set VERSION=latest

:: Build the Docker image from repo directory
cd ..
echo Building Docker image...
docker build -t openalgo:!VERSION! .\openalgo

:: Create a directory for the portable package
set PACKAGE_DIR=openalgo_portable_!VERSION!
if exist "!PACKAGE_DIR!" rd /s /q "!PACKAGE_DIR!"
mkdir "!PACKAGE_DIR!"

:: Save the Docker image to a tar file
echo Saving Docker image to tar file...
docker save openalgo:!VERSION! > "!PACKAGE_DIR!\openalgo_image.tar"

:: Copy necessary files from repo
echo Copying deployment files...
copy /Y "openalgo\docker-compose.yaml" "!PACKAGE_DIR!\"
copy /Y "openalgo\start.sh" "!PACKAGE_DIR!\"

:: Create instructions file
(
echo # OpenAlgo Portable Deployment
echo.
echo This package contains everything needed to run OpenAlgo in an offline environment.
echo.
echo ## Deployment Steps
echo.
echo 1. Load the Docker image:
echo    ```bash
echo    docker load ^< openalgo_image.tar
echo    ```
echo.
echo 2. Start the application:
echo    ```bash
echo    docker-compose up -d
echo    ```
echo.
echo 3. The application will be available at http://localhost:8000
echo.
echo ## Requirements
echo - Docker Engine 20.10 or later
echo - Docker Compose v2.0 or later
) > "!PACKAGE_DIR!\DEPLOY.md"

:: Create ZIP archive
echo Creating ZIP archive...
if exist "!PACKAGE_DIR!.zip" del "!PACKAGE_DIR!.zip"
powershell -Command "Compress-Archive -Path '!PACKAGE_DIR!' -DestinationPath '!PACKAGE_DIR!.zip' -Force"

:: Cleanup
rd /s /q "!PACKAGE_DIR!"

echo Portable package created: !PACKAGE_DIR!.zip
echo Done!

:: Return to original directory
cd openalgo

