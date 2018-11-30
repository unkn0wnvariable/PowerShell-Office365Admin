# Exchange Online with AzureAD Connect

## What is this?

The scripts in this folder are for managing mailboxes in a synced environment, where you have an Exchange server on-prem purely for management purposes. This means all mailboxes are seen as "remote" mailboxes, so all the scripts use commands to that effect. These can easily be updated to a normal environment like on-prem only or cloud only just by removing the work "remote" from the commands. For example, Get-RemoteMailbox to just Get-Mailbox.

## Pre-requisites

These scripts require you to have on-prem Active Directory with an on-prem Exchange server for management, and using AzureAD Connect to sync to AzureAD.

It's pretty niche.

## Disclaimer

All scripts are provided as is without warranty of any kind, use them at your own risk.
