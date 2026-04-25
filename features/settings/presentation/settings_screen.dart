import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/presentation/components/glass_container.dart';
import '../../../core/presentation/components/bounce_button.dart';
import '../../../core/presentation/components/shimmer_widget.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/firestore_sync_service.dart';
import '../../auth/domain/profile_model.dart';
import '../application/settings_provider.dart';
import '../../home/application/home_provider.dart';

// ✅ Tambahan import untuk fitur Export (Bagian 5d)
import '../application/export_service.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

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

  void _switchProfile(String profileId) async {
    await HiveService.setActiveProfileId(profileId);

    ref.invalidate(activeProfileProvider);
    ref.invalidate(homeSummaryProvider);
    ref.invalidate(recentTransactionsProvider);

    if (mounted) context.go('/');
  }

  Future<void> _seedDefaultCategories(String profileId) async {
    final db = await DatabaseService().database;
    final defaults = [
      {'name': 'Makanan & Minuman', 'icon': '🍔', 'colorValue': 0xFFFF7043},
      {'name': 'Transportasi', 'icon': '🚗', 'colorValue': 0xFF42A5F5},
      {'name': 'Belanja', 'icon': '🛍️', 'colorValue': 0xFFEC407A},
      {'name': 'Tagihan', 'icon': '🧾', 'colorValue': 0xFF78909C},
      {'name': 'Hiburan', 'icon': '🎮', 'colorValue': 0xFFAB47BC},
      {'name': 'Kesehatan', 'icon': '💊', 'colorValue': 0xFF26A69A},
      {'name': 'Gaji', 'icon': '💼', 'colorValue': 0xFFC9A84C},
      {'name': 'Investasi', 'icon': '📈', 'colorValue': 0xFF66BB6A},
    ];
    for (final cat in defaults) {
      await db.insert('categories', {
        'id': const Uuid().v4(),
        'profileId': profileId,
        'name': cat['name'],
        'icon': cat['icon'],
        'colorValue': cat['colorValue'],
        'isDefault': 1,
      });
    }
  }

  void _addProfile(String name) async {
    final newProfile = ProfileModel(
      id: const Uuid().v4(),
      name: name,
      email: '',
      currency: 'IDR',
    );
    final db = await DatabaseService().database;
    await db.insert('profiles', newProfile.toMap());
    await _seedDefaultCategories(newProfile.id);
    ref.invalidate(allProfilesProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Profil & Pengaturan',
              style: AppTextStyles.heading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Profil Aktif'),
            const SizedBox(height: 12),
            _buildProfileSelector(),
            const SizedBox(height: 32),

            _buildSectionTitle('Export Data'),
            const SizedBox(height: 12),
            _buildExportSection(),
            const SizedBox(height: 32),

            _buildSectionTitle('Notifikasi'),
            const SizedBox(height: 12),
            _buildNotificationSection(),
            const SizedBox(height: 32),

            _buildSectionTitle('Data & Sinkronisasi'),
            const SizedBox(height: 12),
            _buildDataSection(),
            const SizedBox(height: 32),

            _buildSectionTitle('Keamanan'),
            const SizedBox(height: 12),
            _buildSecuritySection(),
            const SizedBox(height: 32),

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
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Keluar dari Akun',
                  style: AppTextStyles.buttonLabel.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading.copyWith(fontSize: 16));
  }

  Widget _buildProfileSelector() {
    final profilesAsync = ref.watch(allProfilesProvider);
    final activeId = HiveService.activeProfileId;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          profilesAsync.when(
            data: (profiles) {
              if (profiles.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Belum ada profil'),
                );
              }
              return Column(
                children: List.generate(profiles.length, (index) {
                  final item = profiles[index];
                  final profile = item.profile;
                  final isActive = activeId == profile.id;

                  return GestureDetector(
                    onTap: () => _switchProfile(profile.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        bottom: index < profiles.length - 1 ? 12 : 0,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.inputBorder,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: isActive
                                ? AppColors.primary
                                : AppColors.surface,
                            child: Icon(
                              Icons.person,
                              color: isActive
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Saldo: Rp ${_formatCompact(item.balance.toInt())}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
            loading: () => const Column(
              children: [
                ShimmerWidget(
                  width: double.infinity,
                  height: 70,
                  borderRadius: 12,
                ),
                SizedBox(height: 12),
                ShimmerWidget(
                  width: double.infinity,
                  height: 70,
                  borderRadius: 12,
                ),
              ],
            ),
            error: (_, _) => const Text('Gagal memuat profil'),
          ),
          const SizedBox(height: 12),
          BounceButton(
            onTap: () => _showAddProfileDialog(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah Profil',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
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
              Text(
                'Tambah Profil Baru',
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtl,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  hintText: 'Nama Profil',
                  prefixIcon: Icon(Icons.person_add, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtl.text.isNotEmpty) {
                      _addProfile(nameCtl.text);
                      if (context.mounted) Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Simpan',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              Text(
                'Pilih Scope Export',
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildScopeTile(
                'Bulan Ini',
                Icons.calendar_today,
                () => _doExport(type, 'Bulan Ini', ctx),
              ),
              const SizedBox(height: 8),
              _buildScopeTile(
                'Per Kategori',
                Icons.category,
                () => _doExport(type, 'Per Kategori', ctx),
              ),
              const SizedBox(height: 8),
              _buildScopeTile(
                'Semua Data',
                Icons.storage,
                () => _doExport(type, 'Semua Data', ctx),
              ),
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

  // ✅ BAGIAN 5d DIPERBAIKI: Sambungan Ke Data Transaksi Nyata
  Future<void> _doExport(String type, String scope, BuildContext ctx) async {
    Navigator.pop(ctx);
    final profileId = HiveService.activeProfileId;
    if (profileId == null) return;

    try {
      final repo = ref.read(transactionRepositoryProvider);
      List<TransactionModel> transactions = await repo.getTransactions(
        profileId,
      );

      // Filter berdasarkan scope
      final now = DateTime.now();
      if (scope == 'Bulan Ini') {
        transactions = transactions
            .where((t) => t.date.month == now.month && t.date.year == now.year)
            .toList();
      } else if (scope == 'Per Kategori') {
        transactions.sort((a, b) => a.categoryId.compareTo(b.categoryId));
      } else {
        // Semua Data, default urut berdasarkan tanggal terbaru
        transactions.sort((a, b) => b.date.compareTo(a.date));
      }

      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada data transaksi untuk di-export.'),
            ),
          );
        }
        return;
      }

      if (type == 'pdf') {
        await ExportService.exportToPdf(transactions);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil export ke PDF!')),
          );
        }
      } else {
        await ExportService.exportToCsv(transactions);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil export ke CSV! Cek folder dokumen Anda.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export data: $e')));
      }
    }
  }

  Widget _buildNotificationSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengingat Harian',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Notifikasi untuk mencatat pengeluaran',
                      style: AppTextStyles.caption,
                    ),
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
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primary,
                          surface: AppColors.surface,
                        ),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Jam pengingat: ${_reminderTime.format(context)}',
                      style: AppTextStyles.body,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.edit,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
            trailing: Text(
              'Aktif',
              style: AppTextStyles.caption.copyWith(color: AppColors.success),
            ),
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
                  title: Text(
                    'Hapus Semua Data?',
                    style: AppTextStyles.heading,
                  ),
                  content: Text(
                    'Tindakan ini tidak bisa dibatalkan.',
                    style: AppTextStyles.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final db = await DatabaseService().database;
                        await db.delete('transactions');
                        await db.delete('budgets');
                        await db.delete('categories');
                        ref.invalidate(allProfilesProvider);
                        if (mounted) {
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil dihapus'),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: AppColors.danger),
                      ),
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
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(color: AppColors.inputBorder.withValues(alpha: 0.5), height: 16);

  String _formatCompact(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toString();
  }
}
