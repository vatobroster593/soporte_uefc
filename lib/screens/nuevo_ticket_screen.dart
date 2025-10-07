import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NuevoTicketScreen extends StatefulWidget {
  @override
  _NuevoTicketScreenState createState() => _NuevoTicketScreenState();
}

class _NuevoTicketScreenState extends State<NuevoTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _nombreController = TextEditingController();
  final _cargoController = TextEditingController();
  final _problemaController = TextEditingController();
  final _solucionController = TextEditingController();

  // Variables para las fotos
  File? _fotoAntes;
  File? _fotoDespues;
  final ImagePicker _picker = ImagePicker();

  String _gradoSeleccionado = 'Señor/a';
  String _tipoProblema = 'Hardware';

  final List<String> grados = [
    'Master',
    'Doctor/a',
    'Ingeniero/a',
    'Licenciado/a',
    'Señor/a',
    'Coronel',
    'Teniente Coronel',
    'Mayor',
    'Capitán',
    'Teniente',
    'Subteniente',
    'Sargento Primero',
    'Sargento Segundo',
    'Cabo Primero',
    'Cabo Segundo',
    'Soldado',
  ];

  final List<String> tiposProblema = [
    'Hardware',
    'Software',
    'Red',
    'Impresora',
    'Contraseña',
    'Otro',
  ];

  // Función para tomar foto ANTES
  Future<void> _tomarFotoAntes() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Comprimir para ahorrar espacio
    );

    if (foto != null) {
      // Guardar en directorio permanente de la app
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'foto_antes_$timestamp.jpg';
      final String permanentPath = path.join(appDir.path, 'fotos', fileName);

      // Crear directorio si no existe
      final Directory fotosDir = Directory(path.join(appDir.path, 'fotos'));
      if (!await fotosDir.exists()) {
        await fotosDir.create(recursive: true);
      }

      // Copiar archivo a ubicación permanente
      final File permanentFile = await File(foto.path).copy(permanentPath);

      setState(() {
        _fotoAntes = permanentFile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Foto ANTES capturada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

// Función para tomar foto DESPUÉS
  Future<void> _tomarFotoDespues() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (foto != null) {
      // Guardar en directorio permanente de la app
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'foto_despues_$timestamp.jpg';
      final String permanentPath = path.join(appDir.path, 'fotos', fileName);

      // Crear directorio si no existe
      final Directory fotosDir = Directory(path.join(appDir.path, 'fotos'));
      if (!await fotosDir.exists()) {
        await fotosDir.create(recursive: true);
      }

      // Copiar archivo a ubicación permanente
      final File permanentFile = await File(foto.path).copy(permanentPath);

      setState(() {
        _fotoDespues = permanentFile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Foto DESPUÉS capturada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Ticket'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'DATOS DEL USUARIO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Campo Nombre
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el nombre';
                }
                return null;
              },
            ),
            SizedBox(height: 10),

            // Dropdown Grado
            DropdownButtonFormField<String>(
              value: _gradoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Grado/Título',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.military_tech),
              ),
              items: grados.map((String grado) {
                return DropdownMenuItem(
                  value: grado,
                  child: Text(grado),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _gradoSeleccionado = newValue!;
                });
              },
            ),
            SizedBox(height: 10),

            // Campo Cargo
            TextFormField(
              controller: _cargoController,
              decoration: InputDecoration(
                labelText: 'Cargo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el cargo';
                }
                return null;
              },
            ),

            SizedBox(height: 20),
            Divider(),

            Text(
              'DETALLES DEL PROBLEMA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Tipo de Problema
            DropdownButtonFormField<String>(
              value: _tipoProblema,
              decoration: InputDecoration(
                labelText: 'Tipo de Problema',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
              ),
              items: tiposProblema.map((String tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _tipoProblema = newValue!;
                });
              },
            ),
            SizedBox(height: 10),

            // Descripción del Problema
            TextFormField(
              controller: _problemaController,
              decoration: InputDecoration(
                labelText: 'Descripción del Problema',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor describa el problema';
                }
                return null;
              },
            ),
            SizedBox(height: 10),

// SECCIÓN DE FOTOS
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📸 EVIDENCIA FOTOGRÁFICA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        // Botón Foto ANTES
                        Expanded(
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _tomarFotoAntes,
                                icon: Icon(Icons.camera_alt),
                                label: Text('Foto ANTES'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                              if (_fotoAntes != null)
                                Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.orange, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _fotoAntes!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _fotoAntes = null;
                                        });
                                      },
                                      child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // Botón Foto DESPUÉS
                        Expanded(
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _tomarFotoDespues,
                                icon: Icon(Icons.camera_alt),
                                label: Text('Foto DESPUÉS'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              if (_fotoDespues != null)
                                Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.green, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _fotoDespues!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _fotoDespues = null;
                                        });
                                      },
                                      child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
// ========== FIN DE SECCIÓN FOTOS ==========

            // Solución Aplicada
            TextFormField(
              controller: _solucionController,
              decoration: InputDecoration(
                labelText: 'Solución Aplicada',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor describa la solución';
                }
                return null;
              },
            ),

            SizedBox(height: 30),

            // Botón Guardar
            ElevatedButton(
              onPressed: _guardarTicket,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'SOLICITAR CONFIRMACIÓN',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),

            SizedBox(height: 20),

            // Indicador de ayuda
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recuerda solicitar la cédula al usuario para confirmar el soporte',
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
        ),
      ),
    );
  }

  void _guardarTicket() {
    if (_formKey.currentState!.validate()) {
      // Mostrar diálogo para confirmación con cédula
      final _cedulaConfirmacionController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Confirmación del Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'El usuario debe ingresar su CÉDULA para confirmar que recibió el soporte:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _cedulaConfirmacionController,
                decoration: InputDecoration(
                  labelText: 'Número de Cédula',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fingerprint),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_cedulaConfirmacionController.text.length >= 10) {
                  // Generar número de ticket con nuevo formato
                  String numeroTicket = await DatabaseService.generarNumeroTicket();

                  // Guardar en base de datos
                  await DatabaseService.guardarTicket({
                    'numero_ticket': numeroTicket,
                    'cedula_confirmacion': _cedulaConfirmacionController.text,
                    'nombre': _nombreController.text,
                    'grado': _gradoSeleccionado,
                    'cargo': _cargoController.text,
                    'tipo_problema': _tipoProblema,
                    'problema': _problemaController.text,
                    'solucion': _solucionController.text,
                    'fecha': DateTime.now().toString(),
                    'confirmado': 1,
                    'foto_antes': _fotoAntes?.path ?? '',
                    'foto_despues': _fotoDespues?.path ?? '',
                  });

                  // Cerrar el diálogo de confirmación
                  Navigator.pop(context);

                  // Obtener el ticket recién guardado para compartir
                  final tickets = await DatabaseService.obtenerTickets();
                  final ticketGuardado = tickets.first;

                  // Mostrar opciones después de guardar
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('¡Ticket Guardado!'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Ticket $numeroTicket guardado exitosamente.'),
                          SizedBox(height: 10),
                          Text('¿Deseas compartir el reporte?'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Método simple: cerrar todo hasta la primera pantalla
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: Text('No, gracias'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Cerrar el diálogo
                            Navigator.of(context).pop();

                            // Compartir PDF
                            final path = await PdfService.generarPdfTicket(ticketGuardado, abrir: false);
                            if (path != null) {
                              await PdfService.compartirPdf(path, ticketGuardado);
                            }

                            // Volver al inicio
                            await Future.delayed(Duration(milliseconds: 500));
                            if (mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          },
                          icon: Icon(Icons.share),
                          label: Text('Compartir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⚠️ La cédula debe tener al menos 10 dígitos'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text('Confirmar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      );
    }
  }

}