import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class PdfService {

  // Cargar imagen del escudo desde assets
  static Future<pw.ImageProvider?> cargarEscudo() async {
    try {
      final data = await rootBundle.load('assets/images/escudo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      print('Error cargando escudo: $e');
      return null;
    }
  }

  // Crear encabezado institucional con escudo centrado
  static Future<pw.Widget> crearEncabezadoInstitucional() async {
    final escudo = await cargarEscudo();

    return pw.Column(
      children: [
        // Escudo centrado
        if (escudo != null)
          pw.Container(
            width: 80,
            height: 100,
            child: pw.Image(escudo, fit: pw.BoxFit.contain),
          ),

        pw.SizedBox(height: 15),

        // Textos institucionales
        pw.Text(
          'REPÚBLICA DEL ECUADOR',
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey700,
            letterSpacing: 1.5,
          ),
        ),

        pw.SizedBox(height: 8),

        pw.Text(
          'UNIDAD EDUCATIVA DE FUERZAS ARMADAS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
          textAlign: pw.TextAlign.center,
        ),

        pw.SizedBox(height: 5),

        pw.Text(
          'COLEGIO MILITAR Nº 6 "COMBATIENTES DE TAPI"',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey800,
          ),
        ),

        pw.SizedBox(height: 15),

        // Línea divisoria elegante
        pw.Container(
          height: 2,
          width: 200,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [PdfColors.grey300, PdfColors.grey800, PdfColors.grey300],
            ),
          ),
        ),
      ],
    );
  }

  static Future<String?> generarPdfTicket(Map<String, dynamic> ticket, {bool abrir = true}) async {
    final pdf = pw.Document();

    // Formatear fecha
    DateTime fecha = DateTime.parse(ticket['fecha']);
    String fechaFormateada = DateFormat('dd \'de\' MMMM \'del\' yyyy').format(fecha);
    String horaFormateada = DateFormat('HH:mm').format(fecha);

    // Cargar imágenes de fotos si existen
    pw.ImageProvider? imagenAntes;
    pw.ImageProvider? imagenDespues;

    if (ticket['foto_antes'] != null && ticket['foto_antes'] != '') {
      try {
        final fileAntes = File(ticket['foto_antes']);
        if (await fileAntes.exists()) {
          final bytes = await fileAntes.readAsBytes();
          imagenAntes = pw.MemoryImage(bytes);
          print('✅ Foto ANTES cargada: ${ticket['foto_antes']}');
        } else {
          print('⚠️ Archivo foto ANTES no existe: ${ticket['foto_antes']}');
        }
      } catch (e) {
        print('❌ Error cargando foto antes: $e');
      }
    }

    if (ticket['foto_despues'] != null && ticket['foto_despues'] != '') {
      try {
        final fileDespues = File(ticket['foto_despues']);
        if (await fileDespues.exists()) {
          final bytes = await fileDespues.readAsBytes();
          imagenDespues = pw.MemoryImage(bytes);
          print('✅ Foto DESPUÉS cargada: ${ticket['foto_despues']}');
        } else {
          print('⚠️ Archivo foto DESPUÉS no existe: ${ticket['foto_despues']}');
        }
      } catch (e) {
        print('❌ Error cargando foto después: $e');
      }
    }

    // Obtener el encabezado
    final encabezado = await crearEncabezadoInstitucional();

    // Crear página del PDF usando MultiPage para mejor manejo de espacio
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (pw.Context context) {
          return [
            // ENCABEZADO INSTITUCIONAL CENTRADO
            pw.Center(child: encabezado),

            pw.SizedBox(height: 25),

            // TÍTULO DEL DOCUMENTO
            pw.Center(
              child: pw.Text(
                'REPORTE DE SOPORTE TÉCNICO',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            // Número de Ticket
            pw.Center(
              child: pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  'TICKET: ${ticket['numero_ticket'] ?? 'N/A'}',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
              ),
            ),

            pw.SizedBox(height: 25),

            // CONTENIDO EN SECCIONES UNIFORMES

            // SECCIÓN 1: INFORMACIÓN GENERAL
            _crearSeccion(
              'INFORMACIÓN GENERAL',
              [
                _crearFilaInfo('Fecha de atención:', fechaFormateada),
                _crearFilaInfo('Hora de atención:', horaFormateada),
                _crearFilaInfo('Técnico responsable:', 'Analista TICs - Soporte Técnico'),
              ],
            ),

            pw.SizedBox(height: 15),

            // SECCIÓN 2: DATOS DEL USUARIO
            _crearSeccion(
              'DATOS DEL USUARIO',
              [
                _crearFilaInfo('Grado/Título:', ticket['grado'] ?? ''),
                _crearFilaInfo('Nombre completo:', ticket['nombre'] ?? ''),
                _crearFilaInfo('Cargo:', ticket['cargo'] ?? ''),
              ],
            ),

            pw.SizedBox(height: 15),

            // SECCIÓN 3: DETALLE DEL PROBLEMA
            _crearSeccion(
              'DETALLE DEL PROBLEMA',
              [
                _crearFilaInfo('Tipo de problema:', ticket['tipo_problema'] ?? ''),
                _crearFilaInfo('Descripción:', ticket['problema'] ?? '', esTextoLargo: true),
              ],
            ),

            pw.SizedBox(height: 15),

            // SECCIÓN 4: SOLUCIÓN APLICADA
            _crearSeccion(
              'SOLUCIÓN APLICADA',
              [
                _crearFilaInfo('Acciones realizadas:', ticket['solucion'] ?? '', esTextoLargo: true),
                _crearFilaInfo('Estado:', 'RESUELTO Y COMPLETADO'),
              ],
            ),

            pw.SizedBox(height: 15),

            // SECCIÓN 5: CONFIRMACIÓN DE RECEPCIÓN
            _crearSeccion(
              'CONFIRMACIÓN DE RECEPCIÓN',
              [
                _crearFilaInfo('Método de confirmación:', 'Cédula de Identidad'),
                _crearFilaInfo('Documento:', ticket['cedula_confirmacion'] ?? 'N/A'),
                _crearFilaInfo('Estado de conformidad:', 'SERVICIO RECIBIDO CONFORME'),
              ],
            ),

            pw.SizedBox(height: 20),

            // EVIDENCIA FOTOGRÁFICA (si existe)
            if (imagenAntes != null || imagenDespues != null) ...[
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EVIDENCIA FOTOGRÁFICA',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        if (imagenAntes != null)
                          pw.Column(
                            children: [
                              pw.Text(
                                'ANTES',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Container(
                                width: 200,
                                height: 150,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.grey400),
                                ),
                                child: pw.Image(imagenAntes, fit: pw.BoxFit.cover),
                              ),
                            ],
                          ),
                        if (imagenDespues != null)
                          pw.Column(
                            children: [
                              pw.Text(
                                'DESPUÉS',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Container(
                                width: 200,
                                height: 150,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.grey400),
                                ),
                                child: pw.Image(imagenDespues, fit: pw.BoxFit.cover),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
            ],

            // SECCIÓN DE FIRMAS - Siempre visible
            pw.Container(
              margin: pw.EdgeInsets.only(top: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _crearCampoFirma(
                    'USUARIO',
                    '${ticket['grado']} ${ticket['nombre']}',
                    'C.I. ${ticket['cedula_confirmacion']}',
                  ),
                  _crearCampoFirma(
                    'TÉCNICO DE SOPORTE',
                    'Analista TICs',
                    'Dpto. Tecnología',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),
          ];
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Text(
                'Departamento de Tecnología - UEFC - Riobamba, Ecuador',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    // Guardar y abrir PDF
    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/ticket_${ticket['numero_ticket']}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (abrir) {
        await OpenFile.open(file.path);
      }

      return file.path;
    } catch (e) {
      print('Error al generar PDF: $e');
      return null;
    }
  }

  // Función auxiliar para crear secciones uniformes
  static pw.Widget _crearSeccion(String titulo, List<pw.Widget> contenido) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey300, height: 1),
          pw.SizedBox(height: 10),
          ...contenido,
        ],
      ),
    );
  }

  // Función auxiliar para crear filas de información
  static pw.Widget _crearFilaInfo(String label, String value, {bool esTextoLargo = false}) {
    if (esTextoLargo) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 8),
        ],
      );
    }

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para campos de firma
  static pw.Widget _crearCampoFirma(String titulo, String nombre, String cargo) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 50,
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                color: PdfColors.grey600,
                width: 1,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          nombre,
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColors.black,
          ),
        ),
        pw.Text(
          cargo,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Función para generar reporte mensual
  static Future<void> generarReporteMensual(List<Map<String, dynamic>> tickets) async {
    final pdf = pw.Document();
    String mesActual = DateFormat('MMMM yyyy').format(DateTime.now());

    // Calcular estadísticas
    int totalTickets = tickets.length;
    int confirmados = tickets.where((t) => t['confirmado'] == 1).length;
    double porcentaje = totalTickets > 0 ? (confirmados / totalTickets) * 100 : 0;

    final encabezado = await crearEncabezadoInstitucional();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (pw.Context context) {
          return [
            // Encabezado
            encabezado,

            pw.SizedBox(height: 25),

            pw.Text(
              'REPORTE MENSUAL DE SOPORTE TÉCNICO',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                mesActual.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),

            pw.SizedBox(height: 25),

            // Resumen estadístico
            pw.Container(
              padding: pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _crearEstadistica('TOTAL', totalTickets.toString()),
                  _crearEstadistica('CONFIRMADOS', confirmados.toString()),
                  _crearEstadistica('PENDIENTES', (totalTickets - confirmados).toString()),
                  _crearEstadistica('EFECTIVIDAD', '${porcentaje.toStringAsFixed(1)}%'),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Tabla de tickets
            pw.Text(
              'DETALLE DE TICKETS',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Encabezado
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _celdaTabla('ID', esEncabezado: true),
                    _celdaTabla('Fecha', esEncabezado: true),
                    _celdaTabla('Usuario', esEncabezado: true),
                    _celdaTabla('Tipo', esEncabezado: true),
                    _celdaTabla('Estado', esEncabezado: true),
                  ],
                ),
                // Datos
                ...tickets.map((ticket) {
                  DateTime fecha = DateTime.parse(ticket['fecha']);
                  String fechaCorta = DateFormat('dd/MM/yy').format(fecha);
                  return pw.TableRow(
                    children: [
                      _celdaTabla(ticket['id'].toString()),
                      _celdaTabla(fechaCorta),
                      _celdaTabla('${ticket['grado']} ${ticket['nombre']}'),
                      _celdaTabla(ticket['tipo_problema']),
                      _celdaTabla(ticket['confirmado'] == 1 ? '✓' : '○'),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 30),

            // Pie de página
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 10),
            pw.Text(
              'Departamento de Tecnología - UEFC - Riobamba, Ecuador',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    // Guardar y abrir
    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/reporte_mensual.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error al generar reporte: $e');
    }
  }

  // Función auxiliar para estadísticas
  static pw.Widget _crearEstadistica(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  // Función auxiliar para celdas de tabla
  static pw.Widget _celdaTabla(String texto, {bool esEncabezado = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: esEncabezado ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: esEncabezado ? PdfColors.grey800 : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Funciones de compartir (se mantienen igual)
  static Future<void> compartirPdf(String filePath, Map<String, dynamic> ticket) async {
    try {
      String mensaje = '''
🔧 SOPORTE TÉCNICO UEFC
━━━━━━━━━━━━━━━━━━━━
📋 Ticket: ${ticket['numero_ticket']}
👤 Usuario: ${ticket['grado']} ${ticket['nombre']}
🔴 Problema: ${ticket['tipo_problema']}
✅ Estado: RESUELTO
📅 Fecha: ${DateTime.parse(ticket['fecha']).day}/${DateTime.parse(ticket['fecha']).month}/${DateTime.parse(ticket['fecha']).year}
━━━━━━━━━━━━━━━━━━━━
UEFC - Colegio Militar Nº6
"Combatientes de Tapi"
Riobamba - Ecuador
    ''';

      await Share.shareXFiles(
        [XFile(filePath)],
        text: mensaje,
        subject: 'Ticket Soporte ${ticket['numero_ticket']} - UEFC',
      );
    } catch (e) {
      print('Error al compartir: $e');
    }
  }

  static Future<void> compartirReporteMensual(List<Map<String, dynamic>> tickets) async {
    try {
      // Generar el PDF primero
      final pdf = pw.Document();
      String mesActual = DateFormat('MMMM yyyy').format(DateTime.now());

      final encabezado = await crearEncabezadoInstitucional();

      // Generar contenido (copiar lógica de generarReporteMensual)
      // ... código para generar PDF ...

      // Guardar archivo temporal
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/reporte_mensual_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      String mensaje = '''
📊 REPORTE MENSUAL - SOPORTE TÉCNICO
━━━━━━━━━━━━━━━━━━━━
🏫 UEFC - Colegio Militar Nº6
📅 Mes: $mesActual
📈 Total Tickets: ${tickets.length}
✅ Confirmados: ${tickets.where((t) => t['confirmado'] == 1).length}
━━━━━━━━━━━━━━━━━━━━
Departamento de Tecnología
Riobamba - Ecuador
    ''';

      await Share.shareXFiles(
        [XFile(file.path)],
        text: mensaje,
        subject: 'Reporte Mensual Soporte UEFC - $mesActual',
      );
    } catch (e) {
      print('Error al compartir reporte: $e');
    }
  }
}