<%@ include file="navbar.jsp" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%
    String error = request.getParameter("error");
%>
<html>
<head>
    <title>Inicio - Biblioteca</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
<div class="main-content">
    <div class="container">
        <% if ("login".equals(error)) { %>
            <div class="error-msg">Correo o contraseña incorrectos.</div>
        <% } else if ("bd".equals(error)) { %>
            <div class="error-msg">Error al conectar con la base de datos. Inténtalo más tarde.</div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <h2>Bienvenido al Sistema de Biblioteca</h2>
            </div>
            <div class="card-body">
                <p>Gestiona tu biblioteca de manera eficiente con nuestro sistema integrado.</p>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-top: 30px;">
                    <div class="card" style="background-color: #f0f7ff;">
                        <h3><i class="fas fa-book" style="color: var(--info-color);"></i> Gestión de Libros</h3>
                        <p>Administra el inventario de libros, registra nuevos ejemplares y mantén actualizado tu catálogo.</p>
                    </div>

                    <div class="card" style="background-color: #fff0f0;">
                        <h3><i class="fas fa-exchange-alt" style="color: var(--accent-color);"></i> Préstamos</h3>
                        <p>Controla los préstamos de libros, fechas de devolución y multas por retraso.</p>
                    </div>

                    <div class="card" style="background-color: #f0fff0;">
                        <h3><i class="fas fa-users" style="color: var(--success-color);"></i> Usuarios</h3>
                        <p>Administra los usuarios registrados en el sistema y sus permisos.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
