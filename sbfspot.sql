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


-- Dumping database structure for SBFspot
CREATE DATABASE IF NOT EXISTS `SBFspot` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `SBFspot`;

-- Dumping structure for table SBFspot.Config
CREATE TABLE IF NOT EXISTS `Config` (
  `Key` varchar(32) NOT NULL DEFAULT '',
  `Value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`Key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table SBFspot.Consumption
CREATE TABLE IF NOT EXISTS `Consumption` (
  `TimeStamp` int(4) NOT NULL,
  `EnergyUsed` int(4) DEFAULT NULL,
  `PowerUsed` int(4) DEFAULT NULL,
  PRIMARY KEY (`TimeStamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table SBFspot.DayData
CREATE TABLE IF NOT EXISTS `DayData` (
  `TimeStamp` int(4) NOT NULL,
  `Serial` int(4) NOT NULL,
  `TotalYield` int(8) DEFAULT NULL,
  `Power` int(8) DEFAULT NULL,
  `PVoutput` int(1) DEFAULT NULL,
  `VZ` int(1) DEFAULT NULL,
  PRIMARY KEY (`TimeStamp`,`Serial`),
  KEY `FK_INVERTER` (`Serial`),
  KEY `PVoutput` (`PVoutput`,`VZ`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table SBFspot.EventData
CREATE TABLE IF NOT EXISTS `EventData` (
  `EntryID` int(4) NOT NULL DEFAULT '0',
  `TimeStamp` int(4) NOT NULL,
  `Serial` int(4) NOT NULL,
  `SusyID` int(2) DEFAULT NULL,
  `EventCode` int(4) DEFAULT NULL,
  `EventType` varchar(32) DEFAULT NULL,
  `Category` varchar(32) DEFAULT NULL,
  `EventGroup` varchar(32) DEFAULT NULL,
  `Tag` varchar(200) DEFAULT NULL,
  `OldValue` varchar(32) DEFAULT NULL,
  `NewValue` varchar(32) DEFAULT NULL,
  `UserGroup` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`Serial`,`EntryID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table SBFspot.Inverters
CREATE TABLE IF NOT EXISTS `Inverters` (
  `Serial` int(4) NOT NULL,
  `Name` varchar(32) DEFAULT NULL,
  `Type` varchar(32) DEFAULT NULL,
  `SW_Version` varchar(32) DEFAULT NULL,
  `TimeStamp` int(4) DEFAULT NULL,
  `TotalPac` int(4) DEFAULT NULL,
  `EToday` int(8) DEFAULT NULL,
  `ETotal` int(8) DEFAULT NULL,
  `OperatingTime` double DEFAULT NULL,
  `FeedInTime` double DEFAULT NULL,
  `Status` varchar(10) DEFAULT NULL,
  `GridRelay` varchar(10) DEFAULT NULL,
  `Temperature` float DEFAULT NULL,
  PRIMARY KEY (`Serial`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table SBFspot.MonthData
CREATE TABLE IF NOT EXISTS `MonthData` (
  `TimeStamp` int(4) NOT NULL,
  `Serial` int(4) NOT NULL,
  `TotalYield` int(8) DEFAULT NULL,
  `DayYield` int(8) DEFAULT NULL,
  PRIMARY KEY (`TimeStamp`,`Serial`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table SBFspot.SpotData
CREATE TABLE IF NOT EXISTS `SpotData` (
  `TimeStamp` int(4) NOT NULL,
  `Serial` int(4) NOT NULL,
  `Pdc1` int(4) DEFAULT NULL,
  `Pdc2` int(4) DEFAULT NULL,
  `Idc1` float DEFAULT NULL,
  `Idc2` float DEFAULT NULL,
  `Udc1` float DEFAULT NULL,
  `Udc2` float DEFAULT NULL,
  `Pac1` int(4) DEFAULT NULL,
  `Pac2` int(4) DEFAULT NULL,
  `Pac3` int(4) DEFAULT NULL,
  `Iac1` float DEFAULT NULL,
  `Iac2` float DEFAULT NULL,
  `Iac3` float DEFAULT NULL,
  `Uac1` float DEFAULT NULL,
  `Uac2` float DEFAULT NULL,
  `Uac3` float DEFAULT NULL,
  `EToday` int(8) DEFAULT NULL,
  `ETotal` int(8) DEFAULT NULL,
  `Frequency` float DEFAULT NULL,
  `OperatingTime` double DEFAULT NULL,
  `FeedInTime` double DEFAULT NULL,
  `BT_Signal` float DEFAULT NULL,
  `Status` varchar(10) DEFAULT NULL,
  `GridRelay` varchar(10) DEFAULT NULL,
  `Temperature` float DEFAULT NULL,
  PRIMARY KEY (`TimeStamp`,`Serial`),
  KEY `FK_SERIAL_SD` (`Serial`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for view SBFspot.vwAvgConsumption
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwAvgConsumption` (
	`Nearest5min` DATETIME NULL,
	`EnergyUsed` DECIMAL(9,0) NULL,
	`PowerUsed` DECIMAL(9,0) NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwAvgSpotData
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwAvgSpotData` (
	`nearest5min` DATETIME NULL,
	`serial` INT(4) NOT NULL,
	`Pdc1` DECIMAL(9,0) NULL,
	`Pdc2` DECIMAL(9,0) NULL,
	`Idc1` DECIMAL(9,3) NULL,
	`Idc2` DECIMAL(9,3) NULL,
	`Udc1` DECIMAL(9,2) NULL,
	`Udc2` DECIMAL(9,2) NULL,
	`Pac1` DECIMAL(9,0) NULL,
	`Pac2` DECIMAL(9,0) NULL,
	`Pac3` DECIMAL(9,0) NULL,
	`Iac1` DECIMAL(9,3) NULL,
	`Iac2` DECIMAL(9,3) NULL,
	`Iac3` DECIMAL(9,3) NULL,
	`Uac1` DECIMAL(9,2) NULL,
	`Uac2` DECIMAL(9,2) NULL,
	`Uac3` DECIMAL(9,2) NULL,
	`Temperature` DECIMAL(9,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwConsumption
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwConsumption` (
	`Timestamp` DATETIME NULL,
	`Nearest5min` DATETIME NULL,
	`EnergyUsed` INT(4) NULL,
	`PowerUsed` INT(4) NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwDayData
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwDayData` (
	`TimeStamp` DATETIME NULL,
	`Name` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Type` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Serial` INT(4) NOT NULL,
	`TotalYield` INT(8) NULL,
	`Power` INT(8) NULL,
	`PVOutput` INT(1) NULL,
	`VZ` INT(1) NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwEventData
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwEventData` (
	`TimeStamp` DATETIME NULL,
	`Name` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Type` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Serial` INT(4) NOT NULL,
	`SusyID` INT(2) NULL,
	`EntryID` INT(4) NOT NULL,
	`EventCode` INT(4) NULL,
	`EventType` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Category` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`EventGroup` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Tag` VARCHAR(200) NULL COLLATE 'latin1_swedish_ci',
	`OldValue` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`NewValue` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`UserGroup` VARCHAR(10) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwInverters
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwInverters` (
	`Serial` INT(4) NOT NULL,
	`Name` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Type` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`SW_Version` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`TimeStamp` DATETIME NULL,
	`TotalPac` INT(4) NULL,
	`EToday` INT(8) NULL,
	`ETotal` INT(8) NULL,
	`OperatingTime` DOUBLE NULL,
	`FeedInTime` DOUBLE NULL,
	`Status` VARCHAR(10) NULL COLLATE 'latin1_swedish_ci',
	`GridRelay` VARCHAR(10) NULL COLLATE 'latin1_swedish_ci',
	`Temperature` FLOAT NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwMonthData
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwMonthData` (
	`TimeStamp` DATETIME NULL,
	`Name` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Type` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Serial` INT(4) NOT NULL,
	`TotalYield` INT(8) NULL,
	`DayYield` INT(8) NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwPvoData
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwPvoData` (
	`Timestamp` DATETIME NULL,
	`Name` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Type` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Serial` INT(4) NOT NULL,
	`V1` INT(8) NULL,
	`V2` INT(8) NULL,
	`V3` DECIMAL(9,0) NULL,
	`V4` DECIMAL(9,0) NULL,
	`V5` BINARY(0) NULL,
	`V6` DECIMAL(9,2) NULL,
	`V7` BINARY(0) NULL,
	`V8` BINARY(0) NULL,
	`V9` BINARY(0) NULL,
	`V10` BINARY(0) NULL,
	`V11` BINARY(0) NULL,
	`V12` BINARY(0) NULL,
	`PVoutput` INT(1) NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwSpotData
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vwSpotData` (
	`TimeStamp` DATETIME NULL,
	`Nearest5min` DATETIME NULL,
	`Name` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Type` VARCHAR(32) NULL COLLATE 'latin1_swedish_ci',
	`Serial` INT(4) NOT NULL,
	`Pdc1` INT(4) NULL,
	`Pdc2` INT(4) NULL,
	`Idc1` FLOAT NULL,
	`Idc2` FLOAT NULL,
	`Udc1` FLOAT NULL,
	`Udc2` FLOAT NULL,
	`Pac1` INT(4) NULL,
	`Pac2` INT(4) NULL,
	`Pac3` INT(4) NULL,
	`Iac1` FLOAT NULL,
	`Iac2` FLOAT NULL,
	`Iac3` FLOAT NULL,
	`Uac1` FLOAT NULL,
	`Uac2` FLOAT NULL,
	`Uac3` FLOAT NULL,
	`PdcTot` BIGINT(12) NULL,
	`PacTot` BIGINT(13) NULL,
	`Efficiency` DECIMAL(17,1) NULL,
	`EToday` INT(8) NULL,
	`ETotal` INT(8) NULL,
	`Frequency` FLOAT NULL,
	`OperatingTime` DOUBLE NULL,
	`FeedInTime` DOUBLE NULL,
	`BT_Signal` DOUBLE(18,1) NULL,
	`Status` VARCHAR(10) NULL COLLATE 'latin1_swedish_ci',
	`GridRelay` VARCHAR(10) NULL COLLATE 'latin1_swedish_ci',
	`Temperature` DOUBLE(18,1) NULL
) ENGINE=MyISAM;

-- Dumping structure for view SBFspot.vwAvgConsumption
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwAvgConsumption`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwAvgConsumption` AS select `vwConsumption`.`Nearest5min` AS `Nearest5min`,cast(avg(`vwConsumption`.`EnergyUsed`) as decimal(9,0)) AS `EnergyUsed`,cast(avg(`vwConsumption`.`PowerUsed`) as decimal(9,0)) AS `PowerUsed` from `SBFspot`.`vwConsumption` group by `vwConsumption`.`Nearest5min`;

-- Dumping structure for view SBFspot.vwAvgSpotData
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwAvgSpotData`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwAvgSpotData` AS select `vwSpotData`.`Nearest5min` AS `nearest5min`,`vwSpotData`.`Serial` AS `serial`,cast(avg(`vwSpotData`.`Pdc1`) as decimal(9,0)) AS `Pdc1`,cast(avg(`vwSpotData`.`Pdc2`) as decimal(9,0)) AS `Pdc2`,cast(avg(`vwSpotData`.`Idc1`) as decimal(9,3)) AS `Idc1`,cast(avg(`vwSpotData`.`Idc2`) as decimal(9,3)) AS `Idc2`,cast(avg(`vwSpotData`.`Udc1`) as decimal(9,2)) AS `Udc1`,cast(avg(`vwSpotData`.`Udc2`) as decimal(9,2)) AS `Udc2`,cast(avg(`vwSpotData`.`Pac1`) as decimal(9,0)) AS `Pac1`,cast(avg(`vwSpotData`.`Pac2`) as decimal(9,0)) AS `Pac2`,cast(avg(`vwSpotData`.`Pac3`) as decimal(9,0)) AS `Pac3`,cast(avg(`vwSpotData`.`Iac1`) as decimal(9,3)) AS `Iac1`,cast(avg(`vwSpotData`.`Iac2`) as decimal(9,3)) AS `Iac2`,cast(avg(`vwSpotData`.`Iac3`) as decimal(9,3)) AS `Iac3`,cast(avg(`vwSpotData`.`Uac1`) as decimal(9,2)) AS `Uac1`,cast(avg(`vwSpotData`.`Uac2`) as decimal(9,2)) AS `Uac2`,cast(avg(`vwSpotData`.`Uac3`) as decimal(9,2)) AS `Uac3`,cast(avg(`vwSpotData`.`Temperature`) as decimal(9,2)) AS `Temperature` from `SBFspot`.`vwSpotData` group by `vwSpotData`.`Serial`,`vwSpotData`.`Nearest5min`;

-- Dumping structure for view SBFspot.vwConsumption
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwConsumption`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwConsumption` AS select from_unixtime(`SBFspot`.`Consumption`.`TimeStamp`) AS `Timestamp`,from_unixtime((case when ((`SBFspot`.`Consumption`.`TimeStamp` % 300) < 150) then (`SBFspot`.`Consumption`.`TimeStamp` - (`SBFspot`.`Consumption`.`TimeStamp` % 300)) else ((`SBFspot`.`Consumption`.`TimeStamp` - (`SBFspot`.`Consumption`.`TimeStamp` % 300)) + 300) end)) AS `Nearest5min`,`SBFspot`.`Consumption`.`EnergyUsed` AS `EnergyUsed`,`SBFspot`.`Consumption`.`PowerUsed` AS `PowerUsed` from `SBFspot`.`Consumption`;

-- Dumping structure for view SBFspot.vwDayData
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwDayData`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwDayData` AS select from_unixtime(`Dat`.`TimeStamp`) AS `TimeStamp`,`Inv`.`Name` AS `Name`,`Inv`.`Type` AS `Type`,`Dat`.`Serial` AS `Serial`,`Dat`.`TotalYield` AS `TotalYield`,`Dat`.`Power` AS `Power`,`Dat`.`PVoutput` AS `PVOutput`,`Dat`.`VZ` AS `VZ` from (`SBFspot`.`DayData` `Dat` join `SBFspot`.`Inverters` `Inv` on((`Dat`.`Serial` = `Inv`.`Serial`))) order by `Dat`.`TimeStamp` desc;

-- Dumping structure for view SBFspot.vwEventData
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwEventData`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwEventData` AS select from_unixtime(`Dat`.`TimeStamp`) AS `TimeStamp`,`Inv`.`Name` AS `Name`,`Inv`.`Type` AS `Type`,`Dat`.`Serial` AS `Serial`,`Dat`.`SusyID` AS `SusyID`,`Dat`.`EntryID` AS `EntryID`,`Dat`.`EventCode` AS `EventCode`,`Dat`.`EventType` AS `EventType`,`Dat`.`Category` AS `Category`,`Dat`.`EventGroup` AS `EventGroup`,`Dat`.`Tag` AS `Tag`,`Dat`.`OldValue` AS `OldValue`,`Dat`.`NewValue` AS `NewValue`,`Dat`.`UserGroup` AS `UserGroup` from (`SBFspot`.`EventData` `Dat` join `SBFspot`.`Inverters` `Inv` on((`Dat`.`Serial` = `Inv`.`Serial`))) order by `Dat`.`EntryID` desc;

-- Dumping structure for view SBFspot.vwInverters
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwInverters`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwInverters` AS select `SBFspot`.`Inverters`.`Serial` AS `Serial`,`SBFspot`.`Inverters`.`Name` AS `Name`,`SBFspot`.`Inverters`.`Type` AS `Type`,`SBFspot`.`Inverters`.`SW_Version` AS `SW_Version`,from_unixtime(`SBFspot`.`Inverters`.`TimeStamp`) AS `TimeStamp`,`SBFspot`.`Inverters`.`TotalPac` AS `TotalPac`,`SBFspot`.`Inverters`.`EToday` AS `EToday`,`SBFspot`.`Inverters`.`ETotal` AS `ETotal`,`SBFspot`.`Inverters`.`OperatingTime` AS `OperatingTime`,`SBFspot`.`Inverters`.`FeedInTime` AS `FeedInTime`,`SBFspot`.`Inverters`.`Status` AS `Status`,`SBFspot`.`Inverters`.`GridRelay` AS `GridRelay`,`SBFspot`.`Inverters`.`Temperature` AS `Temperature` from `SBFspot`.`Inverters`;

-- Dumping structure for view SBFspot.vwMonthData
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwMonthData`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwMonthData` AS select convert_tz(from_unixtime(`Dat`.`TimeStamp`),'SYSTEM','+00:00') AS `TimeStamp`,`Inv`.`Name` AS `Name`,`Inv`.`Type` AS `Type`,`Dat`.`Serial` AS `Serial`,`Dat`.`TotalYield` AS `TotalYield`,`Dat`.`DayYield` AS `DayYield` from (`SBFspot`.`MonthData` `Dat` join `SBFspot`.`Inverters` `Inv` on((`Dat`.`Serial` = `Inv`.`Serial`))) order by `Dat`.`TimeStamp` desc;

-- Dumping structure for view SBFspot.vwPvoData
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwPvoData`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwPvoData` AS select `dd`.`TimeStamp` AS `Timestamp`,`dd`.`Name` AS `Name`,`dd`.`Type` AS `Type`,`dd`.`Serial` AS `Serial`,`dd`.`TotalYield` AS `V1`,`dd`.`Power` AS `V2`,`cons`.`EnergyUsed` AS `V3`,`cons`.`PowerUsed` AS `V4`,NULL AS `V5`,`spot`.`Uac1` AS `V6`,NULL AS `V7`,NULL AS `V8`,NULL AS `V9`,NULL AS `V10`,NULL AS `V11`,NULL AS `V12`,`dd`.`PVOutput` AS `PVoutput` from ((`SBFspot`.`vwDayData` `dd` left join `SBFspot`.`vwAvgSpotData` `spot` on(((`dd`.`Serial` = `spot`.`serial`) and (`dd`.`TimeStamp` = `spot`.`nearest5min`)))) left join `SBFspot`.`vwAvgConsumption` `cons` on((`dd`.`TimeStamp` = `cons`.`Nearest5min`))) order by `dd`.`TimeStamp` desc;

-- Dumping structure for view SBFspot.vwSpotData
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vwSpotData`;
CREATE ALGORITHM=UNDEFINED DEFINER=`sbfspot`@`localhost` SQL SECURITY DEFINER VIEW `SBFspot`.`vwSpotData` AS select from_unixtime(`Dat`.`TimeStamp`) AS `TimeStamp`,from_unixtime((case when ((`Dat`.`TimeStamp` % 300) < 150) then (`Dat`.`TimeStamp` - (`Dat`.`TimeStamp` % 300)) else ((`Dat`.`TimeStamp` - (`Dat`.`TimeStamp` % 300)) + 300) end)) AS `Nearest5min`,`Inv`.`Name` AS `Name`,`Inv`.`Type` AS `Type`,`Dat`.`Serial` AS `Serial`,`Dat`.`Pdc1` AS `Pdc1`,`Dat`.`Pdc2` AS `Pdc2`,`Dat`.`Idc1` AS `Idc1`,`Dat`.`Idc2` AS `Idc2`,`Dat`.`Udc1` AS `Udc1`,`Dat`.`Udc2` AS `Udc2`,`Dat`.`Pac1` AS `Pac1`,`Dat`.`Pac2` AS `Pac2`,`Dat`.`Pac3` AS `Pac3`,`Dat`.`Iac1` AS `Iac1`,`Dat`.`Iac2` AS `Iac2`,`Dat`.`Iac3` AS `Iac3`,`Dat`.`Uac1` AS `Uac1`,`Dat`.`Uac2` AS `Uac2`,`Dat`.`Uac3` AS `Uac3`,(`Dat`.`Pdc1` + `Dat`.`Pdc2`) AS `PdcTot`,((`Dat`.`Pac1` + `Dat`.`Pac2`) + `Dat`.`Pac3`) AS `PacTot`,(case when ((`Dat`.`Pdc1` + `Dat`.`Pdc2`) = 0) then 0 else (case when ((`Dat`.`Pdc1` + `Dat`.`Pdc2`) > ((`Dat`.`Pac1` + `Dat`.`Pac2`) + `Dat`.`Pac3`)) then round(((((`Dat`.`Pac1` + `Dat`.`Pac2`) + `Dat`.`Pac3`) / (`Dat`.`Pdc1` + `Dat`.`Pdc2`)) * 100),1) else 100.0 end) end) AS `Efficiency`,`Dat`.`EToday` AS `EToday`,`Dat`.`ETotal` AS `ETotal`,`Dat`.`Frequency` AS `Frequency`,`Dat`.`OperatingTime` AS `OperatingTime`,`Dat`.`FeedInTime` AS `FeedInTime`,round(`Dat`.`BT_Signal`,1) AS `BT_Signal`,`Dat`.`Status` AS `Status`,`Dat`.`GridRelay` AS `GridRelay`,round(`Dat`.`Temperature`,1) AS `Temperature` from (`SBFspot`.`SpotData` `Dat` join `SBFspot`.`Inverters` `Inv` on((`Dat`.`Serial` = `Inv`.`Serial`)));

-- Dumping data for table SBFspot.Inverters: ~3 rows (approximately)
/*!40000 ALTER TABLE `Inverters` DISABLE KEYS */;
INSERT INTO `Inverters` (`Serial`, `Name`, `Type`, `SW_Version`, `TimeStamp`, `TotalPac`, `EToday`, `ETotal`, `OperatingTime`, `FeedInTime`, `Status`, `GridRelay`, `Temperature`) VALUES
	(11094, 'Consumption', 'Consumption Device', NULL, 1534886722, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(2001626495, 'SN: 2001626495', 'SB 2100TL', '12.12.205.R', 1534875616, 7, 6, 17690, 33549.7, 33244.6, 'OK', '?', 0),
	(2100302423, 'SN: 2100302423', 'SB 4000TL-20', '03.01.05.R', 1534878069, 0, 12, 38020, 32526.2, 31208.6, 'OK', 'N/A', 0);
/*!40000 ALTER TABLE `Inverters` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
