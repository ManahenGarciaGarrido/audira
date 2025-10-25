import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/metrics_service.dart';
import '../../../data/services/auth_service.dart';

/// Pantalla completa de estadísticas de usuario
/// Muestra minutos escuchados, canciones favoritas, géneros preferidos, etc.
class UserStatsScreen extends StatefulWidget {
  const UserStatsScreen({super.key});

  @override
  State<UserStatsScreen> createState() => _UserStatsScreenState();
}

class _UserStatsScreenState extends State<UserStatsScreen>
    with SingleTickerProviderStateMixin {
  final _metricsService = MetricsService();
  final _authService = AuthService();

  bool _isLoading = true;
  Map<String, dynamic>? _userMetrics;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedPeriod = 'week'; // week, month, year, all

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Cargar métricas de usuario
      final metrics = await _metricsService.getUserMetrics(userId);

      setState(() {
        _userMetrics = metrics;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error cargando estadísticas: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userMetrics == null
              ? _buildErrorState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Period Selector
                          _buildPeriodSelector(),
                          const SizedBox(height: 16),

                          // Main Stats Cards
                          _buildMainStatsCards(),
                          const SizedBox(height: 24),

                          // Listening Time Chart
                          _buildListeningTimeChart(),
                          const SizedBox(height: 24),

                          // Top Genres
                          _buildTopGenres(),
                          const SizedBox(height: 24),

                          // Listening Habits
                          _buildListeningHabits(),
                          const SizedBox(height: 24),

                          // Activity Heatmap
                          _buildActivityHeatmap(),
                          const SizedBox(height: 24),

                          // Achievements
                          _buildAchievements(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          const Text('No se pudieron cargar las estadísticas'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildPeriodChip('Semana', 'week'),
            const SizedBox(width: 8),
            _buildPeriodChip('Mes', 'month'),
            const SizedBox(width: 8),
            _buildPeriodChip('Año', 'year'),
            const SizedBox(width: 8),
            _buildPeriodChip('Todo', 'all'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: ChoiceChip(
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedPeriod = value);
          }
        },
        selectedColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMainStatsCards() {
    // Datos simulados (en producción vendrían del backend)
    final totalMinutes = 12450;
    final totalSongs = 324;
    final differentArtists = 87;
    final totalMoney = 45.60;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Tiempo Total',
          '${(totalMinutes / 60).toStringAsFixed(0)}h ${totalMinutes % 60}m',
          Icons.access_time,
          Colors.purple,
          'de música escuchada',
        ),
        _buildStatCard(
          'Canciones',
          totalSongs.toString(),
          Icons.music_note,
          Colors.blue,
          'diferentes escuchadas',
        ),
        _buildStatCard(
          'Artistas',
          differentArtists.toString(),
          Icons.person,
          Colors.orange,
          'descubiertos',
        ),
        _buildStatCard(
          'Invertido',
          '\$${totalMoney.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
          'en música',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningTimeChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minutos Escuchados por Día',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}m',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                          if (value.toInt() < 0 ||
                              value.toInt() >= days.length) {
                            return const Text('');
                          }
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 45),
                        FlSpot(1, 80),
                        FlSpot(2, 95),
                        FlSpot(3, 120),
                        FlSpot(4, 110),
                        FlSpot(5, 150),
                        FlSpot(6, 130),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.5),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.3),
                            AppTheme.primaryColor.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGenres() {
    final genres = [
      {'name': 'Rock', 'percentage': 35.0, 'color': Colors.red},
      {'name': 'Pop', 'percentage': 25.0, 'color': Colors.pink},
      {'name': 'Electronic', 'percentage': 20.0, 'color': Colors.cyan},
      {'name': 'Jazz', 'percentage': 12.0, 'color': Colors.blue},
      {'name': 'Indie', 'percentage': 8.0, 'color': Colors.green},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Géneros Más Escuchados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...genres.map((genre) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            genre['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${genre['percentage']}%',
                            style: TextStyle(
                              color: genre['color'] as Color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (genre['percentage'] as double) / 100,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          genre['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningHabits() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hábitos de Escucha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildHabitRow(
              Icons.wb_sunny,
              'Momento Favorito',
              'Noche (22:00 - 02:00)',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildHabitRow(
              Icons.headphones,
              'Promedio Diario',
              '2h 15m de música',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildHabitRow(
              Icons.repeat,
              'Canción Más Repetida',
              'Midnight Dreams (47 veces)',
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildHabitRow(
              Icons.calendar_today,
              'Racha Actual',
              '12 días consecutivos',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityHeatmap() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividad por Hora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 4 != 0) {
                            return const Text('');
                          }
                          return Text(
                            '${value.toInt()}h',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(24, (index) {
                    // Simular actividad con picos en ciertas horas
                    double value;
                    if (index >= 6 && index <= 9) {
                      value = 40 + (index - 6) * 10; // Mañana
                    } else if (index >= 12 && index <= 14) {
                      value = 50; // Mediodía
                    } else if (index >= 18 && index <= 23) {
                      value = 60 + (index - 18) * 5; // Noche
                    } else {
                      value = 10; // Madrugada
                    }

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.5),
                              AppTheme.primaryColor,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {
        'icon': Icons.star,
        'title': 'Early Adopter',
        'description': 'Miembro desde hace más de 1 año',
        'color': Colors.amber,
        'unlocked': true,
      },
      {
        'icon': Icons.music_note,
        'title': 'Melómano',
        'description': 'Escuchaste más de 1000 canciones',
        'color': Colors.blue,
        'unlocked': true,
      },
      {
        'icon': Icons.favorite,
        'title': 'Super Fan',
        'description': 'Sigue a más de 50 artistas',
        'color': Colors.pink,
        'unlocked': false,
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Coleccionista',
        'description': 'Compró más de 10 álbumes',
        'color': Colors.green,
        'unlocked': true,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final unlocked = achievement['unlocked'] as bool;

                return Opacity(
                  opacity: unlocked ? 1.0 : 0.4,
                  child: Card(
                    color: unlocked
                        ? (achievement['color'] as Color).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            achievement['icon'] as IconData,
                            color: achievement['color'] as Color,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            achievement['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement['description'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
