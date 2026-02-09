import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Me
  final _myNameController = TextEditingController();
  final _myNicknameController = TextEditingController();
  DateTime? _myBirthday;

  // Partner
  final _partnerNameController = TextEditingController();
  final _partnerNicknameController = TextEditingController();
  DateTime? _partnerBirthday;

  DateTime? _relationshipStart;
  String? _myAvatarPath;
  String? _partnerAvatarPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final profiles = ref.read(profileProvider);
    if (profiles.isEmpty) return;

    final me = profiles[0];
    final partner = profiles[1];

    _myNameController.text = me.name;
    _myNicknameController.text = me.nickname;
    _myBirthday = me.birthday;
    _relationshipStart = me.relationshipStartDate;
    _myAvatarPath = me.avatarPath;

    _partnerNameController.text = partner.name;
    _partnerNicknameController.text = partner.nickname;
    _partnerBirthday = partner.birthday;
    _partnerAvatarPath = partner.avatarPath;
  }

  Future<void> _pickImage(bool isPartner) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isPartner) {
          _partnerAvatarPath = image.path;
        } else {
          _myAvatarPath = image.path;
        }
      });
    }
  }

  Future<void> _saveData() async {
    final profiles = ref.read(profileProvider);
    if (profiles.length < 2) return;

    final me = profiles[0];
    final partner = profiles[1];

    // Update objects
    me.name = _myNameController.text.trim();
    me.nickname = _myNicknameController.text.trim();
    me.birthday = _myBirthday ?? me.birthday;
    me.relationshipStartDate = _relationshipStart;
    me.avatarPath = _myAvatarPath;

    partner.name = _partnerNameController.text.trim();
    partner.nickname = _partnerNicknameController.text.trim();
    partner.birthday = _partnerBirthday ?? partner.birthday;
    partner.avatarPath = _partnerAvatarPath;

    // Use provider to save everywhere
    await ref
        .read(profileProvider.notifier)
        .updateProfiles(me: me, partner: partner);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Details Updated!'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      context.pop();
    }
  }

  Future<void> _selectDate(
    BuildContext context, {
    required Function(DateTime) onPicked,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _SectionHeader(title: "My Profile"),
            _buildAvatarPicker(false),
            const SizedBox(height: 16),
            _EditField(
              controller: _myNameController,
              label: "Name",
              icon: Icons.face_rounded,
            ),
            _EditField(
              controller: _myNicknameController,
              label: "Nickname",
              icon: Icons.short_text_rounded,
            ),
            _DateSelector(
              label: "My Birthday",
              date: _myBirthday,
              onTap: () =>
                  _selectDate(context, onPicked: (d) => _myBirthday = d),
            ),

            const SizedBox(height: 32),
            _SectionHeader(title: "Partner's Profile"),
            _buildAvatarPicker(true),
            const SizedBox(height: 16),
            _EditField(
              controller: _partnerNameController,
              label: "Name",
              icon: Icons.face_3_rounded,
            ),
            _EditField(
              controller: _partnerNicknameController,
              label: "Nickname",
              icon: Icons.short_text_rounded,
            ),
            _DateSelector(
              label: "Partner's Birthday",
              date: _partnerBirthday,
              onTap: () =>
                  _selectDate(context, onPicked: (d) => _partnerBirthday = d),
            ),

            const SizedBox(height: 32),
            _SectionHeader(title: "Relationship"),
            _DateSelector(
              label: "Start Date",
              date: _relationshipStart,
              onTap: () =>
                  _selectDate(context, onPicked: (d) => _relationshipStart = d),
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(bool isPartner) {
    final avatarPath = isPartner ? _partnerAvatarPath : _myAvatarPath;
    final color = Theme.of(context).primaryColor;

    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(isPartner),
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
                image: avatarPath != null
                    ? DecorationImage(
                        image: avatarPath.startsWith('http')
                            ? NetworkImage(avatarPath)
                            : FileImage(File(avatarPath)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarPath == null
                  ? Icon(
                      isPartner ? Icons.face_3_rounded : Icons.face_rounded,
                      size: 40,
                      color: color,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMMd();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Colors.grey),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  date != null ? df.format(date!) : "Select Date",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
