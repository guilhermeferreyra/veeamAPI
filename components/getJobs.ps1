#region Config
$veeamServer = "denver"
$veeamDeployment = "Infiniit"#+ $env:COMPUTERNAME
$APIendpoint = "https://veeamapi.infiniit.com.br/"
$HourstoCheck = 720
#$credentials = "C:\Users\guilherme.ferreira\cred.txt"

Add-PSSnapin VeeamPSSnapin
#Disconnect-VBRServer
#Connect-VBRServer -Server $veeamServer -Credential (Import-CliXml -Path $credentials) -ErrorAction Ignore
#endregion

#region Functions
function Get-Duration {
  param ($ts)
  $days = ""
  If ($ts.Days -gt 0) {
    $days = "{0}:" -f $ts.Days
  }
  "{0}{1}:{2,2:D2}:{3,2:D2}" -f $days,$ts.Hours,$ts.Minutes,$ts.Seconds
}
#endregion

#region Script
$agentJobs = Get-VBRComputerBackupJob
foreach($agentJob in $agentJobs){
  $objAgentJob = New-Object -TypeName PSObject
  $objAgentJob | Add-Member -MemberType NoteProperty -Name Customer -Value $veeamDeployment
  $objAgentJob | Add-Member -MemberType NoteProperty -Name JobID -Value $agentJob.Id
  $objAgentJob | Add-Member -MemberType NoteProperty -Name Name -Value $agentJob.Name
  $objAgentJob | Add-Member -MemberType NoteProperty -Name OSPlatform -Value ([string]$agentJob.OSPlatform)
  $objAgentJob | Add-Member -MemberType NoteProperty -Name BackupObject -Value $agentJob.BackupObject.Name
  $objAgentJob | Add-Member -MemberType NoteProperty -Name JobEnabled -Value ([string]$agentJob.JobEnabled)
 
  Invoke-WebRequest -Uri ($APIendpoint+"/sendAgent.php") -Method Post -Body ($objAgentJob | ConvertTo-Json) -ContentType 'application/json'
}

$agentSessions = Get-VBRComputerBackupJobSession
$agentSessions = @($agentSessions | Where-Object {($_.CreationTime -ge (Get-Date).AddHours(-$HourstoCheck)) -and $_.State -eq "Stopped"})
foreach($agentSession in $agentSessions){

  $objAgent = New-Object -TypeName PSObject
  $objAgent | Add-Member -MemberType NoteProperty -Name Customer -Value $veeamDeployment
  $objAgent | Add-Member -MemberType NoteProperty -Name CreationTime -Value ([datetime]$agentSession.CreationTime | Get-date -Format "yyyy-MM-dd HH:mm:ss")
  $objAgent | Add-Member -MemberType NoteProperty -Name EndTime -Value ([datetime]$agentSession.EndTime | Get-date -Format "yyyy-MM-dd HH:mm:ss")
  $objAgent | Add-Member -MemberType NoteProperty -Name JobId -Value $agentSession.JobId
  $objAgent | Add-Member -MemberType NoteProperty -Name Result -Value ([string]$agentSession.result)
  $objAgent | Add-Member -MemberType NoteProperty -Name SessionId -Value $agentSession.Id

  Invoke-WebRequest -Uri ($APIendpoint+"/sendAgent.php") -Method Post -Body ($objAgent | ConvertTo-Json) -ContentType 'application/json'
}

$backupJobs = Get-VBRJob
foreach($backupJob in $backupJobs){
  $objJob = New-Object -TypeName PSObject
  $objJob | Add-Member -MemberType NoteProperty -Name JobName -Value $backupJob.Name
  $objJob | Add-Member -MemberType NoteProperty -Name JobType -Value $backupJob.TypeToString
  $objJob | Add-Member -MemberType NoteProperty -Name Uid -Value $backupJob.Uid.Uid
  $objJob | Add-Member -MemberType NoteProperty -Name LatestRunLocal -Value ([datetime]$backupJob.CreationTime | Get-date -Format "yyyy-MM-dd HH:mm:ss")
  $objJob | Add-Member -MemberType NoteProperty -Name LatestStatus -Value ([string]$backupJob.Info.LatestStatus)
  $objJob | Add-Member -MemberType NoteProperty -Name Customer -Value $veeamDeployment
  $objJob | Add-Member -MemberType NoteProperty -Name JobHash -Value ([string]$objJob.Uid + [string]$objJob.LatestRunLocal)

  Invoke-WebRequest -Uri ($APIendpoint+"/sendJob.php") -Method Post -Body ($objJob | ConvertTo-Json) -ContentType 'application/json'
}

$backupSessions = Get-VBRBackupSession
$backupSessions = @($backupSessions | Where-Object {($_.EndTime -ge (Get-Date).AddHours(-$HourstoCheck) -or $_.CreationTime -ge (Get-Date).AddHours(-$HourstoCheck) -or $_.State -eq "Working") <#-and $_.JobType -eq "Backup"#>})
foreach($session in $backupSessions){
  
  if ($session.Progress.ReadSize -eq 0){$dedupe = 0} 
  Else {$dedupe = [string][Math]::Round($session.BackupStats.GetDedupeX(),1) +"x"}
  
  if ($session.Progress.ReadSize -eq 0){$compress = 0}
  Else {$compress = [string][Math]::Round($session.BackupStats.GetCompressX(),1) +"x"}
    
  $objSession = New-Object -TypeName PSObject
  $objSession | Add-Member -MemberType NoteProperty -Name Job_Name -Value $session.Name
  $objSession | Add-Member -MemberType NoteProperty -Name Job_Type -Value ([string]$session.JobType)
  $objSession | Add-Member -MemberType NoteProperty -Name SessionID -Value ([string]$session.Id)
  $objSession | Add-Member -MemberType NoteProperty -Name JobID -Value ([string]$session.Info.JobId)
  $objSession | Add-Member -MemberType NoteProperty -Name Customer -Value $veeamDeployment
  $objSession | Add-Member -MemberType NoteProperty -Name State -Value ([string]$session.Info.Result)
  $objSession | Add-Member -MemberType NoteProperty -Name Start_Time -Value ([datetime]$session.CreationTime | Get-date -Format "yyyy-MM-dd HH:mm:ss")
  $objSession | Add-Member -MemberType NoteProperty -Name Stop_Time -Value ([datetime]$session.EndTime | Get-date -Format "yyyy-MM-dd HH:mm:ss")
  $objSession | Add-Member -MemberType NoteProperty -Name Duration -Value $session.Progress.Duration.TotalSeconds
  $objSession | Add-Member -MemberType NoteProperty -Name Avg_Speed -Value ([Math]::Round($session.Progress.AvgSpeed/1MB,2))
  $objSession | Add-Member -MemberType NoteProperty -Name Total -Value ([Math]::Round($session.Progress.ProcessedSize/1GB,2))
  $objSession | Add-Member -MemberType NoteProperty -Name Processed -Value ([Math]::Round($session.Progress.ProcessedUsedSize/1GB,2))
  $objSession | Add-Member -MemberType NoteProperty -Name Data_read -Value ([Math]::Round($session.Progress.ReadSize/1GB,2))
  $objSession | Add-Member -MemberType NoteProperty -Name Transferred -Value ([Math]::Round($session.Progress.TransferedSize/1GB,2))
  $objSession | Add-Member -MemberType NoteProperty -Name DedupeRate -Value $dedupe
  $objSession | Add-Member -MemberType NoteProperty -Name CompressionRate -Value $compress
    
  Invoke-WebRequest -Uri ($APIendpoint+"/sendSession.php") -Method Post -Body ($objSession | ConvertTo-Json) -ContentType 'application/json' 
}


#endregion



#Disconnect-VBRServer