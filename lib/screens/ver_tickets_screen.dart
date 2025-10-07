import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'dart:io';

class VerTicketsScreen extends StatefulWidget {
  @override
  _VerTicketsScreenState createState() => _VerTicketsScreenState();
}

class _VerTicketsScreenState extends State<VerTicketsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Tickets'),
        actions: [
          // Botón de menú con opciones
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'eliminar_todos') {
                // Confirmar antes de eliminar todos
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text('¡ATENCIÓN!'),
                      ],
                    ),
                    content: Text(
                      '¿Estás seguro de eliminar TODOS los tickets?\n\nEsta acción no se puede deshacer.',
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('CANCELAR'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('ELIMINAR TODO'),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  await DatabaseService.eliminarTodosTickets();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Todos los tickets han sido eliminados'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'eliminar_todos',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar todos los tickets'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.obtenerTickets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text('No hay tickets registrados'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final ticket = snapshot.data![index];
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Dismissible(
                              key: Key(ticket['id'].toString()),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                // Mostrar diálogo de confirmación
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Confirmar Eliminación'),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('¿Estás seguro de eliminar este ticket?'),
                                        SizedBox(height: 10),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ticket #${ticket['id'].toString().padLeft(4, '0')}',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text('Usuario: ${ticket['grado']} ${ticket['nombre']}'),
                                              Text('Problema: ${ticket['tipo_problema']}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('CANCELAR'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text('ELIMINAR'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) async {
                                // Eliminar de la base de datos
                                await DatabaseService.eliminarTicket(ticket['id']);

                                // Mostrar mensaje
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Ticket eliminado'),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    action: SnackBarAction(
                                      label: 'Deshacer',
                                      textColor: Colors.white,
                                      onPressed: () async {
                                        // Restaurar el ticket (re-insertarlo)
                                        await DatabaseService.guardarTicket(ticket);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );

                                // Actualizar la lista
                                setState(() {});
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete, color: Colors.white, size: 30),
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              child: Card(
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: Theme.of(context).brightness == Brightness.dark
                                          ? [Color(0xFF2A2A2A), Color(0xFF1E1E1E)]
                                          : [Colors.white, Color(0xFFFAFAFA)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: ticket['confirmado'] == 1
                                              ? [Colors.green, Color(0xFF4CAF50)]
                                              : [Colors.orange, Colors.deepOrange],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ticket['confirmado'] == 1
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.orange.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        ticket['confirmado'] == 1
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      '${ticket['grado']} ${ticket['nombre']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.warning_amber, size: 14, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              ticket['tipo_problema'],
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              ticket['fecha'].substring(0, 10),
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Color(0xFF4A5D23)
                                            : Color(0xFF4A5D23).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '#${ticket['id'].toString().padLeft(4, '0')}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Color(0xFFD4AF37)
                                              : Color(0xFF4A5D23),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      // Mantén aquí el código existente del showDialog
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Row(
                                            children: [
                                              Icon(Icons.description, color: Colors.green),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Ticket #${ticket['id'].toString().padLeft(4, '0')}',
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // INFORMACIÓN DEL USUARIO
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.person, size: 16, color: Colors.blue),
                                                          SizedBox(width: 5),
                                                          Text('DATOS DEL USUARIO',
                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                      Divider(),
                                                      Text('👤 ${ticket['grado']} ${ticket['nombre']}'),
                                                      Text('💼 ${ticket['cargo']}'),
                                                      Text('🆔 Cédula: ${ticket['cedula_confirmacion'] ?? 'N/A'}'),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(height: 10),

                                                // INFORMACIÓN DEL PROBLEMA
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.warning, size: 16, color: Colors.red),
                                                          SizedBox(width: 5),
                                                          Text('PROBLEMA',
                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                      Divider(),
                                                      Text('Tipo: ${ticket['tipo_problema']}'),
                                                      SizedBox(height: 5),
                                                      Text(ticket['problema']),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(height: 10),

                                                // SOLUCIÓN
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                                                          SizedBox(width: 5),
                                                          Text('SOLUCIÓN',
                                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                      Divider(),
                                                      Text(ticket['solucion']),
                                                    ],
                                                  ),
                                                ),

                                                // MOSTRAR FOTOS SI EXISTEN
                                                if (ticket['foto_antes'] != null && ticket['foto_antes'] != '') ...[
                                                  SizedBox(height: 10),
                                                  Text('📸 EVIDENCIA FOTOGRÁFICA',
                                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      if (ticket['foto_antes'] != null && ticket['foto_antes'] != '')
                                                        Expanded(
                                                          child: Column(
                                                            children: [
                                                              Text('ANTES', style: TextStyle(fontSize: 12)),
                                                              Container(
                                                                height: 100,
                                                                margin: EdgeInsets.all(2),
                                                                child: Image.file(
                                                                  File(ticket['foto_antes']),
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return Container(
                                                                      color: Colors.grey[300],
                                                                      child: Icon(Icons.broken_image),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      if (ticket['foto_despues'] != null && ticket['foto_despues'] != '')
                                                        Expanded(
                                                          child: Column(
                                                            children: [
                                                              Text('DESPUÉS', style: TextStyle(fontSize: 12)),
                                                              Container(
                                                                height: 100,
                                                                margin: EdgeInsets.all(2),
                                                                child: Image.file(
                                                                  File(ticket['foto_despues']),
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return Container(
                                                                      color: Colors.grey[300],
                                                                      child: Icon(Icons.broken_image),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            // BOTONES DE ACCIÓN
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // Botón Eliminar - NUEVO
                                                IconButton(
                                                  onPressed: () async {
                                                    // Confirmar eliminación
                                                    bool? confirmar = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: Text('¿Eliminar este ticket?'),
                                                        content: Text('Esta acción no se puede deshacer.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: Text('Cancelar'),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red,
                                                            ),
                                                            child: Text('Eliminar'),
                                                          ),
                                                        ],
                                                      ),
                                                    );

                                                    if (confirmar == true) {
                                                      await DatabaseService.eliminarTicket(ticket['id']);
                                                      Navigator.pop(context); // Cerrar detalles
                                                      setState(() {}); // Actualizar lista
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Ticket eliminado'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: Icon(Icons.delete, color: Colors.red, size: 30),
                                                  tooltip: 'Eliminar',
                                                ),

                                                // Botón Ver PDF (existente)
                                                IconButton(
                                                  onPressed: () async {
                                                    await PdfService.generarPdfTicket(ticket);
                                                  },
                                                  icon: Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                                                  tooltip: 'Ver PDF',
                                                ),

                                                // Botón Compartir (existente)
                                                IconButton(
                                                  onPressed: () async {
                                                    final path = await PdfService.generarPdfTicket(ticket, abrir: false);
                                                    if (path != null) {
                                                      await PdfService.compartirPdf(path, ticket);
                                                    }
                                                  },
                                                  icon: Icon(Icons.share, color: Colors.green, size: 30),
                                                  tooltip: 'Compartir',
                                                ),

                                                // Botón Cerrar (existente)
                                                IconButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  icon: Icon(Icons.close, color: Colors.grey, size: 30),
                                                  tooltip: 'Cerrar',
                                                ),
                                              ],
                                            ),
                                          ],                                  ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (snapshot.data!.isNotEmpty && snapshot.data!.length <= 3)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swipe_left, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Desliza un ticket hacia la izquierda para eliminarlo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}