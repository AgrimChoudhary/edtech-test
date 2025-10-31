import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';

class QualificationsScreen extends StatefulWidget {
  const QualificationsScreen({super.key});

  @override
  State<QualificationsScreen> createState() => _QualificationsScreenState();
}

class _QualificationsScreenState extends State<QualificationsScreen> {
  final List<Map<String, dynamic>> _qualifications = [];
  
  final List<String> _levels = ['10th', '12th', 'Diploma', 'Graduation', 'Post-Graduation'];
  final List<String> _streams = ['Any', 'Science', 'Commerce', 'Arts', 'Engineering'];
  final List<String> _statuses = ['Completed', 'Pursuing'];

  void _addQualification() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _QualificationDialog(),
    );

    if (result != null) {
      final supabaseService = context.read<SupabaseService>();
      final success = await supabaseService.addQualification(
        level: result['level'],
        stream: result['stream'],
        degree: result['degree'],
        marks: result['marks'],
        status: result['status'],
        completionYear: result['completion_year'],
      );

      if (success) {
        setState(() {
          _qualifications.add(result);
        });
      }
    }
  }

  void _continue() {
    if (_qualifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one qualification')),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Qualifications'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add your qualifications',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us match you with the right opportunities',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _qualifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No qualifications added yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _qualifications.length,
                    itemBuilder: (context, index) {
                      final qual = _qualifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: const Icon(Icons.school),
                          title: Text('${qual['level']} - ${qual['stream'] ?? 'N/A'}'),
                          subtitle: Text(
                            '${qual['status']} ${qual['completion_year'] != null ? '(${qual['completion_year']})' : ''}',
                          ),
                          trailing: Text(
                            qual['marks'] != null ? '${qual['marks']}%' : '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _addQualification,
                    icon: const Icon(Icons.add),
                    label: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Add Qualification'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _continue,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Continue to Dashboard'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QualificationDialog extends StatefulWidget {
  @override
  State<_QualificationDialog> createState() => _QualificationDialogState();
}

class _QualificationDialogState extends State<_QualificationDialog> {
  String? _level;
  String? _stream;
  String? _degree;
  double? _marks;
  String _status = 'Completed';
  int? _completionYear;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Qualification'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Level'),
              items: ['10th', '12th', 'Diploma', 'Graduation', 'Post-Graduation']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (value) => setState(() => _level = value),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Stream'),
              items: ['Science', 'Commerce', 'Arts', 'Engineering']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _stream = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Degree (Optional)'),
              onChanged: (value) => _degree = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Marks/CGPA'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _marks = double.tryParse(value),
            ),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Completed', 'Pursuing']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _completionYear = int.tryParse(value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_level != null) {
              Navigator.pop(context, {
                'level': _level,
                'stream': _stream,
                'degree': _degree,
                'marks': _marks,
                'status': _status,
                'completion_year': _completionYear,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
