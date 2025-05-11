## Introduction

The version of OpenSSH bundled with Windows does not include the `ssh-copy-id` utility for quickly copying a SSH key to a remote machine.

I use 1Password's SSH agent, and store my SSH key in 1Password, so I can unlock it with biometrics (Windows Hello) instead of a passphrase, easily synchronize it between my machines, and avoid storing it on local disks. However, this means I can't just copy my `id_ed25519.pub` from one of my boxes using the 1Password SSH agent (because that file isn't created!)

This is a function to interact with 1Password via the `op` CLI utility and copy a SSH key to a remote host's `~/.ssh/authorized_keys` file.

Accompanying blog post can be found [here](https://wporter.org/lazy-powershell-ssh-copy-id-for-windows-with-ssh-keys-stored-in-1password/).

## Prerequisites

You'll need the 1Password CLI. Documentation for setting it up is available from [AgileBits here](https://developer.1password.com/docs/cli/get-started/#install).

If you get an error about "connecting to desktop app: the pipe is being closed", the 1Pass release team probably forgot to sign the 1Password CLI app again:

```txt
~
❯ op vault list
[ERROR] 2025/05/11 14:17:06 connecting to desktop app: write: The pipe is being closed.
```

 You can confirm this by reviewing the 1Password logs (at `$env:LOCALAPPDATA\1Password\logs\1Password_rCURRENT.log`) and looking for an untrusted certificate error.

```txt
~
❯ gc $env:LOCALAPPDATA\1Password\logs\1Password_rCURRENT.log | select-string UntrustedFileCertificate

ERROR 2025-05-11T18:23:25.547+00:00 runtime-worker(ThreadId(21)) [1P:native-messaging\op-native-core-integration\src\lib.rs:647] Failed to accept new connection.: PipeAuthError(UntrustedFileCertificate(WinApi(Error HRESULT(0x800B0100): No signature was present in the subject.)))
```

In my case, I was able to resolve this by removing the latest release of the 1PW CLI (2.31.0) and reinstalling the prior release (2.30.3), which was properly signed:

```txt
~
❯ winget remove AgileBits.1Password.CLI

~
❯ winget install AgileBits.1Password.CLI --version 2.30.3

~
❯ op vault list
ID                            NAME
bd47xrtpknghhqruss4cppqwu4    Network
tregvgg3zxzildruwc52wrhb6q    Private
mswku5ai6dyyubsy6vxc3xyscu    Shared
```

## Usage

Import the file and run the function. Specify a remote host to copy your SSH key to. Optionally, specify the name of your SSH key (item name in 1Password):

```txt
~
❯ Import-Module .\Copy-PubKey.ps1
```

```txt
~
❯ Copy-PubKey wt14g2a
liam@wt14g2a's password:

~ took 4s
❯ ssh wt14g2a
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Sun May 11 16:11:51 2025 from 192.168.77.1
liam@wt14g2a:~$ exit
logout
Connection to wt14g2a closed.

~ took 3s
❯
```

```
~
❯ Copy-PubKey -RemoteHost wt14g2a -KeyName 'id_ed25519'
liam@wt14g2a's password:

~ took 4s
❯ ssh wt14g2a
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Sun May 11 16:11:51 2025 from 192.168.77.1
liam@wt14g2a:~$ exit
logout
Connection to wt14g2a closed.

~ took 3s
❯
```