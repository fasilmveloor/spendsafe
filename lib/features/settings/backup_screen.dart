import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../../shared/theme/app_theme.dart';
import '../../core/services/google_drive_service.dart';
import '../../core/db/database_helper.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  bool _isSignedIn = false;
  String? _userEmail;
  bool _isLoading = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    final isSignedIn = await _driveService.isSignedIn();
    if (isSignedIn) {
      await _driveService.signIn(); // Re-initialize client if already signed in
      setState(() {
        _isSignedIn = true;
        _userEmail = _driveService.currentUserEmail;
      });
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final account = await _driveService.signIn();
    setState(() {
      _isSignedIn = account != null;
      _userEmail = account?.email;
      _isLoading = false;
    });
  }

  Future<void> _handleSignOut() async {
    await _driveService.signOut();
    setState(() {
      _isSignedIn = false;
      _userEmail = null;
    });
  }

  Future<void> _backupToDrive() async {
    setState(() => _isBackingUp = true);
    try {
      final dbFile = await _dbHelper.getDatabaseFile();
      await _driveService.uploadBackup(dbFile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _restoreFromDrive() async {
    setState(() => _isRestoring = true);
    try {
      // 1. List backups
      final backups = await _driveService.listBackups();
      
      if (backups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No backups found in Drive.')),
          );
        }
        return;
      }

      // 2. Show selection dialog
      if (mounted) {
        final selectedFile = await showDialog<drive.File>(
          context: context,
          builder: (context) => _BackupSelectionDialog(backups: backups),
        );

        if (selectedFile != null && selectedFile.id != null) {
          // 3. Download and replace
          // Note: In a real app, you might want to close the DB connection properly first
          // or create a separate 'import' flow. For now, we replace the file.
          final restoredFile = await _driveService.downloadBackup(selectedFile.id!);
          
          if (restoredFile != null) {
            // Replace live DB with restored file
            final liveDb = await _dbHelper.getDatabaseFile();
            await liveDb.writeAsBytes(await restoredFile.readAsBytes());
            
            // Restart app suggestion
            if (mounted) {
               showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restore Complete'),
                  content: const Text('Data restored successfully. Please restart the app for changes to take effect.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Sign In Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isSignedIn ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              border: Border.all(
                color: _isSignedIn ? Colors.green.shade100 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_queue, 
                  size: 48, 
                  color: _isSignedIn ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSignedIn ? 'Connected to Drive' : 'Not Connected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _isSignedIn ? Colors.green.shade800 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignedIn 
                            ? (_userEmail ?? 'Unknown User')
                            : 'Sign in to save data to cloud',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSignedIn)
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    onPressed: _handleSignOut,
                  ),
              ],
            ),
          ),
          
          if (!_isSignedIn) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSignIn,
              icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],

          if (_isSignedIn) ...[
            const SizedBox(height: 32),
            _buildActionCard(
              title: 'Create Backup',
              description: 'Upload your current database to Google Drive.',
              icon: Icons.upload_file,
              buttonText: 'Backup Now',
              isLoading: _isBackingUp,
              onTap: _backupToDrive,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Restore Data',
              description: 'Download and overwrite with a backup from Drive.',
              icon: Icons.download_for_offline,
              buttonText: 'Restore...',
              isDestructive: true,
              isLoading: _isRestoring,
              onTap: _restoreFromDrive,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.textPrimary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? Colors.red.shade50 : AppTheme.primary.withOpacity(0.1),
                foregroundColor: isDestructive ? Colors.red : AppTheme.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDestructive ? Colors.red : AppTheme.primary,
                      ),
                    )
                  : Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupSelectionDialog extends StatelessWidget {
  final List<drive.File> backups;

  const _BackupSelectionDialog({required this.backups});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Backup'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: backups.length,
          itemBuilder: (context, index) {
            final file = backups[index];
            final date = file.createdTime != null
                ? DateFormat.yMMMd().add_jm().format(file.createdTime!)
                : 'Unknown Date';
            
            return ListTile(
              leading: const Icon(Icons.restore),
              title: Text(date),
              subtitle: Text(file.name ?? 'Untitled'),
              onTap: () => Navigator.pop(context, file),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
