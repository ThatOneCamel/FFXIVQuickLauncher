# [Initial Version: 7/6/22]
# [Updated: 12/10/22]

$global:FILENAME = ".env"
$pythonFile = "python-3.10.5.exe"
$pyVersion = "3.10.5"
$checksum = "eb59401a8da40051ec3b429897ae1203"

Function makeENV([string]$FILENAME)
    {
    $SECRET = Read-Host -Prompt "Please enter the secret for your FFXIV Account then press 'Enter'"
    New-Item -Path . -Name ".env" -Value "$SECRET"
    Write-Output "Created .env containing secret key"
    }

Function checkValidENV()
    {
    #If file exists and is not empty
    if (test-path $FILENAME)
        {
        if ( [String]::IsNullOrWhiteSpace((Get-Content $FILENAME)) )
            {
            Remove-Item $FILENAME
            makeENV($FILENAME)
            }
        else
            {
            Write-Output ".env file already exists, continuing..."
            }
        }
    else
        {
        makeENV($FILENAME)
        }        
    }

Function validatePython()
    {
    #Extracting the version number from the 'python --version' command
    $result = & python --version 2>&1 | Select-String -Pattern 'Python\s*([\d.]+)'  #| foreach-object {$_ -replace "[^0-9]." , ''}
    #Base32 regex
    # ^(?:[A-Z2-7]{8})*(?:[A-Z2-7]{2}={6}|[A-Z2-7]{4}={4}|[A-Z2-7]{5}={3}|[A-Z2-7]{7}=)?$
    #$result == [regex]::match($version, "Python\s*([\d.]+)").Groups[1].Value
    return $result.matches.groups[1]
    }

#Start of main process
checkValidENV

$SECRET = Get-Content $FILENAME
Write-Output $SECRET
if ( (Test-Path $pythonFile) -and (Get-FileHash "./$pythonFile" -Algorithm MD5).Hash -eq $checksum)
    {
    Write-Output "Found Python3 executable..."
    }
else
    {
    $response = Read-Host -Prompt "Python3 is required to use YubiKey authentication. Would you like to download it? (Y/N)"
    $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/$pyVersion/$pythonFile" -OutFile $pythonFile
    Write-Output "Finished downloading $pythonFile"
    }
$version = validatePython
if($version)
    {
    #Found python version, check if 3.6 or higher...
    Write-Output "Found installed python version: $version"
    }
else
    {
    #Install python
    $res = validatePython
    Write-Output "Please check prompt, and install python3 $res"
    $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
    Start-Process -FilePath "./$pythonFile" -ArgumentList "InstallAllUsers=1 PrependPath=1 Include_test=0"  -NoNewWindow -Wait
    }

#PYTHON 3 URL: https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe
#ykman oath accounts add ffxiv-test --oath-type TOTP $SECRET --touch