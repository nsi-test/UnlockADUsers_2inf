# UnlockADUsers_2inf
Powershell compiled executable gui for  unlocking massive locked AD Users.

- Windows executable tool for unlocking any locked AD users.  
(compiled from Powershell with PowerGUI Script Editor 3.8.0.129 /free/)
<!-- two spaces  for rodinary newline (after 'users') -->

- The main logic is in one class, it accepts two different interface instances - cmdline one and Gui one - they result in two different exe files:
UnlockADUsersCmdline_v.1.3.0.exe and UnlockADUsersGui_v.1.3.0.exe

- The powershell source is in the code. It can be runned too - by UnlockUsers_2inf_Gui_start.ps1, UnlockUsers_2inf_Cmdline_start.ps1

- For normal work, executing the exe or ps1 must be done by user with appropriate rights on AD. It can be done from the windows graphical or cmd interface

- The interface is intuitive
