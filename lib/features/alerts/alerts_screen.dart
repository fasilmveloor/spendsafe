import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/alert.dart';
import '../../shared/theme/app_theme.dart';

/// Alerts screen
/// View and manage system-generated alerts
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Alert> _alerts = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final where = _showOnlyUnread ? 'is_read = 0' : null;
    final alertMaps = await _db.query(
      'alerts',
      where: where,
      orderBy: 'created_at DESC',
    );
    final alerts = alertMaps.map((m) => Alert.fromMap(m)).toList();
    
    // Count unread
    final unreadResult = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM alerts WHERE is_read = 0',
    );
    final unread = (unreadResult.first['count'] as int?) ?? 0;
    
    setState(() {
      _alerts = alerts;
      _unreadCount = unread;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(int alertId) async {
    await _db.update(
      'alerts',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [alertId],
    );
    _loadAlerts();
  }

  Future<void> _markAllAsRead() async {
    await _db.update(
      'alerts',
      {'is_read': 1},
      where: 'is_read = 0',
    );
    _loadAlerts();
  }

  Future<void> _deleteAlert(int alertId) async {
    await _db.delete('alerts', where: 'id = ?', whereArgs: [alertId]);
    _loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, h:mm a');
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alerts'),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
          PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      _showOnlyUnread ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Show only unread'),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _showOnlyUnread = !_showOnlyUnread;
                  });
                  Future.delayed(Duration.zero, _loadAlerts);
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: _alerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showOnlyUnread ? Icons.check_circle_outline : Icons.notifications_none,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showOnlyUnread ? 'No unread alerts' : 'No alerts yet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showOnlyUnread
                                ? 'You\'re all caught up!'
                                : 'Alerts will appear here when generated',
                            style: TextStyle(
                              color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        final alert = _alerts[index];
                        final color = _getSeverityColor(alert.severity);
                        final icon = _getTypeIcon(alert.type);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key('alert_${alert.id}'),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteAlert(alert.id!);
                            },
                            child: InkWell(
                              onTap: () {
                                if (!alert.isRead) {
                                  _markAsRead(alert.id!);
                                }
                              },
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: alert.isRead ? Colors.white : color.withAlpha((0.05 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  border: Border.all(
                                    color: alert.isRead
                                        ? Colors.grey.shade100
                                        : color.withAlpha((0.3 * 255).toInt()),
                                    width: alert.isRead ? 1 : 2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color.withAlpha((0.1 * 255).toInt()),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 20,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _getTypeLabel(alert.type),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: color,
                                                  ),
                                                ),
                                              ),
                                              if (!alert.isRead)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            alert.message,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              color: alert.isRead
                                                  ? AppTheme.textSecondary
                                                  : AppTheme.textPrimary,
                                              fontWeight: alert.isRead
                                                  ? FontWeight.w400
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            dateFormat.format(alert.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary.withAlpha((0.7 * 255).toInt()),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return AppTheme.primary;
      case AlertSeverity.warning:
        return AppTheme.alertAmberIcon;
      case AlertSeverity.danger:
        return Colors.red;
    }
  }

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.pace:
        return Icons.speed;
      case AlertType.budget:
        return Icons.warning_rounded;
      case AlertType.fund:
        return Icons.savings;
      case AlertType.due:
        return Icons.people;
      case AlertType.system:
        return Icons.info;
    }
  }

  String _getTypeLabel(AlertType type) {
    switch (type) {
      case AlertType.pace:
        return 'Pace Alert';
      case AlertType.budget:
        return 'Budget Warning';
      case AlertType.fund:
        return 'Fund Update';
      case AlertType.due:
        return 'Due Reminder';
      case AlertType.system:
        return 'System';
    }
  }
}
