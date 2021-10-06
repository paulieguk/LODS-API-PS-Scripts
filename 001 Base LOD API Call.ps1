## Set your api key, site url, Be sure to remove the <>Brackets when adding the api key.
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
    $apiResponse.LabProfiles | Format-Table Id, Name, Number, SeriesID
}else{
    Write-Host "This Catalog does not contain any Lab Profiles" -ForegroundColor Magenta
}

