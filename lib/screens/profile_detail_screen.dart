import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/widgets/simple_button.dart';
import 'package:bubble/screens/spotify_connect_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  // Form Controllers
  final _bioController = TextEditingController();
  final List<TextEditingController> _promptControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final _heightController = TextEditingController();

  // Basic Info State
  DateTime? _selectedBirthday;
  String? _selectedGender;
  String? _locationType = 'Hostel'; // Default

  // Profile Content State
  final List<String> _selectedInterests = [];
  final List<String> _selectedLookingFor = [];
  late List<String> _selectedPrompts;

  // Preferences State
  final List<String> _selectedYearPrefs = [];
  final List<String> _selectedDeptPrefs = [];
  String? _selectedGenderPref;

  // Lifestyle State
  final List<String> _selectedLifestyleTags = [];

  // Pools
  final List<String> _interestPool = [
    'Coding', 'Design', 'Music', 'Gaming', 'Fitness', 
    'Travel', 'Anime', 'Photography', 'Art', 'Reading',
    'Startups', 'Blockchain', 'AI', 'Web3', 'Cafe Hopping'
  ];

  final List<String> _lookingForOptions = [
    'Study Partner', 'Gym Buddy', 'BFFs', 'Dating', 
    'Startup Co-founder', 'Casual Hangouts'
  ];

  final List<String> _promptPool = [
    'The best way to win me over is...',
    'My secret talent is...',
    'A controversial opinion I have is...',
    'My zombie apocalypse plan is...',
    'You\'ll know I like you if...',
    'My idea of a perfect date is...',
    'The most spontaneous thing I\'ve done...',
    'One thing I can\'t live without is...',
  ];

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', 'Graduate'];
  final List<String> _departments = ['IT', 'CSE', 'ECE', 'EEE', 'Mech', 'Civil', 'BME'];
  final List<String> _lifestyleTags = [
    'Active', 'Night Owl', 'Early Bird', 'Vegan', 'Pet Lover', 
    'Social', 'Introvert', 'Coffee Addict', 'Tea Person'
  ];

  @override
  void initState() {
    super.initState();
    _selectedPrompts = [_promptPool[0], _promptPool[1]];
  }

  @override
  void dispose() {
    _bioController.dispose();
    _heightController.dispose();
    for (var controller in _promptControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryCoral,
              onPrimary: Colors.white,
              surface: AppTheme.backgroundNavy,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  void _showPromptSelection(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose a Prompt',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _promptPool.length,
                  itemBuilder: (context, i) {
                    final bool isSelected = _selectedPrompts.contains(_promptPool[i]);
                    return ListTile(
                      title: Text(
                        _promptPool[i],
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryCoral : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: isSelected ? null : () {
                        setState(() {
                          _selectedPrompts[index] = _promptPool[i];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SpotifyConnectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Complete Profile',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                  ),
                  const SizedBox(height: 8),

                  // 1. Basic Info Section
                  _buildHeader('Basic Info'),
                  _buildDatePickerTile('Birthday', _selectedBirthday != null ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}' : 'Select Date'),
                  _buildDropdownTile('Gender', _selectedGender, ['Male', 'Female'], (v) => setState(() => _selectedGender = v)),
                  _buildInputTile('Height (cm)', _heightController, '175', TextInputType.number),
                  _buildToggleTile('Location Type', _locationType, ['Hostel', 'Day Scholar'], (v) => setState(() => _locationType = v)),

                  const SizedBox(height: 32),

                  // 2. Profile Content Section
                  _buildHeader('Profile Content'),
                  const SizedBox(height: 12),
                  const Text('Bio', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _bioController, hint: 'Share a little about yourself...', maxLines: 3),
                  const SizedBox(height: 24),
                  const Text('Interests', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildMultiSelectChips(_interestPool, _selectedInterests, AppTheme.primaryCoral),
                  const SizedBox(height: 24),
                  const Text('I am looking for...', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildMultiSelectChips(_lookingForOptions, _selectedLookingFor, AppTheme.accentPurple),
                  
                  const SizedBox(height: 32),
                  const Text('Profile Prompts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap a prompt to change it', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
                  const SizedBox(height: 16),
                  _buildClickablePrompt(0),
                  const SizedBox(height: 16),
                  _buildClickablePrompt(1),

                  const SizedBox(height: 32),

                  // 3. Preferences Section
                  _buildHeader('Preferences'),
                  const SizedBox(height: 12),
                  const Text('Year of Study Preference', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildMultiSelectChips(_years, _selectedYearPrefs, AppTheme.accentLightBlue),
                  const SizedBox(height: 24),
                  const Text('Department Preference', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildMultiSelectChips(_departments, _selectedDeptPrefs, AppTheme.accentPurple),
                  const SizedBox(height: 24),
                  const Text('Gender Preference', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildSingleSelectChips(['Male', 'Female', 'Both'], _selectedGenderPref, (v) => setState(() => _selectedGenderPref = v), AppTheme.primaryCoral),

                  const SizedBox(height: 32),

                  // 4. Lifestyle Section
                  _buildHeader('Lifestyle'),
                  const SizedBox(height: 12),
                  _buildMultiSelectChips(_lifestyleTags, _selectedLifestyleTags, Colors.greenAccent),

                  const SizedBox(height: 48),

                  SimpleButton(
                    text: 'Continue',
                    gradient: AppTheme.primaryGradient,
                    onPressed: _handleContinue,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const Divider(color: Colors.white24, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildDatePickerTile(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: AppTheme.primaryCoral, fontWeight: FontWeight.bold)),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildDropdownTile(String label, String? value, List<String> options, Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
        DropdownButton<String>(
          value: value,
          hint: const Text('Choose', style: TextStyle(color: AppTheme.textGray)),
          dropdownColor: AppTheme.backgroundNavy,
          style: const TextStyle(color: Colors.white),
          underline: const SizedBox.shrink(),
          onChanged: onChanged,
          items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        ),
      ],
    );
  }

  Widget _buildInputTile(String label, TextEditingController controller, String hint, TextInputType type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            keyboardType: type,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.textGray),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(String label, String? value, List<String> options, Function(String) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
        Row(
          children: options.map((s) {
            final isSel = value == s;
            return GestureDetector(
              onTap: () => onChanged(s),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel ? AppTheme.primaryCoral : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? AppTheme.primaryCoral : AppTheme.textGray.withOpacity(0.3)),
                ),
                child: Text(s, style: TextStyle(color: isSel ? Colors.white : AppTheme.textGray, fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textGray.withOpacity(0.5)),
        filled: true,
        fillColor: AppTheme.backgroundDark.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.textGray.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryCoral, width: 2)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildMultiSelectChips(List<String> pool, List<String> selected, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pool.map((item) {
        final isSelected = selected.contains(item);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? selected.remove(item) : selected.add(item);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.8) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? color : AppTheme.textGray.withOpacity(0.3)),
            ),
            child: Text(item, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textLight, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectChips(List<String> pool, String? selected, Function(String) onSelect, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pool.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.8) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? color : AppTheme.textGray.withOpacity(0.3)),
            ),
            child: Text(item, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textLight, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClickablePrompt(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showPromptSelection(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedPrompts[index],
                    style: const TextStyle(color: AppTheme.accentLightBlue, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.swap_horiz, color: AppTheme.accentLightBlue, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(controller: _promptControllers[index], hint: 'Your answer...'),
      ],
    );
  }
}
