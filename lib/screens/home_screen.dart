import 'package:astro_cast/screens/welcome_animation.dart';
import 'package:flutter/material.dart';
import '../data/models/weather_data.dart';
import '../widgets/space_animated_background.dart';
import '../widgets/weather_card.dart';
import '../widgets/search_panel.dart';
import '../widgets/weather_tips.dart';
import '../widgets/current_weather.dart';
import '../services/weather_api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  WeatherData? _weatherData;
  bool _isLoading = false;
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();
  DateTime? _selectedSearchDate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearch(String location, DateTime date) async {
    if (location.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _weatherData = null;
      _selectedSearchDate = date;
    });

    try {
      final weatherData = await WeatherApiService.getWeatherByDate(location, date);

      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            400,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  String _getDateType() {
    if (_selectedSearchDate == null) return 'current';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedSearchDate!.year, _selectedSearchDate!.month, _selectedSearchDate!.day);

    if (selected == today) return 'current';
    if (selected.isBefore(today)) return 'historical';
    return 'forecast';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _weatherData != null ? FloatingActionButton(
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 8,
      ) : null,

      body: Stack(
        children: [
          SpaceAnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Header section
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Row(
                              children: [
                                Icon(Icons.storm, color: Colors.white, size: 32),
                                const SizedBox(width: 12),
                                Text(
                                  'WeatherWise Pro',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Text(
                              'Professional Weather Intelligence & Probability Analysis',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Search panel
                  SliverToBoxAdapter(
                    child: SearchPanel(onSearch: _handleSearch),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Error message
                  if (_errorMessage.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildErrorCard(),
                    )

                  // Loading state
                  else if (_isLoading)
                    SliverToBoxAdapter(
                      child: _WeatherLoadingAnimation(),
                    )

                  // Results section
                  else if (_weatherData != null)
                      SliverList(
                        delegate: SliverChildListDelegate([
                          CurrentWeather(
                            weatherData: _weatherData!,
                            dateType: _getDateType(),
                          ),
                          const SizedBox(height: 20),
                          _buildDateAnalysisHeader(),
                          const SizedBox(height: 20),
                          _WeatherResultsGrid(weatherData: _weatherData!),
                          const SizedBox(height: 30),
                          WeatherTips(weatherData: _weatherData!),
                          const SizedBox(height: 50),
                        ]),
                      )

                    // Welcome state
                    else
                      SliverToBoxAdapter(
                        child: WelcomeAnimation(),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unable to fetch weather data',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '• City name spelling\n• Internet connection\n• Date range (past 7 days or next 14 days)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.withOpacity(0.8),
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

  Widget _buildDateAnalysisHeader() {
    final dateType = _getDateType();
    String title = 'Current Weather Analysis';
    String subtitle = 'Based on real-time weather conditions';

    if (dateType == 'historical') {
      title = 'Historical Weather Analysis';
      subtitle = 'Based on recorded weather data for the selected date';
    } else if (dateType == 'forecast') {
      title = 'Weather Forecast Analysis';
      subtitle = 'Based on weather prediction models';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            dateType == 'current' ? Icons.real_estate_agent :
            dateType == 'historical' ? Icons.history : Icons.nature,
            color: const Color(0xFF6C63FF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherLoadingAnimation extends StatefulWidget {
  @override
  __WeatherLoadingAnimationState createState() => __WeatherLoadingAnimationState();
}

class __WeatherLoadingAnimationState extends State<_WeatherLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.satellite_alt, size: 80, color: const Color(0xFF6C63FF)),
          const SizedBox(height: 20),
          Text(
            'Analyzing Weather Patterns...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 10),
          Text(
            'Processing historical data and probability models',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherResultsGrid extends StatelessWidget {
  final WeatherData weatherData;

  const _WeatherResultsGrid({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final conditions = {
      'very_hot': {'label': 'Very Hot', 'icon': Icons.wb_sunny, 'color': Color(0xFFFF6584)},
      'very_cold': {'label': 'Very Cold', 'icon': Icons.ac_unit, 'color': Color(0xFF6C63FF)},
      'very_windy': {'label': 'Very Windy', 'icon': Icons.air, 'color': Color(0xFF00BFA6)},
      'very_wet': {'label': 'Very Wet', 'icon': Icons.beach_access, 'color': Color(0xFF2196F3)},
      'very_uncomfortable': {'label': 'Uncomfortable', 'icon': Icons.sentiment_dissatisfied, 'color': Color(0xFFFF9800)},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather Probability Assessment',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'AI-powered probability analysis based on current and historical weather patterns',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 2 : 2;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: conditions.entries.map((entry) {
                final condition = entry.key;
                final data = entry.value;
                final probability = weatherData.probabilities[condition] ?? 0.0;

                return WeatherCard(
                  title: data['label'] as String,
                  probability: probability,
                  color: data['color'] as Color,
                  icon: data['icon'] as IconData,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}