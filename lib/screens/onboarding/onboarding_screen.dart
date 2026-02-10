import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../providers/theme_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../core/globals.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Controllers
  final _myNameController = TextEditingController();
  final _myNicknameController = TextEditingController();
  DateTime? _myBirthday;
  String? _myAvatarPath;

  final _partnerNameController = TextEditingController();
  final _partnerNicknameController = TextEditingController();
  DateTime? _partnerBirthday;
  String? _partnerAvatarPath;

  DateTime? _relationshipStart;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _myNameController.dispose();
    _myNicknameController.dispose();
    _partnerNameController.dispose();
    _partnerNicknameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
      );
      setState(() => _currentPage++);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _pickImage(bool isMe) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(image.path);
      final String localPath = p.join(directory.path, fileName);
      await File(image.path).copy(localPath);

      setState(() {
        if (isMe) {
          _myAvatarPath = localPath;
        } else {
          _partnerAvatarPath = localPath;
        }
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final themeId = ref.read(themeProvider);
    final isMale = themeId == 'sky_dreams';

    final myProfile = UserProfile(
      name: _myNameController.text.trim(),
      nickname: _myNicknameController.text.trim(),
      gender: isMale ? 'male' : 'female',
      birthday: _myBirthday!,
      avatarPath: _myAvatarPath,
      relationshipStartDate: _relationshipStart,
      isPartner: false,
    );

    final partnerProfile = UserProfile(
      name: _partnerNameController.text.trim(),
      nickname: _partnerNicknameController.text.trim(),
      gender: isMale ? 'female' : 'male',
      birthday: _partnerBirthday!,
      avatarPath: _partnerAvatarPath,
      isPartner: true,
    );

    await ref
        .read(profileProvider.notifier)
        .updateProfiles(me: myProfile, partner: partnerProfile);

    if (mounted) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Welcome! Let's start your journey ❤️"),
          duration: Duration(milliseconds: 2000),
        ),
      );
      context.go('/');
    }
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isMyBirthday,
    bool isRelation = false,
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
      setState(() {
        if (isRelation) {
          _relationshipStart = picked;
        } else if (isMyBirthday) {
          _myBirthday = picked;
        } else {
          _partnerBirthday = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildThemeSelection(),
                  _buildMyProfileStep(),
                  _buildPartnerProfileStep(),
                  _buildTimelineStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelection() {
    final themeId = ref.watch(themeProvider);
    final isMale = themeId == 'sky_dreams';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome to\nUs Two',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
          const SizedBox(height: 48),
          Text(
            'Who are you?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: 'Male',
                  color: AppColors.malePrimary,
                  isSelected: isMale,
                  onTap: () =>
                      ref.read(themeProvider.notifier).setTheme('sky_dreams'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderCard(
                  label: 'Female',
                  color: AppColors.femalePrimary,
                  isSelected: themeId == 'cotton_candy',
                  onTap: () =>
                      ref.read(themeProvider.notifier).setTheme('cotton_candy'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const Spacer(),
          _NextButton(onPressed: _nextPage),
        ],
      ),
    );
  }

  Widget _buildMyProfileStep() {
    final themeId = ref.watch(themeProvider);
    final isMale = themeId == 'sky_dreams';
    return _ProfileForm(
      title: "Tell me about you",
      nameController: _myNameController,
      nicknameController: _myNicknameController,
      birthday: _myBirthday,
      avatarPath: _myAvatarPath,
      onBirthdayTap: () => _selectDate(context, isMyBirthday: true),
      onAvatarTap: () => _pickImage(true),
      onNext: _nextPage,
      color: Theme.of(context).primaryColor,
      isMaleTheme: isMale,
    );
  }

  Widget _buildPartnerProfileStep() {
    final themeId = ref.watch(themeProvider);
    final isUserMale = themeId == 'sky_dreams';
    final partnerColor = isUserMale
        ? AppColors.femalePrimary
        : AppColors.malePrimary;

    return _ProfileForm(
      title: "Tell me about your partner",
      nameController: _partnerNameController,
      nicknameController: _partnerNicknameController,
      birthday: _partnerBirthday,
      avatarPath: _partnerAvatarPath,
      onBirthdayTap: () => _selectDate(context, isMyBirthday: false),
      onAvatarTap: () => _pickImage(false),
      onNext: _nextPage,
      color: partnerColor,
      isMaleTheme: !isUserMale,
    );
  }

  Widget _buildTimelineStep() {
    final df = DateFormat.yMMMMd();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_rounded, size: 80, color: AppColors.femaleAccent)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 32),
          Text(
            "When did your story begin?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () =>
                _selectDate(context, isMyBirthday: false, isRelation: true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _relationshipStart != null
                    ? df.format(_relationshipStart!)
                    : "Pick a Date",
                style: GoogleFonts.varelaRound(
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _relationshipStart != null
                  ? _completeOnboarding
                  : null,
              child: const Text("Start Our Journey"),
            ),
          ).animate().fadeIn(),
        ],
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController nicknameController;
  final DateTime? birthday;
  final String? avatarPath;
  final VoidCallback onBirthdayTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onNext;
  final Color color;
  final bool isMaleTheme;

  const _ProfileForm({
    required this.title,
    required this.nameController,
    required this.nicknameController,
    required this.birthday,
    required this.avatarPath,
    required this.onBirthdayTap,
    required this.onAvatarTap,
    required this.onNext,
    required this.color,
    required this.isMaleTheme,
  });

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMMd();
    final bool isComplete =
        widget.nameController.text.isNotEmpty &&
        widget.nicknameController.text.isNotEmpty &&
        widget.birthday != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().moveY(begin: 10, end: 0),
          const SizedBox(height: 24),

          // Avatar Picker
          Center(
            child: GestureDetector(
              onTap: widget.onAvatarTap,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: widget.avatarPath == null
                    ? Icon(
                        Icons.add_a_photo_rounded,
                        color: widget.color,
                        size: 40,
                      )
                    : ClipOval(
                        child: widget.avatarPath!.startsWith('http')
                            ? Image.network(
                                widget.avatarPath!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(widget.avatarPath!),
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.avatarPath == null ? "Add Photo (Optional)" : "Change Photo",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSub, fontSize: 12),
          ),

          const SizedBox(height: 32),
          _CustomTextField(
            controller: widget.nameController,
            label: "Full Name *",
            color: widget.color,
            icon: widget.isMaleTheme
                ? Icons.face_rounded
                : Icons.face_3_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _CustomTextField(
            controller: widget.nicknameController,
            label: "Nickname *",
            color: widget.color,
            icon: Icons.favorite_border_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.onBirthdayTap,
            child: AbsorbPointer(
              child: _CustomTextField(
                controller: TextEditingController(
                  text: widget.birthday != null
                      ? df.format(widget.birthday!)
                      : "",
                ),
                label: "Birthday *",
                color: widget.color,
                icon: Icons.cake_rounded,
                isReadOnly: true,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _NextButton(
            onPressed: isComplete
                ? widget.onNext
                : () {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all required fields (*)"),
                        duration: Duration(milliseconds: 1500),
                      ),
                    );
                  },
            color: isComplete ? widget.color : Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color color;
  final IconData icon;
  final bool isReadOnly;
  final Function(String)? onChanged;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.color,
    required this.icon,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSub),
          prefixIcon: Icon(icon, color: color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;

  const _NextButton({required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: color != null
            ? ElevatedButton.styleFrom(backgroundColor: color)
            : null,
        onPressed: onPressed,
        child: const Text('Next'),
      ),
    ).animate().scale(delay: 200.ms);
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 1.0 : 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
