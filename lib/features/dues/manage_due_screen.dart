import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/due.dart';
import '../../core/models/account.dart';
import '../../shared/theme/app_theme.dart';

/// Manage due screen
/// Add or edit a due (money owed)
class ManageDueScreen extends StatefulWidget {
  final Due? due;
  
  const ManageDueScreen({super.key, this.due});

  @override
  State<ManageDueScreen> createState() => _ManageDueScreenState();
}

class _ManageDueScreenState extends State<ManageDueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _amountController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Account> _accounts = [];
  Account? _selectedAccount;
  DueType _type = DueType.owedToMe;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // If editing, populate fields
    if (widget.due != null) {
      _personNameController.text = widget.due!.personName;
      _amountController.text = widget.due!.amount.toString();
      _type = widget.due!.type;
    }
  }

  Future<void> _loadData() async {
    final accountMaps = await _db.query('accounts', orderBy: 'name ASC');
    final accounts = accountMaps.map((m) => Account.fromMap(m)).toList();
    
    setState(() {
      _accounts = accounts;
      _isLoading = false;
      
      // Set selected account
      if (widget.due != null && widget.due!.accountId != null) {
        _selectedAccount = accounts.firstWhere(
          (a) => a.id == widget.due!.accountId,
          orElse: () => accounts.first,
        );
      } else if (accounts.isNotEmpty) {
        _selectedAccount = accounts.first;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final due = Due(
        id: widget.due?.id,
        personName: _personNameController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _type,
        status: widget.due?.status ?? DueStatus.open,
        accountId: _selectedAccount?.id,
      );

      if (widget.due == null) {
        // Create new
        await _db.insert('dues', due.toMap());
      } else {
        // Update existing
        await _db.update(
          'dues',
          due.toMap(),
          where: 'id = ?',
          whereArgs: [widget.due!.id],
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.due == null ? 'Add Due' : 'Edit Due'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Type selection
                  const Text(
                    'Type *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _type = DueType.owedToMe),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _type == DueType.owedToMe
                                  ? Colors.green.shade50
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: _type == DueType.owedToMe
                                    ? Colors.green.shade300
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: _type == DueType.owedToMe
                                      ? Colors.green.shade700
                                      : AppTheme.textSecondary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Owed to Me',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _type == DueType.owedToMe
                                        ? Colors.green.shade700
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _type = DueType.iOwe),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _type == DueType.iOwe
                                  ? Colors.red.shade50
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: _type == DueType.iOwe
                                    ? Colors.red.shade300
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: _type == DueType.iOwe
                                      ? Colors.red.shade700
                                      : AppTheme.textSecondary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'I Owe',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _type == DueType.iOwe
                                        ? Colors.red.shade700
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Person name input
                  const Text(
                    'Person Name *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _personNameController,
                    autofocus: widget.due == null,
                    decoration: InputDecoration(
                      hintText: 'e.g., John, Alice, Friend',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Amount input
                  const Text(
                    'Amount *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Account selection (optional)
                  const Text(
                    'Linked Account (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: DropdownButtonFormField<Account?>(
                      value: _selectedAccount,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      hint: const Text('None'),
                      items: [
                        const DropdownMenuItem<Account?>(
                          value: null,
                          child: Text('No account'),
                        ),
                        ..._accounts.map((account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(account.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedAccount = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _type == DueType.owedToMe
                          ? Colors.green
                          : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.due == null ? 'Add Due' : 'Save Changes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
