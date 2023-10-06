# Install wsl
````
# https://gist.github.com/netbrain/a1093ff0d882b95c8fb62787c1c53227
# Function to download the tar file
function Download-NixOS {
    $url = "https://github.com/nix-community/nixos-wsl/releases/latest/download/nixos-wsl.tar.gz"
    $output = "$env:TEMP\nixos-wsl.tar.gz"
    Invoke-WebRequest -Uri $url -OutFile $output
    return $output
}

# Function to check if WSL is installed and install if it's not
function Install-WSL {
    $wslInstalled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    if ($wslInstalled.State -ne 'Enabled') {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
    }
}

# Function to import into WSL
function Import-WSL ($tarPath) {
    wsl --import NixOS .\NixOS\ $tarPath --version 2
}

# Main execution
$tarPath = Download-NixOS
Install-WSL
Import-WSL -tarPath $tarPath
````

# Then install nixos
````
wsl -d NixOS -u root
usermod -d /home/netbrain nixos
usermod -l netbrain nixos

rm -rf /etc/nixos
git clone https://github.com/netbrain/nix /etc/nixos
nixos-rebuild switch --flake /etc/nixos#wsl --impure
wsl --shutdown
wsl
````
