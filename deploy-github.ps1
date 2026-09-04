# Deploy Saqib portfolio to GitHub + enable Pages
# Run from PowerShell:
#   cd C:\Users\Amum\Downloads\Saqib-Portfolio
#   powershell -ExecutionPolicy Bypass -File .\deploy-github.ps1

$ErrorActionPreference = "Stop"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Set-Location $PSScriptRoot

Write-Host "Checking GitHub login..." -ForegroundColor Cyan
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub login required. Complete the browser login, then run this script again." -ForegroundColor Yellow
    Start-Process "https://github.com/login/device"
    gh auth login -h github.com -p https -w
    gh auth status *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Login not completed. Run this script again after signing in." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Creating repo saqibportfolio (if needed)..." -ForegroundColor Cyan
gh repo view saqibma960-prog/saqibportfolio *> $null
if ($LASTEXITCODE -ne 0) {
    gh repo create saqibportfolio --public --description "Saqib Sharif - PHP Laravel Portfolio" --source=. --remote=origin --push
} else {
    if (-not (git remote get-url origin 2>$null)) {
        git remote add origin https://github.com/saqibma960-prog/saqibportfolio.git
    }
    git push -u origin main
}

Write-Host "Enabling GitHub Pages..." -ForegroundColor Cyan
gh api repos/saqibma960-prog/saqibportfolio/pages -X POST -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" *> $null
if ($LASTEXITCODE -ne 0) {
    gh api repos/saqibma960-prog/saqibportfolio/pages -X PUT -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" *> $null
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host "Repo:  https://github.com/saqibma960-prog/saqibportfolio" -ForegroundColor Green
Write-Host "Live:  https://saqibma960-prog.github.io/saqibportfolio/" -ForegroundColor Green
Write-Host "Pages may take 1-2 minutes on first deploy." -ForegroundColor Yellow
