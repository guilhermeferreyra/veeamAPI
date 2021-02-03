#region Config
$veeamServer = "denver"
$veeamDeployment = "Infiniit"#+ $env:COMPUTERNAME
$APIendpoint = "http://10.0.1.220:8080/"
$HourstoCheck = 720
$credentials = "C:\Users\guilherme.ferreira\cred.txt"

Add-PSSnapin VeeamPSSnapin
Disconnect-VBRServer
Connect-VBRServer -Server $veeamServer -Credential (Import-CliXml -Path $credentials) -ErrorAction Ignore

#endregion

#region Script

$backupSessions = Get-VBRBackupSession

$backupSessions = @($backupSessions | Where-Object {($_.EndTime -ge (Get-Date).AddHours(-$HourstoCheck) -or $_.CreationTime -ge (Get-Date).AddHours(-$HourstoCheck) -or $_.State -eq "Working") -and $_.JobType -eq "Backup"})

foreach($session in $backupSessions){
  
  if ($session.Progress.ReadSize -eq 0){$dedupe = 0} 
  Else {$dedupe = [string][Math]::Round($session.BackupStats.GetDedupeX(),1) +"x"}
  
  if ($session.Progress.ReadSize -eq 0){$compress = 0}
  Else {$compress = [string][Math]::Round($session.BackupStats.GetCompressX(),1) +"x"}
    
  $objSession = New-Object -TypeName PSObject
  $objSession | Add-Member -MemberType NoteProperty -Name Job_Name -Value $session.Name
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
  #$objSession | ConvertTo-Json
}
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

$backupJobs = Get-VBRJob
$backupJobs = @($backupJobs | Where-Object -Property TypeToString -NotLike "*Copy")

foreach($job in $backupJobs){
  $objJob = New-Object -TypeName PSObject
  $objJob | Add-Member -MemberType NoteProperty -Name JobName -Value $job.Name
  $objJob | Add-Member -MemberType NoteProperty -Name JobType -Value $job.TypeToString
  $objJob | Add-Member -MemberType NoteProperty -Name Uid -Value $job.Uid.Uid
  $objJob | Add-Member -MemberType NoteProperty -Name LatestRunLocal -Value ([datetime]$session.CreationTime | Get-date -Format "yyyy-MM-dd HH:mm:ss")
  $objJob | Add-Member -MemberType NoteProperty -Name LatestStatus -Value ([string]$job.Info.LatestStatus)
  $objJob | Add-Member -MemberType NoteProperty -Name Customer -Value $veeamDeployment
  $objJob | Add-Member -MemberType NoteProperty -Name JobHash -Value ([string]$objJob.Uid + [string]$objJob.LatestRunLocal)

  Invoke-WebRequest -Uri ($APIendpoint+"/sendJob.php") -Method Post -Body ($objJob | ConvertTo-Json) -ContentType 'application/json'
  #$objJob | ConvertTo-Json 
}

#Disconnect-VBRServer