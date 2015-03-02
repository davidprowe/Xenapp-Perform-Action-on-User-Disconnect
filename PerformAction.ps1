#Make a published app with the command line executable:
#ctxhide C:\Path\PerformAction.ps1
#Application to initially open by user: path to exe and processname as found by get-process
$launch = "C:\windows\system32\notepad.exe"
$procname = "notepad"
#$arglist = "Arg1 Arg2 Arg3"
#process to run on disconnected state
$myproc = "c:\Program Files (x86)\Internet Explorer\iexplore.exe"
#open app
Start-Process $launch #-ArgumentList $arglist
#get the SessionID - first list the correct session ID
start-sleep 10
function Get-TSSessions {
    param(
        $ComputerName = "localhost"
    )

    qwinsta /server:$ComputerName |
    #Parse output
    ForEach-Object {
        $_.Trim() -replace "\s+",","
    } |
    #Convert to objects
    ConvertFrom-Csv
}
#set session variable to correct sessionID, and then start exe running loop
$session = (Get-TSSessions |? {$_.USERNAME -eq "$env:username"}|? {$_.TYPE -eq "wdica"}).ID

Add-PSSnapin Citrix.XenApp.Commands -ErrorAction Stop 
#Check to see if $appname is running. Remove write-host to see state of script
while ((get-process -name $procname|Where-Object {$_.SessionID -eq $session}) -ne $null)
	{
		#If active sleep script
		while (((Get-XASession -ServerName $env:computername|?{$_.AccountName -match $env:username}|?{$_.Protocol -match "ica"}).state -eq "Active") -and ((get-process -name $procname|Where-Object {$_.SessionID -eq $session}) -ne $null))
		#discheck = 1 means it hasnt been secured
		{
		#Write-host "sleeping"
		$discheck = "1"
		start-sleep -m 500
		}
		#if disconnected do this stuff
		if ($discheck -eq "1"){
		#Write-host "run action"
		#############################
		start-process $myproc
		#uncomment below to run a vbscript
		#run a vbscript::::::cscript "C:\TEMP\MYFILE.vbs"
		$discheck = "0"
		}
		else{
		start-sleep -m 500
		#Write-host "Disconnected - process ran"
		}
		
		}
		#write-host "no exe running"
		
		
		
		