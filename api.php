<?php
if(strcasecmp($_SERVER['REQUEST_METHOD'], 'POST') != 0){
    throw new Exception('Request method must be POST!');
}

$contentType = isset($_SERVER["CONTENT_TYPE"]) ? trim($_SERVER["CONTENT_TYPE"]) : '';
if(strcasecmp($contentType, 'application/json') != 0){
    throw new Exception('Content type must be: application/json');
}
 
$content = trim(file_get_contents("php://input"));
$decoded = json_decode($content, true);

if(!is_array($decoded)){
    throw new Exception('Received content contained invalid JSON!');
}

// Função para conexão com banco de dados.
function conexaoPDO(){	
    #Iniciando conexão com banco de dados
    $pdo = new PDO ('localhost:dbname=veeam_api','infiniit', '1nfini!T');
    $pdo->setattribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION); 
    return $pdo;
}
echo $content."\n";
var_dump($decoded);

$job_name = $decoded->JobName;
$customer = $decoded->Customer;
$state = $decoded->State;
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



conexaoPDO();
populateDb($job_name, $customer, $state, $start_time, $end_time, $duration, $avg_speed, $data_processed, $data_total, $data_read, $data_transferred, $data_dedupe, $data_compress);

function populateDb($job_name, $customer, $state, $start_time, $end_time, $duration, $avg_speed, $data_processed, $data_total, $data_read, $data_transferred, $data_dedupe, $data_compress){ 
    $pdo = conexaoPDO();
    $stmt = $pdo->prepare('
        INSERT INTO veeam_api(
            customer,
            state,
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
            job_name
        )VALUES(
            :customer,
            :state,
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
            :job_name
        );' 	
    );

    $stmt->bindValue(":customer", $customer);
    $$stmt->bindValue(":state", $state);
    $stmt->bindValue(":start_time", $start_time);
    $stmt->bindValue(":end_time", $end_time);
    $stmt->bindValue(":duration", $duration);
    $stmt->bindValue(":avg_speed", $avg_speed);
    $stmt->bindValue(":data_processed", $data_processed);
    $stmt->bindValue(":data_total", $data_total);
    $stmt->bindValue(":data_read", $data_read);
    $stmt->bindValue(":data_transferred", $data_transferred);
    $stmt->bindValue(":data_dedupe", $data_dedupe);
    $stmt->bindValue(":data_compress", $data_compress);
    $stmt->bindValue(":job_name", $job_name);

    $stmt->execute();
    
    return $pdo->lastInsertId();
}
?>