<%-- 
    Document   : registrarLibro
    Created on : 26/05/2025, 9:11:59 p. m.
    Author     : SATANAS
--%>
<%@page import="java.sql.*"%>
<%@page import="utils.conexion"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Procesar el formulario si se envió
    String mensaje = "";
    String tipoMensaje = "";
    
    if (request.getMethod().equals("POST")) {
        String titulo = request.getParameter("titulo");
        String autor = request.getParameter("autor");
        String isbn = request.getParameter("isbn");
        String categoria = request.getParameter("categoria");
        String cantidadDisponible = request.getParameter("cantidadDisponible");
        String cantidadTotal = request.getParameter("cantidadTotal");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // Usar la clase de conexión existente
            conn = conexion.getConnection();
            
            // Preparar la consulta SQL con los nombres exactos de las columnas
            String sql = "INSERT INTO libro (titulo, autor, isbn, categoria, cantidadDisponible, cantidadTotal, fechaRegistro) VALUES (?, ?, ?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            
            // Establecer los parámetros
            pstmt.setString(1, titulo);
            pstmt.setString(2, autor.isEmpty() ? null : autor);
            pstmt.setString(3, isbn.isEmpty() ? null : isbn);
            pstmt.setString(4, categoria.isEmpty() ? null : categoria);
            pstmt.setInt(5, cantidadDisponible.isEmpty() ? 0 : Integer.parseInt(cantidadDisponible));
            pstmt.setInt(6, cantidadTotal.isEmpty() ? 0 : Integer.parseInt(cantidadTotal));
            
            // Ejecutar la inserción
            int filasAfectadas = pstmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                mensaje = "Libro registrado exitosamente";
                tipoMensaje = "success";
            } else {
                mensaje = "Error al registrar el libro";
                tipoMensaje = "error";
            }
            
        } catch (SQLException e) {
            mensaje = "Error de base de datos: " + e.getMessage();
            tipoMensaje = "error";
        } catch (NumberFormatException e) {
            mensaje = "Error: Las cantidades deben ser números válidos";
            tipoMensaje = "error";
        } catch (Exception e) {
            mensaje = "Error inesperado: " + e.getMessage();
            tipoMensaje = "error";
        } finally {
            // Cerrar recursos
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }
%>

<%@ include file="navbar.jsp" %>
<html>
<head>
    <title>Registrar Libro - Biblioteca</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <style>
        .mensaje {
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
            font-weight: bold;
        }
        .mensaje.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .mensaje.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
<div class="main-content">
    <div class="container">
        <div class="card">
            <div class="card-header">
                <h2>Registrar Nuevo Libro</h2>
            </div>
            
            <% if (!mensaje.equals("")) { %>
                <div class="mensaje <%= tipoMensaje %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="post" style="max-width: 600px; margin: 0 auto;">
                <div class="form-group">
                    <label for="titulo">Título:</label>
                    <input type="text" id="titulo" name="titulo" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="autor">Autor:</label>
                    <input type="text" id="autor" name="autor" class="form-control" required>
                </div>
                <div class="form-group">
                    <label for="isbn">ISBN:</label>
                    <input type="text" id="isbn" name="isbn" class="form-control">
                </div>
                <div class="form-group">
                    <label for="categoria">Categoría:</label>
                    <input type="text" id="categoria" name="categoria" class="form-control">
                </div>
                <div class="form-group">
                    <label for="cantidadDisponible">Cantidad Disponible:</label>
                    <input type="number" id="cantidadDisponible" name="cantidadDisponible" class="form-control" min="0" value="0">
                </div>
                <div class="form-group">
                    <label for="cantidadTotal">Cantidad Total:</label>
                    <input type="number" id="cantidadTotal" name="cantidadTotal" class="form-control" min="0" value="0" required>
                </div>
                <button type="submit" class="btn btn-block">
                    <i class="fas fa-save"></i> Registrar Libro
                </button>
            </form>
        </div>
    </div>
</div>
</body>
</html>