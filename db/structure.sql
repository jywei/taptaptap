-- MySQL dump 10.13  Distrib 5.5.29, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: taps_dev
-- ------------------------------------------------------
-- Server version	5.5.29-0ubuntu0.12.10.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `current_volume`
--

DROP TABLE IF EXISTS `current_volume`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `current_volume` (
  `volume` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geo_batches`
--

DROP TABLE IF EXISTS `geo_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `geo_batches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `min_id` int(11) DEFAULT NULL,
  `max_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `full_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `short_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `metro` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `region` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `county` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locality` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zipcode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bounds_max_lat` float DEFAULT NULL,
  `bounds_max_long` float DEFAULT NULL,
  `bounds_min_lat` float DEFAULT NULL,
  `bounds_min_long` float DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locations_on_parent_id` (`parent_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `posting_examples`
--

DROP TABLE IF EXISTS `posting_examples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posting_examples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `posting` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `posting_monitors`
--

DROP TABLE IF EXISTS `posting_monitors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posting_monitors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time_mark` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `hmngs` int(11) DEFAULT NULL,
  `remls` int(11) DEFAULT NULL,
  `ebaym` int(11) DEFAULT NULL,
  `craig` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `posting_validation_infos`
--

DROP TABLE IF EXISTS `posting_validation_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posting_validation_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `posting_id` int(11) DEFAULT NULL,
  `source` tinyint(1) DEFAULT '1',
  `category` tinyint(1) DEFAULT '1',
  `external_id` tinyint(1) DEFAULT '1',
  `external_url` tinyint(1) DEFAULT '1',
  `heading` tinyint(1) DEFAULT '1',
  `body` tinyint(1) DEFAULT '1',
  `html` tinyint(1) DEFAULT '1',
  `expires` tinyint(1) DEFAULT '1',
  `language` tinyint(1) DEFAULT '1',
  `price` tinyint(1) DEFAULT '1',
  `currency` tinyint(1) DEFAULT '1',
  `images` tinyint(1) DEFAULT '1',
  `annotations` tinyint(1) DEFAULT '1',
  `status` tinyint(1) DEFAULT '1',
  `flagged` tinyint(1) DEFAULT '1',
  `deleted` tinyint(1) DEFAULT '1',
  `immortal` tinyint(1) DEFAULT '1',
  `timestamp` tinyint(1) DEFAULT '1',
  `category_group` tinyint(1) DEFAULT '1',
  `country` tinyint(1) DEFAULT '1',
  `state` tinyint(1) DEFAULT '1',
  `metro` tinyint(1) DEFAULT '1',
  `region` tinyint(1) DEFAULT '1',
  `county` tinyint(1) DEFAULT '1',
  `city` tinyint(1) DEFAULT '1',
  `locality` tinyint(1) DEFAULT '1',
  `zipcode` tinyint(1) DEFAULT '1',
  `lat` tinyint(1) DEFAULT '1',
  `long` tinyint(1) DEFAULT '1',
  `accuracy` tinyint(1) DEFAULT '1',
  `min_lat` tinyint(1) DEFAULT '1',
  `max_lat` tinyint(1) DEFAULT '1',
  `min_long` tinyint(1) DEFAULT '1',
  `max_long` tinyint(1) DEFAULT '1',
  `account_id` tinyint(1) DEFAULT '1',
  `posting_state` tinyint(1) DEFAULT '1',
  `flagged_status` tinyint(1) DEFAULT '1',
  `origin_ip_address` tinyint(1) DEFAULT '1',
  `transit_ip_address` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `postings`
--

DROP TABLE IF EXISTS `postings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `postings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `external_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `external_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `heading` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `html` text COLLATE utf8_unicode_ci,
  `expires` int(11) DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` float DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `images` text COLLATE utf8_unicode_ci,
  `annotations` text COLLATE utf8_unicode_ci,
  `status` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `flagged` tinyint(1) DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `immortal` tinyint(1) DEFAULT NULL,
  `timestamp` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `category_group` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `metro` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `region` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `county` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locality` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zipcode` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lat` decimal(9,6) DEFAULT NULL,
  `long` decimal(9,6) DEFAULT NULL,
  `accuracy` int(11) DEFAULT NULL,
  `min_lat` float DEFAULT NULL,
  `max_lat` float DEFAULT NULL,
  `min_long` float DEFAULT NULL,
  `max_long` float DEFAULT NULL,
  `account_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `posting_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `flagged_status` int(11) DEFAULT NULL,
  `origin_ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transit_ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_postings_on_source` (`source`),
  KEY `index_postings_on_category_group` (`category_group`),
  KEY `index_postings_on_category` (`category`),
  KEY `index_postings_on_country` (`country`),
  KEY `index_postings_on_state` (`state`),
  KEY `index_postings_on_metro` (`metro`),
  KEY `index_postings_on_region` (`region`),
  KEY `index_postings_on_county` (`county`),
  KEY `index_postings_on_city` (`city`),
  KEY `index_postings_on_locality` (`locality`),
  KEY `index_postings_on_zipcode` (`zipcode`),
  KEY `index_postings_on_status` (`status`),
  KEY `index_postings_on_external_id_and_source` (`external_id`,`source`),
  KEY `index_postings_on_timestamp` (`timestamp`),
  KEY `index_postings_on_id_and_source_and_category_and_city` (`id`,`source`,`category`,`city`),
  KEY `index_postings_on_posting_state` (`posting_state`)
) ENGINE=MyISAM AUTO_INCREMENT=14637 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `postings_old`
--

DROP TABLE IF EXISTS `postings_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `postings_old` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `external_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `external_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `heading` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `html` text COLLATE utf8_unicode_ci,
  `expires` int(11) DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` float DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `images` text COLLATE utf8_unicode_ci,
  `annotations` text COLLATE utf8_unicode_ci,
  `status` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `flagged` tinyint(1) DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `immortal` tinyint(1) DEFAULT NULL,
  `timestamp` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `category_group` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `metro` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `region` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `county` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locality` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zipcode` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `long` float DEFAULT NULL,
  `accuracy` int(11) DEFAULT NULL,
  `min_lat` float DEFAULT NULL,
  `max_lat` float DEFAULT NULL,
  `min_long` float DEFAULT NULL,
  `max_long` float DEFAULT NULL,
  `account_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `posting_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_postings_old_on_id` (`id`),
  KEY `index_postings_old_on_source` (`source`),
  KEY `index_postings_old_on_category_group` (`category_group`),
  KEY `index_postings_old_on_category` (`category`),
  KEY `index_postings_old_on_country` (`country`),
  KEY `index_postings_old_on_state` (`state`),
  KEY `index_postings_old_on_metro` (`metro`),
  KEY `index_postings_old_on_region` (`region`),
  KEY `index_postings_old_on_county` (`county`),
  KEY `index_postings_old_on_city` (`city`),
  KEY `index_postings_old_on_locality` (`locality`),
  KEY `index_postings_old_on_zipcode` (`zipcode`),
  KEY `index_postings_old_on_status` (`status`),
  KEY `index_postings_old_on_external_id_and_source` (`external_id`,`source`)
) ENGINE=MyISAM AUTO_INCREMENT=11637 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_data`
--

DROP TABLE IF EXISTS `system_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `table_recent_anchors`
--

DROP TABLE IF EXISTS `table_recent_anchors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `table_recent_anchors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `anchor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `timestamps`
--

DROP TABLE IF EXISTS `timestamps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timestamps` (
  `timestamp` int(10) NOT NULL,
  PRIMARY KEY (`timestamp`),
  KEY `index_timestamps_on_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `zipcodes`
--

DROP TABLE IF EXISTS `zipcodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zipcodes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zipcode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lat` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `long` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_zipcodes_on_zipcode` (`zipcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-11-19 15:52:44
INSERT INTO schema_migrations (version) VALUES ('20130704161556');

INSERT INTO schema_migrations (version) VALUES ('20130711100406');

INSERT INTO schema_migrations (version) VALUES ('20130715082559');

INSERT INTO schema_migrations (version) VALUES ('20130715114949');

INSERT INTO schema_migrations (version) VALUES ('20130717101546');

INSERT INTO schema_migrations (version) VALUES ('20130717141844');

INSERT INTO schema_migrations (version) VALUES ('20130723143725');

INSERT INTO schema_migrations (version) VALUES ('20130726074139');

INSERT INTO schema_migrations (version) VALUES ('20130729141750');

INSERT INTO schema_migrations (version) VALUES ('20130805173051');

INSERT INTO schema_migrations (version) VALUES ('20130806022252');

INSERT INTO schema_migrations (version) VALUES ('20130807071658');

INSERT INTO schema_migrations (version) VALUES ('20130807181123');

INSERT INTO schema_migrations (version) VALUES ('20130812050137');

INSERT INTO schema_migrations (version) VALUES ('20130815021753');

INSERT INTO schema_migrations (version) VALUES ('20130820190831');

INSERT INTO schema_migrations (version) VALUES ('20130820223422');

INSERT INTO schema_migrations (version) VALUES ('20130822081247');

INSERT INTO schema_migrations (version) VALUES ('20130823061710');

INSERT INTO schema_migrations (version) VALUES ('20130827140409');

INSERT INTO schema_migrations (version) VALUES ('20130828074621');

INSERT INTO schema_migrations (version) VALUES ('20130829125211');

INSERT INTO schema_migrations (version) VALUES ('20130829140856');

INSERT INTO schema_migrations (version) VALUES ('20130830095141');

INSERT INTO schema_migrations (version) VALUES ('20130903153143');

INSERT INTO schema_migrations (version) VALUES ('20130904152649');

INSERT INTO schema_migrations (version) VALUES ('20130905092204');

INSERT INTO schema_migrations (version) VALUES ('20130905095404');

INSERT INTO schema_migrations (version) VALUES ('20130911084832');

INSERT INTO schema_migrations (version) VALUES ('20130911085735');

INSERT INTO schema_migrations (version) VALUES ('20130913092557');

INSERT INTO schema_migrations (version) VALUES ('20130916152526');

INSERT INTO schema_migrations (version) VALUES ('20130917115835');
