# PowerShell Script to Check Python Installation
# This script verifies Python 3.11.9 is properly installed

Write-Host "Checking Python installation..." -ForegroundColor Cyan

# Check if Python is in PATH
$pythonCommand = Get-Command python -ErrorAction SilentlyContinue

if ($pythonCommand) {
    $version = & python --version 2>&1
    Write-Host "Found: $version" -ForegroundColor Green
    
    if ($version -match "Python 3\.11") {
        Write-Host "✓ Python 3.11.x is installed" -ForegroundColor Green
        
        # Check if requests library is installed
        Write-Host "`nChecking for 'requests' library..." -ForegroundColor Cyan
        $requestsCheck = & python -c "import requests; print(requests.__version__)" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ requests library is installed (version $requestsCheck)" -ForegroundColor Green
        } else {
            Write-Host "✗ requests library is NOT installed" -ForegroundColor Red
            Write-Host "Installing requests library..." -ForegroundColor Yellow
            & python -m pip install requests
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Successfully installed requests library" -ForegroundColor Green
            } else {
                Write-Host "✗ Failed to install requests library" -ForegroundColor Red
                Write-Host "Please run manually: pip install requests" -ForegroundColor Yellow
            }
        }
        
        # Check pip
        Write-Host "`nChecking pip..." -ForegroundColor Cyan
        $pipVersion = & python -m pip --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ pip is working: $pipVersion" -ForegroundColor Green
        } else {
            Write-Host "✗ pip is not working properly" -ForegroundColor Red
        }
        
        Write-Host "`n✓ All checks passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "✗ Wrong Python version. Need Python 3.11.x, found: $version" -ForegroundColor Red
        Write-Host "Please install Python 3.11.9 from: https://www.python.org/downloads/" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✗ Python is not found in PATH" -ForegroundColor Red
    
    # Check common installation locations
    $commonPaths = @(
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "C:\Python311\python.exe",
        "$env:PROGRAMFILES\Python311\python.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            Write-Host "Found Python at: $path" -ForegroundColor Yellow
            Write-Host "But it's not in PATH. Please add it to PATH or reinstall Python with 'Add to PATH' option." -ForegroundColor Yellow
            exit 1
        }
    }
    
    Write-Host "Python 3.11.9 needs to be installed." -ForegroundColor Yellow
    Write-Host "Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "During installation, make sure to check 'Add Python to PATH'" -ForegroundColor Yellow
    exit 1
}
