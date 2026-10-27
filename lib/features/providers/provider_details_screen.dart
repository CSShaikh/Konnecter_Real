import 'package:flutter/material.dart';

import 'booking_flow_screen.dart';
import 'service_provider.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: provider.photoUrl.trim().isNotEmpty
                  ? Image.network(
                      provider.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.home_repair_service, size: 70),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.home_repair_service, size: 70),
                    ),
            ),
            const SizedBox(height: 22),
            Text(
              provider.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 21),
                const SizedBox(width: 5),
                Text(
                  provider.rating.toStringAsFixed(1),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.verified_user_outlined, size: 18),
                const SizedBox(width: 5),
                const Text('Service provider'),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.build_outlined, size: 18),
                  label: Text(provider.service),
                ),
                Chip(
                  avatar: Icon(
                    provider.available
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 18,
                  ),
                  label: Text(
                    provider.available ? 'Available' : 'Currently unavailable',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'About this provider',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.description.trim().isEmpty
                  ? 'No description has been added yet.'
                  : provider.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_rupee, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting price',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '₹${provider.price}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('Price may vary by job'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: provider.available
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingFlowScreen(provider: provider),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Book this provider'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your booking request will be sent to the provider for confirmation.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
