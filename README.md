# RegCloak
A PowerShell script that attempts to help malware analysts hide their Windows VirtualBox VM's from malware that may be trying to evade analysis. The script Rrnames several registry keys that malware typically uses for VM detection. Guaranteed to bring down your pafish ratings by at least a few points ;)

# Usage

1. Simply run RegCloak.ps1 as Administrator on your Windows VirtualBox VM.
2. Start analyzing/reversing malware!
3. When done, reset your VM to clean state.

# Warnings

- Ensure to make a snapshot of your VM before running this. These registry chnages will damage your VM if used long-term!
