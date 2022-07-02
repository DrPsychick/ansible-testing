# Setup WinRM - HTTP, basic
Set-Item -Path WSMan:\localhost\Client\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Client\AllowUnencrypted -Value $true
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true

# remove all listeners
Remove-Item -Path WSMan:\localhost\Listener\* -Recurse -Force

# create HTTP listener
$selector_set = @{
    Address = "*"
    Transport = "HTTP"
}
$value_set = @{
    Hostname = "{{ instance.hostname|default(instance.name) }}"
    Enabled = "true"
}
New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set

Get-Service -Name WinRM | Restart-Service