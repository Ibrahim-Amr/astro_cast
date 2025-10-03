import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchPanel extends StatefulWidget {
  final Function(String, DateTime) onSearch;

  const SearchPanel({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchPanelState createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSearching = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1D1F33),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1D1F33),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _search() {
    final location = _locationController.text.trim();
    if (location.isNotEmpty) {
      setState(() => _isSearching = true);
      widget.onSearch(location, _selectedDate);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  String _getDateDescription(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Today, ${DateFormat('MMM d, yyyy').format(date)}';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${DateFormat('MMM d, yyyy').format(date)}';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('MMM d, yyyy').format(date)}';
    } else {
      return DateFormat('EEE, MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search header
            Row(
              children: [
                Icon(Icons.search, color: const Color(0xFF6C63FF), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Weather Search',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Location input
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'City Name',
                hintText: 'e.g., Cairo, London, Tokyo',
                prefixIcon: Icon(Icons.location_on, color: Colors.white70),
                suffixIcon: _isSearching
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6C63FF)),
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: const Color(0xFF1D1F33).withOpacity(0.8),
              ),
              onSubmitted: (_) => _search(),
            ),

            const SizedBox(height: 15),

            // Date selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1F33).withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF4C4F5E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: const Color(0xFF6C63FF), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Select Date',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0E21),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(_selectedDate),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDateDescription(_selectedDate),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6C63FF),
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.calendar_month,
                            color: const Color(0xFF6C63FF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _search,
                icon: _isSearching
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(Icons.search),
                label: Text(_isSearching ? 'Searching...' : 'Get Weather Analysis'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Info tip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: const Color(0xFF6C63FF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Historical data analysis provides probability assessment for selected date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
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
}