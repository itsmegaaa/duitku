import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/bounce_button.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/firestore_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  int _activeProfileIndex = 0;

  // Dummy profiles for Multi-Profil (Bagian 10)
  final List<Map<String, dynamic>> _profiles = [
    {'name': 'Budi Santoso', 'avatar': Icons.person, 'balance': 12500000},
    {'name': 'Siti Aisyah', 'avatar': Icons.person_2, 'balance': 8300000},
    {'name': 'Anak', 'avatar': Icons.child_care, 'balance': 500000},
  ];

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    final saved = await NotificationService.getSavedReminderTime();
    if (saved != null && mounted) {
      setState(() {
        _reminderEnabled = true;
        _reminderTime = saved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Text('Profil & Pengaturan', style: AppTextStyles.heading.copyWith(fontSize: 24)),
            const SizedBox(height: 24),

            // ── Bagian 10: Multi Profil ─────────────────────
            _buildSectionTitle('Profil Aktif'),
            const SizedBox(height: 12),
            _buildProfileSelector(),
            const SizedBox(height: 32),

            // ── Bagian 9: Export Data ────────────────────────
            _buildSectionTitle('Export Data'),
            const SizedBox(height: 12),
            _buildExportSection(),
            const SizedBox(height: 32),

            // ── Bagian 12: Notifikasi ───────────────────────
            _buildSectionTitle('Notifikasi'),
            const SizedBox(height: 12),
            _buildNotificationSection(),
            const SizedBox(height: 32),

            // ── Bagian 11: Data & Sync ──────────────────────
            _buildSectionTitle('Data & Sinkronisasi'),
            const SizedBox(height: 12),
            _buildDataSection(),
            const SizedBox(height: 32),

            // ── Keamanan ────────────────────────────────────
            _buildSectionTitle('Keamanan'),
            const SizedBox(height: 12),
            _buildSecuritySection(),
            const SizedBox(height: 32),

            // ── Logout ──────────────────────────────────────
            BounceButton(
              onTap: () async {
                await HiveService.setAuthenticated(false);
                if (context.mounted) context.go('/auth/login');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text('Keluar dari Akun', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.danger)),
              ),
            ),
            const SizedBox(height: 100), // navbar spacing
          ],
        ),
      ),
    );
  }

  // ─── Section Title ─────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading.copyWith(fontSize: 16));
  }

  // ─── Multi Profil (Bagian 10) ──────────────────────────
  Widget _buildProfileSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...List.generate(_profiles.length, (index) {
            final profile = _profiles[index];
            final isActive = _activeProfileIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _activeProfileIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: index < _profiles.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.inputBorder,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isActive ? AppColors.primary : AppColors.surface,
                      child: Icon(profile['avatar'] as IconData, color: isActive ? AppColors.background : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile['name'] as String, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            'Saldo: Rp ${_formatCompact(profile['balance'] as int)}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          BounceButton(
            onTap: () => _showAddProfileDialog(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), style: BorderStyle.solid),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Tambah Profil', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProfileDialog() {
    final nameCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tambah Profil Baru', style: AppTextStyles.heading, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtl,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(hintText: 'Nama Profil', prefixIcon: Icon(Icons.person_add)),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtl.text.isNotEmpty) {
                      setState(() {
                        _profiles.add({'name': nameCtl.text, 'avatar': Icons.person, 'balance': 0});
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  child: Text('Simpan', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.background)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Export Section (Bagian 9) ──────────────────────────
  Widget _buildExportSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.picture_as_pdf,
            title: 'Export PDF',
            subtitle: 'Laporan rapi dengan tabel & rangkuman',
            onTap: () => _showExportScopeDialog('pdf'),
          ),
          _divider(),
          _buildSettingsTile(
            icon: Icons.table_chart,
            title: 'Export CSV',
            subtitle: 'Untuk analisis di spreadsheet',
            onTap: () => _showExportScopeDialog('csv'),
          ),
        ],
      ),
    );
  }

  void _showExportScopeDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pilih Scope Export', style: AppTextStyles.heading, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _buildScopeTile('Bulan Ini', Icons.calendar_today, () => _doExport(type, 'Bulan Ini', ctx)),
              const SizedBox(height: 8),
              _buildScopeTile('Per Kategori', Icons.category, () => _doExport(type, 'Per Kategori', ctx)),
              const SizedBox(height: 8),
              _buildScopeTile('Semua Data', Icons.storage, () => _doExport(type, 'Semua Data', ctx)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScopeTile(String label, IconData icon, VoidCallback onTap) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _doExport(String type, String scope, BuildContext ctx) async {
    Navigator.pop(ctx);
    if (type == 'pdf') {
      await ExportService.exportPdf(context, scope: scope);
    } else {
      final path = await ExportService.exportCsv();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV tersimpan di: $path')),
        );
      }
    }
  }

  // ─── Notification Section (Bagian 12) ──────────────────
  Widget _buildNotificationSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengingat Harian', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('Notifikasi untuk mencatat pengeluaran', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Switch(
                value: _reminderEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (val) async {
                  setState(() => _reminderEnabled = val);
                  if (val) {
                    await NotificationService.scheduleDailyReminder(
                      hour: _reminderTime.hour,
                      minute: _reminderTime.minute,
                    );
                  } else {
                    await NotificationService.cancelAll();
                  }
                },
              ),
            ],
          ),
          if (_reminderEnabled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _reminderTime = picked);
                  await NotificationService.scheduleDailyReminder(
                    hour: picked.hour,
                    minute: picked.minute,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text('Jam pengingat: ${_reminderTime.format(context)}', style: AppTextStyles.body),
                    const Spacer(),
                    const Icon(Icons.edit, color: AppColors.textSecondary, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Data Section (Bagian 11) ──────────────────────────
  Widget _buildDataSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.cloud_sync,
            title: 'Sinkronisasi Cloud',
            subtitle: 'Sinkronkan data ke Firebase Firestore',
            onTap: () async {
              await FirestoreSyncService.fullSync();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sinkronisasi selesai!')),
                );
              }
            },
          ),
          _divider(),
          _buildSettingsTile(
            icon: Icons.storage,
            title: 'Penyimpanan Lokal',
            subtitle: 'Data tersimpan offline via Hive',
            trailing: Text('Aktif', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
          ),
          _divider(),
          _buildSettingsTile(
            icon: Icons.delete_sweep,
            title: 'Hapus Semua Data',
            subtitle: 'Menghapus seluruh data lokal',
            titleColor: AppColors.danger,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text('Hapus Semua Data?', style: AppTextStyles.heading),
                  content: Text('Tindakan ini tidak bisa dibatalkan.', style: AppTextStyles.body),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Hapus', style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Security Section ──────────────────────────────────
  Widget _buildSecuritySection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.lock_reset,
            title: 'Ubah PIN',
            subtitle: 'Ganti PIN 6 digit',
            onTap: () => context.push('/auth/pin-setup'),
          ),
          _divider(),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometrik',
            subtitle: 'Gunakan sidik jari untuk membuka app',
            trailing: Switch(
              value: HiveService.isPinActive,
              activeThumbColor: AppColors.primary,
              onChanged: (val) async {
                await HiveService.setIsPinActive(val);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared Helpers ────────────────────────────────────
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: titleColor)),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(color: AppColors.inputBorder.withValues(alpha: 0.5), height: 16);

  String _formatCompact(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toString();
  }
}
