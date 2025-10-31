import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import 'community_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  void _launchURL() async {
    if (job.officialWebsiteUrl != null) {
      final uri = Uri.parse(job.officialWebsiteUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocks = job.detailsJson['blocks'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.business, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.organization,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today,
                        label: 'Apply by: ${job.applicationEndDate.day}/${job.applicationEndDate.month}/${job.applicationEndDate.year}',
                      ),
                      if (job.vacancies != null)
                        _InfoChip(
                          icon: Icons.people,
                          label: '${job.vacancies} vacancies',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (blocks != null) ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: blocks.map((block) {
                    final type = block['type'];
                    final content = block['content'];

                    if (type == 'heading') {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          content,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      );
                    } else if (type == 'paragraph') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          content,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    } else if (type == 'list') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (content as List<dynamic>).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontSize: 18)),
                                  Expanded(child: Text(item)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }).toList(),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (job.officialWebsiteUrl != null) ...[
                    FilledButton.icon(
                      onPressed: _launchURL,
                      icon: const Icon(Icons.open_in_new),
                      label: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Visit Official Website'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityScreen(jobId: job.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.forum),
                    label: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Join Discussion'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
