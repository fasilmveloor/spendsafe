import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/fund.dart';
import '../../shared/theme/app_theme.dart';

/// Create fund screen
/// Create a new sinking fund for savings goals
class CreateFundScreen extends StatefulWidget {
  final Fund? fund;
  
  const CreateFundScreen({super.key, this.fund});

  @override
  State<CreateFundScreen> createState() => _CreateFundScreenState();
}

class _CreateFundScreenState extends State<CreateFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  FundLabel _selectedLabel = FundLabel.goal;
  FundStorageType _selectedStorageType = FundStorageType.cash;
  DateTime? _targetDate;
  bool _isSaving = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final fund = Fund(
        id: widget.fund?.id,
        name: _nameController.text.trim(),
        label: _selectedLabel,
        storageType: _selectedStorageType,
        targetAmount: _targetAmountController.text.isEmpty
            ? 0
            : double.parse(_targetAmountController.text),
        targetDate: _targetDate,
        isActive: widget.fund?.isActive ?? true,
      );

      if (widget.fund == null) {
        // Create new
        await _db.insert('funds', fund.toMap());
      } else {
        // Update existing
        await _db.update(
          'funds',
          fund.toMap(),
          where: 'id = ?',
          whereArgs: [widget.fund!.id],
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving fund: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields
    if (widget.fund != null) {
      _nameController.text = widget.fund!.name;
      _selectedLabel = widget.fund!.label;
      _selectedStorageType = widget.fund!.storageType;
      if (widget.fund!.targetAmount > 0) {
        _targetAmountController.text = widget.fund!.targetAmount.toString();
      }
      _targetDate = widget.fund!.targetDate;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fund == null ? 'Create Fund' : 'Edit Fund'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
                      'Funds help you save for future goals. Monthly contributions reduce your Available to Spend.',
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
            
            // Name input
            const Text(
              'Fund Name *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., Emergency Fund, Vacation, New Car',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a fund name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Label selection
            const Text(
              'Fund Type *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: FundLabel.values.map((label) {
                final isSelected = _selectedLabel == label;
                return ChoiceChip(
                  label: Text(label.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLabel = label);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Storage type selection
            const Text(
              'Storage Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: FundStorageType.values.map((type) {
                final isSelected = _selectedStorageType == type;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStorageType = type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Target amount input
            const Text(
              'Target Amount (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: 'Leave empty for no target',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Target date selection
            const Text(
              'Target Date (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _targetDate == null
                          ? 'Select target date'
                          : dateFormat.format(_targetDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _targetDate == null
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (_targetDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() => _targetDate = null);
                        },
                      ),
                  ],
                ),
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
                      widget.fund == null ? 'Create Fund' : 'Save Changes',
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
