<%@page import="java.sql.*"%>
<%@page import="utils.conexion"%>
<%@page import="java.util.*"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.temporal.ChronoUnit"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String mensaje = "";
    String tipoMensaje = "";
    
    if (request.getMethod().equals("POST")) {
        String prestamoId = request.getParameter("prestamoId");
        String accion = request.getParameter("accion");
        
        if ("devolver".equals(accion) && prestamoId != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            PreparedStatement pstmtUpdate = null;
            ResultSet rs = null;
            
            try {
                conn = conexion.getConnection();
                conn.setAutoCommit(false);
                
                // 1. Obtener información del préstamo
                String sqlPrestamo = "SELECT idLibro, fechaLimite FROM prestamo WHERE id = ? AND estado = 'pendiente'";
                pstmt = conn.prepareStatement(sqlPrestamo);
                pstmt.setInt(1, Integer.parseInt(prestamoId));
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    int libroId = rs.getInt("idLibro");
                    
                    rs.close();
                    pstmt.close();
                    
                    // Actualizar el préstamo como devuelto
                    String sqlUpdate = "UPDATE prestamo SET estado = 'devuelto', fechaDevolucion = CURDATE() WHERE id = ?";
                    pstmt = conn.prepareStatement(sqlUpdate);
                    pstmt.setInt(1, Integer.parseInt(prestamoId));
                    
                    int filasAfectadas = pstmt.executeUpdate();
                    
                    if (filasAfectadas > 0) {
                        // Aumentar la cantidad disponible del libro
                        String sqlUpdateLibro = "UPDATE libro SET cantidadDisponible = cantidadDisponible + 1 WHERE id = ?";
                        pstmtUpdate = conn.prepareStatement(sqlUpdateLibro);
                        pstmtUpdate.setInt(1, libroId);
                        pstmtUpdate.executeUpdate();
                        
                        conn.commit();
                        
                        mensaje = "Devolución registrada exitosamente.";
                        tipoMensaje = "success";
                    } else {
                        conn.rollback();
                        mensaje = "Error al procesar la devolución";
                        tipoMensaje = "error";
                    }
                } else {
                    mensaje = "Préstamo no encontrado o ya devuelto";
                    tipoMensaje = "error";
                }
                
            } catch (SQLException e) {
                try {
                    if (conn != null) conn.rollback();
                } catch (SQLException ex) {}
                mensaje = "Error de base de datos: " + e.getMessage();
                tipoMensaje = "error";
            } catch (Exception e) {
                try {
                    if (conn != null) conn.rollback();
                } catch (SQLException ex) {}
                mensaje = "Error inesperado: " + e.getMessage();
                tipoMensaje = "error";
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (pstmtUpdate != null) pstmtUpdate.close();
                    if (conn != null) {
                        conn.setAutoCommit(true);
                        conn.close();
                    }
                } catch (SQLException e) {
                    System.out.println("Error al cerrar recursos: " + e.getMessage());
                }
            }
        }
    }
    
    List<Map<String, Object>> prestamosActivos = new ArrayList<>();
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = conexion.getConnection();
        String sql = "SELECT p.id, u.nombre, u.apellido, u.cedula, l.titulo, l.autor, " +
                     "p.fechaPrestamo, p.fechaLimite, p.estado " +
                     "FROM prestamo p " +
                     "INNER JOIN usuario u ON p.idUsuario = u.id " +
                     "INNER JOIN libro l ON p.idLibro = l.id " +
                     "WHERE p.estado = 'pendiente' " +
                     "ORDER BY p.fechaLimite ASC";
        
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);
        
        LocalDate fechaHoy = LocalDate.now();
        
        while (rs.next()) {
            Map<String, Object> prestamo = new HashMap<>();
            prestamo.put("id", rs.getInt("id"));
            prestamo.put("usuario", rs.getString("nombre") + " " + rs.getString("apellido"));
            prestamo.put("cedula", rs.getString("cedula"));
            prestamo.put("libro", rs.getString("titulo") + " - " + (rs.getString("autor") != null ? rs.getString("autor") : "Sin autor"));
            prestamo.put("fechaPrestamo", rs.getDate("fechaPrestamo"));
            prestamo.put("fechaLimite", rs.getDate("fechaLimite"));
            prestamo.put("estado", rs.getString("estado"));
            
            // Calcular estado visual y días restantes
            LocalDate fechaLimite = rs.getDate("fechaLimite").toLocalDate();
            long diasHastaVencimiento = ChronoUnit.DAYS.between(fechaHoy, fechaLimite);
            
            String estadoVisual;
            String diasTexto;
            
            if (diasHastaVencimiento < 0) {
                // Vencido
                estadoVisual = "vencido";
                long diasVencido = Math.abs(diasHastaVencimiento);
                diasTexto = "Vencido hace " + diasVencido + " día" + (diasVencido == 1 ? "" : "s");
            } else if (diasHastaVencimiento == 0) {
                // Vence hoy
                estadoVisual = "hoy";
                diasTexto = "Vence hoy";
            } else if (diasHastaVencimiento <= 2) {
                // Próximo a vencer (1-2 días)
                estadoVisual = "proximo";
                diasTexto = "Vence en " + diasHastaVencimiento + " día" + (diasHastaVencimiento == 1 ? "" : "s");
            } else {
                // Activo normal
                estadoVisual = "activo";
                diasTexto = "Vence en " + diasHastaVencimiento + " días";
            }
            
            prestamo.put("estadoVisual", estadoVisual);
            prestamo.put("diasTexto", diasTexto);
            prestamosActivos.add(prestamo);
        }
    } catch (Exception e) {
        System.out.println("Error al cargar préstamos: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar recursos: " + e.getMessage());
        }
    }
    
    // Contar préstamos por estado
    long prestamosVencidos = prestamosActivos.stream()
        .filter(p -> "vencido".equals(p.get("estadoVisual")))
        .count();
    
    long prestamosProximos = prestamosActivos.stream()
        .filter(p -> "proximo".equals(p.get("estadoVisual")) || "hoy".equals(p.get("estadoVisual")))
        .count();
%>

<%@ include file="navbar.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Préstamos Activos - Biblioteca</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .mensaje {
            padding: 15px;
            margin: 20px 0;
            border-radius: 6px;
            font-weight: bold;
            border: 1px solid;
        }
        .mensaje.success {
            background-color: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }
        .mensaje.error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        .mensaje.warning {
            background-color: #fff3cd;
            color: #856404;
            border-color: #ffeaa7;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .stat-card.warning {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .stat-card.danger {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .estado-activo {
            color: #28a745;
            font-weight: bold;
        }
        
        .estado-proximo {
            color: #ffc107;
            font-weight: bold;
        }
        
        .estado-hoy {
            color: #fd7e14;
            font-weight: bold;
        }
        
        .estado-vencido {
            color: #dc3545;
            font-weight: bold;
        }
        
        .btn-devolver {
            background-color: #28a745;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: background-color 0.3s;
        }
        
        .btn-devolver:hover {
            background-color: #218838;
        }
        
        .table-responsive {
            overflow-x: auto;
        }
        
        .table th {
            background-color: #f8f9fa;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        .filter-container {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        
        .filter-row {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .filter-group label {
            font-size: 12px;
            font-weight: bold;
            color: #666;
        }
        
        .filter-input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
    </style>
</head>
<body>
<div class="main-content">
    <div class="container">
        <!-- Estadísticas rápidas -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number"><%= prestamosActivos.size() %></div>
                <div>Total Préstamos Activos</div>
            </div>
            <div class="stat-card warning">
                <div class="stat-number"><%= prestamosProximos %></div>
                <div>Próximos a Vencer</div>
            </div>
            <div class="stat-card danger">
                <div class="stat-number"><%= prestamosVencidos %></div>
                <div>Préstamos Vencidos</div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h1><i class="fas fa-list"></i> Préstamos Activos</h1>
                <p>Gestión y seguimiento de todos los préstamos en curso</p>
            </div>
            
            <% if (!mensaje.equals("")) { %>
                <div class="mensaje <%= tipoMensaje %>">
                    <i class="fas fa-<%= tipoMensaje.equals("success") ? "check-circle" : tipoMensaje.equals("warning") ? "exclamation-triangle" : "times-circle" %>"></i>
                    <%= mensaje %>
                </div>
            <% } %>
            
            <!-- Filtros -->
            <div class="filter-container">
                <div class="filter-row">
                    <div class="filter-group">
                        <label>Buscar Usuario:</label>
                        <input type="text" id="filtroUsuario" class="filter-input" placeholder="Nombre o cédula...">
                    </div>
                    <div class="filter-group">
                        <label>Buscar Libro:</label>
                        <input type="text" id="filtroLibro" class="filter-input" placeholder="Título o autor...">
                    </div>
                    <div class="filter-group">
                        <label>Estado:</label>
                        <select id="filtroEstado" class="filter-input">
                            <option value="">Todos</option>
                            <option value="activo">Activos</option>
                            <option value="proximo">Próximos a vencer</option>
                            <option value="hoy">Vencen hoy</option>
                            <option value="vencido">Vencidos</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>&nbsp;</label>
                        <button onclick="limpiarFiltros()" class="btn" style="background-color: #6c757d;">
                            <i class="fas fa-eraser"></i> Limpiar
                        </button>
                    </div>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table" id="tablaPrestamos">
                    <thead>
                        <tr>
                            <th>Usuario</th>
                            <th>Libro</th>
                            <th>Fecha Préstamo</th>
                            <th>Fecha Límite</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        if (prestamosActivos.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="6" style="text-align: center; padding: 40px;">
                                    <i class="fas fa-inbox" style="font-size: 3rem; color: #ccc; margin-bottom: 15px;"></i>
                                    <p style="color: #666; font-size: 1.1rem;">No hay préstamos activos en este momento</p>
                                    <a href="prestamosRegistro.jsp" class="btn">
                                        <i class="fas fa-plus"></i> Registrar Nuevo Préstamo
                                    </a>
                                </td>
                            </tr>
                        <% 
                        } else {
                            for (Map<String, Object> prestamo : prestamosActivos) { 
                                String estadoVisual = (String) prestamo.get("estadoVisual");
                        %>
                        <tr data-estado="<%= estadoVisual %>" data-usuario="<%= prestamo.get("usuario") %> <%= prestamo.get("cedula") %>" data-libro="<%= prestamo.get("libro") %>">
                            <td>
                                <strong><%= prestamo.get("usuario") %></strong><br>
                                <small style="color: #666;">CC <%= prestamo.get("cedula") %></small>
                            </td>
                            <td><%= prestamo.get("libro") %></td>
                            <td><%= prestamo.get("fechaPrestamo") %></td>
                            <td><%= prestamo.get("fechaLimite") %></td>
                            <td>
                                <span class="estado-<%= estadoVisual %>">
                                    <i class="fas fa-<%= estadoVisual.equals("vencido") ? "exclamation-triangle" : 
                                        estadoVisual.equals("hoy") ? "clock" :
                                        estadoVisual.equals("proximo") ? "hourglass-half" : "check-circle" %>"></i>
                                    <%= prestamo.get("diasTexto") %>
                                </span>
                            </td>
                            <td>
                                <form method="post" style="display: inline;" onsubmit="return confirmarDevolucion('<%= prestamo.get("usuario") %>', '<%= prestamo.get("libro") %>')">
                                    <input type="hidden" name="prestamoId" value="<%= prestamo.get("id") %>">
                                    <input type="hidden" name="accion" value="devolver">
                                    <button type="submit" class="btn-devolver" title="Registrar devolución">
                                        <i class="fas fa-undo"></i> Devolver
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <% 
                            } 
                        } 
                        %>
                    </tbody>
                </table>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
                <a href="prestamosRegistro.jsp" class="btn">
                    <i class="fas fa-plus"></i> Registrar Nuevo Préstamo
                </a>
                <button onclick="window.print()" class="btn" style="background-color: #17a2b8; margin-left: 10px;">
                    <i class="fas fa-print"></i> Imprimir Lista
                </button>
            </div>
        </div>
    </div>
</div>

<script>
function confirmarDevolucion(usuario, libro) {
    return confirm('¿Confirma la devolución del préstamo?\n\nUsuario: ' + usuario + '\nLibro: ' + libro + '\n\nEsta acción no se puede deshacer.');
}

document.getElementById('filtroUsuario').addEventListener('input', aplicarFiltros);
document.getElementById('filtroLibro').addEventListener('input', aplicarFiltros);
document.getElementById('filtroEstado').addEventListener('change', aplicarFiltros);

function aplicarFiltros() {
    const filtroUsuario = document.getElementById('filtroUsuario').value.toLowerCase();
    const filtroLibro = document.getElementById('filtroLibro').value.toLowerCase();
    const filtroEstado = document.getElementById('filtroEstado').value;
    
    const filas = document.querySelectorAll('#tablaPrestamos tbody tr');
    let filasVisibles = 0;
    
    filas.forEach(fila => {
        if (fila.cells.length === 1) return;
        
        const textoUsuario = fila.getAttribute('data-usuario') ? fila.getAttribute('data-usuario').toLowerCase() : '';
        const textoLibro = fila.getAttribute('data-libro') ? fila.getAttribute('data-libro').toLowerCase() : '';
        const estado = fila.getAttribute('data-estado');
        
        const coincideUsuario = !filtroUsuario || textoUsuario.includes(filtroUsuario);
        const coincideLibro = !filtroLibro || textoLibro.includes(filtroLibro);
        const coincideEstado = !filtroEstado || estado === filtroEstado;
        
        if (coincideUsuario && coincideLibro && coincideEstado) {
            fila.style.display = '';
            filasVisibles++;
        } else {
            fila.style.display = 'none';
        }
    });
    
    actualizarMensajeNoResultados(filasVisibles);
}

function actualizarMensajeNoResultados(filasVisibles) {
    let mensajeExistente = document.getElementById('mensaje-no-resultados');
    
    if (filasVisibles === 0) {
        if (!mensajeExistente) {
            const tbody = document.querySelector('#tablaPrestamos tbody');
            const fila = document.createElement('tr');
            fila.id = 'mensaje-no-resultados';
            fila.innerHTML = `
                <td colspan="6" style="text-align: center; padding: 20px; color: #666;">
                    <i class="fas fa-search"></i> No se encontraron préstamos que coincidan con los filtros
                </td>
            `;
            tbody.appendChild(fila);
        }
    } else {
        if (mensajeExistente) {
            mensajeExistente.remove();
        }
    }
}

function limpiarFiltros() {
    document.getElementById('filtroUsuario').value = '';
    document.getElementById('filtroLibro').value = '';
    document.getElementById('filtroEstado').value = '';
    aplicarFiltros();
}

// Opcional: Auto-refresh cada 5 minutos
setInterval(function() {
    if (confirm('¿Desea actualizar la lista de préstamos?')) {
        location.reload();
    }
}, 300000);
</script>

</body>
</html>