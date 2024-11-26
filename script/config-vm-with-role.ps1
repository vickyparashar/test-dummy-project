
# Define script parameters with default values
param(
    [Parameter(Mandatory = $false)]
    [string]$env = "",  # Environment name
    [Parameter(Mandatory = $false)]
    [string]$group = "",  # Group name for the playbook
    [Parameter(Mandatory = $false)]
    [string]$playbookpath = "",  # Path to the playbook directory
    [Parameter(Mandatory = $false)]
    [string]$logs = "False"  # Flag to enable/disable logging
)

# Read the inventory file for the specified environment
$inventorytext = Get-Content -ErrorAction stop "$playbookpath/environments/$env/inventory"

# Check if logging is disabled
if ($logs -eq "False") {
    # Run Ansible playbook with verbose output if logging is disabled
    ansible-playbook -v `
    -i "$playbookpath/environments/$env/inventory" `
    "$playbookpath/$group.yaml" `
    -e ansible_ssh_common_args='"-o StrictHostKeyChecking=no"' `
    -e "env=$env" `
    -e "logs=$logs"
} else {
    # Run Ansible playbook without verbose output if logging is enabled
    ansible-playbook `
    -i "$playbookpath/environments/$env/inventory" `
    "$playbookpath/$group.yaml" `
    -e ansible_ssh_common_args='"-o StrictHostKeyChecking=no"' `
    -e "env=$env" `
    -e "logs=$logs"
}

# Capture the exit code from the Ansible playbook execution
$exitCode = $LastExitCode

# Check if the Ansible playbook execution was successful
if ($exitCode -ne 0) {
    # If not successful, log the error and exit with the same code
    Write-Error "Ansible playbook failed with exit code $exitCode"
    if ($Error.Count -gt 0) {
        Write-Host "Latest Error: $($Error[0].Exception.Message)"
    }
    Write-Host "Ansible playbook with exit code $exitCode"
    exit $exitCode
} else {
    # If successful, print success message
    Write-Output "Success!"
}
