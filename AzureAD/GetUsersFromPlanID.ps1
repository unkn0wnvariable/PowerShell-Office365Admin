# Some example scripts for finding users with specific plans assigned
#
# A full list of subscription and plan ID's is available from:
# https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
#
# Here I'm using the following plan IDs.
# 
# OFFICESUBSCRIPTION (43de0ff5-c92c-492b-9116-175376d08c38)
# PROJECT_CLIENT_SUBSCRIPTION (fafd7243-e5c1-4a3a-9e40-495efcb1d3c3)
# VISIO_CLIENT_SUBSCRIPTION (663a804f-1c30-4ff0-9915-9db84f0d1cea)
# 

# Plan ID's to check for
$planID1 = '43de0ff5-c92c-492b-9116-175376d08c38'
$planID2 = 'fafd7243-e5c1-4a3a-9e40-495efcb1d3c3'
$planID3 = '663a804f-1c30-4ff0-9915-9db84f0d1cea'

# Import the AzureAD module and connect
Import-Module AzureAD
Connect-AzureAD

# Get all users from AzureAD
$allUsers = Get-AzureADUser -All $true

# Create variables to put the users in to
$planID1Users = @()
$planID2Users = @()
$planID3Users = @()

# Check through the users and check what plans are assigned and enabled
foreach ($user in $allUsers) {
    foreach ($assignedPlan in $user.AssignedPlans) {
        # Find all users of plan 1 and add to the related variable
        if ($assignedPlan.ServicePlanId -eq $planID1 -and $assignedPlan.CapabilityStatus -eq 'Enabled') {
            $planID1Users += $user
        }
        # Find all users of plan 2 and add to the related variable
        if ($assignedPlan.ServicePlanId -eq $planID2 -and $assignedPlan.CapabilityStatus -eq 'Enabled') {
            $planID2Users += $user
        }
        # Find all users of plan 3 and add to the related variable
        if ($assignedPlan.ServicePlanId -eq $planID3 -and $assignedPlan.CapabilityStatus -eq 'Enabled') {
            $planID3Users += $user
        }
    }
}

# Create variables to put the users in to
$plan1OnlyUsers = @()
$planID1and2Users = @()
$planID1and3Users = @()
$planID12and3Users = @()

# Using plan 1 as the master list, check which other licences are assigned
foreach ($planID1User in $planID1Users) {
    # Find users who are only in the plan 1 list
    if ($planID1User -notin $planID2Users -and $planID1User -notin $planID3Users) {
        $plan1OnlyUsers += $planID1User
    }
    # Find users who are the plan 1 and plan 2 list
    if ($planID1User -in $planID2Users) {
        $planID1and2Users += $planID1User
    }
    # Find users who are in the plan 1 and plan 3 list
    if ($planID1User -in $planID3Users) {
        $planID1and3Users += $planID1User
    }
    # Find users who are in all three lists
    if ($planID1User -in $planID2Users -and $planID1User -in $planID3Users) {
        $planID12and3Users += $planID1User
    }
}

# How many people in each list?
$plan1OnlyUsers.Count
$planID1and2Users.Count
$planID1and3Users.Count
$planID12and3Users.Count

# Who are those people?
$plan1OnlyUsers
$planID1and2Users
$planID1and3Users
$planID12and3Users
