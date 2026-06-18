$ErrorActionPreference = "Stop"
$root = "F:\trip_advisor_chatbot_project"
Set-Location $root

$tmpSave = "$env:TEMP\travel-repo-setup"
if (Test-Path $tmpSave) { Remove-Item $tmpSave -Recurse -Force }
New-Item -ItemType Directory -Path "$tmpSave\backend" -Force | Out-Null
New-Item -ItemType Directory -Path "$tmpSave\frontend" -Force | Out-Null

Copy-Item -Path "$root\backend\*" -Destination "$tmpSave\backend" -Recurse -Force
Copy-Item -Path "$root\frontend\*" -Destination "$tmpSave\frontend" -Recurse -Force
Copy-Item -Path "$root\scripts\README-backend.md" -Destination "$tmpSave\README-backend.md" -Force
Copy-Item -Path "$root\scripts\README-frontend.md" -Destination "$tmpSave\README-frontend.md" -Force
Copy-Item -Path "$root\.gitignore" -Destination "$tmpSave\gitignore-main" -Force

function Clear-Root {
    Get-ChildItem $root -Force | Where-Object { $_.Name -ne '.git' } | Remove-Item -Recurse -Force
}

if (-not (Test-Path .git)) { git init -b main }

git add .
git commit -m "Initial commit: AI Travel Advisor full monorepo with backend and frontend."

# BACKEND branch
git checkout --orphan backend
git rm -rf --cached . 2>$null | Out-Null
Clear-Root
Copy-Item -Path "$tmpSave\backend\*" -Destination $root -Recurse -Force
Copy-Item -Path "$tmpSave\README-backend.md" -Destination "$root\README.md" -Force
Set-Content "$root\.gitignore" "venv/`n__pycache__/`n**/__pycache__/`n*.db`n.env`n*.pyc`n.idea/`n.vscode/`n.DS_Store"
git add .
git commit -m "Backend branch: FastAPI travel chatbot API with RAG and NLP."

# FRONTEND branch
git checkout --orphan frontend
git rm -rf --cached . 2>$null | Out-Null
Clear-Root
Copy-Item -Path "$tmpSave\frontend\*" -Destination $root -Recurse -Force
Copy-Item -Path "$tmpSave\README-frontend.md" -Destination "$root\README.md" -Force
Set-Content "$root\.gitignore" ".dart_tool/`nbuild/`n.flutter-plugins`n.flutter-plugins-dependencies`n.packages`n.pub-cache/`n.pub/`n.idea/`n.vscode/`n*.iml`n.DS_Store"
git add .
git commit -m "Frontend branch: Flutter travel chatbot demo app."

git checkout main
Remove-Item $tmpSave -Recurse -Force
Write-Host "Branches:"
git branch
