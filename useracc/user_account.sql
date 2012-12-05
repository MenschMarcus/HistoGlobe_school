-- phpMyAdmin SQL Dump
-- version 3.4.5
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le : Sam 03 Mars 2012 à 20:00
-- Version du serveur: 5.5.8
-- Version de PHP: 5.3.5

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `user_account`
--

-- --------------------------------------------------------

--
-- Structure de la table `individual`
--

CREATE TABLE IF NOT EXISTS `individual` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(32) NOT NULL,
  `pass_SHA1` varchar(40) NOT NULL,
  `member_mail` varchar(100) NOT NULL,
  `member_registration` date NOT NULL,
  `member_age` varchar(11) NOT NULL,
  `member_lastLogin` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login` (`login`),
  UNIQUE KEY `pass_md5` (`pass_SHA1`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=12 ;

--
-- Contenu de la table `individual`
--

INSERT INTO `individual` (`id`, `login`, `pass_SHA1`, `member_mail`, `member_registration`, `member_age`, `member_lastLogin`) VALUES
(8, 'Pierre-Olivier', '48d53a10cbcaadfff87871afda2ea3fec288ed62', 'po', '2012-02-09', '22', '2012-02-09');

-- --------------------------------------------------------

--
-- Structure de la table `module_store`
--

CREATE TABLE IF NOT EXISTS `module_store` (
  `module_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_name` varchar(32) NOT NULL,
  `module_content` varchar(1000) NOT NULL,
  `module_lastUpdate` bigint(20) NOT NULL,
  PRIMARY KEY (`module_id`),
  UNIQUE KEY `module_name` (`module_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `permission`
--

CREATE TABLE IF NOT EXISTS `permission` (
  `permission_id` int(11) NOT NULL AUTO_INCREMENT,
  `id` int(11) NOT NULL,
  `module_id` int(11) NOT NULL,
  `buy_date` date NOT NULL,
  PRIMARY KEY (`permission_id`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `module_id` (`module_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `private_institution`
--

CREATE TABLE IF NOT EXISTS `private_institution` (
  `PI_id` int(11) NOT NULL AUTO_INCREMENT,
  `PI_name` varchar(40) NOT NULL,
  `PI_address` varchar(40) NOT NULL,
  `PI_contactName` varchar(100) NOT NULL,
  `PI_requestDate` date NOT NULL,
  `PI_contactPhoneNumber` varchar(20) NOT NULL,
  `PI_contactEmail` varchar(50) NOT NULL,
  `PI_size` varchar(14) NOT NULL,
  PRIMARY KEY (`PI_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `private_institution`
--

INSERT INTO `private_institution` (`PI_id`, `PI_name`, `PI_address`, `PI_contactName`, `PI_requestDate`, `PI_contactPhoneNumber`, `PI_contactEmail`, `PI_size`) VALUES
(1, 'a', 'a', 'a', '2012-01-26', 'a', 'a', 'a'),
(2, 'h', 'h', 'h', '2012-01-31', 'h', 'h', 'h');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
