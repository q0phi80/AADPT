# Source: https://github.com/arth0sz/Practice-AD-CS-Domain-Escalation
# Source: https://github.com/Orange-Cyberdefense/GOAD/tree/main/ansible/roles/adcs_templates/files

$templateNames = @("ESC1", "ESC2", "ESC3-1", "ESC3-2", "ESC4")

Write-Host "Publishing and Enrolling vulnerable certificates..."

foreach ($templateName in $templateNames) {
    # Check if template exists
    $templateExists = Get-ADCSTemplate -DisplayName $templateName -ErrorAction SilentlyContinue

    if (!$templateExists) {
        # Create and publish template
        New-ADCSTemplate -DisplayName $templateName -JSON (Get-Content C:\$templateName.json -Raw) -Publish
        Write-Host "Published template: $templateName"
    }
    else {
        Write-Host "Template '$templateName' already exists, skipping..."
    }

    # Set ACL only if the template was published
    if ($templateExists) {
        Set-ADCSTemplateACL -DisplayName $templateName -Identity 'CLIENT\Domain Users', 'CLIENT\Domain Computers' -Enroll -AutoEnroll
        Write-Host "Set permissions for '$templateName'"
    }
}