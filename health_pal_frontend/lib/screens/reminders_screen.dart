import 'package:flutter/material.dart';
import 'package:health_pal_frontend/utils/api_client.dart';
import 'package:health_pal_frontend/services/reminder_service.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _reminderService = ReminderService(apiClient: ApiClient());
  final TextEditingController _scheduledTimeController = TextEditingController();
  final TextEditingController _customMessageController = TextEditingController();
  String _selectedReminderType = 'custom';
  List<Map<String, dynamic>> _reminders = [];
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  @override
  void dispose() {
    _scheduledTimeController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> _fetchReminders() async {
    try {
      final fetchedReminders = await _reminderService.getReminders();
      setState(() {
        _reminders = fetchedReminders;
        _message = _reminders.isEmpty ? 'No reminders found.' : '';
      });
    } catch (e) {
      setState(() {
        _message = 'Error fetching reminders: ${e.toString()}';
      });
      debugPrint('Error fetching reminders: ${e.toString()}');
    }
  }

  Future<void> _scheduleReminder() async {
    if (_scheduledTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a scheduled time.')),
      );
      return;
    }

    if (_selectedReminderType == 'custom' && _customMessageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a custom message.')),
      );
      return;
    }

    setState(() {
      _message = 'Scheduling reminder...';
    });

    try {
      final scheduledTime = DateTime.parse(_scheduledTimeController.text);
      final reminderData = {
        'scheduled_time': scheduledTime.toIso8601String(),
        'type': _selectedReminderType,
        if (_selectedReminderType == 'custom') 'custom_message': _customMessageController.text,
      };

      await _reminderService.scheduleReminder(reminderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder scheduled successfully!')),
      );
      _scheduledTimeController.clear();
      _customMessageController.clear();
      _fetchReminders(); // Refresh reminders
    } catch (e) {
      setState(() {
        _message = 'Failed to schedule reminder: ${e.toString()}';
      });
      debugPrint('Error scheduling reminder: ${e.toString()}');
    }
  }

  Future<void> _selectScheduledTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _scheduledTimeController.text = fullDateTime.toIso8601String();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders & Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_message),
            const SizedBox(height: 20),
            TextField(
              controller: _scheduledTimeController,
              readOnly: true,
              onTap: () => _selectScheduledTime(context),
              decoration: const InputDecoration(
                labelText: 'Scheduled Time',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedReminderType,
              decoration: const InputDecoration(
                labelText: 'Reminder Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'custom', child: Text('Custom Message')),
                DropdownMenuItem(value: 'morning_checkin', child: Text('Morning Check-in')),
                DropdownMenuItem(value: 'exercise_reminder', child: Text('Exercise Reminder')),
                DropdownMenuItem(value: 'nutrition_tip', child: Text('Nutrition Tip')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedReminderType = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            if (_selectedReminderType == 'custom')
              TextField(
                controller: _customMessageController,
                decoration: const InputDecoration(
                  labelText: 'Custom Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _scheduleReminder,
              child: const Text('Schedule Reminder'),
            ),
            const SizedBox(height: 40),
            const Text('Scheduled Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _reminders.isEmpty
                  ? const Center(child: Text('No reminders scheduled.'))
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _reminders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(reminder['reminder_text']),
                            subtitle: Text('Scheduled: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(reminder['scheduled_time']))}\nStatus: ${reminder['status']}'),
                            trailing: reminder['sent_at'] != null
                                ? Text('Sent: ${DateFormat('HH:mm').format(DateTime.parse(reminder['sent_at']))}')
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}