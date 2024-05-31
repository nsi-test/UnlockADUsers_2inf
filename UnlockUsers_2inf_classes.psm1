#[Void][reflection.assembly]::loadwithpartialname('System.Windows.Forms')
#[Void][reflection.assembly]::loadwithpartialname('System.Drawing')
#cannot be used like this

using namespace System.Collections.Generic #for List

using module ".\IconB64.psm1"

Write-Verbose "IconB64 imported"
#Write-Verbose $(GetIconB64)

class UsersUnlocker {
	
	[System.Object] $liface
	
	#constructor
	UsersUnlocker([System.Object] $liface) { #he doesn't know the exact type
	
		$unlocker_funs = [PSCustomObject]@{
				'GetLUsers'=$this.GetLUsers
				'UnlockLUsers'=$this.UnlockLUsers
				}	

		$this.liface = $liface
		#this.liface accepts the fn object... (the two liface are the same in fact...)
		$this.liface.GetOuterFnObject($unlocker_funs) #the function's name should be formally known...
		
	} #constructor

	#[System.Object[]] GetLUsers() {
	[List[PSObject]] GetLUsers() {	
		return $(Get-ADUser -Filter * -Properties SamAccountname, badPwdCount, badPasswordTime, lockedout, enabled | Where-Object {$_.lockedout -eq "True"} | % {
		New-Object PSObject -Property @{
        username = $_.SamAccountname
        badPwdCount = $_.badPwdCount
        badPasswordTime = [DateTime]::FromFileTime($_.badPasswordTime)
        enabled = $_.enabled
      }
    } | Sort-Object -Property badPasswordTime)
	} #GetUsers fn
	
	[System.Object] UnlockLUsers([System.Object[]] $UserData, [bool] $enabledonly) {
		Write-Verbose "in UnlockLUsers, UserUnlocker: $UserData"
		Write-Verbose "$($UserData.gettype())"
		
		if (! $UserData) {$UserData = @()} #(!)
		$message = ""
		$unlockednum = 0
		
		$UserData | % {
			
			$message += "$($_.num) " #should be before any row...
			
			if (! $_.enabled -and $enabledonly) {
				"$($_.username) is disabled - remains locked" | Tee-Object -variable msg | Write-Verbose
				Write-Verbose "in if enabled, user: $($_.username)"

				$message += "$msg`r`n"
				$msg = ""
				return
				#return instead of continue
			} #if enabled
        
			$message += "$(if (!$_.Enabled) {"(disabled) "})" #maj stava i s dvete "
			$msg = ""
		
			$username = $_.username
			$global:error.clear()
			Try {	
				Unlock-ADAccount -Identity $_.username
			}
			Catch {
				"unlockling $username error: $($global:error.Exception.Message)" | Tee-Object -variable msg | Write-Verbose
				$message += "$msg`r`n"
				$msg = ""
			}
			Finally {
				If (! $global:error) {
					"$($_.username) unlocked" | Tee-Object -variable msg | Write-Verbose
					$message += "$msg`r`n"
					$msg = ""
					$unlockednum += 1
				} #if error
			} #finally	
			
		} #%
		
		return @{"message" = $message; "unlockednum" = $unlockednum}
	} #UnlockLUsers fn

	[void] Run() {
		$this.liface.Show()
	}

} #class UnlockUsers

