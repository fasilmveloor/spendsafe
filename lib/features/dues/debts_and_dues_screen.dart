import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/due.dart';
import '../../shared/theme/app_theme.dart';
import 'manage_due_screen.dart';

/// Debts & Dues screen
/// Track money owed to you or that you owe to others
class DebtsAndDuesScreen extends StatefulWidget {
  const DebtsAndDuesScreen({super.key});

  @override
  State<DebtsAndDuesScreen> createState() => _DebtsAndDuesScreenState();
}

class _DebtsAndDuesScreenState extends State<DebtsAndDuesScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Due> _dues = [];
  double _totalOwedToMe = 0.0;
  double _totalIOwe = 0.0;
  bool _isLoading = true;
  bool _showSettled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final where = _showSettled ? null : 'status = ?';
    final whereArgs = _showSettled ? null : ['open'];
    
    final dueMaps = await _db.query(
      'dues',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    final dues = dueMaps.map((m) => Due.fromMap(m)).toList();
    
    // Calculate totals (only open dues)
    double owedToMe = 0.0;
    double iOwe = 0.0;
    
    for (final due in dues) {
      if (due.status == DueStatus.open) {
        if (due.type == DueType.owedToMe) {
          owedToMe += due.amount;
        } else {
          iOwe += due.amount;
        }
      }
    }
    
    setState(() {
      _dues = dues;
      _totalOwedToMe = owedToMe;
      _totalIOwe = iOwe;
      _isLoading = false;
    });
  }

  Future<void> _settleDue(Due due) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settle Due'),
        content: Text(
          due.type == DueType.owedToMe
              ? 'Mark "${due.personName}" as paid?'
              : 'Mark payment to "${due.personName}" as complete?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Settle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.update(
        'dues',
        {'status': 'settled'},
        where: 'id = ?',
        whereArgs: [due.id],
      );
      _loadData();
    }
  }

  Future<void> _deleteDue(int id) async {
    await _db.delete('dues', where: 'id = ?', whereArgs: [id]);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts & Dues'),
        actions: [
          IconButton(
            icon: Icon(_showSettled ? Icons.visibility_off : Icons.visibility),
            tooltip: _showSettled ? 'Hide settled' : 'Show settled',
            onPressed: () {
              setState(() => _showSettled = !_showSettled);
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const ManageDueScreen(),
                ),
              );
              if (result == true) _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: Colors.green.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Owed to Me',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(_totalOwedToMe).replaceAll('.00', ''),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'I Owe',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(_totalIOwe).replaceAll('.00', ''),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Track money you owe or are owed. Open dues impact your FTS calculation.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Dues list
                  if (_dues.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _showSettled ? 'No settled dues' : 'No open dues',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Track borrowing and lending',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._dues.map((due) {
                      final color = due.type == DueType.owedToMe
                          ? Colors.green
                          : Colors.red;
                      final isSettled = due.status == DueStatus.settled;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key('due_${due.id}'),
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
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Due'),
                                content: Text('Delete "${due.personName}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            _deleteDue(due.id!);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSettled
                                  ? Colors.grey.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: isSettled
                                    ? Colors.grey.shade200
                                    : color.shade100,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.shade50,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                  ),
                                  child: Icon(
                                    due.type == DueType.owedToMe
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: color.shade700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              due.personName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                decoration: isSettled
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: isSettled
                                                    ? AppTheme.textSecondary
                                                    : AppTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (isSettled)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(
                                                  AppTheme.radiusDefault,
                                                ),
                                              ),
                                              child: const Text(
                                                'Settled',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        due.type == DueType.owedToMe
                                            ? 'Owes you'
                                            : 'You owe',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary.withAlpha(
                                            (0.8 * 255).toInt(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormat.format(due.amount).replaceAll('.00', ''),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isSettled
                                            ? AppTheme.textSecondary
                                            : color.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (!isSettled)
                                      TextButton(
                                        onPressed: () => _settleDue(due),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Settle',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: color.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
