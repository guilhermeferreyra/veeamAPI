<?php
if(strcasecmp($_SERVER['REQUEST_METHOD'], 'POST') != 0){
    throw new Exception('Request method must be POST!');
}

$contentType = isset($_SERVER["CONTENT_TYPE"]) ? trim($_SERVER["CONTENT_TYPE"]) : '';
if(strcasecmp($contentType, 'application/json') != 0){
    throw new Exception('Content type must be: application/json');
}
 
$content = trim(file_get_contents("php://input"));
$decoded = json_decode($content);


$customer = $decoded->Customer;
$session_id = $decoded->SessionID;
$job_id = $decoded->JobID;
$job_name = $decoded->Job_Name;
$last_status = $decoded->State;
$start_time = $decoded->Start_Time;
$end_time = $decoded->Stop_Time;
$duration = $decoded->Duration;
$avg_speed = $decoded->Avg_Speed;
$data_processed = $decoded->Processed;
$data_total = $decoded->Total;
$data_read = $decoded->Data_read;
$data_transferred = $decoded->Transferred;
$data_dedupe = $decoded->DedupeRate;
$data_compress = $decoded->CompressionRate;

echo $last_status."\n";

try
{
    $pdo = new PDO( 'mysql:host=' . "localhost" . ';dbname=' . "veeam_api", "root", "" );
}
catch ( PDOException $e )
{
    echo 'Erro ao conectar com o MySQL: ' . $e->getMessage();
}

$pdo->exec("set names utf8");

$sql = "INSERT INTO backup_sessions( 
    customer,
    job_id,
    ses_id,
    last_status,
    start_time,
    end_time,
    duration,
    avg_speed,
    data_processed,
    data_total,
    data_read,
    data_transferred,
    data_dedupe,
    data_compress,
    job_name) 
VALUES(
    :customer,
    :job_id,
    :ses_id,
    :last_status,
    :start_time,
    :end_time,
    :duration,
    :avg_speed,
    :data_processed,
    :data_total,
    :data_read,
    :data_transferred,
    :data_dedupe,
    :data_compress,
    :job_name)";

$stmt = $pdo->prepare($sql);
$stmt->bindParam(':customer', $customer);
$stmt->bindParam(':job_id', $job_id);
$stmt->bindParam(':ses_id', $session_id);
$stmt->bindParam(':last_status', $last_status);
$stmt->bindParam(':start_time', $start_time);
$stmt->bindParam(':end_time', $end_time);
$stmt->bindParam(':duration', $duration);
$stmt->bindParam(':avg_speed', $avg_speed);
$stmt->bindParam(':data_processed', $data_processed);
$stmt->bindParam(':data_total', $data_total);
$stmt->bindParam(':data_read', $data_read);
$stmt->bindParam(':data_transferred', $data_transferred);
$stmt->bindParam(':data_dedupe', $data_dedupe);
$stmt->bindParam(':data_compress', $data_compress);
$stmt->bindParam(':job_name', $job_name);

$result = $stmt->execute();
 
if ( ! $result )
{
    var_dump( $stmt->errorInfo() );
    exit;
}
 
echo $stmt->rowCount() . "linhas inseridas\n";
?>