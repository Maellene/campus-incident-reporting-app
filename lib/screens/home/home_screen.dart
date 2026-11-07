import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/summary_tile.dart';
import '../incidents/incident_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onSeeAll;

  const HomeScreen({
    super.key,
    required this.onReport,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<IncidentProvider>();
    final isStaff = auth.isStaff;
    final firstName = (auth.appUser?.name ?? '').split(' ').first;

    final listSource = isStaff
        ? provider.incidents
            .where((i) => i.status == AppConstants.statusSubmitted)
            .toList()
        : provider.incidents;
    final recent = listSource.take(3).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hello, $firstName',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            isStaff
                ? 'Review reports and keep campus running.'
                : 'Help make our campus safer.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            isStaff
                ? 'Update the status as issues are resolved.'
                : 'Report issues and track their resolution.',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          if (!isStaff) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C47FF), Color(0xFF9B83FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'See an issue\non campus?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Report it and help improve our learning environment.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: onReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle),
                      label: const Text(
                        'Report an Issue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          _SectionHeader(
            title: isStaff ? 'Campus Overview' : 'Report Summary',
            onSeeAll: onSeeAll,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SummaryTile(
                count: provider.totalCount,
                label: isStaff ? 'All Reports' : 'My Reports',
                icon: Icons.description,
                color: const Color(0xFF6C47FF),
              ),
              SummaryTile(
                count: provider.inProgressCount,
                label: 'In Progress',
                icon: Icons.access_time,
                color: const Color(0xFF2F80ED),
              ),
              SummaryTile(
                count: provider.resolvedCount,
                label: 'Resolved',
                icon: Icons.check_circle,
                color: const Color(0xFF2E8B57),
              ),
              SummaryTile(
                count: provider.submittedCount,
                label: 'Submitted',
                icon: Icons.error,
                color: const Color(0xFFE5484D),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: isStaff ? 'Needs Attention' : 'Recent Reports',
            onSeeAll: onSeeAll,
          ),
          const SizedBox(height: 12),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  isStaff ? 'No reports waiting for review' : 'No reports yet',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            )
          else
            ...recent.map(
              (incident) => IncidentCard(
                incident: incident,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        IncidentDetailsScreen(incidentId: incident.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}