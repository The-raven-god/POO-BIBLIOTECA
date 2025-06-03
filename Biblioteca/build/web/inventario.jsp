<%@page import="java.sql.*"%>
<%@page import="utils.conexion"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String mensaje = "";
    String tipoMensaje = "";
    
    String eliminarId = request.getParameter("eliminar");
    if (eliminarId != null && !eliminarId.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = conexion.getConnection();
            String sql = "DELETE FROM libro WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(eliminarId));
            
            int filasAfectadas = pstmt.executeUpdate();
            if (filasAfectadas > 0) {
                mensaje = "Libro eliminado exitosamente";
                tipoMensaje = "success";
            } else {
                mensaje = "Error al eliminar el libro";
                tipoMensaje = "error";
            }
        } catch (Exception e) {
            mensaje = "Error al eliminar: " + e.getMessage();
            tipoMensaje = "error";
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }
    
    String actualizarId = request.getParameter("actualizarId");
    if (actualizarId != null && !actualizarId.isEmpty()) {
        String titulo = request.getParameter("titulo");
        String autor = request.getParameter("autor");
        String isbn = request.getParameter("isbn");
        String categoria = request.getParameter("categoria");
        String cantidadDisponible = request.getParameter("cantidadDisponible");
        String cantidadTotal = request.getParameter("cantidadTotal");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = conexion.getConnection();
            String sql = "UPDATE libro SET titulo=?, autor=?, isbn=?, categoria=?, cantidadDisponible=?, cantidadTotal=? WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, titulo);
            pstmt.setString(2, autor.isEmpty() ? null : autor);
            pstmt.setString(3, isbn.isEmpty() ? null : isbn);
            pstmt.setString(4, categoria.isEmpty() ? null : categoria);
            pstmt.setInt(5, cantidadDisponible.isEmpty() ? 0 : Integer.parseInt(cantidadDisponible));
            pstmt.setInt(6, cantidadTotal.isEmpty() ? 0 : Integer.parseInt(cantidadTotal));
            pstmt.setInt(7, Integer.parseInt(actualizarId));
            
            int filasAfectadas = pstmt.executeUpdate();
            if (filasAfectadas > 0) {
                mensaje = "Libro actualizado exitosamente";
                tipoMensaje = "success";
            } else {
                mensaje = "Error al actualizar el libro";
                tipoMensaje = "error";
            }
        } catch (Exception e) {
            mensaje = "Error al actualizar: " + e.getMessage();
            tipoMensaje = "error";
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }
    
    List<Map<String, Object>> libros = new ArrayList<>();
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = conexion.getConnection();
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT * FROM libro ORDER BY id DESC");
        
        while (rs.next()) {
            Map<String, Object> libro = new HashMap<>();
            libro.put("id", rs.getInt("id"));
            libro.put("titulo", rs.getString("titulo"));
            libro.put("autor", rs.getString("autor"));
            libro.put("isbn", rs.getString("isbn"));
            libro.put("categoria", rs.getString("categoria"));
            libro.put("cantidadDisponible", rs.getInt("cantidadDisponible"));
            libro.put("cantidadTotal", rs.getInt("cantidadTotal"));
            libro.put("fechaRegistro", rs.getTimestamp("fechaRegistro"));
            libros.add(libro);
        }
    } catch (Exception e) {
        mensaje = "Error al cargar libros: " + e.getMessage();
        tipoMensaje = "error";
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar recursos: " + e.getMessage());
        }
    }
%>

<%@ include file="navbar.jsp" %>
<html>
<head>
    <title>Inventario - Biblioteca</title>
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
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 600px;
            border-radius: 8px;
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: black;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
    </style>
</head>
<body>
<div class="main-content">
    <div class="container">
        <div class="card">
            <div class="card-header">
                <h2>Inventario de Libros</h2>
                <a href="registrarLibro.jsp" class="btn"><i class="fas fa-plus"></i> Nuevo Libro</a>
            </div>
            
            <% if (!mensaje.equals("")) { %>
                <div class="mensaje <%= tipoMensaje %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Título</th>
                        <th>Autor</th>
                        <th>ISBN</th>
                        <th>Categoría</th>
                        <th>Disponibles</th>
                        <th>Total</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    if (libros.isEmpty()) {
                    %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 20px;">
                                No hay libros registrados
                            </td>
                        </tr>
                    <% 
                    } else {
                        for (Map<String, Object> libro : libros) { 
                    %>
                    <tr>
                        <td><%= libro.get("id") %></td>
                        <td><strong><%= libro.get("titulo") %></strong></td>
                        <td><%= libro.get("autor") != null ? libro.get("autor") : "N/A" %></td>
                        <td><%= libro.get("isbn") != null ? libro.get("isbn") : "N/A" %></td>
                        <td><%= libro.get("categoria") != null ? libro.get("categoria") : "N/A" %></td>
                        <td><%= libro.get("cantidadDisponible") %></td>
                        <td><%= libro.get("cantidadTotal") %></td>
                        <td>
                            <button onclick="editarLibro('<%= libro.get("id") %>', '<%= libro.get("titulo") %>', '<%= libro.get("autor") != null ? libro.get("autor") : "" %>', '<%= libro.get("isbn") != null ? libro.get("isbn") : "" %>', '<%= libro.get("categoria") != null ? libro.get("categoria") : "" %>', '<%= libro.get("cantidadDisponible") %>', '<%= libro.get("cantidadTotal") %>')" 
                                    class="btn" style="background-color: var(--info-color); padding: 5px 10px;">
                                <i class="fas fa-edit"></i>
                            </button>
                            <a href="?eliminar=<%= libro.get("id") %>" class="btn" style="background-color: var(--accent-color); padding: 5px 10px;"
                               onclick="return confirm('¿Está seguro de eliminar este libro?');">
                                <i class="fas fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <% 
                        }
                    } 
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal para editar libro -->
<div id="modalEditar" class="modal">
    <div class="modal-content">
        <span class="close" onclick="cerrarModal()">&times;</span>
        <h2>Editar Libro</h2>
        <form method="post">
            <input type="hidden" id="actualizarId" name="actualizarId" />
            
            <div class="form-group">
                <label for="editTitulo">Título:</label>
                <input type="text" id="editTitulo" name="titulo" required>
            </div>
            
            <div class="form-group">
                <label for="editAutor">Autor:</label>
                <input type="text" id="editAutor" name="autor">
            </div>
            
            <div class="form-group">
                <label for="editIsbn">ISBN:</label>
                <input type="text" id="editIsbn" name="isbn">
            </div>
            
            <div class="form-group">
                <label for="editCategoria">Categoría:</label>
                <input type="text" id="editCategoria" name="categoria">
            </div>
            
            <div class="form-group">
                <label for="editCantidadDisponible">Cantidad Disponible:</label>
                <input type="number" id="editCantidadDisponible" name="cantidadDisponible" min="0">
            </div>
            
            <div class="form-group">
                <label for="editCantidadTotal">Cantidad Total:</label>
                <input type="number" id="editCantidadTotal" name="cantidadTotal" min="0" required>
            </div>
            
            <div style="text-align: right;">
                <button type="button" onclick="cerrarModal()" class="btn" style="background-color: #6c757d;">Cancelar</button>
                <button type="submit" class="btn" style="margin-left: 10px;">
                    <i class="fas fa-save"></i> Actualizar
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function editarLibro(id, titulo, autor, isbn, categoria, cantDisponible, cantTotal) {
    document.getElementById('actualizarId').value = id;
    document.getElementById('editTitulo').value = titulo;
    document.getElementById('editAutor').value = autor;
    document.getElementById('editIsbn').value = isbn;
    document.getElementById('editCategoria').value = categoria;
    document.getElementById('editCantidadDisponible').value = cantDisponible;
    document.getElementById('editCantidadTotal').value = cantTotal;
    
    document.getElementById('modalEditar').style.display = 'block';
}

function cerrarModal() {
    document.getElementById('modalEditar').style.display = 'none';
}

window.onclick = function(event) {
    var modal = document.getElementById('modalEditar');
    if (event.target == modal) {
        modal.style.display = "none";
    }
}
</script>

</body>
</html>