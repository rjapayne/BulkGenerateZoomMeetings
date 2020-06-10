$JTWToken = 'JTWToken GOES HERE'
$headers = @{"Authorization"="Bearer "+$JTWToken}
$domain = 'https://api.zoom.us/v2/'
$list = Import-Csv ($PSScriptRoot + '\zoom_meetings.csv') #get list from .csv
$outputData = @('"name","username","url"')
cd $PSScriptRoot

foreach($user in $list){
    if($user.name -ne '' -and $user.email){
        try{
            $meetingURI = $domain+'/users/'+$user.email+'/meetings'
            $meetingSettings = @{
                "host_video"= "false";
                "participant_video"= "false";
                "waiting_room"="true";
                "join_before_host"= "false";
                "mute_upon_entry"= "true";
                "use_pmi"= "false";
                "audio"= "BOTH";
                "auto_recording"= "false";
                "alternative_hosts"= $user.cohost;
                "approval_type" = "2";
            }
            $meetingParams =@{
                "topic"=($user.name + " - " + $user.meetingName);
                "type"="2";
                "start_time"=$user.start_date;
                "duration"="480";
                "schedule_for"=$user.email;
                "timezone"="Australia/Sydney";
                "settings"=$meetingSettings;
            }
            $data1 = (Invoke-WebRequest -Headers $headers -Method POST -ContentType 'application/json' -Uri $meetingURI -Body ($meetingParams | ConvertTo-Json)) | ConvertFrom-JSON
            $outputData += @($user.name+","+$user.email+","+$data1.join_url)
        }catch{$outputData += @($user.name+","+$user.email+","+"ERROR: Is email correct?")}
    }
}

Remove-Item ($PSScriptRoot + '\zoomdata.csv')
$outputData | foreach { Add-Content -Path ($PSScriptRoot+'\zoomdata.csv') -Value $_ }