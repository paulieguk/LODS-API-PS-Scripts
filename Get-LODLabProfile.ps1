<#
    .SYNOPSIS
    This example script enables the searching of Lab Profiles using text matching against all the Lab Profile data exposed by the API Consumer.

    .DESCRIPTION
    Version 1.0.0.0
    This script will use the LOD Catalog API (https://docs.skillable.com/lod/lod-api/lod-api-catalog.md) call to retrieve and search for a list of Lab Profiles matching the input values.
    When a match is found the Lab Profile details contained in the Catalog are returned.

    The script output will report the following information for matching Lab Profiles:
    Lap Profile ID
    Lab Profile Number
    Lab Profile Name

    The script uses different exit codes if the script fails to find data:

    Code  |  Reason
    ------|-----------------------------------------------
    1000  | No Lab Profiles found against the API Consumer
    1001  | No Lab Profiles found matching the search term

    This script can be edited to embed the API key within the script for more automation scenarios.  
    The API Key is inserted by replacing the text 'Type API Key between these quotes replacing this text' ensure the single quotes are left in place.
    
    .EXAMPLE
    Get-LODSLabProfile.ps1 -APIKey '12345678-1234-1234-1234-12345678'
#>


Param (
    [Parameter(Mandatory=$True,
        Position=0,
        HelpMessage="InputData specifies the string you would like to match in the Lab Profile data.  This input will match against all Lap Profile fields that are exposed via the LOD API"
        )]
        [Alias("ID")]
        #InputData specifies the string you would like to match in the Lab Profile data.  This input will match against all Lap Profile fields that are exposed via the LOD API
        [string[]]
        $InputData,
    [Parameter(
        HelpMessage="Specifies the API Consumer API Key in the format of a GUID (for example: 12345678-1234-1234-1234-12345678)" )]
        [Alias("APIKey","ak","API-Key")]
        #Specifies the API Consumer API Key in the format of a GUID (for example: 12345678-1234-1234-1234-12345678)
        $API_Key = $null
)

## Set your api key,  Be sure to remove the <>Brackets when adding the api key.
if ($API_key -eq $null){
    $api_key = @{'api_key' = 'Type API Key between these quotes replacing this text'}
    }
    Else {
    $api_key = @{'api_key' = "$($API_key)"}
    }

## Setup the API call
$baseURL = 'https://labondemand.com/api/v3'
$apiCMD = 'catalog'

## Powershell setup the API Call.
$apiCall = @{
        Method = "Get"
        Uri =  "$($baseURL)/$($apiCMD)"
        ContentType = "application/json"
        Headers = $api_key
    }

## Execute the API call.
$apiResponse = Invoke-RestMethod @apiCall

## Test to see if any Lab Profiles have been returned (did the API call work or does the API Consumer have Labs published
if ($apiResponse.LabProfiles.Count -eq 0) {
    Write-Host -ForegroundColor "Yellow" "No Lab Profiles returned using this API Key"
    Exit 1000
    }

## Test to see if any Lab Profiles match the search critrea
$results = $apiResponse.LabProfiles -match $InputData
if ($results.count -eq 0){
    Write-Host -ForegroundColor "Yellow" "No Lab Profiles found using the input value of $InputData"
    Exit 1001
    }

## Display results
$results | format-table id, number, name
