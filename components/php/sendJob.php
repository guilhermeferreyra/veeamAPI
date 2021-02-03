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
$job_type = $decoded->JobType;
$job_uid = $decoded->Uid;
$latest_run = $decoded->LatestRunLocal;
$latest_status = $decoded->LatestStatus;
$job_hash = $decoded->JobHash;
$customer = $decoded->Customer;

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
    job_name,
    customer,
    job_type,
    job_uid,
    latest_run,
    job_hash,
    latest_status)
    VALUES(
    :job_name,
    :customer,
    :job_type,
    :job_uid,
    :latest_run,
    :job_hash,
    :latest_status)";

$stmt = $pdo->prepare($sql);
$stmt->bindParam(':job_name', $job_name);
$stmt->bindParam(':customer', $customer);
$stmt->bindParam(':job_type', $job_type);
$stmt->bindParam(':job_uid', $job_uid);
$stmt->bindParam(':latest_run', $latest_run);
$stmt->bindParam(':job_hash', $job_hash);
$stmt->bindParam(':latest_status', $latest_status);

$result = $stmt->execute();
 
if (!$result)
{
    var_dump($stmt->errorInfo());
    exit;
}
 
echo $stmt->rowCount() . "linhas inseridas\n";
?>
