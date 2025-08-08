import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TopUpBankPage extends StatefulWidget {
  const TopUpBankPage({super.key});

  @override
  State<TopUpBankPage> createState() => _TopUpBankPageState();
}

class _TopUpBankPageState extends State<TopUpBankPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();
  int? _selectedUserId;
  String _selectedUsername = "";
  List<Map<String, dynamic>> _siswaList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSiswaList();
  }

  Future<void> _fetchSiswaList() async {
    try {
      final url = Uri.parse('http://localhost/api_aplikasi/get_user_bank.php');
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final siswaOnly = (data['data'] as List)
            .where((item) => item['role'] == 'Siswa')
            .map<Map<String, dynamic>>((item) => {
                  'id_user': int.parse(item['id_user'].toString()),
                  'username': item['username'],
                })
            .toList();

        setState(() {
          _siswaList = siswaOnly;
          if (_siswaList.isNotEmpty) {
            _selectedUserId = _siswaList[0]['id_user'];
            _selectedUsername = _siswaList[0]['username'];
          }
        });
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      _showMessage('Gagal mengambil data siswa: $e');
    }
  }

  Future<void> _submitTopUp() async {
    if (!_formKey.currentState!.validate() || _selectedUserId == null) return;

    final jumlah = double.tryParse(_jumlahController.text) ?? 0;
    final tanggal = DateTime.now().toIso8601String().split('T').first;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://localhost/api_aplikasi/topup_bank.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': _selectedUserId,
          'jumlah': jumlah,
          'tanggal': tanggal,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _showMessage('Top up berhasil ke siswa');
        await _cetakPdfStruk(_selectedUsername, tanggal, jumlah);
        _jumlahController.clear();
      } else {
        _showMessage('Gagal: ${data['message']}');
      }
    } catch (e) {
      _showMessage('Kesalahan koneksi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cetakPdfStruk(String namaSiswa, String tanggal, double jumlah) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('BUKTI TOP UP SALDO', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text('Tanggal: $tanggal'),
                pw.Text('Nama Siswa: $namaSiswa'),
                pw.SizedBox(height: 10),
                pw.Text('Jumlah Top Up:', style: pw.TextStyle(fontSize: 14)),
                pw.Text(
                  'Rp ${jumlah.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 25),
                pw.Text('Terima kasih telah melakukan top up.',
                    style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        title: const Text("Top Up oleh Bank"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedUserId,
                items: _siswaList.map((user) {
                  return DropdownMenuItem<int>(
                    value: user['id_user'],
                    child: Text(user['username']),
                  );
                }).toList(),
                onChanged: (value) {
                  final selected = _siswaList.firstWhere((u) => u['id_user'] == value);
                  setState(() {
                    _selectedUserId = value;
                    _selectedUsername = selected['username'];
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Pilih Siswa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Top Up',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Masukkan jumlah';
                  final jml = double.tryParse(value);
                  if (jml == null || jml <= 0) return 'Jumlah harus > 0';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitTopUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Top Up ke Siswa',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
