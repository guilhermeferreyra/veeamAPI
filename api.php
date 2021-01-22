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


$job_name = $decoded->JobName;
$customer = $decoded->Customer;
$last_status = $decoded->Result;
$start_time = $decoded->Start_Time->DateTime;
$end_time = $decoded->Stop_Time->DateTime;
$duration = $decoded->Duration;
$avg_speed = $decoded->Avg_Speed;
$data_processed = $decoded->Processed;
$data_total = $decoded->Customer;
$data_read = $decoded->Data_Read;
$data_transferred = $decoded->Transferred;
$data_dedupe = $decoded->DedupeRate;
$data_compress = $decoded->CompressionRate;

/*
$insert = [
    ':customer' => $customer,
    ':last_status' => $last_status,
    ':start_time' => $start_time,
    ':end_time' => $end_time,
    ':duration' => $duration,
    ':avg_speed' => $avg_speed,
    ':data_processed' => $data_processed,
    ':data_total' => $data_total,
    ':data_read' => $data_read,
    ':data_transferred' => $data_transferred,
    ':data_dedupe' => $data_dedupe,
    ':data_compress' => $data_compress,
    ':job_name' => $job_name,
];


{
    "Job Name":  "INFINIIT (Incremental)",
    "State":  -1,
    "JobName":  "INFINIIT",
    "Customer":  "Infiniit Dom Pedro",
    "Start_Time":  {
                       "value":  "\/Date(1611190823377)\/",
                       "DateTime":  "quarta-feira, 20 de janeiro de 2021 22:00:23"
                   },
    "Stop_Time":  {
                      "value":  "\/Date(1611191815627)\/",
                      "DateTime":  "quarta-feira, 20 de janeiro de 2021 22:16:55"
                  },
    "Duration":  "0:16:32",
    "Avg_Speed":  88.01,
    "Total":  1120,
    "Processed":  432.32,
    "Data_Read":  8.9,
    "Transferred":  2.35,
    "DedupeRate":  "1.1x",
    "CompressionRate":  "2.3x",
    "Details":  "",
    "Result":  0
}

*/

try
{
    $pdo = new PDO( 'mysql:host=' . "localhost" . ';dbname=' . "veeam_api", "root", "" );
}
catch ( PDOException $e )
{
    echo 'Erro ao conectar com o MySQL: ' . $e->getMessage();
}

$pdo->exec("set names utf8");

$sql = "INSERT INTO backup_jobs( 
    customer,
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

var_dump($stmt);

$result = $stmt->execute();
 
if ( ! $result )
{
    var_dump( $stmt->errorInfo() );
    exit;
}
 
echo $stmt->rowCount() . "linhas inseridas";



/*
$sql = "INSERT INTO veeam_api (customer, last_status, start_time, end_time, duration, avg_speed, data_processed, data_total, data_read, data_transferred, data_dedupe, data_compress, job_name) 
VALUES (:customer, :last_status, :start_time, :end_time, :duration, :avg_speed, :data_processed, :data_total, :data_read, :data_transferred, :data_dedupe, :data_compress, :job_name";
$stmt= $pdo->prepare($sql);
var_dump($pdo);
$stmt->execute($insert);
*/

/*
populateDb($job_name, $customer, $last_status, $start_time, $end_time, $duration, $avg_speed, $data_processed, $data_total, $data_read, $data_transferred, $data_dedupe, $data_compress);

function populateDb($job_name, $customer, $last_status, $start_time, $end_time, $duration, $avg_speed, $data_processed, $data_total, $data_read, $data_transferred, $data_dedupe, $data_compress){ 
    $pdo = conexaoPDO();
    $stmt = $pdo->prepare('INSERT INTO veeam_api (customer,state,start_time,end_time,duration,avg_speed,data_processed,data_total,data_read,data_transferred,data_dedupe,data_compress,job_name) VALUES (:customer,:state,:start_time,:end_time,:duration,:avg_speed,:data_processed,:data_total,:data_read,:data_transferred,:data_dedupe,:data_compress,:job_name);' 	
    );

    $stmt->bindParam("customer", $customer);
    $stmt->bindParam("state", $last_status);
    $stmt->bindParam("start_time", $start_time);
    $stmt->bindParam("end_time", $end_time);
    $stmt->bindParam("duration", $duration);
    $stmt->bindParam("avg_speed", $avg_speed);
    $stmt->bindParam("data_processed", $data_processed);
    $stmt->bindParam("data_total", $data_total);
    $stmt->bindParam("data_read", $data_read);
    $stmt->bindParam("data_transferred", $data_transferred);
    $stmt->bindParam("data_dedupe", $data_dedupe);
    $stmt->bindParam("data_compress", $data_compress);
    $stmt->bindParam("job_name", $job_name);

    $stmt->execute();
    
    return $pdo->lastInsertId();
}
*/
?>