<#
.SYNOPSIS
    Envia telemetria para Application Insights indicando status de stage de pipeline.
.PARAMETER StageName
    Nome do stage da pipeline (ex: Build, Test, Deploy)
.PARAMETER Status
    Status do stage: "Succeeded" ou "Failed"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$StageName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Succeeded","Failed")]
    [string]$Status
)

# Obtém Connection String do App Insights
$conn = $env:APPINSIGHTS_CONNECTION_STRING
if ($conn -notmatch "InstrumentationKey=([^;]+)") {
    Write-Warning "APPINSIGHTS_CONNECTION_STRING inválida ou não definida."
    return
}

$iKey = $matches[1]

# Define endpoint de ingestão
if ($conn -match "IngestionEndpoint=([^;]+)") {
    $endpoint = "$($matches[1])v2/track"
} else {
    $endpoint = "https://dc.services.visualstudio.com/v2/track"
}

# Captura variáveis do Azure DevOps via ambiente
$pipeline = $env:BUILD_DEFINITIONNAME
$buildId  = $env:BUILD_BUILDID
$agent    = $env:AGENT_NAME

# Monta o evento para enviar
$event = @{
    name = "Microsoft.ApplicationInsights.Event"
    time = (Get-Date).ToUniversalTime().ToString("o")
    iKey = $iKey
    data = @{
        baseType = "EventData"
        baseData = @{
            name = "PipelineStageCompleted"
            properties = @{
                stage    = $StageName
                pipeline = $pipeline
                buildId  = $buildId
                agent    = $agent
                status   = $Status
            }
        }
    }
}

# Converte para JSON
$body = ConvertTo-Json @($event) -Depth 10 -Compress

# Envia via REST para Application Insights
try {
    Invoke-RestMethod `
        -Uri $endpoint `
        -Method Post `
        -ContentType "application/json" `
        -Headers @{ "x-ms-connection-string" = $conn } `
        -Body $body

    Write-Host "Telemetria enviada: Stage=$StageName, Status=$Status"
} catch {
    Write-Warning "Falha ao enviar telemetria: $_"
}
