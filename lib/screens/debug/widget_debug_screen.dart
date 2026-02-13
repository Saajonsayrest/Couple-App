import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../../providers/profile_provider.dart';

class WidgetDebugScreen extends ConsumerWidget {
  const WidgetDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Widget Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Profiles: ${profiles.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (profiles.length >= 2) ...[
              Text('Me: ${profiles[0].name} (${profiles[0].nickname})'),
              Text('Partner: ${profiles[1].name} (${profiles[1].nickname})'),
              Text('Avatar 1: ${profiles[0].avatarPath ?? "none"}'),
              Text('Avatar 2: ${profiles[1].avatarPath ?? "none"}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  print('🔄 Manually triggering widget update...');
                  await ref
                      .read(profileProvider.notifier)
                      .updateProfiles(me: profiles[0], partner: profiles[1]);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Widget update triggered! Check logs.'),
                      ),
                    );
                  }
                },
                child: const Text('Force Widget Update'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  print('📖 Reading widget data from UserDefaults...');
                  final name1 = await HomeWidget.getWidgetData<String>('name1');
                  final name2 = await HomeWidget.getWidgetData<String>('name2');
                  final days = await HomeWidget.getWidgetData<String>('days');
                  final avatar1 = await HomeWidget.getWidgetData<String>(
                    'avatar1Path',
                  );
                  final avatar2 = await HomeWidget.getWidgetData<String>(
                    'avatar2Path',
                  );

                  print('   Name1: $name1');
                  print('   Name2: $name2');
                  print('   Days: $days');
                  print('   Avatar1: $avatar1');
                  print('   Avatar2: $avatar2');

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Widget Data'),
                        content: Text(
                          'Name1: $name1\n'
                          'Name2: $name2\n'
                          'Days: $days\n'
                          'Avatar1: $avatar1\n'
                          'Avatar2: $avatar2',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Read Widget Data'),
              ),
            ] else ...[
              const Text('No profiles found. Complete onboarding first.'),
            ],
          ],
        ),
      ),
    );
  }
}
