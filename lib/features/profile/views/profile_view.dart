import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_text_project/core/resources/app_assets_manager.dart';
import 'package:flutter_text_project/core/resources/app_color_manager.dart';
import 'package:flutter_text_project/core/route/routes.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _originalName = '';
  String _originalEmail = '';
  String _originalPhone = '';
  String _originalNationality = '';

  String _selectedNationality = '';
  bool _hasChanges = false;
  bool _isLoadingProfile = true;

  final List<String> _nationalities = [
    'Egyptian',
    'Saudi',
    'Emirati',
    'Kuwaiti',
    'Jordanian',
    'Moroccan',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _addListeners();
  }

  void _addListeners() {
    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _originalName = prefs.getString('name') ?? '';
      _originalEmail = prefs.getString('email') ?? '';
      _originalPhone = prefs.getString('phone') ?? '';
      _originalNationality = prefs.getString('nationality') ?? '';

      _nameController.text = _originalName;
      _emailController.text = _originalEmail;
      _phoneController.text = _originalPhone;
      _selectedNationality = _originalNationality;

      _hasChanges = false;
      _isLoadingProfile = false;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('nationality', _selectedNationality);

    setState(() {
      _originalName = _nameController.text;
      _originalEmail = _emailController.text;
      _originalPhone = _phoneController.text;
      _originalNationality = _selectedNationality;
      _hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      PageRouteName.signUp,
      (_) => false,
    );
  }

  void _checkForChanges() {
    if (_isLoadingProfile) return;

    final changed =
        _nameController.text != _originalName ||
        _emailController.text != _originalEmail ||
        _phoneController.text != _originalPhone ||
        _selectedNationality != _originalNationality;

    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  void _showNationalityDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Nationality'),
        children: _nationalities
            .map(
              (nation) => SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    _selectedNationality = nation;
                  });
                  _checkForChanges();
                  Navigator.pop(context);
                },
                child: Text(nation),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
        ),
      ),
    );
  }

  Widget _buildNationalityField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: InkWell(
        onTap: _showNationalityDialog,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Nationality',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          child: Text(
            _selectedNationality.isEmpty
                ? 'Select nationality'
                : _selectedNationality,
            style: TextStyle(
              color: _selectedNationality.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _hasChanges ? _saveProfileData : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _hasChanges ? ColorManager.primaryColor : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        minimumSize: Size(double.infinity, 6.h),
      ),
      child: const Text(
        "Save Changes",
        style: TextStyle(color: ColorManager.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: SvgPicture.asset(
              AppAssetsManager.logout,
              width: 24,
              height: 24,
              // ignore: deprecated_member_use
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: ColorManager.greyTextFormField,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileField(
                    label: "Name",
                    controller: _nameController,
                  ),
                  _buildProfileField(
                    label: "Email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildProfileField(
                    label: "Phone",
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildNationalityField(),
                  SizedBox(height: 2.h),
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
