import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:period_tracker_flutter/widgets/calendar/calendar_widget.dart';
import 'package:period_tracker_flutter/widgets/result_card/result_card.dart';
import 'package:period_tracker_flutter/utils/date_utils.dart' as utils;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';
import 'history_page.dart';
import 'log_page.dart';
import 'settings_page.dart';

class PeriodTrackerPage extends StatefulWidget {
  const PeriodTrackerPage({Key? key}) : super(key: key);

  @override
  State<PeriodTrackerPage> createState() => _PeriodTrackerPageState();
}

class _PeriodTrackerPageState extends State<PeriodTrackerPage> {
  DateTime? lastPeriodDate;
  int? cycleLength;
  String result = '';
  final TextEditingController _cycleLengthController = TextEditingController();
  bool _showSavedMessage = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPeriodMillis = prefs.getInt('lastPeriodDate');
    final savedCycleLength = prefs.getInt('cycleLength');

    setState(() {
      if (lastPeriodMillis != null) {
        lastPeriodDate = DateTime.fromMillisecondsSinceEpoch(lastPeriodMillis);
      }
      if (savedCycleLength != null) {
        cycleLength = savedCycleLength;
        _cycleLengthController.text = savedCycleLength.toString();
      }
    });

    if (lastPeriodDate != null && cycleLength != null) {
      _calculate();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (lastPeriodDate != null) {
      await prefs.setInt('lastPeriodDate', lastPeriodDate!.millisecondsSinceEpoch);
    }
    if (cycleLength != null) {
      await prefs.setInt('cycleLength', cycleLength!);
    }
  }

  @override
  void dispose() {
    _cycleLengthController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    if (lastPeriodDate == null || cycleLength == null || cycleLength! < 20 || cycleLength! > 40) {
      setState(() {
        result = '';
      });
      return;
    }

    final nextPeriod = lastPeriodDate!.add(Duration(days: cycleLength! - 1));
    final ovulation = lastPeriodDate!.add(Duration(days: cycleLength! - 14));
    final unsafeStart = ovulation.subtract(const Duration(days: 5));
    final unsafeEnd = ovulation.add(const Duration(days: 5));
    final safe1Start = lastPeriodDate!;
    final safe1End = unsafeStart.subtract(const Duration(days: 1));
    final safe2Start = unsafeEnd.add(const Duration(days: 1));
    final safe2End = nextPeriod;

    String format(DateTime d) => "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
    String safeRange = '';
    if (!safe1End.isBefore(safe1Start)) {
      safeRange += "${format(safe1Start)} to ${format(safe1End)}";
    }
    if (!safe2End.isBefore(safe2Start)) {
      if (safeRange.isNotEmpty) safeRange += ' and ';
      safeRange += "${format(safe2Start)} to ${format(safe2End)}";
    }

    setState(() {
      result = '${format(nextPeriod)}\n'
          '${format(ovulation)}\n'
          '${format(unsafeStart)} to ${format(unsafeEnd)}\n'
          '$safeRange';
    });
  }

  Future<void> _saveToHistory() async {
    if (lastPeriodDate != null && cycleLength != null && result.isNotEmpty) {
      final historyItem = HistoryItem(
        lastPeriodDate: lastPeriodDate!,
        cycleLength: cycleLength!,
        result: result,
        savedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('history') ?? [];
      historyJson.add(jsonEncode(historyItem.toJson()));
      await prefs.setStringList('history', historyJson);

      setState(() {
        _showSavedMessage = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSavedMessage = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: Text(
          'Period Tracker',
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your period details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: lastPeriodDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    lastPeriodDate = picked;
                    result = ''; // Clear results when date changes
                  });
                  await _saveData();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: (Theme.of(context).inputDecorationTheme.border as OutlineInputBorder?)?.borderRadius,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                    const SizedBox(width: 10),
                    Text(
                      lastPeriodDate == null
                          ? 'Last period date'
                          : "${lastPeriodDate!.day.toString().padLeft(2, '0')} ${utils.DateUtils.monthName(lastPeriodDate!.month)} ${lastPeriodDate!.year}",
                      style: TextStyle(
                        color: lastPeriodDate == null 
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (lastPeriodDate == null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _cycleLengthController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Average cycle length (days)',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                errorText: (cycleLength == null || cycleLength! < 20 || cycleLength! > 40)
                    ? 'Enter 20-40'
                    : null,
                errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (val) async {
                final n = int.tryParse(val);
                setState(() {
                  cycleLength = n;
                  result = ''; // Clear results when cycle length changes
                });
                await _saveData();
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 32),
              GestureDetector(
                onDoubleTap: _saveToHistory,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Predictions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (_showSavedMessage)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Saved to history!',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ResultCard(resultData: result),
              const SizedBox(height: 32),
              Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (lastPeriodDate != null && cycleLength != null)
                CalendarWidget(
                  lastPeriodDate: lastPeriodDate!,
                  cycleLength: cycleLength!,
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        currentIndex: 0, // Home tab
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index != 0) { // If not home
            if (index == 1) { // History
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryPage(),
                ),
              );
            } else if (index == 2) { // Log
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogPage(),
                ),
              );
            } else if (index == 3) { // Settings
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
