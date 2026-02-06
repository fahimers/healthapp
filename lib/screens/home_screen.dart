import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/health_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _foodSearchController = TextEditingController();
  bool _isFoodLoading = false;
  String? _foodName;
  String? _foodCalories;
  String? _foodError;
  bool _isFoodSearchLoading = false;
  List<Map<String, dynamic>> _foodSearchResults = [];
  String? _foodSearchError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset All Data',
            onPressed: () {
              _showResetDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<StepProvider>(
        builder: (context, stepProvider, child) {
          final todaySteps = stepProvider.getTotalStepsToday();
          final totalSteps = stepProvider.getTotalSteps();
          final todayCalories = stepProvider.getTotalCaloriesTodayFormatted();
          final totalCalories = stepProvider.getTotalCaloriesFormatted();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Today's Steps Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Today\'s Steps',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$todaySteps',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'steps',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Calories Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Today\'s Calories Burned',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          todayCalories,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Total Steps Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Steps',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalSteps',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.trending_up,
                          size: 48,
                          color: Colors.blue.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Total Calories Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Calories Burned',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalCalories kcal',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.local_fire_department,
                          size: 48,
                          color: Colors.orange.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Food Search with Dropdown
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Search Food Calories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _foodSearchController,
                          decoration: InputDecoration(
                            labelText: 'Type at least 3 letters',
                            hintText: 'e.g., app, ban, chi',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _foodSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _foodSearchController.clear();
                                        _foodSearchResults.clear();
                                        _foodSearchError = null;
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length >= 3) {
                              _searchFood(value);
                            } else {
                              setState(() {
                                _foodSearchResults.clear();
                                _foodSearchError = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_isFoodSearchLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_foodSearchError != null)
                          Text(
                            _foodSearchError!,
                            style: const TextStyle(color: Colors.red),
                          )
                        else if (_foodSearchResults.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _foodSearchResults.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final food = _foodSearchResults[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    food['name'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    food['calories'] ?? 'Calories unavailable',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.food_bank, size: 20),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Random Food Calories
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Random Food Calories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isFoodLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_foodError != null)
                          Text(
                            _foodError!,
                            style: const TextStyle(color: Colors.red),
                          )
                        else if (_foodName != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _foodName!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _foodCalories ?? 'Calories unavailable',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            'Tap the button to fetch a random food item.',
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isFoodLoading ? null : _fetchRandomFood,
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Get Random Food'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Reset Button
                ElevatedButton.icon(
                  onPressed: () {
                    _showResetDialog(context);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset All Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Add Steps Section
                const Text(
                  'Add Steps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stepsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Steps',
                    hintText: 'Enter steps taken',
                    prefixIcon: const Icon(Icons.directions_walk),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final steps = int.tryParse(_stepsController.text);
                    if (steps != null && steps > 0) {
                      stepProvider.addSteps(steps);
                      _stepsController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $steps steps!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid number'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Steps',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 32),

                // Recent Entries
                const Text(
                  'Recent Entries',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (stepProvider.stepsList.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No steps recorded yet.\nStart tracking your steps!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stepProvider.stepsList.length,
                    itemBuilder: (context, index) {
                      final stepData = stepProvider.stepsList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              Icons.directions_walk,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            '${stepData.steps} steps',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDateTime(stepData.timestamp),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${stepData.caloriesFormated} kcal burned',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              stepProvider.deleteSteps(stepData.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Entry deleted'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset All Data'),
          content: const Text(
            'Are you sure you want to reset all steps and calories data? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final provider = Provider.of<StepProvider>(context, listen: false);
                await provider.resetAllData();
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been reset!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _foodSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.length < 3) return;

    setState(() {
      _isFoodSearchLoading = true;
      _foodSearchError = null;
    });

    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl'
        '?search_terms=${Uri.encodeComponent(query)}'
        '&search_simple=1'
        '&action=process'
        '&json=1'
        '&page_size=10'
        '&fields=product_name,product_name_en,nutriments',
      );
      
      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'health-tracking-app/1.0'},
      );

      if (response.statusCode != 200) {
        throw Exception('Request failed');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>?;

      if (products == null || products.isEmpty) {
        setState(() {
          _foodSearchResults.clear();
          _foodSearchError = 'No foods found matching "$query"';
        });
        return;
      }

      final results = <Map<String, dynamic>>[];
      for (var product in products) {
        final productMap = product as Map<String, dynamic>;
        final name = (productMap['product_name'] ?? 
                     productMap['product_name_en'] ?? 
                     'Unknown food') as String;
        
        final nutriments = productMap['nutriments'] as Map<String, dynamic>?;
        double? kcal;
        final kcalValue = nutriments?['energy-kcal_100g'] ?? 
                         nutriments?['energy-kcal'];
        if (kcalValue is num) {
          kcal = kcalValue.toDouble();
        } else if (kcalValue is String) {
          kcal = double.tryParse(kcalValue);
        }

        results.add({
          'name': name.trim().isEmpty ? 'Unknown food' : name,
          'calories': kcal != null
              ? '${kcal.toStringAsFixed(0)} kcal / 100g'
              : 'Calories unavailable',
        });
      }

      setState(() {
        _foodSearchResults = results;
      });
    } catch (_) {
      setState(() {
        _foodSearchError = 'Failed to search. Please try again.';
        _foodSearchResults.clear();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFoodSearchLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRandomFood() async {
    setState(() {
      _isFoodLoading = true;
      _foodError = null;
    });

    try {
      final randomPage = Random().nextInt(2000) + 1;
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/search'
        '?fields=product_name,product_name_en,nutriments'
        '&page_size=1'
        '&page=$randomPage',
      );
      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'health-tracking-app/1.0'},
      );

      if (response.statusCode != 200) {
        throw Exception('Request failed');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>?;
      final product = products != null && products.isNotEmpty
          ? products.first as Map<String, dynamic>
          : null;

      if (product == null) {
        throw Exception('No product');
      }

      final name = (product['product_name'] ?? product['product_name_en'] ?? 'Unknown food') as String;
      final nutriments = product['nutriments'] as Map<String, dynamic>?;

      double? kcal;
      final kcalValue = nutriments?['energy-kcal_100g'] ?? nutriments?['energy-kcal'];
      if (kcalValue is num) {
        kcal = kcalValue.toDouble();
      } else if (kcalValue is String) {
        kcal = double.tryParse(kcalValue);
      }

      setState(() {
        _foodName = name.trim().isEmpty ? 'Unknown food' : name;
        _foodCalories = kcal != null
            ? '${kcal.toStringAsFixed(0)} kcal / 100g'
            : 'Calories unavailable';
      });
    } catch (_) {
      setState(() {
        _foodError = 'Failed to load random food. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFoodLoading = false;
        });
      }
    }
  }
}
