import 'package:flutter/material.dart';
import '../services/database_service.dart';

class EstadisticasCard extends StatefulWidget {
  @override
  _EstadisticasCardState createState() => _EstadisticasCardState();
}

class _EstadisticasCardState extends State<EstadisticasCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  int ticketsHoy = 0;
  int ticketsSemana = 0;
  int ticketsMes = 0;
  double porcentajeConfirmados = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _cargarEstadisticas();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarEstadisticas() async {
    final tickets = await DatabaseService.obtenerTickets();
    final ahora = DateTime.now();
    final inicioHoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicioSemana = ahora.subtract(Duration(days: 7));
    final inicioMes = DateTime(ahora.year, ahora.month, 1);

    setState(() {
      ticketsHoy = tickets.where((t) {
        final fecha = DateTime.parse(t['fecha']);
        return fecha.isAfter(inicioHoy);
      }).length;

      ticketsSemana = tickets.where((t) {
        final fecha = DateTime.parse(t['fecha']);
        return fecha.isAfter(inicioSemana);
      }).length;

      ticketsMes = tickets.where((t) {
        final fecha = DateTime.parse(t['fecha']);
        return fecha.isAfter(inicioMes);
      }).length;

      if (tickets.isNotEmpty) {
        int confirmados = tickets.where((t) => t['confirmado'] == 1).length;
        porcentajeConfirmados = (confirmados / tickets.length) * 100;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: esOscuro
                ? [Color(0xFF1E1E1E), Color(0xFF2A2A2A)]
                : [Colors.white, Color(0xFFF5F5F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: esOscuro ? Colors.black45 : Colors.grey.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: esOscuro ? Color(0xFFD4AF37) : Color(0xFF4A5D23),
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  'Estadísticas Rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: esOscuro ? Color(0xFFD4AF37) : Color(0xFF4A5D23),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Grid de estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'HOY',
                  ticketsHoy.toString(),
                  Icons.today,
                  Colors.blue,
                ),
                _buildStatItem(
                  'SEMANA',
                  ticketsSemana.toString(),
                  //Icons.calendar_week,
                  Icons.date_range,
                  Colors.green,
                ),
                _buildStatItem(
                  'MES',
                  ticketsMes.toString(),
                  Icons.calendar_month,
                  Colors.orange,
                ),
                _buildStatItem(
                  'CONFIRMADOS',
                  '${porcentajeConfirmados.toStringAsFixed(0)}%',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ],
            ),

            SizedBox(height: 15),

            // Barra de progreso visual
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: esOscuro ? Colors.grey[800] : Colors.grey[300],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: porcentajeConfirmados / 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A5D23), Color(0xFFD4AF37)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: esOscuro ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: esOscuro ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}