import 'package:flutter/material.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const Divider(),
          _buildLogList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Okuma İstatistikleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Bu Ay', '15'),
                _buildStatItem('Bu Hafta', '3'),
                _buildStatItem('Toplam', '45'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLogList() {
    // Dummy data
    final List<Map<String, String>> logs = [
      {
        'date': '2024-03-15',
        'title': 'Kardiyoloji - Chapter 1: Temel Kavramlar',
        'type': 'Textbook',
      },
      {
        'date': '2024-03-14',
        'title': 'ESC Heart Failure Guidelines 2023',
        'type': 'Guideline',
      },
      {
        'date': '2024-03-13',
        'title': 'Kardiyoloji - Chapter 2: EKG Okuma',
        'type': 'Textbook',
      },
    ];

    return Expanded(
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                log['type'] == 'Textbook' ? Icons.book : Icons.description,
                color: Colors.blue,
              ),
              title: Text(log['title']!),
              subtitle: Text(
                _formatDate(log['date']!),
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: log['type'] == 'Textbook'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log['type']!,
                  style: TextStyle(
                    color:
                        log['type'] == 'Textbook' ? Colors.blue : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtreleme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Tümü'),
              _buildFilterOption('Textbook'),
              _buildFilterOption('Guideline'),
              const Divider(),
              _buildFilterOption('Bu Ay'),
              _buildFilterOption('Bu Hafta'),
              _buildFilterOption('Geçmiş'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.check),
      onTap: () {
        // TODO: Implement filter logic
      },
    );
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }
}
