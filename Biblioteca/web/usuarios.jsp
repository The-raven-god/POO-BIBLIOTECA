<%@ page import="java.sql.*" %>
<%@ include file="navbar.jsp" %>
<html>
<head>
    <title>Registrar Usuario</title>
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
                <h2>Registrar Nuevo Usuario</h2>
            </div>

            <%-- PROCESAR FORMULARIO --%>
            <%
                String mensaje = "";
                String tipoMensaje = "";
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String nombre = request.getParameter("nombre");
                    String apellido = request.getParameter("apellido");
                    String cedula = request.getParameter("cedula");
                    String email = request.getParameter("email");
                    String password = request.getParameter("password");
                    String telefono = request.getParameter("telefono");
                    String direccion = request.getParameter("direccion");
                    String tipoUsuario = request.getParameter("tipoUsuario");

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "");

                        String sql = "INSERT INTO usuario (nombre, apellido, cedula, email, password, telefono, direccion, tipoUsuario) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                        PreparedStatement stmt = conn.prepareStatement(sql);
                        stmt.setString(1, nombre);
                        stmt.setString(2, apellido);
                        stmt.setString(3, cedula);
                        stmt.setString(4, email);
                        stmt.setString(5, password);
                        stmt.setString(6, telefono);
                        stmt.setString(7, direccion);
                        stmt.setString(8, tipoUsuario);

                        int filas = stmt.executeUpdate();
                        if (filas > 0) {
                            mensaje = "Usuario registrado correctamente.";
                            tipoMensaje = "success";
                        } else {
                            mensaje = "Error al registrar.";
                            tipoMensaje = "error";
                        }

                        stmt.close();
                        conn.close();
                    } catch (Exception e) {
                        mensaje = "Error: " + e.getMessage();
                        tipoMensaje = "error";
                    }
                }
            %>

            <% if (!mensaje.isEmpty()) { %>
                <div class="mensaje <%= tipoMensaje %>">
                    <%= mensaje %>
                </div>
            <% } %>

            <form method="post" style="max-width: 600px; margin: 0 auto;">
                <div class="form-group">
                    <label>Nombre:</label>
                    <input type="text" name="nombre" class="form-control" required>
                </div>

                <div class="form-group">
                    <label>Apellido:</label>
                    <input type="text" name="apellido" class="form-control" required>
                </div>

                <div class="form-group">
                    <label>Cédula:</label>
                    <input type="text" name="cedula" class="form-control" required>
                </div>

                <div class="form-group">
                    <label>Email:</label>
                    <input type="email" name="email" class="form-control" required>
                </div>

                <div class="form-group">
                    <label>Contraseña:</label>
                    <input type="password" name="password" class="form-control" required>
                </div>

                <div class="form-group">
                    <label>Teléfono:</label>
                    <input type="text" name="telefono" class="form-control">
                </div>

                <div class="form-group">
                    <label>Dirección:</label>
                    <input type="text" name="direccion" class="form-control">
                </div>

                <div class="form-group">
                    <label>Tipo de Usuario:</label>
                    <select name="tipoUsuario" class="form-control" required>
                        <option value="usuario">Usuario</option>
                        <option value="administrativo">Administrativo</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-block">
                    <i class="fas fa-user-plus"></i> Registrar Usuario
                </button>
            </form>
        </div>
    </div>
</div>
</body>
</html>
