import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/status_chip.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final String incidentId;

  const IncidentDetailsScreen({super.key, required this.incidentId});

  Future<void> _changeStatus(
    BuildContext context,
    Incident incident,
    String status,
  ) async {
    if (status == incident.status) return;
    final provider = context.read<IncidentProvider>();
    final success = await provider.updateStatus(incident.id, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status updated to ${AppConstants.statusLabel(status)}'
              : provider.errorMessage ?? 'Could not update the status',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete report'),
        content: const Text('This report will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<IncidentProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteIncident(incident);
    if (success) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted')));
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Could not delete the report'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final auth = context.watch<AuthProvider>();
    final incident = provider.findById(incidentId);

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const Center(child: Text('Report not found')),
      );
    }

    final isStaff = auth.isStaff;
    final isOwner = auth.appUser?.uid == incident.reporterId;
    final canDelete = isStaff ||
        (isOwner && incident.status == AppConstants.statusSubmitted);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, incident),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incident.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              incident.location,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: incident.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(
                    icon: Icons.category_outlined,
                    text: incident.category,
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    text:
                        'Submitted on ${AppConstants.formatDateTime(incident.createdAt)}',
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(
                    icon: Icons.person_outline,
                    text: 'Reported by ${incident.reporterName}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Status Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _StatusTimeline(incident: incident),
            if (isStaff) ...[
              const SizedBox(height: 24),
              const Text(
                'Update Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: AppConstants.statusSubmitted,
                      label: Text('Submitted', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: AppConstants.statusInProgress,
                      label:
                          Text('In Progress', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: AppConstants.statusResolved,
                      label: Text('Resolved', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  selected: {incident.status},
                  onSelectionChanged: (value) =>
                      _changeStatus(context, incident, value.first),
                ),
              ),
              if (incident.updatedBy != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Last updated by ${incident.updatedBy}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              incident.description,
              style: const TextStyle(height: 1.4),
            ),
            if (incident.imageUrl != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Attached Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  incident.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 120,
                    child: Center(child: Text('Could not load the photo')),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final Incident incident;

  const _StatusTimeline({required this.incident});

  static const List<String> _steps = [
    AppConstants.statusSubmitted,
    AppConstants.statusInProgress,
    AppConstants.statusResolved,
  ];

  @override
  Widget build(BuildContext context) {
    final current = _steps.indexOf(incident.status);
    final dates = [
      incident.createdAt,
      incident.inProgressAt,
      incident.resolvedAt,
    ];
    const grey = Color(0xFFD9D9E3);

    return Row(
      children: List.generate(_steps.length, (i) {
        final reached = i <= current;
        final date = dates[i];
        final leftColor = i == 0
            ? Colors.transparent
            : (reached ? AppTheme.primary : grey);
        final rightColor = i == _steps.length - 1
            ? Colors.transparent
            : (i < current ? AppTheme.primary : grey);

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 2, color: leftColor)),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reached ? AppTheme.primary : grey,
                    ),
                    child: reached
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  Expanded(child: Container(height: 2, color: rightColor)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.statusLabel(_steps[i]),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: reached ? AppTheme.primary : Colors.black45,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                reached && date != null ? AppConstants.formatShort(date) : '-',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        );
      }),
    );
  }
}