-- --------------------------------------------------------
-- Host:                         ***REMOVED***.de
-- Server version:               10.0.31-MariaDB-0ubuntu0.16.04.2 - Ubuntu 16.04
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             9.5.0.5196
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for volkszaehler
CREATE DATABASE IF NOT EXISTS `volkszaehler` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `volkszaehler`;

-- Dumping structure for table volkszaehler.aggregate
CREATE TABLE IF NOT EXISTS `aggregate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `timestamp` bigint(20) NOT NULL,
  `value` double NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ts_uniq` (`channel_id`,`type`,`timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=1711788 DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table volkszaehler.data
CREATE TABLE IF NOT EXISTS `data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel_id` int(11) DEFAULT NULL,
  `timestamp` bigint(20) NOT NULL,
  `value` double NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_unique` (`channel_id`,`timestamp`),
  KEY `IDX_ADF3F36372F5A1AA` (`channel_id`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `FK_ADF3F36372F5A1AA` FOREIGN KEY (`channel_id`) REFERENCES `entities` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1618685 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Dumping structure for table volkszaehler.entities
CREATE TABLE IF NOT EXISTS `entities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) COLLATE utf8_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `class` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_50EC64E5D17F50A6` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Dumping structure for table volkszaehler.entities_in_aggregator
CREATE TABLE IF NOT EXISTS `entities_in_aggregator` (
  `parent_id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  PRIMARY KEY (`parent_id`,`child_id`),
  KEY `IDX_2BD88468727ACA70` (`parent_id`),
  KEY `IDX_2BD88468DD62C21B` (`child_id`),
  CONSTRAINT `FK_2BD88468727ACA70` FOREIGN KEY (`parent_id`) REFERENCES `entities` (`id`),
  CONSTRAINT `FK_2BD88468DD62C21B` FOREIGN KEY (`child_id`) REFERENCES `entities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Dumping structure for table volkszaehler.properties
CREATE TABLE IF NOT EXISTS `properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) DEFAULT NULL,
  `pkey` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `value` longtext COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `property_unique` (`entity_id`,`pkey`),
  KEY `IDX_87C331C781257D5D` (`entity_id`),
  CONSTRAINT `FK_87C331C781257D5D` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.
-- Dumping structure for view volkszaehler.vwData
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwData` (
	`id` INT(11) NOT NULL,
	`channel_id` INT(11) NULL,
	`timestamp` DATETIME(4) NULL,
	`value` DOUBLE NOT NULL
) ENGINE=MyISAM;

-- Dumping structure for view volkszaehler.vwData
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwData`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`%` SQL SECURITY DEFINER VIEW `vwData` AS select `Dat`.`id` AS `id`,`Dat`.`channel_id` AS `channel_id`,from_unixtime((`Dat`.`timestamp` / 1000)) AS `timestamp`,`Dat`.`value` AS `value` from `data` `Dat`;

-- Dumping data for table volkszaehler.entities: ~12 rows (approximately)
/*!40000 ALTER TABLE `entities` DISABLE KEYS */;
INSERT INTO `entities` (`id`, `uuid`, `type`, `class`) VALUES
	(1, '93aaa5d0-c20b-11e5-9dae-01f028965b22', 'powersensor', 'channel'),
	(2, '9b65c360-c463-11e5-b344-614a759a4ea3', 'powersensor', 'channel'),
	(3, '986a6730-c54f-11e5-b0ec-cdcbe5be9c13', 'electric meter', 'channel'),
	(4, 'c02d7500-c54f-11e5-8bb2-11946a89326c', 'electric meter', 'channel'),
	(5, 'ea22f190-c6cc-11e5-83cd-31338465454f', 'powersensor', 'channel'),
	(6, 'f9dc92d0-c6cc-11e5-90d8-fd3a9bc5eba5', 'powersensor', 'channel'),
	(7, 'b43a9ba0-d0fd-11e5-979d-2d1e16fdd9db', 'powersensor', 'channel'),
	(8, 'fad24550-d0fd-11e5-ae11-1332c4ef6f47', 'electric meter', 'channel'),
	(9, 'edb38ba0-6e99-11e6-a547-697441a361c2', 'powersensor', 'channel'),
	(10, 'caca38d0-7293-11e6-8611-bfa24bd6335e', 'powersensor', 'channel');
/*!40000 ALTER TABLE `entities` ENABLE KEYS */;

-- Dumping data for table volkszaehler.entities_in_aggregator: ~0 rows (approximately)
/*!40000 ALTER TABLE `entities_in_aggregator` DISABLE KEYS */;
/*!40000 ALTER TABLE `entities_in_aggregator` ENABLE KEYS */;

-- Dumping data for table volkszaehler.properties: ~67 rows (approximately)
/*!40000 ALTER TABLE `properties` DISABLE KEYS */;
INSERT INTO `properties` (`id`, `entity_id`, `pkey`, `value`) VALUES
	(1, 3, 'title', 'Einspeisung (Zählerstand)'),
	(2, 3, 'resolution', '1'),
	(3, 3, 'public', '1'),
	(4, 3, 'color', 'aqua'),
	(5, 3, 'style', 'lines'),
	(6, 3, 'fillstyle', '0.45'),
	(7, 3, 'yaxis', 'auto'),
	(8, 4, 'title', 'Bezug (Zählerstand)'),
	(9, 4, 'resolution', '1'),
	(10, 4, 'public', '1'),
	(11, 4, 'color', '#cc0033'),
	(12, 4, 'style', 'lines'),
	(13, 4, 'fillstyle', '0.5'),
	(14, 4, 'yaxis', 'auto'),
	(15, 3, 'active', '1'),
	(16, 4, 'active', '1'),
	(17, 5, 'title', 'Einspeisung'),
	(18, 5, 'public', '1'),
	(19, 5, 'color', '#3399ff'),
	(20, 5, 'style', 'lines'),
	(21, 5, 'fillstyle', '0'),
	(22, 5, 'yaxis', 'auto'),
	(23, 6, 'title', 'Bezug'),
	(24, 6, 'public', '1'),
	(25, 6, 'color', '#ff3366'),
	(26, 6, 'style', 'lines'),
	(27, 6, 'fillstyle', '0.45'),
	(28, 6, 'yaxis', 'auto'),
	(29, 5, 'active', '1'),
	(30, 6, 'active', '1'),
	(31, 6, 'resolution', '0.001'),
	(32, 5, 'resolution', '0.001'),
	(33, 4, 'cost', '0.2528'),
	(34, 7, 'title', 'PV'),
	(35, 7, 'color', '#ffcc00'),
	(36, 7, 'style', 'lines'),
	(37, 7, 'fillstyle', '0.3'),
	(38, 7, 'yaxis', 'auto'),
	(39, 7, 'public', '1'),
	(40, 7, 'active', '1'),
	(41, 8, 'title', 'PV (Zählerstand)'),
	(42, 8, 'resolution', '1000'),
	(43, 8, 'public', '1'),
	(44, 8, 'color', '#ffff33'),
	(45, 8, 'style', 'lines'),
	(46, 8, 'fillstyle', '0.45'),
	(47, 8, 'yaxis', 'auto'),
	(49, 8, 'active', '1'),
	(50, 3, 'cost', '0.3405'),
	(51, 9, 'title', 'Verbrauch (Zählerstand)'),
	(52, 9, 'public', '1'),
	(53, 9, 'color', '#ff00cc'),
	(54, 9, 'style', 'lines'),
	(55, 9, 'fillstyle', '0'),
	(56, 9, 'yaxis', 'auto'),
	(57, 10, 'title', 'Verbrauch'),
	(58, 10, 'public', '1'),
	(59, 10, 'color', '#9966cc'),
	(60, 10, 'style', 'lines'),
	(61, 10, 'fillstyle', '0'),
	(62, 10, 'yaxis', 'auto'),
	(63, 10, 'active', '1'),
	(64, 10, 'cost', '0.2528'),
	(65, 8, 'cost', '0.3405');
/*!40000 ALTER TABLE `properties` ENABLE KEYS */;


/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
