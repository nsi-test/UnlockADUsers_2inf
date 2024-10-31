using module ".\UnlockUsers_2inf_assemblies.psm1" #gui assemblies

using module ".\Locked_2inf_GuiInterface.psm1" #gui interface class

using module ".\UnlockUsers_2inf_classes.psm1" #classes

#$VerbosePreference = "Continue" #uncomment for verbose (in fact works only outside)

Set-Variable -Name ULVersion -Value "1.4.1" -Option ReadOnly -Force -Scope global

Write-Verbose "UL Version is: $global:ULVersion"

#main

#gui iface:

$lgui = [LockedGui]::new() #no params

$usersunl_worker = [UsersUnlocker]::new($lgui) #accepts the gui object (can be other)

$usersunl_worker.Run()

Remove-Variable -Name ULVersion -Force -Scope global

Write-Verbose "(after worker.Run()) UL Version variable removed"
#removed not to exist in outside shell
