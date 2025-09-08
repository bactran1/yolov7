@echo off
setlocal

REM ============================================
REM YOLOv7 CPU environment bootstrapper (Windows)
REM ============================================

REM ---   Configurable bits   ---
set "CONDA_DIR=C:\ProgramData\miniconda3"
set "ENV_NAME=yolov7-test"
set "PY_VER=3.10"
set "MINICONDA_VER=py311_24.7.1-0"
set "MINICONDA_EXE=Miniconda3-%MINICONDA_VER%-Windows-x86_64.exe"
set "DOWNLOAD_URL=https://repo.anaconda.com/miniconda/%MINICONDA_EXE%"

echo:
echo === YOLOv7 CPU Setup ===
echo Target conda: %CONDA_DIR%
echo Env name     : %ENV_NAME%
echo Python       : %PY_VER%
echo:

REM --- Check OS architecture ---
if /i not "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
  echo [ERROR] This script is for 64-bit Windows. Exiting.
  exit /b 1
)

REM --- Install Miniconda if missing ---
if not exist "%CONDA_DIR%\Scripts\conda.exe" (
  echo [INFO] Miniconda not found. Installing to %CONDA_DIR% ...
  set "TMP_DL=%TEMP%\%MINICONDA_EXE%"
  echo [INFO] Downloading Miniconda installer...
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TMP_DL%' -UseBasicParsing } Catch { exit 1 }"
  if errorlevel 1 (
    echo [ERROR] Failed to download Miniconda.
    exit /b 1
  )
  echo [INFO] Running silent installer...
  "%TMP_DL%" /InstallationType=JustMe /AddToPath=1 /RegisterPython=0 /D=%CONDA_DIR%
  if errorlevel 1 (
    echo [ERROR] Miniconda installation failed.
    exit /b 1
  )
REM  del /q "%TMP_DL%" >nul 2>&1
) else (
  echo [INFO] Miniconda already present at %CONDA_DIR%.
)

REM --- Initialize conda ---
call "%CONDA_DIR%\Scripts\activate.bat"
if errorlevel 1 (
  echo [ERROR] Could not activate base conda environment.
  exit /b 1
)

REM --- Create (or reuse) environment ---
for /f "tokens=*" %%E in ('conda env list ^| findstr /i " %ENV_NAME% "') do set "ENV_EXISTS=1"
if defined ENV_EXISTS (
  echo [INFO] Conda env "%ENV_NAME%" already exists. Skipping creation.
) else (
  echo [INFO] Creating env "%ENV_NAME%" with Python %PY_VER% ...
  conda create -y -n "%ENV_NAME%" python=%PY_VER%
  if errorlevel 1 (
    echo [ERROR] Failed to create conda env.
    exit /b 1
  )
)

REM --- Activate env ---
call conda activate "%ENV_NAME%"
if errorlevel 1 (
  echo [ERROR] Failed to activate env "%ENV_NAME%".
  exit /b 1
)

REM --- Upgrade pip tooling ---
python -m pip install --upgrade pip setuptools wheel

REM --- Install PyTorch CPU wheels ---
echo [INFO] Installing PyTorch CPU build...
python -m pip install --index-url https://download.pytorch.org/whl/cu128 ^
  torch torchvision torchaudio

REM --- Install YOLOv7 dependencies ---
echo [INFO] Installing YOLOv7 dependencies...
python -m pip install ^
  opencv-python>=4.1.1 ^
  numpy ^
  matplotlib ^
  seaborn ^
  pandas ^
  pillow ^
  PyYAML ^
  scipy ^
  tqdm ^
  requests ^
  psutil ^
  thop ^
  tensorboard ^
  onnx onnxruntime

REM --- Verify ---
echo [INFO] Verifying installation...
python - <<PYCODE
import sys, torch, cv2
print("python:", sys.version)
print("torch:", torch.__version__, "cuda_available:", torch.cuda.is_available())
print("opencv:", cv2.__version__)
PYCODE

echo:
echo ============================================
echo  Setup complete!
echo  To use this environment in a new prompt:
echo      conda activate yolov7
echo  (Python version is pinned to %PY_VER%)
echo ============================================
echo:

endlocal
exit /b 0
