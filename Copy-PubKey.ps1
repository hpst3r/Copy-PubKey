<#
.SYNOPSIS
Copy a SSH key from 1Password to a remote host that's using the Bourne shell. Requires the 'op' 1Password CLI tool.

.COMPONENT
op - the 1Password CLI utility: https://developer.1password.com/docs/cli

.EXAMPLE
Copy-PubKey wt14g2a

.EXAMPLE
Copy-PubKey -RemoteHost '192.0.2.10' -KeyName 'MySSHKey'
#>
Function Copy-PubKey {
    param (
        [Parameter(Position = 0,
            Mandatory = $true)]
		    [string]$RemoteHost,
		    
        [Parameter(Position = 1)]
        [string]$KeyName = "id_ed25519"
    )

    $Command = @"
key="$(op item get $($KeyName) --fields 'public key')"
ssh_dir="`$HOME/.ssh"
auth_keys="`$ssh_dir/authorized_keys"
mkdir -p "`$ssh_dir"
touch "`$auth_keys"
chmod 700 "`$ssh_dir"
chmod 600 "`$auth_keys"
grep -qF "`$key" "`$auth_keys" || echo "`$key" >> "`$auth_keys"
"@

    $Command = $Command -replace "`r", ""

    & ssh $RemoteHost bash -c "'$Command'"

}