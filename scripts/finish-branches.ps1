$ErrorActionPreference = "Stop"
$root = "F:\trip_advisor_chatbot_project"
Set-Location $root

$tmpSave = "$env:TEMP\travel-repo-setup-v2"
if (Test-Path $tmpSave) { Remove-Item $tmpSave -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path "$tmpSave\backend" -Force | Out-Null
New-Item -ItemType Directory -Path "$tmpSave\frontend" -Force | Out-Null

robocopy "$root\backend" "$tmpSave\backend" /E /XD venv __pycache__ .pytest_cache /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
robocopy "$root\frontend" "$tmpSave\frontend" /E /XD build .dart_tool /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
Copy-Item "$root\scripts\README-backend.md" "$tmpSave\README-backend.md" -Force
Copy-Item "$root\scripts\README-frontend.md" "$tmpSave\README-frontend.md" -Force

function Clear-RootExceptGit {
    Get-ChildItem $root -Force | Where-Object { $_.Name -ne '.git' -and $_.Name -ne 'backend' } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path "$root\backend") {
        Get-ChildItem "$root\backend" -Force | Where-Object { $_.Name -ne 'venv' } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# BACKEND
git checkout --orphan backend
git rm -rf --cached . 2>$null | Out-Null
Clear-RootExceptGit
Copy-Item "$tmpSave\backend\*" $root -Recurse -Force
Copy-Item "$tmpSave\README-backend.md" "$root\README.md" -Force
Set-Content "$root\.gitignore" "venv/`n__pycache__/`n**/__pycache__/`n*.db`n.env`n*.pyc`n.idea/`n.vscode/`n.DS_Store"
git add .
git commit -m "Backend branch: FastAPI travel chatbot API with RAG and NLP."

# FRONTEND
git checkout --orphan frontend
git rm -rf --cached . 2>$null | Out-Null
Clear-RootExceptGit
Get-ChildItem $root -Force | Where-Object { $_.Name -eq 'backend' } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$tmpSave\frontend\*" $root -Recurse -Force
Copy-Item "$tmpSave\README-frontend.md" "$root\README.md" -Force
Set-Content "$root\.gitignore" ".dart_tool/`nbuild/`n.flutter-plugins`n.flutter-plugins-dependencies`n.packages`n.pub-cache/`n.pub/`n.idea/`n.vscode/`n*.iml`n.DS_Store"
git add .
git commit -m "Frontend branch: Flutter travel chatbot demo app."

git checkout main
Remove-Item $tmpSave -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Branches ready:"; git branch
