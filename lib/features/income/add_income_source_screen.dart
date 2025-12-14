import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/income_source.dart';
import '../../core/models/account.dart';
import '../../shared/theme/app_theme.dart';

/// Add/Edit income source screen
class AddIncomeSourceScreen extends StatefulWidget {
  final IncomeSource? incomeSource;
  
  const AddIncomeSourceScreen({super.key, this.incomeSource});

  @override
  State<AddIncomeSourceScreen> createState() => _AddIncomeSourceScreenState();
}

class _AddIncomeSourceScreenState extends State<AddIncomeSourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Account> _accounts = [];
  Account? _selectedAccount;
  bool _isActive = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // If editing, populate fields
    if (widget.incomeSource != null) {
      _nameController.text = widget.incomeSource!.name;
      _isActive = widget.incomeSource!.isActive;
    }
  }

  Future<void> _loadData() async {
    final accountMaps = await _db.query('accounts', orderBy: 'name ASC');
    final accounts = accountMaps.map((m) => Account.fromMap(m)).toList();
    
    setState(() {
      _accounts = accounts;
      _isLoading = false;
      
      // Set selected account
      if (widget.incomeSource != null) {
        _selectedAccount = accounts.firstWhere(
          (a) => a.id == widget.incomeSource!.accountId,
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
      final source = IncomeSource(
        id: widget.incomeSource?.id,
        name: _nameController.text.trim(),
        accountId: _selectedAccount!.id!,
        isActive: _isActive,
      );

      if (widget.incomeSource == null) {
        // Create new
        await _db.insert('income_sources', source.toMap());
      } else {
        // Update existing
        await _db.update(
          'income_sources',
          source.toMap(),
          where: 'id = ?',
          whereArgs: [widget.incomeSource!.id],
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incomeSource == null ? 'Add Income Source' : 'Edit Income Source'),
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
                    'Source Name *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    autofocus: widget.incomeSource == null,
                    decoration: InputDecoration(
                      hintText: 'e.g., Salary, Freelance, Business',
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

                  // Account selection
                  const Text(
                    'Default Account *',
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
                                'Active sources appear in income recording',
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
                            widget.incomeSource == null ? 'Add Source' : 'Save Changes',
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
