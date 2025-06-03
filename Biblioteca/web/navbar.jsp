<%-- 
    Document   : navbar
    Created on : 26/05/2025, 9:11:34 p. m.
    Author     : SATANAS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div class="navbar">
    <div class="navbar-header">
        <h2>Biblioteca</h2>
    </div>
    <ul class="nav-links">
        <li><a href="index.jsp"><i class="fas fa-home"></i> Inicio</a></li>
        <li><a href="inventario.jsp"><i class="fas fa-book"></i> Inventario</a></li>
        <li><a href="registrarLibro.jsp"><i class="fas fa-plus-circle"></i> Registrar Libro</a></li>
        <li class="dropdown">
            <a href="#"><i class="fas fa-exchange-alt"></i> Préstamos <i class="fas fa-caret-down"></i></a>
            <ul class="dropdown-menu">
                <li><a href="PrestamosActivos.jsp">Préstamos Activos</a></li>
                <li><a href="PrestamosRegistro.jsp">Registrar Préstamo</a></li>
            </ul>
        </li>
        <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
        <li><a href="inicio.jsp"><i class="fas fa-users"></i> inicio</a></li>
    </ul>
</div>

<style>
    .dropdown {
        position: relative;
    }

    .dropdown a {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .dropdown-menu {
        display: none;
        position: absolute;
        top: 100%;
        left: 0;
        background-color: #fff;
        list-style: none;
        padding: 0;
        margin: 0;
        box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        z-index: 1000;
    }

    .dropdown:hover .dropdown-menu {
        display: block;
    }

    .dropdown-menu li {
        padding: 10px 20px;
    }

    .dropdown-menu li a {
        color: #333;
        text-decoration: none;
    }

    .dropdown-menu li:hover {
        background-color: #f1f1f1;
    }
</style>


<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">