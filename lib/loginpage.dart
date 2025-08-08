import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import halaman sesuai role
import 'admin.dart';
import 'bank.dart';
import 'kantin.dart';
import 'siswa.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;

  final List<String> _roles = ['Admin', 'Bank', 'Kantin', 'Siswa'];

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih role terlebih dahulu')),
        );
        return;
      }

      loginUser(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole!,
        context,
      );
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_pin, size: 80, color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      Text(
                        "Login User",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.blue[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Username harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.blue[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Password harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: _roles
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRole = value),
                        decoration: InputDecoration(
                          labelText: 'Pilih Role',
                          prefixIcon: Icon(Icons.people_outline),
                          filled: true,
                          fillColor: Colors.blue[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null ? 'Role harus dipilih' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
          ),
        ),
      ),
    );
  }
}

Future<void> loginUser(
    String username, String password, String role, BuildContext context) async {
  // Ganti dengan IP server kamu. Jangan pakai localhost jika dari emulator/device.
  final url = Uri.parse('http://localhost/api_aplikasi/login.php');
  
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final int idUser = int.parse(data['id_user'].toString());
        final username = data['username'];
        final role = data['role'];

        switch (role.toLowerCase()) {
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AdminPage(idUser: idUser, username: username)),
            );
            break;
          case 'bank':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => BankPage(idUser: idUser, username: username)),
            );
            break;
          case 'kantin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => KantinPage(idUser: idUser, username: username)),
            );
            break;
          case 'siswa':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      SiswaPage(idUser: idUser, username: username)),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Role tidak dikenali')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login gagal')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kesalahan koneksi: $e')),
    );
  }
}
