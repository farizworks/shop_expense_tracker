import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../domain/entities/expense_item.dart';

class ExpenseItemInput extends StatefulWidget {
  final String type; // 'shop' or 'misc'
  final List<ExpenseItem> initialItems;
  final Function(List<ExpenseItem>) onItemsChanged;

  const ExpenseItemInput({
    super.key,
    required this.type,
    this.initialItems = const [],
    required this.onItemsChanged,
  });

  @override
  State<ExpenseItemInput> createState() => _ExpenseItemInputState();
}

class _ExpenseItemInputState extends State<ExpenseItemInput> {
  final List<_ExpenseItemData> _items = [];
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadInitialItems();

    // Notify changes after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only set _isInitialLoad to false if we started with non-empty items
      // If we started with empty items, keep it true to allow edit mode data to load
      if (widget.initialItems.isNotEmpty) {
        _isInitialLoad = false;
      }
      _notifyChanges();
    });
  }

  @override
  void didUpdateWidget(ExpenseItemInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Skip updates after initial load - widget manages its own state
    // Only reload if this is during initial load phase
    if (_isInitialLoad) {
      // Only reload if the actual content changed, not just the reference
      // Check if lengths are different first (quick check)
      if (oldWidget.initialItems.length != widget.initialItems.length) {
        _clearItems();
        _loadInitialItems();

        // If we now have items, we can mark initial load as complete
        if (widget.initialItems.isNotEmpty) {
          _isInitialLoad = false;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifyChanges();
        });
        return;
      }

      // If lengths are the same, check if content actually changed
      bool contentChanged = false;
      for (int i = 0; i < widget.initialItems.length; i++) {
        final oldItem = oldWidget.initialItems[i];
        final newItem = widget.initialItems[i];
        if (oldItem.name != newItem.name ||
            oldItem.amount != newItem.amount ||
            oldItem.imagePath != newItem.imagePath) {
          contentChanged = true;
          break;
        }
      }

      if (contentChanged) {
        _clearItems();
        _loadInitialItems();

        // If we now have items, we can mark initial load as complete
        if (widget.initialItems.isNotEmpty) {
          _isInitialLoad = false;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifyChanges();
        });
      }
    } else {
    }
  }

  void _loadInitialItems() {

    if (widget.initialItems.isNotEmpty) {
      for (final item in widget.initialItems) {
        final itemData = _ExpenseItemData(
          nameController: TextEditingController(text: item.name),
          amountController: TextEditingController(text: item.amount.toString()),
          imagePath: item.imagePath,
        );
        _addListenersToItem(itemData);
        _items.add(itemData);
      }
    } else {
      // Add initial item without triggering notification during init
      final itemData = _ExpenseItemData(
        nameController: TextEditingController(),
        amountController: TextEditingController(text: '0'),
      );
      _addListenersToItem(itemData);
      _items.add(itemData);
    }

  }

  void _addListenersToItem(_ExpenseItemData item) {
    item.nameController.addListener(() {
      // Defer notification to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyChanges();
      });
    });
    item.amountController.addListener(() {
      // Defer notification to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyChanges();
      });
    });
  }

  void _clearItems() {
    for (final item in _items) {
      item.nameController.dispose();
      item.amountController.dispose();
    }
    _items.clear();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.nameController.dispose();
      item.amountController.dispose();
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      final itemData = _ExpenseItemData(
        nameController: TextEditingController(),
        amountController: TextEditingController(text: '0'),
      );
      _addListenersToItem(itemData);
      _items.add(itemData);
    });
    // Defer notification to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].nameController.dispose();
      _items[index].amountController.dispose();
      _items.removeAt(index);
      if (_items.isEmpty) {
        // Add item without calling _addNewItem to avoid double notification
        final itemData = _ExpenseItemData(
          nameController: TextEditingController(),
          amountController: TextEditingController(text: '0'),
        );
        _addListenersToItem(itemData);
        _items.add(itemData);
      }
    });
    // Defer notification to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  Future<void> _pickImage(int index) async {
    // Use professional image picker helper with permission handling
    final imageFile = await ImagePickerHelper.pickImageFromGallery(context);

    if (imageFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedImage = await imageFile.copy(
        '${appDir.path}/$fileName',
      );

      setState(() {
        _items[index].imagePath = savedImage.path;
      });
      // Defer notification to after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyChanges();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _items[index].imagePath = null;
    });
    // Defer notification to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  void _notifyChanges() {
    final validItems = <ExpenseItem>[];
    for (final itemData in _items) {
      final name = itemData.nameController.text.trim();
      final amountText = itemData.amountController.text.trim();

      if (name.isNotEmpty && amountText.isNotEmpty) {
        final amount = double.tryParse(amountText) ?? 0;
        if (amount > 0) {
          validItems.add(ExpenseItem(
            dailyEntryId: 0, // Will be set when saving
            name: name,
            amount: amount,
            imagePath: itemData.imagePath,
            type: widget.type,
            createdAt: DateTime.now(),
          ));
        }
      }
    }
    widget.onItemsChanged(validItems);
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) {
      final amount = double.tryParse(item.amountController.text) ?? 0;
      return sum + amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.type == 'shop' ? 'Shop Expenses' : 'Miscellaneous Expenses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Total: AED ${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return _buildItemCard(index);
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addNewItem,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ],
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: item.nameController,
                    labelText: 'Item Name',
                    hintText: 'e.g., Vegetables',
                    validator: (value) => null, // Optional validation
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: item.amountController,
                    labelText: 'Amount',
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePositiveNumber,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(index),
                    icon: const Icon(Icons.image),
                    label: Text(
                      item.imagePath == null ? 'Add Bill Image' : 'Change Image',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                if (item.imagePath != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _removeImage(index),
                  ),
                ],
              ],
            ),
            if (item.imagePath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(item.imagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseItemData {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String? imagePath;

  _ExpenseItemData({
    required this.nameController,
    required this.amountController,
    this.imagePath,
  });
}
