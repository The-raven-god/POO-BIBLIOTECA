-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 03-06-2025 a las 15:31:28
-- Versión del servidor: 8.0.30
-- Versión de PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `biblioteca`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libro`
--

CREATE TABLE `libro` (
  `id` int NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `autor` varchar(100) DEFAULT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  `categoria` varchar(50) DEFAULT NULL,
  `cantidadDisponible` int DEFAULT '0',
  `cantidadTotal` int DEFAULT '0',
  `fechaRegistro` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `libro`
--

INSERT INTO `libro` (`id`, `titulo`, `autor`, `isbn`, `categoria`, `cantidadDisponible`, `cantidadTotal`, `fechaRegistro`) VALUES
(8, 'Los vagabundos de Dios', 'Mario Mendoza', '10', 'Superacion', 1, 3, '2025-06-03 02:51:21'),
(9, 'Cien años de soledad', 'Gabriel', '12345', 'Literatura', 4, 5, '2025-06-03 12:32:47');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamo`
--

CREATE TABLE `prestamo` (
  `id` int NOT NULL,
  `idUsuario` int DEFAULT NULL,
  `idLibro` int DEFAULT NULL,
  `fechaPrestamo` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fechaLimite` timestamp NULL DEFAULT NULL,
  `fechaDevolucion` timestamp NULL DEFAULT NULL,
  `estado` enum('pendiente','devuelto','atrasado') DEFAULT 'pendiente',
  `multa` decimal(10,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `prestamo`
--

INSERT INTO `prestamo` (`id`, `idUsuario`, `idLibro`, `fechaPrestamo`, `fechaLimite`, `fechaDevolucion`, `estado`, `multa`) VALUES
(1, 2, 8, '2025-06-03 05:00:00', '2025-06-10 05:00:00', '2025-06-03 05:00:00', 'devuelto', 0.00),
(2, 1, 8, '2025-06-03 05:00:00', '2025-06-10 05:00:00', '2025-06-03 05:00:00', 'devuelto', 0.00),
(3, 4, 9, '2025-06-03 05:00:00', '2025-06-10 05:00:00', '2025-06-03 05:00:00', 'devuelto', 0.00),
(4, 2, 8, '2025-06-03 05:00:00', '2025-06-10 05:00:00', NULL, 'pendiente', 0.00),
(5, 3, 9, '2025-06-03 05:00:00', '2025-06-10 05:00:00', NULL, 'pendiente', 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `apellido` varchar(50) DEFAULT NULL,
  `cedula` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `tipoUsuario` enum('administrativo','usuario') NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `fechaRegistro` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `nombre`, `apellido`, `cedula`, `email`, `password`, `telefono`, `direccion`, `tipoUsuario`, `activo`, `fechaRegistro`) VALUES
(1, 'Santiago', 'Rueda Quintero', '1029929292', 'santi@gmail.com', '1234', '3125108134', 'AV 5 CALLE 18', 'usuario', 1, '2025-06-03 03:33:41'),
(2, 'Yuritzi', 'sanchez caile', '1111111111', 'yuri@gmail.com', '1234', '3122133516', 'av 28', 'usuario', 1, '2025-06-03 05:22:12'),
(3, 'Eliecer', 'Guevara', '123456789', 'eliecer@gmail.com', '1234', '111111111', 'Su casa', 'usuario', 1, '2025-06-03 06:11:40'),
(4, 'Angel', 'Ureña', '123456', 'angel@gmail.com', '1234', '111020212102', 'AV 4 CALLE 18', 'usuario', 1, '2025-06-03 12:31:29');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `libro`
--
ALTER TABLE `libro`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `isbn` (`isbn`);

--
-- Indices de la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idUsuario` (`idUsuario`),
  ADD KEY `idLibro` (`idLibro`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cedula` (`cedula`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `libro`
--
ALTER TABLE `libro`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `prestamo`
--
ALTER TABLE `prestamo`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD CONSTRAINT `prestamo_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prestamo_ibfk_2` FOREIGN KEY (`idLibro`) REFERENCES `libro` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
