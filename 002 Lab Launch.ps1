##This script will launch a LOD lab API using PowerShell.

## Set your api key,  Be sure to remove the <>Brackets when adding the api key.
$api_key = @{'api_key' = 'API Key goes here'}
$baseURL = 'https://labondemand.com/api/v3'
$apiCMD = 'launch'
$labId = 'LabId'
$UserId = 'UserID'
$firstName = 'FName'
$lastName = 'LName'

$apiCMD = "$($apiCMD)?labid=$($labId)&userid=$($userid)&firstname=$($firstName)&lastname=$($lastname)"

## Powershell setup the API Call.
$apiCall = @{
        Method = "Get"
        Uri =  "$($baseURL)/$($apiCMD)"
        ContentType = "application/json"
        Headers = $api_key
    }

## This is the actual API Call to get the class as it is currently.
$apiResponse = Invoke-RestMethod @apiCall

start-process "$($apiResponse.url)"

