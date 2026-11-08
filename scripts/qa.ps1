param([Parameter(Mandatory=$true)][string]$BaseUrl)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force evidence | Out-Null
$BaseUrl = $BaseUrl.TrimEnd('/')
$results = [System.Collections.Generic.List[object]]::new()
function K {
    param([string[]]$Arguments)
    $value = & kubectl --context=week04 -n week04 @Arguments
    if ($LASTEXITCODE -ne 0) { throw "kubectl failed: $Arguments" }
    return $value
}
function Record { param([string]$Name, $Detail) $results.Add([pscustomobject]@{check=$Name;status='PASS';detail=$Detail});Write-Host "PASS: $Name" }
function Assert-HealthyReplicas {
    $pods = (K @('get','pods','-l','app=web-app','-o','json') | Out-String | ConvertFrom-Json).items
    $active = @($pods | Where-Object { -not $_.metadata.deletionTimestamp })
    $ready = @($active | Where-Object { $_.status.phase -eq 'Running' -and @($_.status.containerStatuses | Where-Object { $_.ready }).Count -eq 1 })
    if ($ready.Count -ne 3) { throw "Expected 3 ready pods; found $($ready.Count)" }
    return $active
}
Start-Transcript -Path evidence/cluster-transcript.txt -Force | Out-Null
try {
    $size = & docker image inspect week04-web:1.0.0 --format '{{.Size}}'
    if ($LASTEXITCODE -ne 0) { throw 'Image inspection failed' }
    $user = & docker image inspect week04-web:1.0.0 --format '{{.Config.User}}'
    if ($LASTEXITCODE -ne 0 -or $user -ne 'node') { throw 'Image USER is not node' }
    Record 'Tagged image size and configured user' "$size bytes; USER=$user"
    foreach ($route in @('/', '/healthz','/readyz','/api/runtime')) {
        $response = Invoke-WebRequest -Uri "$BaseUrl$route" -UseBasicParsing
        if ($response.StatusCode -ne 200) { throw "Failed endpoint: $route" }
        if ($route -eq '/healthz' -and ($response.Content | ConvertFrom-Json).status -ne 'healthy') { throw 'Unexpected health payload' }
        if ($route -eq '/api/runtime') {
            $metadata = $response.Content | ConvertFrom-Json
            if (-not $metadata.podName -or $metadata.uid -ne 1000) { throw 'Pod identity or process UID invalid' }
        }
        Record "HTTP 200 $route" $response.Content
    }
    K @('scale','deployment/web-app','--replicas=3')
    K @('rollout','status','deployment/web-app','--timeout=180s')
    K @('wait','--for=condition=Ready','pod','-l','app=web-app','--timeout=180s')
    $pods = @(Assert-HealthyReplicas)
    Record 'Scale to 3 healthy replicas' ($pods.metadata.name -join ', ')
    foreach ($pod in $pods) {
        $uid = K @('exec',$pod.metadata.name,'--','id','-u')
        if (($uid | Out-String).Trim() -ne '1000') { throw 'A pod runs with unexpected UID' }
        $processes = K @('exec',$pod.metadata.name,'--','ps','-o','user,pid,args')
        Record "Non-root process: $($pod.metadata.name)" ($processes | Out-String)
    }
    $victim = $pods[0].metadata.name
    $oldUid = $pods[0].metadata.uid
    # Delete a Pod, not the Deployment. The ReplicaSet must create a new Pod UID.
    K @('delete','pod',$victim,'--wait=true','--timeout=90s')
    K @('rollout','status','deployment/web-app','--timeout=180s')
    K @('wait','--for=condition=Ready','pod','-l','app=web-app','--timeout=180s')
    $replacements = @(Assert-HealthyReplicas)
    if (@($replacements | Where-Object { $_.metadata.uid -eq $oldUid }).Count -ne 0) { throw 'Deleted pod still exists' }
    $replacementUids = @($replacements.metadata.uid | Where-Object { $_ -notin $pods.metadata.uid })
    if ($replacementUids.Count -lt 1) { throw 'No new replacement pod UID found' }
    Record 'Self-healing: replacement pod ready' "Deleted=$victim UID=$oldUid; new UID=$replacementUids"
    K @('set','env','deployment/web-app','APP_VERSION=v2')
    K @('rollout','status','deployment/web-app','--timeout=180s')
    Assert-HealthyReplicas | Out-Null
    $runtime = Invoke-RestMethod "$BaseUrl/api/runtime"
    if ($runtime.version -ne 'v2') { throw 'Rolling update did not serve v2' }
    Record 'Rolling update' "Observed version=$($runtime.version)"
    K @('rollout','undo','deployment/web-app')
    K @('rollout','status','deployment/web-app','--timeout=180s')
    Assert-HealthyReplicas | Out-Null
    $runtime = Invoke-RestMethod "$BaseUrl/api/runtime"
    if ($runtime.version -ne 'v1') { throw 'Rollback did not restore v1; start from a fresh v1 deployment' }
    Record 'Rollback' "Observed version=$($runtime.version)"
} catch {
    $results.Add([pscustomobject]@{check='Execution stopped';status='FAIL';detail=$_.Exception.Message})
    throw
} finally {
    $report = [pscustomobject]@{recordedAt=(Get-Date).ToString('o');baseUrl=$BaseUrl;checks=$results;browserDevTools='MANUAL CHECK REQUIRED';continuousAvailability='NOT MEASURED BY THIS SCRIPT'}
    $report | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 evidence/qa-results.json
    Stop-Transcript | Out-Null
}
Write-Host 'Saved evidence/qa-results.json and evidence/cluster-transcript.txt. Complete the browser checks and recording.'
