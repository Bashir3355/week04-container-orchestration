$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE" }
}
Invoke-Checked docker @('info')
Invoke-Checked minikube @('start', '-p', 'week04', '--driver=docker', '--cpus=2', '--memory=3072')
Invoke-Checked docker @('build', '--progress=plain', '-t', 'week04-web:1.0.0', '.')
Invoke-Checked minikube @('-p', 'week04', 'image', 'load', 'week04-web:1.0.0')
Invoke-Checked kubectl @('--context=week04', 'apply', '-f', 'k8s/app.yaml')
Invoke-Checked kubectl @('--context=week04', '-n', 'week04', 'rollout', 'status', 'deployment/web-app', '--timeout=180s')
Invoke-Checked kubectl @('--context=week04', '-n', 'week04', 'get', 'pods', '-o', 'wide')
Write-Host 'Ready. In another PowerShell window, run: minikube -p week04 service web-app -n week04 --url'
Write-Host 'Keep that window open. Use its printed URL in your browser.'
