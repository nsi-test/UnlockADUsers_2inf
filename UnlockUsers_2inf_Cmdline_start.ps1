using module ".\Locked_2inf_CmdlineInterface.psm1" #cmdline interface class

using module ".\UnlockUsers_2inf_classes.psm1" #worker classes

#$VerbosePreference = "Continue" #uncomment for verbose

Set-Variable -Name ULVersion -Value "1.3.0" -Option ReadOnly -Force -Scope global

Write-Verbose "UL Version is: $global:ULVersion"

Write-Host "Starting Unlocking users - 2 interfaces, cmdline v$global:ULVersion..."

#main

#another i-face idea:

$lcmdline = [LockedCmdline]::new() #no params

$usersunl_worker = [UsersUnlocker]::new($lcmdline) #accepts the cmdline object (can be other)

$usersunl_worker.Run()

Remove-Variable -Name ULVersion -Force -Scope global

Write-Verbose "(after worker.Run()) UL Version variable removed"

