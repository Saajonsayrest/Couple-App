import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../data/models/user_profile.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final box = Hive.box<UserProfile>(AppConstants.userBox);
    if (box.isEmpty) return;

    final me = box.getAt(0);
    final partner = box.getAt(1);

    if (me != null) {
      _myNameController.text = me.name;
      _myNicknameController.text = me.nickname;
      _myBirthday = me.birthday;
      _relationshipStart = me.relationshipStartDate;
    }

    if (partner != null) {
      _partnerNameController.text = partner.name;
      _partnerNicknameController.text = partner.nickname;
      _partnerBirthday = partner.birthday;
    }
  }

  Future<void> _saveData() async {
    final box = Hive.box<UserProfile>(AppConstants.userBox);

    // Get existing objects to preserve gender/ID
    final me = box.getAt(0);
    final partner = box.getAt(1);

    if (me != null) {
      me.name = _myNameController.text.trim();
      me.nickname = _myNicknameController.text.trim();
      me.birthday = _myBirthday ?? DateTime.now();
      me.relationshipStartDate = _relationshipStart;
      await box.putAt(0, me);
    }

    if (partner != null) {
      partner.name = _partnerNameController.text.trim();
      partner.nickname = _partnerNicknameController.text.trim();
      partner.birthday = _partnerBirthday ?? DateTime.now();
      await box.putAt(1, partner);
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Details Updated!')));
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
                child: const Text('Save Changes'),
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
