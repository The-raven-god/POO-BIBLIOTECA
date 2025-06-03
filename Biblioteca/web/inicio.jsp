<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="utils.conexion"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.security.NoSuchAlgorithmException"%>

<%
    String mensaje = "";
    String tipoMensaje = "";
    
    if ("POST".equals(request.getMethod()) && "login".equals(request.getParameter("action"))) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        try {
            Connection conn = conexion.getConnection();
            String sql = "SELECT id, nombre, apellido, tipoUsuario FROM usuario WHERE email = ? AND password = ? AND activo = 1";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, password);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                session.setAttribute("usuarioId", rs.getInt("id"));
                session.setAttribute("usuarioNombre", rs.getString("nombre"));
                session.setAttribute("usuarioApellido", rs.getString("apellido"));
                session.setAttribute("tipoUsuario", rs.getString("tipoUsuario"));
                
                if ("administrativo".equals(rs.getString("tipoUsuario"))) {
                    response.sendRedirect("index.jsp");
                } else {
                    response.sendRedirect("index.jsp");
                }
                return;
            } else {
                mensaje = "Email o contraseña incorrectos";
                tipoMensaje = "error";
            }
            
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (Exception e) {
            mensaje = "Error de conexión: " + e.getMessage();
            tipoMensaje = "error";
        }
    }
    
    if ("POST".equals(request.getMethod()) && "register".equals(request.getParameter("action"))) {
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String cedula = request.getParameter("cedula");
        String email = request.getParameter("email");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");
        String password = request.getParameter("password");
        
        try {
            Connection conn = conexion.getConnection();
            
            String checkSql = "SELECT COUNT(*) FROM usuario WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet checkRs = checkStmt.executeQuery();
            checkRs.next();
            
            if (checkRs.getInt(1) > 0) {
                mensaje = "El email ya está registrado";
                tipoMensaje = "error";
            } else {
                String sql = "INSERT INTO usuario (nombre, apellido, cedula, email, password, telefono, direccion, tipoUsuario, activo, fechaRegistro) VALUES (?, ?, ?, ?, ?, ?, ?, 'usuario', 1, NOW())";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, nombre);
                stmt.setString(2, apellido);
                stmt.setString(3, cedula);
                stmt.setString(4, email);
                stmt.setString(5, password);
                stmt.setString(6, telefono);
                stmt.setString(7, direccion);
                
                int result = stmt.executeUpdate();
                
                if (result > 0) {
                    mensaje = "Usuario registrado exitosamente. Ahora puedes iniciar sesión.";
                    tipoMensaje = "success";
                } else {
                    mensaje = "Error al registrar usuario";
                    tipoMensaje = "error";
                }
                
                stmt.close();
            }
            
            checkRs.close();
            checkStmt.close();
            conn.close();
            
        } catch (Exception e) {
            mensaje = "Error de conexión: " + e.getMessage();
            tipoMensaje = "error";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login / Registro - Biblioteca</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(to right, var(--primary-color), var(--secondary-color));
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
        }

        .login-register-container {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 400px;
        }

        h2 {
            text-align: center;
            color: var(--primary-color);
            margin-bottom: 25px;
        }

        .form-group {
            margin-bottom: 20px;
            position: relative;
        }

        .form-group label {
            position: absolute;
            top: 10px;
            left: 15px;
            font-size: 14px;
            color: #777;
            pointer-events: none;
            transition: 0.2s ease all;
        }

        .form-control {
            width: 100%;
            padding: 14px 15px 6px 15px;
            border: none;
            border-bottom: 2px solid var(--primary-color);
            background-color: transparent;
            font-size: 16px;
            box-sizing: border-box;
        }

        .form-control:focus {
            outline: none;
            border-bottom-color: var(--accent-color);
        }

        .btn {
            width: 100%;
            padding: 12px;
            background-color: var(--primary-color);
            color: #fff;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .btn:hover {
            background-color: var(--secondary-color);
        }

        .switch {
            text-align: center;
            margin-top: 20px;
        }

        .switch a {
            color: var(--accent-color);
            text-decoration: none;
            font-weight: bold;
            cursor: pointer;
        }
        
        .hidden-label {
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s ease;
        }

        #registerForm {
            display: none;
        }

        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 4px;
            text-align: center;
        }

        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="login-register-container">
        <% if (!mensaje.isEmpty()) { %>
            <div class="message <%= tipoMensaje %>">
                <%= mensaje %>
            </div>
        <% } %>

        <!-- LOGIN -->
        <div id="loginForm">
            <h2>Iniciar Sesión</h2>
            <form method="post">
                <input type="hidden" name="action" value="login">
                <div class="form-group">
                    <label for="emailLogin">Correo electrónico</label>
                    <input id="emailLogin" type="email" class="form-control" name="email" required>
                </div>
                <div class="form-group">
                    <label for="passwordLogin">Contraseña</label>
                    <input id="passwordLogin" type="password" class="form-control" name="password" required>
                </div>
                <button type="submit" class="btn">Entrar</button>
            </form>
            <div class="switch">
                <p>¿No tienes cuenta? <a id="showRegister">Regístrate</a></p>
            </div>
        </div>

        <!-- REGISTRO -->
        <div id="registerForm">
            <h2>Registro de Usuario</h2>
            <form method="post">
                <input type="hidden" name="action" value="register">
                <div class="form-group">
                    <label for="nombre">Nombre</label>
                    <input type="text" class="form-control" name="nombre" required>
                </div>
                <div class="form-group">
                    <label for="apellido">Apellido</label>
                    <input type="text" class="form-control" name="apellido" required>
                </div>
                <div class="form-group">
                    <label for="cedula">Cédula</label>
                    <input type="text" class="form-control" name="cedula" required>
                </div>
                <div class="form-group">
                    <label for="emailRegister">Correo electrónico</label>
                    <input id="emailRegister" type="email" class="form-control" name="email" required>
                </div>
                <div class="form-group">
                    <label for="telefono">Teléfono</label>
                    <input type="text" class="form-control" name="telefono" required>
                </div>
                <div class="form-group">
                    <label for="direccion">Dirección</label>
                    <input type="text" class="form-control" name="direccion" required>
                </div>
                <div class="form-group">
                    <label for="passwordRegister">Contraseña</label>
                    <input id="passwordRegister" type="password" class="form-control" name="password" required>
                </div>
                <button type="submit" class="btn">Registrarse</button>
            </form>
            <div class="switch">
                <p>¿Ya tienes cuenta? <a id="showLogin">Inicia sesión</a></p>
            </div>
        </div>
    </div>

    <script>
        const showRegisterBtn = document.getElementById('showRegister');
        const showLoginBtn = document.getElementById('showLogin');
        const loginForm = document.getElementById('loginForm');
        const registerForm = document.getElementById('registerForm');

        showRegisterBtn.addEventListener('click', () => {
            loginForm.style.display = 'none';
            registerForm.style.display = 'block';
        });

        showLoginBtn.addEventListener('click', () => {
            registerForm.style.display = 'none';
            loginForm.style.display = 'block';
        });

        function toggleLabelVisibility(input) {
            const label = input.previousElementSibling;
            if(input.value.length > 0) {
                label.classList.add('hidden-label');
            } else {
                label.classList.remove('hidden-label');
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            const inputs = document.querySelectorAll('.form-control');

            inputs.forEach(input => {
                toggleLabelVisibility(input);

                input.addEventListener('input', () => {
                    toggleLabelVisibility(input);
                });
            });
        });
    </script>
</body>
</html>