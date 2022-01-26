<#

    .SYNOPSIS
    This example script will take a text/CSV file containing a single column of Lab Instance ID's, extract the performance testing data and output a resulting CSV file for analysis in Pivot tables or PowerBI etc.

    .DESCRIPTION
    Version 1.0.0.0
    This script can be used to extract the activity results for a set of Lab Instances by specifying the Lab Instance ID's in a file that can be extracted from LabOnDemand or from the TMS by using a Lab Instances Report.  The source file requires a single column of Lab Instance ID's available across the API consumer that is specfied either on the command line or by editing the script to bake in the API key.

    The initial use of this script would allow aspect of the exams quality to be reviewed.  Examples of this would be:
        Which questions are always answer correctly
        Which questions are always answer wrongly
        Which questions are never/hardly answered
        Analyis pass and fail rates

    The script expects that all the Lab Instances specficied are for the same exam.  If they are not the script will still work but additional post script filtering will be required to organise the data.

    Depending on the number of Lab Instances being queried this script can take some time to run in testing 250 Lab Instances takes approxiamtely 2 minutes.

    Limitations:
        Does not error out when no activities are present
        Currently does not support activity groups
        Does not validate source file
        Does not check API Key is valid
        Does not error is Lab Instances are not available via the API Consumer

    .EXAMPLE
    Extract-LODActivityData.ps1 -InputFile 'D:\Data\Lab Instances full.csv'
    
    .EXAMPLE
    Extract-LODActivityData.ps1 -InputFile 'D:\Data\Lab Instances full.csv' -OutputFile 'D:\Data\Lab Instances full - Results.csv'
    
    .EXAMPLE
    Extract-LODActivityData.ps1 -InputFile 'D:\Data\Lab Instances full.csv' -OutputFile 'D:\Data\Lab Instances full - Results.csv' -APIKey '12345678-1234-1234-1234-12345678'
#>

Param (
    [Parameter(Mandatory=$True,
        Position=0,
        HelpMessage="Add the filename of teh file containing the Lab Instance ID's.")]
        [Alias("I","InputFileName","Path")]
        [string[]]
        #Specifies the name of the source file containing a column of Lab Instances ID's
        $InputFile,
    [Parameter(Position=1
        )]
        [Alias("O","OutputFileName","Destination")]
        [string[]]
        #Specifies the name of the Output file.  If omitted the input filename will be used with -output added to the filename
        $OutputFile = $null,
    [Parameter()]
        [Alias("APIKey","ak","API-Key")]
        #Specifies the API Consumer API Key in the format of a GUID (for example: 12345678-1234-1234-1234-12345678) 
        $API_Key = $null
)

##Global veriables
$Results = @{}

if (!(test-path "$inputfile")) {
    throw "Input filename is invalid"
    }

if ($outputfile -eq $null) {
    $outputfile = [System.IO.Path]::GetDirectoryName($inputfile) + "\" + [System.IO.Path]::GetFileNameWithoutExtension($inputfile) + "-output.csv"
    }

## Set your api key,  Be sure to remove the <>Brackets when adding the api key.
if ($API_key -eq $null){
    $api_key = @{'api_key' = 'Type API Key between these quotes replacing this text'}
    }
    Else {
    $api_key = @{'api_key' = "$($API_key)"}
    }

## Read CSV file in
$p = import-csv -path $inputfile


##  This main loop starts the extraction of each instance from the API.  The instance ID's are ready from the input list.
$baseURL = 'https://labondemand.com/api/v3'

For ($i=0; $i -lt $p.Count; $i++) {

$labinstanceid = $p[$i].psobject.properties.value
$apiCMD = "details?labinstanceid=$($labinstanceid)"

## Powershell setup the API Call.
$apiCall = @{
        Method = "Get"
        Uri =  "$($baseURL)/$($apiCMD)"
        ContentType = "application/json"
        Headers = $api_key
    }

## This is the actual API Call to get the class as it is currently.
$apiResponse = Invoke-RestMethod @apiCall

## Generates the progress bar
Write-Progress -Activity "Retreving Activity Data" -Status "Found Lab Instance: $labinstanceid" -PercentComplete ($i / $p.count * 100)

## This section contains the non activity related fields that are required for the CSV file.  Update as needed
$Results[$i] = 
    [ordered]@{
    "labInstanceID" = $apiResponse.Id 
    "Lab Profile Name" = $apiResponse.LabProfileName 
    "Maximum Score" = $apiResponse.ExamMaxPossibleScore 
    "Passing Score" = $apiResponse.ExamPassingScore 
    "Actual Score" = $apiResponse.ExamScore 
    "Pass" = $apiResponse.ExamPassed 
    "Date taken" = $apiResponse.StartTime 
    "First Name" = $apiResponse.UserFirstName 
    "Surname Name" = $apiResponse.UserLastName 
    "Lab Run Time" = $apiResponse.TotalRunTime
    }

## This iner loop cycles through the activities and extracts the Activity ID and a True/False for pass and fail.  
##Additional Activity fields could be added.

    For ($i1=0; $i1 -lt $apiResponse.ActivityResults.Count; $i1++){
    $Results[$i] += [ordered]@{
        "ActivityID: $($apiResponse.ActivityResults[$i1].ActivityID)" = $apiResponse.ActivityResults[$i1].Passed 
        }
    } 
}

## Write file to the output CSV
$Results.GetEnumerator() | ForEach-Object {[PSCustomObject]$_.value} | Export-Csv -Path "$outputfile" -NoTypeInformation


Write-host "Output written to $($outputfile).  The script run in $($elapsedTime.Second) seconds"
