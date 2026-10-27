import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnecter_customer/features/providers/provider_screen.dart';

import '../../core/services/auth_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key, required this.user});

  final User user;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  String _location = 'Select your location';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  final List<_ServiceCategory> _categories = const [
    _ServiceCategory(
      name: 'Electrician',
      icon: Icons.electrical_services_rounded,
      color: Color(0xFFFFF0D5),
      iconColor: Color(0xFFE49A16),
    ),
    _ServiceCategory(
      name: 'Plumber',
      icon: Icons.plumbing_rounded,
      color: Color(0xFFDCEEFF),
      iconColor: Color(0xFF2878CF),
    ),
    _ServiceCategory(
      name: 'Home Cleaning',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFFE0F5E9),
      iconColor: Color(0xFF24945A),
    ),
    _ServiceCategory(
      name: 'AC Repair',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFFE3E7FF),
      iconColor: Color(0xFF5967D8),
    ),
    _ServiceCategory(
      name: 'Painting',
      icon: Icons.format_paint_rounded,
      color: Color(0xFFFFE4E7),
      iconColor: Color(0xFFD94E67),
    ),
    _ServiceCategory(
      name: 'Carpentry',
      icon: Icons.handyman_rounded,
      color: Color(0xFFF4E7D8),
      iconColor: Color(0xFF9A6A35),
    ),
    _ServiceCategory(
      name: 'Appliance Repair',
      icon: Icons.home_repair_service_rounded,
      color: Color(0xFFE4F3F5),
      iconColor: Color(0xFF258B98),
    ),
    _ServiceCategory(
      name: 'Other Services',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFFECE8F9),
      iconColor: Color(0xFF7958B8),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ServiceCategory> get _filteredCategories {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return _categories;

    return _categories
        .where((category) => category.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      _buildBookingsPage(),
      _buildWalletPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konnecter Real',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              _showMessage('Notifications will be available soon.');
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    final theme = Theme.of(context);
    final categories = _filteredCategories;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showLocationDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR LOCATION',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search for a service',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 22),

          _buildBanner(theme),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Our Services',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${categories.length} services',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Find the right professional for your home.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: Text('No services match your search.')),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.32,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category);
              },
            ),

          const SizedBox(height: 26),
          Text(
            'Why choose us?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          const _BenefitTile(
            icon: Icons.verified_user_outlined,
            title: 'Trusted professionals',
            subtitle: 'Discover professionals for your home needs.',
          ),
          const _BenefitTile(
            icon: Icons.schedule_rounded,
            title: 'Convenient scheduling',
            subtitle: 'Choose a suitable time for your service.',
          ),
          const _BenefitTile(
            icon: Icons.support_agent_rounded,
            title: 'Customer support',
            subtitle: 'Help is available when you need it.',
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            Color.lerp(
                  theme.colorScheme.primary,
                  const Color(0xFF142C54),
                  0.45,
                ) ??
                theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'HOME SERVICES, SIMPLIFIED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your home deserves\nthe best care.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Find professionals for everyday home needs.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Explore services that fit your needs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_ServiceCategory category) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProvidersScreen(serviceName: category.name),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(category.icon, color: category.iconColor, size: 25),
              ),
              const Spacer(),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Explore professionals',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsPage() {
    final theme = Theme.of(context);

    return _PlaceholderPage(
      icon: Icons.calendar_month_outlined,
      title: 'My Bookings',
      description:
          'Your upcoming and previous service bookings will appear here.',
      actionLabel: 'Explore Services',
      onAction: () => setState(() => _selectedIndex = 0),
      iconColor: theme.colorScheme.primary,
    );
  }

  Widget _buildWalletPage() {
    final theme = Theme.of(context);

    return _PlaceholderPage(
      icon: Icons.account_balance_wallet_outlined,
      title: 'My Wallet',
      description:
          'Your wallet balance and transaction history will appear here.',
      actionLabel: 'Explore Services',
      onAction: () => setState(() => _selectedIndex = 0),
      iconColor: theme.colorScheme.primary,
    );
  }

  Widget _buildProfilePage() {
    final theme = Theme.of(context);
    final displayName = widget.user.displayName?.trim();
    final email = widget.user.email?.trim();
    final phone = widget.user.phoneNumber?.trim();

    final name = displayName != null && displayName.isNotEmpty
        ? displayName
        : 'Customer';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 14),
          CircleAvatar(
            radius: 42,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person_rounded,
              size: 46,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              email?.isNotEmpty == true
                  ? email!
                  : (phone?.isNotEmpty == true ? phone! : 'Account details'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Saved Location'),
            subtitle: Text(_location),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _showLocationDialog,
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('My Bookings'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('My Wallet'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLocationDialog() async {
    final controller = TextEditingController(
      text: _location == 'Select your location' ? '' : _location,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Set your location'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter area, city or address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('Save Location'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || result == null || result.isEmpty) return;

    setState(() => _location = result);
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !mounted) return;

    try {
      await AuthService.signOut();
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to sign out. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ServiceCategory {
  const _ServiceCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String name;
  final IconData icon;
  final Color color;
  final Color iconColor;
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: iconColor),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
