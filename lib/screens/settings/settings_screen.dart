import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/auth_provider.dart';

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeEnabledProvider = StateProvider<bool>((ref) => false);
final locationEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final darkModeEnabled = ref.watch(darkModeEnabledProvider);
    final locationEnabled = ref.watch(locationEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Change your name, email, photo',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Manage your privacy settings',
            onTap: () {},
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, 'Preferences'),
          SwitchListTile(
            secondary: Icon(
              Icons.notifications_outlined,
              color: Colors.grey[700],
            ),
            title: const Text('Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: notificationsEnabled,
            onChanged: (value) async {
              ref.read(notificationsEnabledProvider.notifier).state = value;
              await _saveNotificationPreference(context, ref, value);
            },
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.dark_mode_outlined,
              color: Colors.grey[700],
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to dark theme'),
            value: darkModeEnabled,
            onChanged: (value) {
              ref.read(darkModeEnabledProvider.notifier).state = value;
            },
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.location_on_outlined,
              color: Colors.grey[700],
            ),
            title: const Text('Location Services'),
            subtitle: const Text('Enable location for better experience'),
            value: locationEnabled,
            onChanged: (value) {
              ref.read(locationEnabledProvider.notifier).state = value;
            },
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, 'App'),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: 'RWF (Rwandan Franc)',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.storage,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, 'Support'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help and FAQs',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Help us improve the app',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.star_outline,
            title: 'Rate the App',
            subtitle: 'Share your experience',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _saveNotificationPreference(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateUserProfile(notificationsEnabled: value);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Notifications enabled'
                  : 'Notifications disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preference: $e')),
        );
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: 'en',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Kinyarwanda'),
              leading: Radio<String>(
                value: 'rw',
                groupValue: 'en',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('French'),
              leading: Radio<String>(
                value: 'fr',
                groupValue: 'en',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data. Your saved places and preferences will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
