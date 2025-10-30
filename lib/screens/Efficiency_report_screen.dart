import 'package:flutter/material.dart';

class EfficiencyReportScreen extends StatelessWidget {
  final String sport;
  final Map<String, int> statsCount;
  final Duration duration;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;

  const EfficiencyReportScreen({
    Key? key,
    required this.sport,
    required this.statsCount,
    required this.duration,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
  }) : super(key: key);

  // Calcular la eficiencia basada en las estadísticas
  double _calculateEfficiency() {
    if (statsCount.isEmpty) return 0;

    // Diferentes pesos para diferentes estadísticas
    final weights = {
      'Goles': 5.0,
      'Asistencias': 3.0,
      'Regates': 1.0,
      'Pases': 0.2,
      'Tiros a puerta': 0.5,
      'Faltas': -0.5,
      'Tarjetas': -2.0,
    };

    double totalPoints = 0;
    int totalStats = 0;

    statsCount.forEach((stat, count) {
      final weight = weights[stat] ?? 1.0;
      totalPoints += count * weight;
      totalStats += count;
    });

    // Normalizar a una escala de 0-100
    double efficiency = (totalPoints / (totalStats > 0 ? totalStats : 1)) * 20;

    // Limitar entre 0 y 100
    return efficiency.clamp(0, 100);
  }

  // Obtener color basado en la eficiencia
  Color _getEfficiencyColor(double efficiency) {
    if (efficiency >= 80) return Colors.green;
    if (efficiency >= 60) return Colors.lightGreen;
    if (efficiency >= 40) return Colors.amber;
    if (efficiency >= 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final efficiency = _calculateEfficiency();
    final efficiencyColor = _getEfficiencyColor(efficiency);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Volver a la pantalla de inicio
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: const Text(
          'Reporte de Eficiencia',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              // Compartir reporte
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartiendo reporte...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de resultado del partido
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Partido de $sport',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  team1Name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  team1Score.toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  team2Name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  team2Score.toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Duración: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tarjeta de eficiencia
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Media de Eficiencia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: efficiency / 100,
                              strokeWidth: 15,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                efficiencyColor,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${efficiency.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: efficiencyColor,
                                ),
                              ),
                              Text(
                                _getEfficiencyLabel(efficiency),
                                style: TextStyle(
                                  color: efficiencyColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getEfficiencyDescription(efficiency),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Estadísticas detalladas
              const Text(
                'Estadísticas Detalladas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A4256),
                ),
              ),
              const SizedBox(height: 12),

              // Gráfico de barras de estadísticas
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...statsCount.entries.map((entry) {
                        final maxValue =
                            statsCount.values
                                .reduce((a, b) => a > b ? a : b)
                                .toDouble();
                        final percentage =
                            maxValue > 0 ? (entry.value / maxValue) : 0.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getStatColor(entry.key),
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Guardar reporte
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reporte guardado')),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D5AF1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Volver a la pantalla de inicio
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Inicio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3D5AF1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFF3D5AF1)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEfficiencyLabel(double efficiency) {
    if (efficiency >= 80) return 'Excelente';
    if (efficiency >= 60) return 'Muy Bueno';
    if (efficiency >= 40) return 'Bueno';
    if (efficiency >= 20) return 'Regular';
    return 'Necesita Mejorar';
  }

  String _getEfficiencyDescription(double efficiency) {
    if (efficiency >= 80) {
      return 'Rendimiento excepcional. Mantén este nivel de juego.';
    }
    if (efficiency >= 60) {
      return 'Muy buen desempeño. Sigue trabajando para mejorar.';
    }
    if (efficiency >= 40) {
      return 'Buen rendimiento. Hay áreas específicas que puedes mejorar.';
    }
    if (efficiency >= 20) {
      return 'Rendimiento regular. Enfócate en mejorar aspectos clave del juego.';
    }
    return 'Necesitas trabajar en los fundamentos. No te desanimes.';
  }

  Color _getStatColor(String stat) {
    switch (stat) {
      case 'Goles':
        return Colors.green;
      case 'Asistencias':
        return Colors.blue;
      case 'Regates':
        return Colors.purple;
      case 'Pases':
        return Colors.teal;
      case 'Tiros a puerta':
        return Colors.orange;
      case 'Faltas':
        return Colors.red;
      case 'Tarjetas':
        return Colors.deepOrange;
      default:
        return const Color(0xFF3D5AF1);
    }
  }
}
