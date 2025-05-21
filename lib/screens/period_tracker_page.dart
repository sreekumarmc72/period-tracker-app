import 'package:flutter/material.dart';
import 'package:period_tracker_flutter/widgets/calendar/calendar_widget.dart';
import 'package:period_tracker_flutter/widgets/result_card/result_card.dart';
import 'package:period_tracker_flutter/utils/date_utils.dart' as utils;

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

  void _reset() {
    setState(() {
      lastPeriodDate = null;
      cycleLength = null;
      result = '';
      _cycleLengthController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: const Text(
          'Period Tracker',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // No shadow
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
                  setState(() => lastPeriodDate = picked);
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
                        color: lastPeriodDate == null ? const Color(0xFF8B5F6C) : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (lastPeriodDate == null)
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Text('Please select a date',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _cycleLengthController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Average cycle length (days)',
                errorText: (cycleLength == null || cycleLength! < 20 || cycleLength! > 40)
                    ? 'Enter 20-40'
                    : null,
              ),
              onChanged: (val) {
                final n = int.tryParse(val);
                setState(() {
                  cycleLength = n;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
              children: [
                SizedBox(
                  width: 120, // Adjust width as needed
                  child: ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 12), // Space between buttons
                SizedBox(
                  width: 100, // Adjust width as needed
                  child: ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Subtle grey background
                      foregroundColor: Colors.black87, // Dark text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Predictions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ResultCard(resultData: result),
              const SizedBox(height: 32),
              const Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
