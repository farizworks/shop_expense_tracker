import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../domain/entities/business.dart';
import '../providers/business_provider.dart';

class BusinessFormPage extends StatefulWidget {
  final int? businessId;

  const BusinessFormPage({super.key, this.businessId});

  @override
  State<BusinessFormPage> createState() => _BusinessFormPageState();
}

class _BusinessFormPageState extends State<BusinessFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String _selectedCategory = AppConstants.businessCategories.first;
  DateTime? _vatExpiryDate;
  DateTime? _licenseExpiryDate;
  String? _vatImagePath;
  String? _licenseImagePath;

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.businessId != null) {
      _isEditMode = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBusiness();
      });
    }
  }

  Future<void> _loadBusiness() async {
    setState(() => _isLoading = true);
    await context.read<BusinessProvider>().loadBusinessById(widget.businessId!);
    final business = context.read<BusinessProvider>().selectedBusiness;

    if (business != null) {
      _nameController.text = business.name;
      _placeController.text = business.place;
      _selectedCategory = business.category;
      _vatNumberController.text = business.vatNumber ?? '';
      _licenseNumberController.text = business.licenseNumber ?? '';
      _vatExpiryDate = business.vatExpiryDate;
      _licenseExpiryDate = business.licenseExpiryDate;
      _vatImagePath = business.vatImagePath;
      _licenseImagePath = business.licenseImagePath;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _vatNumberController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isVat) async {
    // Use professional image picker helper with permission handling
    final imageFile = await ImagePickerHelper.pickImageFromGallery(context);

    if (imageFile != null) {
      // Save image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedImage = await imageFile.copy(
        '${appDir.path}/$fileName',
      );

      setState(() {
        if (isVat) {
          _vatImagePath = savedImage.path;
        } else {
          _licenseImagePath = savedImage.path;
        }
      });
    }
  }

  Future<void> _selectDate(bool isVat) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isVat
          ? (_vatExpiryDate ?? DateTime.now())
          : (_licenseExpiryDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        if (isVat) {
          _vatExpiryDate = picked;
        } else {
          _licenseExpiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final business = Business(
      id: widget.businessId,
      name: _nameController.text.trim(),
      place: _placeController.text.trim(),
      category: _selectedCategory,
      vatNumber: _vatNumberController.text.trim().isEmpty
          ? null
          : _vatNumberController.text.trim(),
      vatExpiryDate: _vatExpiryDate,
      vatImagePath: _vatImagePath,
      licenseNumber: _licenseNumberController.text.trim().isEmpty
          ? null
          : _licenseNumberController.text.trim(),
      licenseExpiryDate: _licenseExpiryDate,
      licenseImagePath: _licenseImagePath,
      createdAt: _isEditMode
          ? context.read<BusinessProvider>().selectedBusiness!.createdAt
          : now,
      updatedAt: now,
    );

    final provider = context.read<BusinessProvider>();
    final success = _isEditMode
        ? await provider.editBusiness(business)
        : await provider.addBusiness(business);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Business' : 'Add Business'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildVatSection(),
                    const SizedBox(height: 24),
                    _buildLicenseSection(),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: _isEditMode ? 'Update Business' : 'Add Business',
                      onPressed: _saveBusiness,
                      isLoading: _isLoading,
                      icon: _isEditMode ? Icons.update : Icons.add,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: 'Business Name',
              prefixIcon: Icons.store,
              validator: (value) => Validators.validateRequired(value, 'Business name'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _placeController,
              labelText: 'Place/Location',
              prefixIcon: Icons.location_on,
              validator: (value) => Validators.validateRequired(value, 'Place'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.businessCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVatSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VAT Information (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _vatNumberController,
              labelText: 'VAT Number',
              prefixIcon: Icons.receipt,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(
                text: _vatExpiryDate != null
                    ? DateFormatter.formatForDisplay(_vatExpiryDate!)
                    : '',
              ),
              labelText: 'VAT Expiry Date',
              prefixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(true),
              suffixIcon: _vatExpiryDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _vatExpiryDate = null),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              label: 'VAT Document',
              imagePath: _vatImagePath,
              onPickImage: () => _pickImage(true),
              onRemoveImage: () => setState(() => _vatImagePath = null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'License Information (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _licenseNumberController,
              labelText: 'License Number',
              prefixIcon: Icons.assignment,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(
                text: _licenseExpiryDate != null
                    ? DateFormatter.formatForDisplay(_licenseExpiryDate!)
                    : '',
              ),
              labelText: 'License Expiry Date',
              prefixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(false),
              suffixIcon: _licenseExpiryDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _licenseExpiryDate = null),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              label: 'License Document',
              imagePath: _licenseImagePath,
              onPickImage: () => _pickImage(false),
              onRemoveImage: () => setState(() => _licenseImagePath = null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required String? imagePath,
    required VoidCallback onPickImage,
    required VoidCallback onRemoveImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.image),
                label: Text(imagePath == null ? 'Pick $label' : 'Change $label'),
              ),
            ),
            if (imagePath != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemoveImage,
              ),
            ],
          ],
        ),
        if (imagePath != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}
