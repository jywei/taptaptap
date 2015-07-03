-- phpMyAdmin SQL Dump
-- version 4.1.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Feb 11, 2014 at 08:14 PM
-- Server version: 5.5.34-0ubuntu0.13.04.1
-- PHP Version: 5.4.9-4ubuntu2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `taps_dev`
--

-- --------------------------------------------------------

--
-- Table structure for table `converters`
--

DROP TABLE IF EXISTS `converters`;
CREATE TABLE IF NOT EXISTS `converters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `convert_status` tinyint(1) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status_wrong_values` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `convert_source` tinyint(1) DEFAULT NULL,
  `source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_wrong_values` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reject_category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_reject_category` tinyint(1) DEFAULT NULL,
  `accept_category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_accept_category` tinyint(1) DEFAULT NULL,
  `reject_category_group` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_reject_category_group` tinyint(1) DEFAULT NULL,
  `accept_category_group` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_accept_category_group` tinyint(1) DEFAULT NULL,
  `use_geolocation_module` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=10 ;

--
-- Dumping data for table `converters`
--

INSERT INTO `converters` (`id`, `convert_status`, `status`, `status_wrong_values`, `convert_source`, `source`, `source_wrong_values`, `reject_category`, `use_reject_category`, `accept_category`, `use_accept_category`, `reject_category_group`, `use_reject_category_group`, `accept_category_group`, `use_accept_category_group`, `use_geolocation_module`, `created_at`, `updated_at`) VALUES
(1, 1, 'for_sale', 'offered', 1, 'OODLE', '', 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 1, '2014-02-07 18:43:24', '2014-02-11 13:15:57'),
(2, 1, 'for_sale', 'offered', 1, 'INDEE', '', 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 1, '2014-02-07 18:59:06', '2014-02-11 13:19:05'),
(3, 1, 'for_sale', '', 1, 'HMNGS', '', 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 1, '2014-02-11 13:15:02', '2014-02-11 15:25:57'),
(4, 1, 'for_sale', 'offered', 1, 'EBAYM', '', 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 0, '2014-02-11 13:15:35', '2014-02-11 13:15:35'),
(5, 1, 'for_sale', 'offered', 1, 'CRAIG', '', 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 1, '2014-02-11 13:17:42', '2014-02-11 13:18:48'),
(6, 1, 'for_rent', 'offered', 1, 'APTSD', '', 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 'AAAA', 0, 1, '2014-02-11 13:18:34', '2014-02-11 13:18:34');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
