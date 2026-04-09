import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _courseProgramController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'Student';
  String? _selectedYearLevel;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  final List<String> _roles = ['Student', 'Adviser'];
  final List<String> _yearLevels = ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Postgraduate'];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _courseProgramController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    final appState = context.read<AppState>();
    final error = await appState.register(
      username: _usernameController.text,
      password: _passwordController.text,
      role: _selectedRole,
      displayName: _displayNameController.text,
      courseProgram: _selectedRole == 'Student' ? _courseProgramController.text : null,
      yearLevel: _selectedRole == 'Student' ? _selectedYearLevel : null,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF311B92), Color(0xFF5E35B1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Register',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text('Create your account',
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                      const SizedBox(height: 20),

                      // Role selector
                      Row(
                        children: _roles.map((role) {
                          final selected = _selectedRole == role;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRole = role),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFE040FB)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(role,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: selected ? Colors.white : Colors.white54,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      _field(_displayNameController, 'Full Name *', Icons.person),
                      _field(_usernameController, 'Username *', Icons.account_circle),
                      _passwordField(_passwordController, 'Password *', _obscurePassword,
                              () => setState(() => _obscurePassword = !_obscurePassword)),
                      _passwordField(
                          _confirmPasswordController,
                          'Confirm Password *',
                          _obscureConfirm,
                              () => setState(() => _obscureConfirm = !_obscureConfirm),
                          isConfirm: true),

                      if (_selectedRole == 'Student') ...[
                        _field(_courseProgramController, 'Course/Program *', Icons.school),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedYearLevel,
                          dropdownColor: const Color(0xFF4A148C),
                          decoration: InputDecoration(
                            labelText: 'Year Level *',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          style: const TextStyle(color: Colors.white),
                          items: _yearLevels
                              .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedYearLevel = v),
                          validator: (v) =>
                          v == null ? 'Please select year level' : null,
                        ),
                        const SizedBox(height: 14),
                      ],

                      _field(_emailController, 'Email (Optional)', Icons.email,
                          required: false,
                          keyboardType: TextInputType.emailAddress),
                      _field(_phoneController, 'Phone (Optional)', Icons.phone,
                          required: false,
                          keyboardType: TextInputType.phone),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 13)),
                        ),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: appState.isLoading ? null : _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE040FB),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                          ),
                          child: appState.isLoading
                              ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                              : const Text('Create Account',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Login',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool required = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white54),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
            ? '${label.replaceAll(' *', '')} is required'
            : null
            : null,
      ),
    );
  }

  Widget _passwordField(
      TextEditingController controller,
      String label,
      bool obscure,
      VoidCallback onToggle, {
        bool isConfirm = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.lock, color: Colors.white54),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.white54),
            onPressed: onToggle,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password is required';
          if (!isConfirm && v.length < 6) return 'Minimum 6 characters';
          if (isConfirm && v != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }
}
