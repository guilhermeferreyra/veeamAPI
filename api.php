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

function inserirEditora($nome, $site, $email, $telefone){ 
    $pdo = conexaoPDO();
    $stmt = $pdo->prepare('
        INSERT INTO Editora(
            nome,
            site,
            email, 
            telefone 
        )VALUES(
            :nome, 
            :site,
            :email, 
            :telefone 
        );' 	
    );

    $stmt->bindValue(":nome", $nome);
    $stmt->bindValue(":site", $site);
    $stmt->bindValue(":email", $email);
    $stmt->bindValue(":telefone", $telefone);
    $stmt->execute();
    
    return $pdo->lastInsertId();
}	




?>