##This script will catalog labs abailable via you API using PowerShell.
##The script output will report the following oinformation:
##  Lab Series Id's and Lab Series Names over the API Consumer
##  Lap Profile Id's, Lab Profile Name, Lab Series Id the Lab Profile is in and the Lab Series Name.

## Set your api key,  Be sure to remove the <>Brackets when adding the api key.
$api_key = @{'api_key' = '<API key goes here>'}
$baseURL = 'https://labondemand.com/api/v3'
$apiCMD = 'catalog'

## Powershell setup the API Call.
$apiCall = @{
        Method = "Get"
        Uri =  "$($baseURL)/$($apiCMD)"
        ContentType = "application/json"
        Headers = $api_key
    }

## This is the actual API Call to get the class as it is currently.
$apiResponse = Invoke-RestMethod @apiCall

##Display the returned data
If ($apiResponse.LabSeries.Count -gt 0) {
    Write-Host
    Write-Host "This Catalog contains $($apiResponse.LabSeries.Count) Lab Series:" -ForegroundColor Green
    $apiResponse.LabSeries | Format-Table Id, Name
}else{
    Write-Host "This Catalog does not contain any Lab Series" -ForegroundColor Magenta
}

If ($apiResponse.LabProfiles.Count -gt 0) {
    Write-Host
    Write-Host "This Catalog contains $($apiResponse.LabProfiles.Count) Lab Profiles:" -ForegroundColor Green
    
    For ($i = 0; $i -le $apiresponse.labprofiles.count; $i++) {
        $count = 0
        while ($apiResponse.LabSeries.Id[$count] -ne $apiResponse.LabProfiles.SeriesId[$i]){
            $count++
        }
        [pscustomobject] @{
            'Lab Profile Id' = $apiResponse.labprofiles.Id[$i]
            Name = $apiResponse.labprofiles.Name[$i]
            'Lab Series Id' = $apiResponse.labprofiles.SeriesId[$i]
            'Lab Series Name' = $apiResponse.LabSeries.Name[$Count]
        }
    } 

}else{
    Write-Host "This Catalog does not contain any Lab Profiles" -ForegroundColor Yellow
} 

 Format-Table


