DROP DATABASE IF EXISTS `explore`;
CREATE DATABASE `explore` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON explore.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
USE `explore`;

CREATE TABLE IF NOT EXISTS `account` (
`address` VARCHAR(42)  NOT NULL   COMMENT '',
`amount` VARCHAR(1000)    COMMENT '',
PRIMARY KEY (`address`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `transaction` (
`tx_index` BIGINT UNSIGNED  NOT NULL   COMMENT '',
`tx_id` VARCHAR(64)  NOT NULL   COMMENT '',
`sender` VARCHAR(42)   COMMENT '',
`function` VARCHAR(50)  NOT NULL   COMMENT '',
`args` VARCHAR(500)  NOT NULL   COMMENT '',
`status` INT  NOT NULL   COMMENT '',
`datetime` TIMESTAMP  NOT NULL   COMMENT '',
PRIMARY KEY (`tx_index`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `issue_token` (
`symbol` VARCHAR(10)  NOT NULL   COMMENT '',
`total_supply` VARCHAR(100)  NOT NULL   COMMENT '',
`decimals` INT  NOT NULL   COMMENT '',
`publish_address` VARCHAR(42)  NOT NULL   COMMENT '',
`msg` VARCHAR(1000)   COMMENT '',
`datetime` TIMESTAMP  NOT NULL   COMMENT '',
PRIMARY KEY (`symbol`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `transfer` (
`tx_index` BIGINT UNSIGNED  NOT NULL   COMMENT '',
`tx_id` VARCHAR(64)  NOT NULL   COMMENT '',
`from_address` VARCHAR(42)  NOT NULL   COMMENT '',
`to_address` VARCHAR(42)  NOT NULL   COMMENT '',
`token_name` VARCHAR(10)  NOT NULL   COMMENT '',
`amounts` VARCHAR(100)  NOT NULL   COMMENT '',
`status` INT  NOT NULL   COMMENT '',
`datetime` TIMESTAMP  NOT NULL   COMMENT '',
PRIMARY KEY (`tx_index`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `token` (
`address` VARCHAR(42)  NOT NULL   COMMENT '',
`coin_type` VARCHAR(20)  NOT NULL   COMMENT '',
`balance` VARCHAR(100)  NOT NULL   COMMENT '',
PRIMARY KEY (`address`,`coin_type`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `peer` (
`name` VARCHAR(50)  NOT NULL   COMMENT '',
`request` VARCHAR(50)  NOT NULL   COMMENT '',
`hostname` VARCHAR(50)  NOT NULL   COMMENT '',
`organization` VARCHAR(50)  NOT NULL   COMMENT '',
PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `block` (
`number` BIGINT UNSIGNED NOT NULL   COMMENT '',
`block_hash` VARCHAR(64)  NOT NULL   COMMENT '',
`tx_count` INT  NOT NULL   COMMENT '',
`block_size` INT  NOT NULL   COMMENT '',
`datetime` TIMESTAMP  NOT NULL   COMMENT '',
PRIMARY KEY (`number`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;