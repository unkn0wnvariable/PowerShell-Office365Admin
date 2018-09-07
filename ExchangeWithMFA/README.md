# Exchange Online with MFA Support

## What is this?

Connecting to Exchange Online through a remote PowerShell session doesn't work when using multi factor authentication. You can (apparrently) get round that by creating an application password, but in my mind creating a password to bypass MFA somewhat defeates the point of enabling MFA in the first place.

There is a new module available which does support MFA, so this folder is where I'll be putting new scripts that support MFA or old scripts as I update them.

## Pre-requisites

To connect using MFA you have to locally install a new module from Microsoft. Which for whatever reason isn't available from PSGallery, nor can it be simply downloaded. Instead it has to be installed from within the Exchange Online admin centre using one of those annoying ClickOnce installers that only work in MS's own web browsers.

Microsoft have a document explaining the unnecessarily convulted install process here:

[Connect to Exchange Online PowerShell using multi-factor authentication](https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps)

In addition, because this will be using a remote session it will require the script execution policy within PowerShell to be changed to RemoteSigned. This is done either globally with:

`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`

Or for the current user with:

`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## Disclaimer

All scripts are provided as is without warranty of any kind, use them at your own risk.
