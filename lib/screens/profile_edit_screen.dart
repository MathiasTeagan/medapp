import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _specialtyController;
  late TextEditingController _institutionController;
  String _selectedLevel = 'Tıp Öğrencisi';
  int _selectedYear = 1;

  final List<String> _academicLevels = [
    'Tıp Öğrencisi',
    'İntörn Hekim',
    'Pratisyen Hekim',
    'Asistan Hekim',
    'Uzman Hekim',
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.name);
    _emailController = TextEditingController(text: userProvider.email);
    _specialtyController = TextEditingController(text: userProvider.specialty);
    _institutionController =
        TextEditingController(text: userProvider.institution);
    _selectedLevel = userProvider.academicLevel;
    _selectedYear = userProvider.currentYear;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        specialty: _specialtyController.text,
        institution: _institutionController.text,
        academicLevel: _selectedLevel,
        currentYear: _selectedYear,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: size.width * 0.15,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: size.width * 0.15,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adınızı giriniz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta adresinizi giriniz';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta adresi giriniz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Akademik Seviye',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: _academicLevels.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLevel = newValue;
                      });
                    }
                  },
                ),
                SizedBox(height: size.height * 0.02),
                DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Bulunduğunuz Yıl',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  items: List.generate(6, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('${index + 1}. Yıl'),
                    );
                  }),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                    }
                  },
                ),
                SizedBox(height: size.height * 0.02),
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'Uzmanlık Alanı',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services_outlined),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                TextFormField(
                  controller: _institutionController,
                  decoration: const InputDecoration(
                    labelText: 'Kurum',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
