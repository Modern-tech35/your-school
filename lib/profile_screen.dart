import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;
  UserProfile? _userProfile;

  final TextEditingController _nameController = TextEditingController();
  String _selectedGender = 'man';
  int _selectedAge = 16;
  String _selectedAvatar = 'man_6997497';
  String _selectedRole = 'student';

  final List<String> _avatars = [
    'man_6997497', 'man_6997671', 'man_18663695',
    'woman_4140040', 'woman_4140049', 'woman_4140062',
  ];

  final List<String> _genders = ['man', 'woman'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userProfile = UserProfile.fromMap(doc.data()!);
            _nameController.text = _userProfile!.name;
            _selectedGender = _userProfile!.gender;
            _selectedAge = _userProfile!.age;
            _selectedAvatar = _userProfile!.avatar;
            _selectedRole = _userProfile!.role;
          });
        }
      } catch (e) {
        // Handle error, e.g., Firestore not configured
        debugPrint('Error loading profile: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = UserProfile(
        name: _nameController.text,
        gender: _selectedGender,
        age: _selectedAge,
        avatar: _selectedAvatar,
        role: _selectedRole,
      );

      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(profile.toMap());

        setState(() {
          _userProfile = profile;
          _isEditing = false;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }

  Widget _buildAvatarSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF212121).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth / 70).floor().clamp(2, 4);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _avatars.length,
            itemBuilder: (context, index) {
              final avatar = _avatars[index];
              final isSelected = _selectedAvatar == avatar;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = avatar;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4FC3F7).withOpacity(0.2) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey.withOpacity(0.5),
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: Image.asset(
                    _getAvatarPath(avatar),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      _getIconData(avatar),
                      size: 40,
                      color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getAvatarPath(String avatar) {
    return 'assets/avatars/$avatar.png';
  }

  IconData _getIconData(String avatar) {
    if (avatar.startsWith('man_')) {
      return Icons.person;
    } else if (avatar.startsWith('woman_')) {
      return Icons.person;
    } else {
      return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveUserProfile,
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bodyPadding = constraints.maxWidth > 600 ? 24.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.all(bodyPadding),
            child: _isEditing ? _buildEditForm() : _buildProfileView(user),
          );
        },
      ),
    );
  }

  Widget _buildProfileView(User? user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 600 ? 24.0 : 16.0;
        return Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: constraints.maxWidth > 600 ? 80 : 60,
                    backgroundColor: const Color(0xFF4FC3F7),
                    child: Image.asset(
                    _getAvatarPath(_userProfile?.avatar ?? 'person'),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      _getIconData(_userProfile?.avatar ?? 'man_6997497'),
                      size: constraints.maxWidth > 600 ? 80 : 60,
                      color: Color(0xFF212121),
                    ),
                  ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userProfile?.name ?? 'No name set',
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 600 ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.email, 'Email: ${user?.email ?? 'Unknown'}'),
                  if (_userProfile != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.wc, 'Gender: ${_userProfile!.gender}'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.calendar_today, 'Age: ${_userProfile!.age}'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.admin_panel_settings, 'Role: ${_userProfile!.role.toUpperCase()}'),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Tap edit to set up your profile',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4FC3F7)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF212121)),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final formPadding = constraints.maxWidth > 600 ? 24.0 : 16.0;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: formPadding / 2, vertical: formPadding),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(formPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Choose Avatar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                ),
                const SizedBox(height: 16),
                _buildAvatarSelector(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: _genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  initialValue: _selectedAge,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: List.generate(45, (index) => 16 + index).map((age) {
                    return DropdownMenuItem(
                      value: age,
                      child: Text(age.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAge = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
