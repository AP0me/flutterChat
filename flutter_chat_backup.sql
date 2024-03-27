-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 27, 2024 at 08:20 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flutter_chat`
--

-- --------------------------------------------------------

--
-- Table structure for table `chat_messages`
--

CREATE TABLE `chat_messages` (
  `message_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `text` text NOT NULL,
  `date_sent` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chat_messages`
--

INSERT INTO `chat_messages` (`message_id`, `user_id`, `text`, `date_sent`) VALUES
(1, 1, 'message0', '2024-03-19 07:36:57'),
(2, 1, 'hi', '2024-03-19 08:59:37'),
(3, 1, 'jojo', '2024-03-19 09:48:53'),
(4, 1, 'ms', '2024-03-24 14:26:27'),
(5, 1, 'hoho', '2024-03-24 14:28:45'),
(6, 1, 'hi', '2024-03-25 10:31:56'),
(7, 1, '32', '2024-03-25 10:34:04'),
(8, 1, 'jojo', '2024-03-25 10:36:09'),
(9, 1, 'hoho', '2024-03-25 11:44:42'),
(10, 1, 'koko', '2024-03-25 11:46:36'),
(11, 1, 'hello', '2024-03-25 11:47:33'),
(12, 1, 'do', '2024-03-25 11:50:59'),
(13, 1, 'go', '2024-03-25 11:54:19'),
(14, 1, 'boo!', '2024-03-25 11:54:59'),
(15, 1, 'yo', '2024-03-25 11:55:14'),
(16, 1, 'hi', '2024-03-25 11:56:41'),
(17, 1, 'lol', '2024-03-25 11:58:04'),
(18, 1, 'hoho', '2024-03-25 11:59:38'),
(19, 1, 'hey!', '2024-03-25 12:00:53'),
(20, 1, 'go', '2024-03-25 12:04:03'),
(21, 1, 'nono', '2024-03-25 12:05:17'),
(22, 1, 'jojo', '2024-03-25 12:06:05'),
(23, 1, 'ker', '2024-03-25 12:06:13'),
(24, 1, 'me', '2024-03-25 12:06:21'),
(25, 1, 'no', '2024-03-25 12:06:23'),
(26, 1, 'ko', '2024-03-25 12:07:07'),
(27, 1, 'lol', '2024-03-25 12:07:11'),
(28, 1, '417', '2024-03-25 12:07:17'),
(29, 1, 'hi', '2024-03-26 08:28:34'),
(30, 1, 'jojo', '2024-03-26 08:28:41'),
(31, 1, 'hi', '2024-03-26 08:29:36'),
(32, 1, 'go', '2024-03-26 08:30:19'),
(33, 1, 'jojo', '2024-03-26 08:32:00'),
(34, 1, 'hi', '2024-03-27 06:29:40'),
(35, 1, 'hoho', '2024-03-27 06:29:49'),
(36, 1, 'jojo', '2024-03-27 06:29:54'),
(37, 1, 'kak', '2024-03-27 06:30:57'),
(38, 1, 'me', '2024-03-27 06:32:25'),
(39, 1, 'koko', '2024-03-27 06:34:20'),
(40, 1, 'nono', '2024-03-27 06:34:28'),
(41, 1, 'lag', '2024-03-27 06:34:42'),
(42, 1, 'is', '2024-03-27 06:34:45'),
(43, 1, 'real', '2024-03-27 06:34:47'),
(44, 1, '.', '2024-03-27 06:34:47'),
(45, 1, 'yep', '2024-03-27 06:34:51'),
(46, 1, '.', '2024-03-27 06:35:01'),
(47, 1, 'jojo', '2024-03-27 06:36:34'),
(48, 2, 'send message', '2024-03-27 06:40:01'),
(49, 1, 'I am guest', '2024-03-27 06:40:49'),
(50, 2, 'I am root', '2024-03-27 06:40:54'),
(51, 1, 'no wait, I am root', '2024-03-27 06:41:04'),
(52, 2, 'yea right I am guest', '2024-03-27 06:41:11');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `password` varchar(16) DEFAULT NULL,
  `salt` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `password`, `salt`) VALUES
(1, 'root', NULL, NULL),
(2, 'guest', NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
