# Set your repository and GitHub token 

$Repo = "Underwriters-Labs/CW.DevOps"     # e.g., "my-org/my-app" 

$pat_token = "Generate PAT and use here" # Your GitHub Personal Access Token 

# GitHub API URL for workflow runs 

$ApiUrl = "https://api.github.com/repos/$Repo/actions/runs?status=queued" 

# Set the Authorization header 
$Headers = @{ 

    Authorization = "token $pat_token" 
    Accept        = "application/vnd.github+json" 
    "User-Agent"  = "PowerShell" 
} 

# Get all queued workflow runs 
$response = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -Method Get 

Write-Host "Response: $response" 

# Extract run IDs and cancel them 
foreach ($run in $response.workflow_runs) { 
    $runId = $run.id 
    Write-Host "Canceling run ID: $runId" 

    # Force cancel the workflow run
    $cancelUrl = "https://api.github.com/repos/$Repo/actions/runs/$runId/force-cancel" 

    try {
        $cancelResponse = Invoke-RestMethod -Uri $cancelUrl -Headers $Headers -Method Post
        Write-Host "Successfully canceled run ID: $runId"
    } catch {
        Write-Host "Failed to cancel run ID: $runId. Error: $_"
    }
}
 