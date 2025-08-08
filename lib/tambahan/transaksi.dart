import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class TransaksiPage extends StatefulWidget {
  final int idUser;
  const TransaksiPage({super.key, required this.idUser});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<dynamic> _barangList = [];
  final Map<int, int> _jumlahBeli = {};
  bool _isLoading = true;
  bool _isProcessing = false;

  final Color softBlue = const Color(0xFFAEDCFF);
  final Color softPink = const Color(0xFFFFD6E8);
  final Color softBackground = const Color(0xFFF7F9FC);
  final Color titleColor = const Color(0xFF3A3D53);

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  Future<void> _fetchBarang() async {
    final url =
        Uri.parse('http://localhost/api_aplikasi/crud_barang.php?action=read');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success']) {
        setState(() {
          _barangList = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetch barang: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePdf(Map<String, dynamic> transaksiData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Bukti Transaksi Kantin',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('ID User: ${transaksiData['idUser']}'),
              pw.Text('Tanggal: ${transaksiData['tanggal']}'),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Nama Barang', 'Jumlah', 'Harga Satuan', 'Total'],
                data: (transaksiData['items'] as List)
                    .map((item) => [
                          item['nama'],
                          item['jumlah'].toString(),
                          'Rp ${item['harga']}',
                          'Rp ${item['total']}',
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total Harga: Rp ${transaksiData['totalHarga']}',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Terima kasih telah bertransaksi!',
                  style: pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void _prosesTransaksi() async {
    final selected = _jumlahBeli.entries
        .where((e) => e.value > 0)
        .map((e) => {
              'id_barang': e.key,
              'jumlah': e.value,
            })
        .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih barang terlebih dahulu')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final url = Uri.parse('http://localhost/api_aplikasi/simpan_transaksi.php');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id_user': widget.idUser,
          'barang': selected,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil! 🎉')),
        );

        // Siapkan data untuk PDF
        final tanggal = DateTime.now().toIso8601String().split('T').first;

        final List<Map<String, dynamic>> itemsForPdf = _barangList
            .where((b) =>
                _jumlahBeli[b['id_barang']] != null &&
                _jumlahBeli[b['id_barang']]! > 0)
            .map((b) {
          final jumlah = _jumlahBeli[b['id_barang']] ?? 0;
          final harga = b['harga'] as int;
          return {
            'nama': b['nama_barang'],
            'jumlah': jumlah,
            'harga': harga,
            'total': harga * jumlah,
          };
        }).toList();

        final totalHarga = itemsForPdf.fold<int>(
            0, (sum, item) => sum + (item['total'] as int));

        // Panggil fungsi generate PDF
        await _generatePdf({
          'idUser': widget.idUser,
          'tanggal': tanggal,
          'items': itemsForPdf,
          'totalHarga': totalHarga,
        });

        // Kosongkan keranjang setelah PDF selesai dibuat
        setState(() => _jumlahBeli.clear());

        // Muat ulang data barang agar stok terbaru tampil
        await _fetchBarang();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat transaksi: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        title: const Text(
          'Transaksi Kantin',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: softBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent))
          : _barangList.isEmpty
              ? const Center(child: Text('Barang tidak tersedia'))
              : Column(
                  children: [
                    Expanded(child: _buildListBarang()),
                    if (_getSelectedItems().isNotEmpty) ...[
                      const Divider(thickness: 1.2),
                      _buildSelectedItems(),
                      _buildKeranjangSection(),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
      floatingActionButton: _isProcessing || _getSelectedItems().isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _prosesTransaksi,
              label: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              icon: const Icon(Icons.shopping_bag_rounded),
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              elevation: 6,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildListBarang() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _barangList.length,
      itemBuilder: (context, index) {
        final barang = _barangList[index];
        final id = barang['id_barang'];
        final jumlah = _jumlahBeli[id] ?? 0;
        final stok = barang['stok'] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang['nama_barang'] ?? 'Barang',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rp ${barang['harga']}",
                        style: TextStyle(
                          color: Colors.pink.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stok: $stok",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, () {
                      setState(() {
                       _jumlahBeli[id] = (jumlah - 1).clamp(0, stok).toInt();
                      });
                    }, softPink),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$jumlah',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildQtyButton(Icons.add, () {
                      if (jumlah < stok) {
                        setState(() {
                         _jumlahBeli[id] = (jumlah + 1).clamp(0, stok).toInt();
                        });
                      }
                    }, softBlue),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  List<Map<String, dynamic>> _getSelectedItems() {
    return _barangList.where((b) {
      final qty = _jumlahBeli[b['id_barang']] ?? 0;
      return qty > 0;
    }).map((b) {
      final qty = _jumlahBeli[b['id_barang']] ?? 0;
      return {
        'id_barang': b['id_barang'],
        'nama_barang': b['nama_barang'],
        'harga': b['harga'],
        'jumlah': qty,
      };
    }).toList();
  }

  Widget _buildSelectedItems() {
    final selectedItems = _getSelectedItems();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barang Dipilih:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...selectedItems.map((b) {
            final qty = _jumlahBeli[b['id_barang']] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${b['nama_barang']} x$qty')),
                  Text('Rp ${b['harga'] * qty}'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildKeranjangSection() {
    final totalBayar = _getSelectedItems().fold<int>(
      0,
      (sum, b) {
        final qty = _jumlahBeli[b['id_barang']] ?? 0;
        final harga = b['harga'] as int;
        return sum + (qty * harga);
      },
    );

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Bayar:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF333366),
            ),
          ),
          Text(
            'Rp $totalBayar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.pink.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
