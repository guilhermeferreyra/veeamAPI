-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.17-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para veeam_api
CREATE DATABASE IF NOT EXISTS `veeam_api` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `veeam_api`;

-- Copiando estrutura para tabela veeam_api.backup_jobs
CREATE TABLE IF NOT EXISTS `backup_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) NOT NULL,
  `customer` varchar(50) NOT NULL,
  `job_type` varchar(50) NOT NULL,
  `job_uid` varchar(50) NOT NULL,
  `latest_run` datetime NOT NULL,
  `latest_status` varchar(30) NOT NULL,
  `job_hash` varchar(100) NOT NULL DEFAULT '"',
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_hash` (`job_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela veeam_api.backup_sessions
CREATE TABLE IF NOT EXISTS `backup_sessions` (
  `db_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer` varchar(100) DEFAULT NULL,
  `last_status` varchar(50) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `avg_speed` float unsigned DEFAULT NULL,
  `data_processed` float DEFAULT NULL,
  `data_total` float DEFAULT NULL,
  `data_read` float DEFAULT NULL,
  `data_transferred` float DEFAULT NULL,
  `data_dedupe` varchar(10) DEFAULT NULL,
  `data_compress` varchar(10) DEFAULT NULL,
  `job_name` varchar(100) DEFAULT NULL,
  `ses_id` varchar(50) NOT NULL DEFAULT '',
  `job_id` varchar(50) NOT NULL,
  PRIMARY KEY (`db_id`),
  UNIQUE KEY `ses_id` (`ses_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
