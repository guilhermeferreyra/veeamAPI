Add-PSSnapin VeeamPSSnapIn

#Connect-VBRServer -Server denver -Credential (Import-CliXml -Path 'C:\Users\guilherme.ferreira\cred.txt')

$HourstoCheck = 24

$allSess = Get-VBRBackupSession

$PreviousDay = [DateTime]::Now.AddHours(-$HourstoCheck)
$sessions = Get-VBRBackupSession | Where-Object {($_.EndTime -gt $PreviousDay -or $_.StartTime -gt $PreviousDay)}
foreach($session in $sessions){
  $lastResult = Get-VBRJob | Where-Object {$_.Name -eq $session.JobName}
  $lastResult = $lastResult.Info.LatestStatus
  $sessionStatus = $session.Result
  $startTime = $session.Progress.StartTimeLocal
  $endTime = $session.Progress.StopTimeLocal
  $duration = $session.Progress.Duration.TotalSeconds
  $backupSize = $session.BackupStats.BackupSize
  
  $sessListBk = @($allSess | ?{($_.EndTime -ge (Get-Date).AddHours(-$HourstoCheck) -or $_.CreationTime -ge (Get-Date).AddHours(-$HourstoCheck) -or $_.State -eq "Working") -and $_.JobType -eq "Backup"})
  
  $arrAllSessBk = $sessListBk | Sort-Object -Property Creationtime | Select-Object -Property @{Name="Job Name"; Expression = {$_.Name}},
        @{Name="State"; Expression = {$_.State}},
        @{Name="Start Time"; Expression = {$_.CreationTime}},
        @{Name="Stop Time"; Expression = {If ($_.EndTime -eq "1/1/1900 12:00:00 AM"){"-"} Else {$_.EndTime}}},
        @{Name="Duration (HH:MM:SS)"; Expression = {Get-Duration -ts $_.Progress.Duration}},                    
        @{Name="Avg Speed (MB/s)"; Expression = {[Math]::Round($_.Progress.AvgSpeed/1MB,2)}},
        @{Name="Total (GB)"; Expression = {[Math]::Round($_.Progress.ProcessedSize/1GB,2)}},
        @{Name="Processed (GB)"; Expression = {[Math]::Round($_.Progress.ProcessedUsedSize/1GB,2)}},
        @{Name="Data Read (GB)"; Expression = {[Math]::Round($_.Progress.ReadSize/1GB,2)}},
        @{Name="Transferred (GB)"; Expression = {[Math]::Round($_.Progress.TransferedSize/1GB,2)}},
        @{Name="Dedupe"; Expression = {
          If ($_.Progress.ReadSize -eq 0) {0}
          Else {([string][Math]::Round($_.BackupStats.GetDedupeX(),1)) +"x"}}},
        @{Name="Compression"; Expression = {
          If ($_.Progress.ReadSize -eq 0) {0}
          Else {([string][Math]::Round($_.BackupStats.GetCompressX(),1)) +"x"}}},
        @{Name="Details"; Expression = {($_.GetDetails()).Replace("<br />","ZZbrZZ")}}, Result
        
             
}

foreach($data in $arrAllSessBk){
  [array]$json = $data | ConvertTo-Json
    
  $post = Invoke-WebRequest -Uri http://localhost/veeamAPI/api.php -Method Post -Body $json -ContentType 'application/json' 
  $post
}



function Get-Duration {
  param ($ts)
  $days = ""
  If ($ts.Days -gt 0) {
    $days = "{0}:" -f $ts.Days
  }
  "{0}{1}:{2,2:D2}:{3,2:D2}" -f $days,$ts.Hours,$ts.Minutes,$ts.Seconds
}

function Get-BackupSize {
  param ($backups)
  $outputObj = @()
  Foreach ($backup in $backups) {
    $backupSize = 0
    $dataSize = 0
    $files = $backup.GetAllStorages()
    Foreach ($file in $Files) {
      $backupSize += [math]::Round([long]$file.Stats.BackupSize/1GB, 2)
      $dataSize += [math]::Round([long]$file.Stats.DataSize/1GB, 2)
    }         
    $repo = If ($($script:repoList | Where {$_.Id -eq $backup.RepositoryId}).Name) {
              $($script:repoList | Where {$_.Id -eq $backup.RepositoryId}).Name
            } Else {
              $($script:repoListSo | Where {$_.Id -eq $backup.RepositoryId}).Name
            }
    $vbrMasterHash = @{
      JobName = $backup.JobName
      VMCount = $backup.VmCount
      Repo = $repo
      DataSize = $dataSize
      BackupSize = $backupSize
    }
    $vbrMasterObj = New-Object -TypeName PSObject -Property $vbrMasterHash
    $outputObj += $vbrMasterObj
  }
  $outputObj
}