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
  // -------------------- Controllers --------------------
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // -------------------- Original Values --------------------
  String _originalName = '';
  String _originalEmail = '';
  String _originalPhone = '';
  String _originalNationality = '';

  // -------------------- Current State --------------------
  String _selectedNationality = '';
  bool _hasChanges = false;
  bool _isLoadingProfile = true;

  // -------------------- Nationalities --------------------
  final List<String> _nationalities = [
    'Egyptian',
    'Saudi',
    'Emirati',
    'Kuwaiti',
    'Jordanian',
    'Moroccan',
    'Other',
  ];

  // -------------------- Lifecycle --------------------
  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _setupListeners();
  }

  void _setupListeners() {
    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
  }

  // -------------------- Data Methods --------------------
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

    // ignore: use_build_context_synchronously
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
      (route) => false,
    );
  }

  // -------------------- Helpers --------------------
  void _checkForChanges() {
    if (_isLoadingProfile) return;

    final hasChanged =
        _nameController.text != _originalName ||
        _emailController.text != _originalEmail ||
        _phoneController.text != _originalPhone ||
        _selectedNationality != _originalNationality;

    if (hasChanged != _hasChanges) {
      setState(() => _hasChanges = hasChanged);
    }
  }

  void _showNationalityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Nationality'),
          children: _nationalities.map((nation) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedNationality = nation;
                  _checkForChanges();
                });
                Navigator.pop(context);
              },
              child: Text(nation),
            );
          }).toList(),
        );
      },
    );
  }

  // -------------------- UI Widgets --------------------
  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: TextField(
        controller: controller,
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
      onPressed: _saveProfileData,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        minimumSize: Size(double.infinity, 6.h),
      ),
      child: const Text(
        "Save Changes",
        style: TextStyle(color: ColorManager.white),
      ),
    );
  }

  // -------------------- Build --------------------
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
                  _buildProfileField("Name", _nameController),
                  _buildProfileField("Email", _emailController),
                  _buildProfileField("Phone", _phoneController),
                  _buildNationalityField(),
                  SizedBox(height: 2.h),
                  if (_hasChanges) _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
