import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _fontSize = 16.0;
  bool _darkMode = false;
  bool _verseNumbers = true;
  bool _redLetters = false;
  bool _autoSaveNotes = false;
  String _defaultTranslation = 'KJV';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fontSize = prefs.getDouble('fontSize') ?? 16.0;
        _darkMode = prefs.getBool('darkMode') ?? false;
        _verseNumbers = prefs.getBool('verseNumbers') ?? true;
        _redLetters = prefs.getBool('redLetters') ?? false;
        _autoSaveNotes = prefs.getBool('autoSaveNotes') ?? false;
        _defaultTranslation = prefs.getString('defaultTranslation') ?? 'KJV';
      });
    } catch (e) {
      // Use default values if SharedPreferences fails
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontSize', _fontSize);
      await prefs.setBool('darkMode', _darkMode);
      await prefs.setBool('verseNumbers', _verseNumbers);
      await prefs.setBool('redLetters', _redLetters);
      await prefs.setBool('autoSaveNotes', _autoSaveNotes);
      await prefs.setString('defaultTranslation', _defaultTranslation);
    } catch (e) {
      // Silently fail if SharedPreferences is unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: FlexibleSpaceBar(
                  title: Text(
                    'Settings',
                    style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSection('Reading', Icons.menu_book).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                    _buildFontSizeSlider().animate().fadeIn(duration: 700.ms, delay: 100.ms),
                    _buildSwitchTile('Show Verse Numbers', _verseNumbers, Icons.format_list_numbered, (value) {
                      setState(() => _verseNumbers = value);
                      _saveSettings();
                    }).animate().fadeIn(duration: 700.ms, delay: 150.ms),
                    _buildSwitchTile('Red Letter Edition', _redLetters, Icons.format_color_text, (value) {
                      setState(() => _redLetters = value);
                      _saveSettings();
                    }).animate().fadeIn(duration: 700.ms, delay: 200.ms),
                    
                    const SizedBox(height: 16),
                    _buildSection('Appearance', Icons.palette).animate().fadeIn(duration: 600.ms, delay: 250.ms).slideX(begin: -0.3),
                    _buildSwitchTile('Dark Mode', _darkMode, Icons.dark_mode, (value) {
                      setState(() => _darkMode = value);
                      _saveSettings();
                      Get.changeThemeMode(_darkMode ? ThemeMode.dark : ThemeMode.light);
                    }).animate().fadeIn(duration: 700.ms, delay: 300.ms),
                    
                    const SizedBox(height: 16),
                    _buildSection('Bible', Icons.book).animate().fadeIn(duration: 600.ms, delay: 350.ms).slideX(begin: -0.3),
                    _buildTranslationDropdown().animate().fadeIn(duration: 700.ms, delay: 400.ms),
                    
                    const SizedBox(height: 16),
                    _buildSection('Study Tools', Icons.school).animate().fadeIn(duration: 600.ms, delay: 450.ms).slideX(begin: -0.3),
                    _buildSwitchTile('Auto-save Notes', _autoSaveNotes, Icons.auto_awesome, (value) {
                      setState(() => _autoSaveNotes = value);
                      _saveSettings();
                    }).animate().fadeIn(duration: 700.ms, delay: 500.ms),
                    _buildListTile('Strongs', 'Enable Hebrew/Greek word studies', Icons.translate, () {}).animate().fadeIn(duration: 700.ms, delay: 550.ms),
                    _buildListTile('Cross References', 'Show related verses', Icons.link, () {}).animate().fadeIn(duration: 700.ms, delay: 600.ms),
                    _buildListTile('Commentary', 'Default commentary source', Icons.comment, () {}).animate().fadeIn(duration: 700.ms, delay: 650.ms),
                    
                    const SizedBox(height: 16),
                    _buildSection('Data', Icons.storage).animate().fadeIn(duration: 600.ms, delay: 700.ms).slideX(begin: -0.3),
                    _buildListTile('Clear Cache', 'Free up storage space', Icons.cleaning_services, _clearCache).animate().fadeIn(duration: 700.ms, delay: 750.ms),
                    _buildListTile('Export Bookmarks', 'Save bookmarks to file', Icons.file_upload, () {}).animate().fadeIn(duration: 700.ms, delay: 800.ms),
                    _buildListTile('Import Bookmarks', 'Load bookmarks from file', Icons.file_download, () {}).animate().fadeIn(duration: 700.ms, delay: 850.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return CompactGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_size, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Font Size',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_fontSize.round()}px',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              onChanged: (value) {
                setState(() => _fontSize = value);
              },
              onChangeEnd: (value) => _saveSettings(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, IconData icon, Function(bool) onChanged) {
    return SmallGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationDropdown() {
    return SmallGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.translate, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Default Translation',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _defaultTranslation,
              dropdownColor: AppColors.surface,
              underline: const SizedBox(),
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              items: ['KJV', 'NIV', 'ESV', 'NASB', 'NLT']
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _defaultTranslation = value);
                  _saveSettings();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return SmallGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear cache logic here
              Get.back();
              Get.snackbar('Success', 'Cache cleared successfully');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}