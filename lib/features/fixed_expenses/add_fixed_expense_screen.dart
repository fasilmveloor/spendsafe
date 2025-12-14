import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/fixed_expense.dart';
import '../../core/models/account.dart';
import '../../shared/theme/app_theme.dart';

/// Add/Edit fixed expense screen
class AddFixedExpenseScreen extends StatefulWidget {
  final FixedExpense? fixedExpense;
  
  const AddFixedExpenseScreen({super.key, this.fixedExpense});

  @override
  State<AddFixedExpenseScreen> createState() => _AddFixedExpenseScreenState();
}

class _AddFixedExpenseScreenState extends State<AddFixedExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Account> _accounts = [];
  Account? _selectedAccount;
  int _dueDay = 1;
  bool _isActive = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // If editing, populate fields
    if (widget.fixedExpense != null) {
      _nameController.text = widget.fixedExpense!.name;
      _amountController.text = widget.fixedExpense!.amount.toString();
      _dueDay = widget.fixedExpense!.dueDay;
      _isActive = widget.fixedExpense!.isActive;
    }
  }

  Future<void> _loadData() async {
    final accountMaps = await _db.query('accounts', orderBy: 'name ASC');
    final accounts = accountMaps.map((m) => Account.fromMap(m)).toList();
    
    setState(() {
      _accounts = accounts;
      _isLoading = false;
      
      // Set selected account
      if (widget.fixedExpense != null) {
        _selectedAccount = accounts.firstWhere(
          (a) => a.id == widget.fixedExpense!.accountId,
          orElse: () => accounts.first,
        );
      } else if (accounts.isNotEmpty) {
        _selectedAccount = accounts.first;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final expense = FixedExpense(
        id: widget.fixedExpense?.id,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        accountId: _selectedAccount!.id!,
        dueDay: _dueDay,
        isActive: _isActive,
      );

      if (widget.fixedExpense == null) {
        // Create new
        await _db.insert('fixed_expenses', expense.toMap());
      } else {
        // Update existing
        await _db.update(
          'fixed_expenses',
          expense.toMap(),
          where: 'id = ?',
          whereArgs: [widget.fixedExpense!.id],
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
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fixedExpense == null ? 'Add Fixed Expense' : 'Edit Fixed Expense'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Name input
                  const Text(
                    'Expense Name *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    autofocus: widget.fixedExpense == null,
                    decoration: InputDecoration(
                      hintText: 'e.g., Rent, Netflix, Gym',
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
                    'Monthly Amount *',
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

                  // Due day selector
                  const Text(
                    'Due Day (1-31) *',
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
                    child: DropdownButtonFormField<int>(
                      value: _dueDay,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: List.generate(31, (index) {
                        final day = index + 1;
                        return DropdownMenuItem(
                          value: day,
                          child: Text('Day $day of the month'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _dueDay = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Account selection
                  const Text(
                    'Payment Account *',
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
                    child: DropdownButtonFormField<Account>(
                      value: _selectedAccount,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      hint: const Text('Select account'),
                      items: _accounts.map((account) {
                        return DropdownMenuItem(
                          value: account,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAccount = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Active expenses reduce Available to Spend',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                            widget.fixedExpense == null ? 'Add Fixed Expense' : 'Save Changes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
