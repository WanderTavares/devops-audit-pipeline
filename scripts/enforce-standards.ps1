Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$deploymentFile = Join-Path "k8s" "petclinic.yml"
$hpaFile        = Join-Path "k8s" "petclinic-hpa.yaml"

$minReplicas    = 3
$maxReplicas    = 6
$maxCpu         = 4
$maxMemoryGi    = 8

$changes = $false

Write-Host "Validando Deployment..."

$yaml = Get-Content $deploymentFile -Raw

if ($yaml -match 'replicas:\s*(\d+)') {
  $replicas = [int]$matches[1]

  if ($replicas -lt $minReplicas) {
    Write-Host "Réplicas abaixo do mínimo ($replicas). Ajustando para $minReplicas..."
    $yaml = $yaml -replace 'replicas:\s*\d+', "replicas: $minReplicas"
    $changes = $true
  }
  elseif ($replicas -gt $maxReplicas) {
    Write-Host "Réplicas acima do máximo ($replicas). Ajustando para $maxReplicas..."
    $yaml = $yaml -replace 'replicas:\s*\d+', "replicas: $maxReplicas"
    $changes = $true
  }
  else {
    Write-Host "Réplicas dentro do padrão: $replicas"
  }
}

$yaml = [regex]::Replace(
  $yaml,
  '(limits:\s*(?:\r?\n\s+.*)*)cpu:\s*"?(\d+)"?',
  {
    param($m)
    $block = $m.Groups[1].Value
    $cpu   = [int]$m.Groups[2].Value

    if ($cpu -gt $maxCpu) {
      Write-Host "CPU (limits) acima do limite ($cpu). Ajustando para $maxCpu..."
      $changes = $true
      return $block + "cpu: `"$maxCpu`""
    }
    else {
      Write-Host "CPU (limits) dentro do padrão: $cpu"
      return $m.Value
    }
  },
  'Singleline'
)

$yaml = [regex]::Replace(
  $yaml,
  '(limits:\s*(?:\r?\n\s+.*)*)memory:\s*"?(\d+)Gi"?',
  {
    param($m)
    $block = $m.Groups[1].Value
    $mem   = [int]$m.Groups[2].Value

    if ($mem -gt $maxMemoryGi) {
      Write-Host "Memória (limits) acima do limite (${mem}Gi). Ajustando para ${maxMemoryGi}Gi..."
      $changes = $true
      return $block + "memory: `"$maxMemoryGi`Gi`""
    }
    else {
      Write-Host "Memória (limits) dentro do padrão: ${mem}Gi"
      return $m.Value
    }
  },
  'Singleline'
)

$yaml | Set-Content $deploymentFile

Write-Host "Validando HPA..."

if (-not (Test-Path $hpaFile)) {
  Write-Error "HPA não encontrado. É obrigatório existir um hpa.yaml."
}

$hpa = Get-Content $hpaFile -Raw

if ($hpa -match 'minReplicas:\s*(\d+)') {
  $min = [int]$matches[1]

  if ($min -lt $minReplicas) {
    Write-Host "HPA minReplicas abaixo do mínimo ($min). Ajustando para $minReplicas..."
    $hpa = $hpa -replace 'minReplicas:\s*\d+', "minReplicas: $minReplicas"
    $changes = $true
  }
  else {
    Write-Host "HPA minReplicas dentro do padrão: $min"
  }
}
else {
  Write-Host "HPA sem minReplicas. Adicionando..."
  $hpa = $hpa -replace '(spec:\s*)', "`$1`n  minReplicas: $minReplicas"
  $changes = $true
}

# --- maxReplicas ---
if ($hpa -match 'maxReplicas:\s*(\d+)') {
  $max = [int]$matches[1]

  if ($max -gt $maxReplicas) {
    Write-Host "HPA maxReplicas acima do máximo ($max). Ajustando para $maxReplicas..."
    $hpa = $hpa -replace 'maxReplicas:\s*\d+', "maxReplicas: $maxReplicas"
    $changes = $true
  }
  else {
    Write-Host "HPA maxReplicas dentro do padrão: $max"
  }
}
else {
  Write-Host "HPA sem maxReplicas. Adicionando..."
  $hpa = $hpa -replace '(spec:\s*)', "`$1`n  maxReplicas: $maxReplicas"
  $changes = $true
}

$hpa | Set-Content $hpaFile


if ($changes) {
  Write-Error "Configurações fora do padrão. Correções aplicadas automaticamente."
}
else {
  Write-Host "Deployment e HPA já estavam em conformidade."
}
