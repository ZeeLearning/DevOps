<# 

Script: Trigger_WorkFlow_From_GitHub_API.ps1 
Author: Zeeshan Yousaf 
Date:   03/26/2025 
Description: This script triggers a GitHub Actions workflow using the GitHub API. It takes parameters for the repository name,  
             environment, and personal access token (PAT).  
             The script sends a request to trigger the workflow and then polls for its status until it completes.  
             Finally, it prints the conclusion of the workflow run. 
Usage: .\Trigger_WorkFlow_From_GitHub_API.ps1 -repo_name "your_repo_name" -environment "your_environment" -pat_token "your_pat_token" 
#> 

# Ensure TLS 1.2 is used for secure connections 

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

# Define parameters  

param ( 
    [string] $repo_name, 
    [string] $environment, 
    [string] $pat_token 

) 

# Define variables 

$owner = "Underwriters-Labs"  # Replace with your GitHub username or org name  
$repo = "CW.DevOps"    # Repository where the workflow file is located 
$workflow_file = "Build_Deploy_Env_GitHub.yml"  # Workflow file name 
$branch = "main"       # The branch to trigger the workflow 

# API URLs  

$apiUrl = "https://api.github.com/repos/$owner/$repo/actions/workflows/$workflow_file/dispatches"  
$headers = @{  

    "Authorization" = "Bearer $pat_token"  
    "Accept"        = "application/vnd.github.v3+json"  
}  

$body = @{  

    "ref"    = $branch  
    "inputs" = @{  
        "repo_name"   = $repo_name 
        "environment" = $environment  
    } 

} | ConvertTo-Json -Compress  

$buildResponse = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"  

Write-Host "Workflow triggered successfully. Waiting for workflow to start..."  

# Wait for a few seconds before fetching runs  

Start-Sleep -Seconds 5  

# Get the latest workflow run ID  

$runUrl = "https://api.github.com/repos/$owner/$repo/actions/runs"  
$runResponse = Invoke-RestMethod -Uri $runUrl -Method Get -Headers $headers  
$runId = $runResponse.workflow_runs[0].id  # Get the latest run ID  

Write-Host "Tracking workflow run ID: $runId"  

# Polling the workflow status until it completes  

$workflowStatus = "queued"  

do {  

    Start-Sleep -Seconds 10  # Wait before polling again  
    $statusUrl = "https://api.github.com/repos/$owner/$repo/actions/runs/$runId"  
    $statusResponse = Invoke-RestMethod -Uri $statusUrl -Method Get -Headers $headers  
    $workflowStatus = $statusResponse.status  
    $workflowConclusion = $statusResponse.conclusion  

    Write-Host "Workflow Status: $workflowStatus"  

} while ($workflowStatus -ne "completed")  

# Print the final result  
Write-Host "Workflow completed with conclusion: $workflowConclusion"  

if ($workflowConclusion -eq "success") {  
    exit 0  # Success   
}
else {  
    exit 1  # Failure  
}  