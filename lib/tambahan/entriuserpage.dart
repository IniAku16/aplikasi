import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EntriUserPage extends StatefulWidget {
  const EntriUserPage({super.key});

  @override
  _EntriUserPageState createState() => _EntriUserPageState();
}

class _EntriUserPageState extends State<EntriUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;

  final List<String> _roles = ['Siswa', 'Kantin', 'Bank'];
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua field yang dibutuhkan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost/api_aplikasi/entri_user.php');
    // Gunakan IP `10.0.2.2` jika testing di emulator Android

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': _selectedRole,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User berhasil ditambahkan')),
        );
        _formKey.currentState!.reset();
        _usernameController.clear();
        _passwordController.clear();
        setState(() => _selectedRole = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal menambahkan user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entri Data User'),
        backgroundColor: Color(0xFF8ACEFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Username harus diisi' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Password harus diisi' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.people),
                ),
                items: _roles
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                validator: (value) =>
                    value == null ? 'Role harus dipilih' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8ACEFF),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Simpan User'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
