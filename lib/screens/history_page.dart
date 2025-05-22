import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';
import '../widgets/calendar/calendar_widget.dart';
import '../utils/date_utils.dart' as utils;
import 'period_tracker_page.dart';
import 'log_page.dart';
import 'settings_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> historyItems = [];
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('history') ?? [];
    setState(() {
      historyItems = historyJson
          .map((item) => HistoryItem.fromJson(json.decode(item)))
          .toList()
          ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
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
      body: historyItems.isEmpty
          ? Center(
              child: Text(
                'No saved predictions yet.\nDouble tap on predictions title to save them.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: historyItems.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      final isExpanded = expandedIndex == index;

                      return Dismissible(
                        key: Key(item.savedAt.toString()),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (direction) async {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Delete Entry',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this history entry?',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'CANCEL',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(
                                      'DELETE',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirm == true) {
                            final prefs = await SharedPreferences.getInstance();
                            final historyJson = prefs.getStringList('history') ?? [];
                            historyJson.removeAt(index);
                            await prefs.setStringList('history', historyJson);
                            
                            setState(() {
                              historyItems.removeAt(index);
                              if (expandedIndex == index) {
                                expandedIndex = null;
                              } else if (expandedIndex != null && expandedIndex! > index) {
                                expandedIndex = expandedIndex! - 1;
                              }
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('History entry deleted'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                          return confirm;
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20.0),
                          color: Theme.of(context).colorScheme.error,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    expandedIndex = isExpanded ? null : index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${item.lastPeriodDate.day.toString().padLeft(2, '0')} ${utils.DateUtils.monthName(item.lastPeriodDate.month)} ${item.lastPeriodDate.year}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Cycle Length: ${item.cycleLength} days",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isExpanded ? Icons.expand_less : Icons.expand_more,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded) ...[
                                Divider(
                                  height: 1,
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: CalendarWidget(
                                    lastPeriodDate: item.lastPeriodDate,
                                    cycleLength: item.cycleLength,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Swipe right to delete an entry',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        currentIndex: 1, // History tab
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
          if (index != 1) { // If not history
            if (index == 0) { // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PeriodTrackerPage(),
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