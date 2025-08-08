import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';


class TopUpPage extends StatefulWidget {
  final int idUser;

  const TopUpPage({super.key, required this.idUser});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  bool _isLoading = false;
  double _saldo = 0;

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
  }

  Future<void> _fetchSaldo() async {
    final url = Uri.parse('http://localhost/api_aplikasi/topup.php');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'action': 'get_saldo',
          'id_user': widget.idUser,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _saldo = (data['saldo'] as num).toDouble();
        });
      } else {
        _showSnackBar(
            'Gagal mengambil saldo: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showSnackBar('Error mengambil saldo: $e');
    }
  }

  Future<void> _submitTopUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost/api_aplikasi/topup.php');
    final jumlah = double.parse(_jumlahController.text);
    final tanggal = DateTime.now().toIso8601String().split('T').first;

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'action': 'topup',
          'id_user': widget.idUser,
          'tanggal': tanggal,
          'jumlah': jumlah,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _showSnackBar("Top up berhasil");
        _jumlahController.clear();
        await _fetchSaldo();
        await _showPdfBuktiTopUp(jumlah, tanggal);
      } else {
        _showSnackBar("Gagal top up: ${data['message']}");
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showPdfBuktiTopUp(double jumlah, String tanggal) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('Bukti Top Up Saldo',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('ID User: ${widget.idUser}',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text('Tanggal: $tanggal', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Jumlah Top Up:', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Rp ${jumlah.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 30),
              pw.Text('Terima kasih telah melakukan top up!',
                  style: pw.TextStyle(
                      fontSize: 14, fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
      ),
    );

    // Tampilkan dialog preview PDF dan opsi cetak/save/share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF4A90E2);
    const backgroundBlue = Color(0xFFF2F7FF);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          'Top Up Saldo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSaldoCard(primaryBlue)
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2),
            const SizedBox(height: 32),
            Text(
              'Form Top Up',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildTopUpForm(primaryBlue, backgroundBlue)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoCard(Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, const Color(0xFF6EB6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded,
              size: 50, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Kamu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Rp ${_saldo.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchSaldo,
            tooltip: 'Refresh Saldo',
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpForm(Color primaryBlue, Color backgroundBlue) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.add_card_rounded, size: 60, color: primaryBlue),
          const SizedBox(height: 20),
          Text(
            'Masukkan Jumlah Top Up',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 25),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp)',
                prefixIcon:
                    Icon(Icons.attach_money_rounded, color: primaryBlue),
                filled: true,
                fillColor: backgroundBlue,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryBlue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryBlue.withOpacity(0.4)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah top up harus diisi';
                }
                final jumlah = double.tryParse(value);
                if (jumlah == null || jumlah <= 0) {
                  return 'Masukkan jumlah valid lebih dari 0';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Top Up',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            onPressed: _isLoading ? null : _submitTopUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
