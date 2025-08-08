import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LaporanKantinPage extends StatefulWidget {
  final int idUser;

  const LaporanKantinPage({super.key, required this.idUser});

  @override
  State<LaporanKantinPage> createState() => _LaporanKantinPageState();
}

class _LaporanKantinPageState extends State<LaporanKantinPage> {
  double _saldo = 0;
  bool _isLoading = false;
  List<dynamic> _laporanTransaksi = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost/api_aplikasi/laporankantin.php');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'action': 'get_laporan',
          'id_user': widget.idUser,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _saldo = (data['saldo'] as num).toDouble();
          _laporanTransaksi = data['laporan'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data: ${data['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil data: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

@override
Widget build(BuildContext context) {
  final primaryBlue = const Color(0xFF8ACEFF);
  final backgroundBlue = const Color(0xFFEAF6FF);
  final softWhite = const Color(0xFFFFFFFF);

  return Scaffold(
    backgroundColor: backgroundBlue,
    appBar: AppBar(
      title: Text(
        'Laporan Kantin',
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: primaryBlue,
      elevation: 0,
    ),
    body: RefreshIndicator(
      onRefresh: _fetchData,
      color: Colors.pinkAccent,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 💰 Saldo Kantin Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: softWhite,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryBlue.withOpacity(0.2),
                          ),
                          child: Icon(Icons.account_balance_wallet_rounded, size: 36, color: primaryBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo Kantin',
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp ${_saldo.toStringAsFixed(0)}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                          onPressed: _fetchData,
                          tooltip: 'Refresh Data',
                        )
                      ],
                    ),
                  ),

                  // 🧾 Judul
                  Text(
                    'Riwayat Transaksi',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📃 List Transaksi
                  if (_laporanTransaksi.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada transaksi',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _laporanTransaksi.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _laporanTransaksi[index];
                        final deskripsi = item['deskripsi'] ?? '-';
                        final harga = item['total'] ?? 0;
                        final tanggal = item['tanggal'] ?? '';

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade100.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            leading: CircleAvatar(
                              backgroundColor: primaryBlue.withOpacity(0.2),
                              child: Icon(Icons.fastfood, color: primaryBlue),
                            ),
                            title: Text(
                              deskripsi,
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total: Rp $harga',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    'Tanggal: $tanggal',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    ),
  );
}
}
