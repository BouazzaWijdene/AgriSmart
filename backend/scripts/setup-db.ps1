<#
  ============================================================
  Agrismart API - Création du rôle et de la base PostgreSQL
  ============================================================
  Nécessite le mot de passe du superutilisateur « postgres »
  (les droits superutilisateur ne servent qu'à cette étape).

  Exemple :
    powershell -File scripts/setup-db.ps1 -MotDePasseSuperutilisateur 'MonMotDePasse'

  Le rôle applicatif et son mot de passe sont lus dans backend/.env
  (PGUSER / PGPASSWORD / PGDATABASE), sinon les valeurs par défaut sont utilisées.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$MotDePasseSuperutilisateur,
    [string]$Hote = 'localhost',
    [int]$Port = 5432
)

$ErrorActionPreference = 'Stop'

# ---------- 1. Configuration applicative (backend/.env) ----------
$role = 'agrismart'
$motDePasseRole = 'agrismart_dev_2024'
$base = 'agrismart'

$fichierEnv = Join-Path $PSScriptRoot '..' 'backend' '.env'
if (Test-Path $fichierEnv) {
    foreach ($ligne in Get-Content $fichierEnv) {
        if ($ligne -match '^\s*PGUSER=(.*)$')     { $role = $Matches[1].Trim() }
        if ($ligne -match '^\s*PGPASSWORD=(.*)$') { $motDePasseRole = $Matches[1].Trim() }
        if ($ligne -match '^\s*PGDATABASE=(.*)$') { $base = $Matches[1].Trim() }
    }
}

# Échappement des quotes pour les littéraux psql
$echapper = { param($s) $s -replace "'", "''" }

# ---------- 2. Localisation de psql.exe ----------
$psql = @(
    'C:\Program Files\PostgreSQL\18\bin\psql.exe',
    'C:\Program Files\PostgreSQL\16\bin\psql.exe',
    'C:\Program Files\PostgreSQL\14\bin\psql.exe'
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $psql) {
    $psql = (Get-Command psql -ErrorAction SilentlyContinue).Source
}
if (-not $psql) {
    Write-Error "psql.exe introuvable : installez PostgreSQL ou ajoutez-le au PATH."
    exit 1
}

Write-Host "Utilisation de : $psql"

# ---------- 3. Script SQL (variables psql, aucune concaténation de mots de passe) ----------
$sql = @"
\set role_nom '$(& $echapper $role)'
\set role_mdp '$(& $echapper $motDePasseRole)'
\set base_nom '$(& $echapper $base)'

-- Rôle applicatif (créé ou remis à jour)
SELECT format('CREATE ROLE %I LOGIN', :'role_nom')
 WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'role_nom') \gexec
SELECT format('ALTER ROLE %I LOGIN PASSWORD %L', :'role_nom', :'role_mdp') \gexec

-- Base dédiée, possédée par le rôle applicatif
SELECT format('CREATE DATABASE %I OWNER %I', :'base_nom', :'role_nom')
 WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'base_nom') \gexec
SELECT format('ALTER DATABASE %I OWNER TO %I', :'base_nom', :'role_nom') \gexec
GRANT ALL PRIVILEGES ON DATABASE :"base_nom" TO :"role_nom";
"@

$fichierSql = Join-Path $env:TEMP "agrismart_setup_$PID.sql"
Set-Content -Path $fichierSql -Value $sql -Encoding UTF8

# ---------- 4. Exécution en tant que superutilisateur ----------
$env:PGPASSWORD = $MotDePasseSuperutilisateur
& $psql -U postgres -h $Hote -p $Port -v ON_ERROR_STOP=1 -f $fichierSql
$codeSortie = $LASTEXITCODE
$env:PGPASSWORD = $null
Remove-Item $fichierSql -ErrorAction SilentlyContinue

if ($codeSortie -ne 0) {
    Write-Error "Échec de la création du rôle/base. Vérifiez le mot de passe superutilisateur."
    exit 1
}

Write-Host ""
Write-Host "Base '$base' et rôle '$role' prêts ✔" -ForegroundColor Green
Write-Host "Étapes suivantes :" -ForegroundColor Cyan
Write-Host "  cd backend"
Write-Host "  npm install"
Write-Host "  npm run db:init    # crée les tables"
Write-Host "  npm run db:seed    # données de démonstration"
Write-Host "  npm run dev        # démarre l'API sur http://localhost:3000"
