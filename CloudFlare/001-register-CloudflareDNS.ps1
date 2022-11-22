#  This script can be used within a Skillable Studio LCA to enable Dynamic DNS agaist Cloudflare.  
# To use this script the following parameters will need to be added as part of the setup

# **publicIP** Will need to have the correct VM @lab put in place, this would normally be the public interface of the VM acting as a firewall
# **hostname** We would recommend that the Lab Instance ID is in the hostname but what other characters would be required around it?
# **$domain** Update with the domain name that the DNS records will be added to  Note the preceding dot/fullstop/period.
# **Headers** Update the Authorization entery to add the Bearer tken that you would get from Cloudflare.  Just replace the string in the angled brackets including the brackets.


$zoneURL = 'https://api.cloudflare.com/client/v4/zones'
$publicIP = '@lab.VirtualMachine(VMName).NetworkAdapter(WAN).IpAddress'
$labInstanceID = '@lab.LabInstance.Id'
$hostname = "i$labInstanceID"
$domain = ".example.com"
$match = $False

## Retrieve the Zone ID for the DNS Domain

$apiCall = @{
        Method = "Get"
        Uri =  $zoneURL
        ContentType = "application/json"
    }

$Headers = @{
    "Authorization" = "Bearer <bearer token goes here>"
   } 


$apiResponse = Invoke-RestMethod @apiCall -Headers $Headers

$zoneID = $apiResponse.result[0].id

## Search for DNS Record - to make sure it does not exist already.

$apiCall = @{
        Method = "GET"
        Uri =  "$($zoneURL)/$($zoneID)/dns_records"
        ContentType = "application/json"
    }

$apiResponse = Invoke-RestMethod @apiCall -Headers $Headers

for ($i=0; $apiResponse.result.Count -gt $i; $i++){
     if ($apiResponse.result[$i].name -eq $hostname+$domain  ) {
      $match = $true
      $i = $apiResponse.result.Count
    }
}

## If the DNS record does not exist, set the DNS Record

if ($match -eq $False ) {

$apiCall = @{
        Method = "POST"
        Uri =  "$($zoneURL)/$($zoneID)/dns_records"
        ContentType = "application/json"
    }

$Body = @{ 
    "type" = "A"
    "name" = $hostname
    "content" = $publicIP
    "proxied" = $true
    "ttl" = 1
}

$apiResponse = Invoke-RestMethod @apiCall -Headers $Headers -Body ( $Body | ConvertTo-Json )

}

