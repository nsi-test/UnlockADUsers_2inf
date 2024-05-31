using namespace System.Collections.Generic #for List

class LockedCmdline {
	#functions given
	[System.Management.Automation.PSMethod] $getlusers_fun
	
	[System.Management.Automation.PSMethod] $unlocklusers_fun
	
	#constructor
	LockedCmdline() {
		Write-Verbose "starting LockedCmdline in constructor"
		
		$this.getlusers_fun = $null #at first
		
		$this.unlocklusers_fun = $null # at first
	} #constructor

	[void] GetOuterFnObject([PSCustomObject] $users_ulocker_funs) {
		$this.getlusers_fun = $users_ulocker_funs.GetLUsers
		$this.unlocklusers_fun = $users_ulocker_funs.UnlockLUsers
	} #GetOuterFnObject fn
	
	
	[List[PSObject]] RefreshInfo() {
		$lusers_list = $this.getlusers_fun.Invoke()

		return $lusers_list
	} #RefreshInfo fn
	
	[void] Roll() {
		While ($True) {
			$ulist = $this.RefreshInfo()
			#this should be List type, the cast afterwards is because selectobj
			
			if (!$ulist) {Write-Host "no locked users"; $ulist = @()} #; return;} #return? #(@() (!))
			
			[List[PSObject]] $ulist = $ulist | Select-Object @{name="num"; expression={$ulist.IndexOf($_)+1}}, * #this adds numbers
			
			$ulist | ft num, username, badPwdCount, badPasswordTime, enabled | Out-Host
			
			Write-Host "locked users count: $($ulist.count) $(' '*20)last refreshed: $([DateTime]::Now.ToString())" #20 looks ok
			
			$answers = @('e', 'a', 'l', 'r', 'q')

			$answer = Read-Host -prompt "Do you want to unlock some users? (<e>nabled/<a>ll/<l>ist/<r>efresh/<q>uit)"

			Write-Host $answer
			
			if (! ($answer -in $answers)) {Write-Host "not an usable answer, try again."; continue;} #continue??? #koe trqbva?
			
			if ($answer -eq 'q') {Write-Host "quitting."; exit;} #this is exit (!)
			
			if ($answer -eq 'r') {Write-Host "refreshing..."; continue;} #continue??? #koe trqbva?
			
			#list part
			if ($answer -eq 'l') {$ulist_temp = $ulist; 
				$ulist = @() # we will fill it after that, temp is for indexing
			
				$answer2 = Read-Host -prompt "Write a list of numbers in the form of 'k, l-m, n, o-p...etc' or similar"
							
				
				$regexpattern = '(^|\s+|,|)(\d+)-*(\d*)(,|$)'
				
				#pattern explanation (hope):
				#there are four groups possible for every match
				#first is beggining of string or white spaces or comma or empty string
				#second - some digits (a number)
				#hyphen (-) is possible but not necessary, and not in a group
				#third - more digits are possible (number n: m-[n])
				#fourth - comma or end of string
				#second group and third group are allays numbers

				
				$allmatches = [regex]::matches($answer2, $regexpattern)
				
				$allmatches | % {
					if (! $_.groups[3].value) {
						if ([int]$_.groups[2].value -lt 1) {write-host "$($_.groups[2].value) is not a valid value, omitting"; continue}
						if ([int]$_.groups[2].value -gt $ulist_temp.count) {write-host "$($_.groups[2].value) is out of range, omitting"; continue} #continue ili return?
						$ulist += $ulist_temp[$_.groups[2].value-1]
						}
					else {
						if ([int]$_.groups[2].value -lt 1) {write-host "the first value of $($_.groups[2].value)-$($_.groups[3].value) is not a valid value, omitting"; continue}
						if ([int]$_.groups[3].value -lt 1) {write-host "the second value of $($_.groups[2].value)-$($_.groups[3].value) is not a valid value, ommiting"; continue}
						if (([int]$_.groups[2].value -gt $ulist_temp.count) -and ([int]$_.groups[3].value -gt $ulist_temp.count)) {write-host "the pair $($_.groups[2].value)-$($_.groups[3].value) is out of range, omitting"; continue}
						if (([int]$_.groups[2].value -gt $ulist_temp.count)) {write-host "the first value of $($_.groups[2].value)-$($_.groups[3].value) is out of range, $($ulist_temp.count)-$($_.groups[3].value) will be used instead"}
						if (([int]$_.groups[3].value -gt $ulist_temp.count)) {write-host "the second value of $($_.groups[2].value)-$($_.groups[3].value) is out of range, $($_.groups[2].value)-$($ulist_temp.count) will be used instead"}
						$ulist += ($ulist_temp[($_.groups[2].value-1)..($_.groups[3].value-1)])
					} #if 3  else
				} # allmatches %
						#some debugging...
						#write-host "ULIST_temp TYPE: $($ulist_temp.gettype())"
						#write-host "ULIST TYPE: $($ulist.gettype())"
			} # if answer 'l'
			
			
			#write-host "ulist now: $($ulist)" #empty when all out of range
			
			if (! $ulist) {continue} #out of rng
			
			#?continue
			
			if ($answer -eq 'e') {
				$unlock_result = $this.unlocklusers_fun.Invoke($ulist, $true) #enabledonly true
			} 
			else {
				$unlock_result = $this.unlocklusers_fun.Invoke($ulist, $false) #enabledonly false (enable all)
			}
			
			Write-Host "unlocked users count: $($unlock_result['unlockednum'])"
			
			Write-Host "$($unlock_result['message'])"
			
			#next is reload the while				
		} #while
	} #Roll #interface questions & results
	
		[void] Show() {
			[void] $this.Roll()
	} #show (for compatibility)
	
} # class LockedCmdline










