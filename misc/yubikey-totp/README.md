# For future me:

## Your ENV File
Create a file named `.env` that contains the **secret key** used for your FFXIV account's 2FA
- At the time of writing this, Square gives you a QR Code, get the secret from that.
  - This should help get you in the right direction, there's plenty of other ways to do so though.
   https://gist.github.com/kensykora/b220573b4230d7622c5a23a497c75fd3

## Prereq Setup
The setup script was never finished, but you'd plug in your yubikey then run this or something similar:
- **ykman oath accounts add ffxiv-test --oath-type TOTP $SECRET --touch**
  - Where `SECRET` is that secret key in the .env file we created earlier.

The above command creates a new entry on your yubikey called `ffxiv-test`
- The actual auth script `yubikey-auth.ps1` will run this line:
  - **ykman oath accounts code ffxiv-test**
- Which attempts to generate then read the TOTP code stored on your Yubikey (prompting you to touch your device.)

Once the code is gotten, `XIVLauncher` is started for you,  the code is sent through a local HTTP request and your game loads. Convenient, huh?

The `.lnk` file was made so that there was a nice little shortcut you could put on your desktop/taskbar for easy access

## Why I'm writing this
I figure sometime in the distant [or near] future you'll come back to this and in the event you're lost for whatever reason, this'll be here to get the cogs turning
- Anything I didn't explain here, you should be able to figure out by ___reading___ the script(s)

It wouldn't be the first time you picked this project back up *6+ months later...*
