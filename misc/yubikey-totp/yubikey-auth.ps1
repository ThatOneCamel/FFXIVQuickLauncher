# [Initial Version: 7/6/22]
# [Updated: 12/10/22]

#Setting up the account on the plugged-in Yubikey
$LauncherPath = "$env:LOCALAPPDATA\XIVLauncher\XIVLauncher.exe"
$SECRET = $null


function Is-Numeric ($str) {
  return $str -match "^[\d\.]+$"
}

function PrintNotice() {
  Write-Host -ForegroundColor Yellow "Yubikey wasn't touched before timeout. Program will exit...`n"
  Write-Host -ForegroundColor Green "Press the 'R' key to try again."
  Write-Host "Press any other key to exit the program.`nAutomatically exiting in 10 seconds..."
}
#TODO
#if (Test-Path $FILENAME){
#	$SECRET = Get-Content $FILENAME
#} else {
#	return -1
#}

$OTP = $null
$form = $null
#ykman oath accounts add ffxiv-test --oath-type TOTP $SECRET --touch

#ykman oath info

#Gets the TOTP code upon yubikey being touched
#GenerateForm

$OTP = ykman oath accounts code ffxiv-test | foreach-object {$_ -replace "[^0-9]" , ''}
if ((Is-Numeric $OTP) -eq $false) {
  PrintNotice
  $count=0
  $sleepTimer=500 #in milliseconds
  $RetryKey=82 #Character code for 'R' key.
  while($count -le 20) {
      if($host.UI.RawUI.KeyAvailable) {
        $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")

        if($key.VirtualKeyCode -eq $RetryKey) {
          $count=0
          Write-Host -ForegroundColor Yellow ("'R' press detected! Reattempting...")
          $OTP = ykman oath accounts code ffxiv-test | foreach-object {$_ -replace "[^0-9]" , ''}

          if (Is-Numeric $OTP) {
            break
          } else {
            PrintNotice
          }
          
        } else {
          break
        }
      }
      #Do your operations
      $count++
      Start-Sleep -m $sleepTimer
  }

  #Checking for a valid OTP once again, in-case the user decided to retry and got a code
  if ((Is-Numeric $OTP) -eq $false) {
    Write-Host -ForegroundColor Green ("The script has stopped.")
    return 0;
  }

}
Write-Output "Success!"
Write-Output $OTP
#Suppress timeout error - TODO


# destroy form

#Wait-Event

if ( ($null -ne $OTP) -and ($OTP.length -eq 6) ) {
    # Check "Enable XL Authenticator app/OTP macro support" in Settings
    # Check "Log in automatically" on the main launcher screen
    Start-Process powershell -ArgumentList $LauncherPath
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    Start-Sleep -Seconds 2
    try {
      Invoke-WebRequest -URI "http://127.0.0.1:4646/ffxivlauncher/$OTP"
    } catch { }
  } else {
    Write-Error "Failed to authenticate or malformed OTP"
    #Read-Host -Prompt "Press Enter to exit"
  }
  

Write-Host -ForegroundColor Green "Logging you in..."
Start-Sleep -m 3000
