import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/incident_card.dart';
import 'incident_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<IncidentProvider>().searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final isStaff = context.watch<AuthProvider>().isStaff;
    final reports = provider.filteredIncidents;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              isStaff ? 'All Reports' : 'My Reports',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by title, description or location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FilterRow(
            options: AppConstants.categories,
            selected: provider.categoryFilter,
            labelFor: (value) => value,
            onSelected: provider.setCategoryFilter,
          ),
          const SizedBox(height: 8),
          _FilterRow(
            options: const [
              AppConstants.statusSubmitted,
              AppConstants.statusInProgress,
              AppConstants.statusResolved,
            ],
            selected: provider.statusFilter,
            labelFor: AppConstants.statusLabel,
            onSelected: provider.setStatusFilter,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildList(context, provider, reports),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    IncidentProvider provider,
    List reports,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.hasActiveFilters
                  ? 'No reports match your search'
                  : 'No reports yet',
              style: const TextStyle(color: Colors.black54),
            ),
            if (provider.hasActiveFilters)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  provider.clearFilters();
                },
                child: const Text('Clear filters'),
              ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final incident = reports[index];
        return IncidentCard(
          incident: incident,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => IncidentDetailsScreen(incidentId: incident.id),
            ),
          ),
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final String Function(String) labelFor;
  final ValueChanged<String?> onSelected;

  const _FilterRow({
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _chip('All', selected == null, () => onSelected(null)),
          ...options.map(
            (option) => _chip(
              labelFor(option),
              selected == option,
              () => onSelected(option),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primary.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primary : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}