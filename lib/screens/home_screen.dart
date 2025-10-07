import 'package:flutter/material.dart';
import '../main.dart';
import 'nuevo_ticket_screen.dart';
import 'ver_tickets_screen.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../widgets/estadisticas_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TICS COMIL6'),
        centerTitle: true,
        actions: [
          // AGREGAR BOTÓN DE TEMA
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              MyApp.of(context)?.cambiarTema();
            },
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Color(0xFF1A1A1A), Color(0xFF2A2A2A)]
                : [Color(0xFFF5F5F0), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo con animación
              Hero(
                tag: 'logo',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF2C3E1D)
                        : Color(0xFF4A5D23),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.support_agent,
                    size: 60,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFFD4AF37)
                        : Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Soporte - Rodrigo Vinueza',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFFD4AF37)
                      : Color(0xFF4A5D23),
                ),
              ),

              // ESTADÍSTICAS CARD
              EstadisticasCard(),

              SizedBox(height: 40),

              // Botón Nuevo Ticket con nuevo estilo
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A5D23), Color(0xFF5C743F)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4A5D23).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add_circle, size: 28),
                  label: Text('NUEVO REGISTRO', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NuevoTicketScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Botón Ver Tickets
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.history, size: 28),
                  label: Text('VER TICKETS', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerTicketsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Botón Reporte con nuevo estilo
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.picture_as_pdf, size: 28),
                  label: Text('REPORTE MENSUAL', style: TextStyle(fontSize: 18)),
                  onPressed: () async {
                    // (mantén el código existente para el reporte)
                    final tickets = await DatabaseService.obtenerTickets();
                    if (tickets.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No hay tickets para generar reporte'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Reporte Mensual'),
                          content: Text('¿Qué deseas hacer con el reporte?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                PdfService.generarReporteMensual(tickets);
                              },
                              child: Text('Ver PDF'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                PdfService.compartirReporteMensual(tickets);
                              },
                              child: Text('Compartir'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}