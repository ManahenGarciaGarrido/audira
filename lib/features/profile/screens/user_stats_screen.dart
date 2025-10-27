import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/providers/auth_provider.dart';

class UserStatsScreen extends StatelessWidget {
  const UserStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stats refreshed')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user?.fullName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Overview Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total Plays', '345', Icons.play_circle, AppTheme.primaryBlue),
                _buildStatCard('Purchased Songs', '28', Icons.music_note, Colors.purple),
                _buildStatCard('Purchased Albums', '5', Icons.album, Colors.orange),
                _buildStatCard('Total Spent', '\$234', Icons.attach_money, Colors.green),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 24),

            const Text('Listening Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatRow('This Week', '45 plays', AppTheme.primaryBlue),
                    const Divider(),
                    _buildStatRow('This Month', '178 plays', AppTheme.primaryBlue),
                    const Divider(),
                    _buildStatRow('Total Listening Time', '12h 34m', Colors.purple),
                    const Divider(),
                    _buildStatRow('Avg. Daily Listening', '35 min', Colors.orange),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            const Text('Top Genres',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _buildGenreItem('Pop', 45, Colors.pink),
                  const Divider(height: 1),
                  _buildGenreItem('Rock', 30, Colors.red),
                  const Divider(height: 1),
                  _buildGenreItem('Jazz', 15, Colors.blue),
                  const Divider(height: 1),
                  _buildGenreItem('Electronic', 10, Colors.purple),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),

            const Text('Recently Played',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (index) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Icon(Icons.music_note, color: Colors.white),
                  ),
                  title: Text('Song ${index + 1}'),
                  subtitle: Text('Artist Name • ${index + 1} plays'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to song detail
                  },
                ),
              ).animate().fadeIn(delay: ((index + 1) * 50).ms),
            ),
            const SizedBox(height: 24),

            const Text('Favorite Artists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryBlue,
                          child: Text('A${index + 1}',
                              style: const TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                        const SizedBox(height: 8),
                        Text('Artist ${index + 1}'),
                      ],
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 350.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildGenreItem(String genre, int percentage, Color color) {
    return ListTile(
      title: Text(genre),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[800],
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
