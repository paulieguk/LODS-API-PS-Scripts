<#
This script is designed to run at teardown and query the Skillable API for the Lab Instance Details and then report spicfic fields to an external web system.  
This script is writen to work with an unauthernticated service but if the destination system requires an API Key set in the header the @lab vartibale van be set 
and the apikey value in the customer EP call can be uncommented.

Currently the default Skilable API Consumer this Lab Profile uses is the CSM API Consumer.  https://labondemand.com/ApiConsumer/345
#>

#Set Variables
$Studio_APIKEY = @{'api_key' = '@lab.Variable(StudioAPIKEY)'}

#If the customer system requires an API Key supplied in the header uncomment this value and set the paramater and key.
#$Customer_APIKEY = @{'api_key' = '@lab.variable(CustomerAPIKEY)'}
$LabInstanceID = '@lab.LabInstance.Id'
$StudioURL = "https://labondemand.com/api/v3/Details?labinstanceid=$($LabInstanceID)"
#Chnage the line below to reflect the customers end point the data needs to go to.
$CustomerEP = '@lab.Variable(webhooksiteurl)/?'

<#
Setup Return data.  Customise the Hashtable below by adding or removing .add enteries.  
The left hand value is the name of the field in the Skillable Studio API Call (refer to htps://connect.skillable.com)
The right hand value is the textyou would like the value displayed against, this would normally be the paramter name the recieving system is expecting.
#>

$returndata = [Ordered]@{}
$returndata.Add('id', 'LabInstanceID')
$returndata.Add('userfirstname', 'FirstName')
$returndata.Add('userlastname', 'Surname')
$returndata.Add('totalruntime', 'TotalLabTime(Seconds)')
$returndata.Add('exampassed', 'Passed')
$returndata.Add('exammaxpossiblescore', 'MaximumScore')
$returndata.Add('exampassingscore', 'RequiredScore')
$returndata.Add('examscore', 'UsersScore')

## Powershell setup the API Call.
$apiCall = @{
        Method = "Get"
        Uri =  "$($StudioURL)"
        ContentType = "application/json"
        Headers = $Studio_APIKEY
    }

## Details API Call to Skillable Studio.
$apiResponse = Invoke-RestMethod @apiCall

## Work in progress this will write an error to the destination system
if ($apiResponse.error -eq "This API consumer does not have access to this lab instance."){
#    Write-Error ""
    }

##  Build the URL to send to the customer system
foreach ($key in $returndata.keys)
{
    $CustomerEP += "$($returndata[$key])=$($apiresponse.$key)&"

}

##  Remove the & off the end of the url
$CustomerEP.Substring(0,$CustomerEP.Length-1)

## Build the customer end point call.  Remove the # if an API Key is required in the header
$CustapiCall = @{
        Method = "Post"
        Uri = "$($CustomerEP)"
        ContentType = "applicaton/json"
        #Headers = $Customer_APIKEY
        }

## This is the API Call to send the data to the customers system.
Invoke-RestMethod @Custapicall
