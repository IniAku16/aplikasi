import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TarikTunaiPage extends StatefulWidget {
  final int idUser; // ID user yang login, jika dibutuhkan

  const TarikTunaiPage({super.key, required this.idUser});

  @override
  _TarikTunaiPageState createState() => _TarikTunaiPageState();
}

class _TarikTunaiPageState extends State<TarikTunaiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _userList = [];
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Ambil data siswa & kantin
  }

  Future<void> _fetchUserData() async {
    try {
      final url = Uri.parse('http://localhost/api_aplikasi/get_user_bank.php');
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          _userList = (data['data'] as List).map<Map<String, dynamic>>((item) {
            return {
              'id_user': int.parse(item['id_user'].toString()),
              'username': item['username'].toString(),
              'role': item['role'].toString(),
            };
          }).toList();

          if (_userList.isNotEmpty) {
            _selectedUserId = _userList[0]['id_user'];
          }
        });
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data pengguna: $e')),
      );
    }
  }

  Future<void> _submitTarikTunai() async {
    if (!_formKey.currentState!.validate() || _selectedUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    final jumlah = double.tryParse(_jumlahController.text.trim()) ?? 0;

    try {
      final url = Uri.parse('http://localhost/api_aplikasi/tarik_tunai.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id_user': _selectedUserId,
          'jumlah': jumlah,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarik tunai berhasil!')),
        );
        _jumlahController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal tarik tunai')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan koneksi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarik Tunai'),
        backgroundColor: const Color(0xFF8ACEFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown user (siswa & kantin)
              DropdownButtonFormField<int>(
                value: _selectedUserId,
                items: _userList.map<DropdownMenuItem<int>>((user) {
                  return DropdownMenuItem<int>(
                    value: user['id_user'],
                    child: Text('${user['username']} (${user['role']})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Pilih Pengguna',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Input jumlah
              TextFormField(
                controller: _jumlahController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Jumlah yang ingin ditarik',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  final n = num.tryParse(value);
                  if (n == null || n <= 0) {
                    return 'Masukkan jumlah valid lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tombol tarik tunai
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitTarikTunai,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Proses Tarik Tunai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8ACEFF),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
