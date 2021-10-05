## Set your api key, site url, Be sure to remove the <>Brackets when adding the api key.
$api_key = @{'api_key' = '<API key goes here>'}
$baseURL = 'https://labondemand.com/api/v3'
$apiCMD = 'catalog'

## Powershell does splatting pretty well, these are the parameters for the api call.
$apiCall = @{
        Method = "Get"
        Uri =  "$($baseURL)/$($apiCMD)"
        ContentType = "application/json"
        Headers = $api_key
    }

## This is the actual API Call to get the class as it is currently.
$apiResponse = Invoke-RestMethod @apiCall