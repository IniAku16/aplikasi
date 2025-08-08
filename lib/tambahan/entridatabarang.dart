import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DaftarBarangPage extends StatefulWidget {
  const DaftarBarangPage({super.key});

  @override
  State<DaftarBarangPage> createState() => _DaftarBarangPageState();
}

class _DaftarBarangPageState extends State<DaftarBarangPage> {
  List<Map<String, dynamic>> _barangList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBarang(); 
  }

  Future<void> fetchBarang() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = Uri.parse('http://localhost/api_aplikasi/crud_barang.php?action=read');
      print('Fetching data from: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed JSON data: $data');

        if (data['success'] == true) {
          final rawData = data['data'] ?? [];
          print('Raw data array: $rawData');
          print('Data type: ${rawData.runtimeType}');

          if (rawData is List) {
            setState(() {
              _barangList = rawData.map<Map<String, dynamic>>((item) {
                print('Processing item: $item');
                return Map<String, dynamic>.from(item);
              }).toList();
              _isLoading = false;
            });
            print('Data loaded successfully: ${_barangList.length} items');
          } else {
            setState(() {
              _errorMessage = 'Invalid data format: expected List, got ${rawData.runtimeType}';
              _isLoading = false;
            });
            print('Data format error: expected List, got ${rawData.runtimeType}');
          }
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Unknown error';
            _isLoading = false;
          });
          print('API Error: ${data['message']}');
        }
      } else {
        setState(() {
          _errorMessage = 'HTTP Error: ${response.statusCode}';
          _isLoading = false;
        });
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  void _showAddForm() {
    final namaController = TextEditingController();
    final hargaController = TextEditingController();
    final stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Barang Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stokController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nama = namaController.text.trim();
              final harga = double.tryParse(hargaController.text.trim()) ?? 0;
              final stok = int.tryParse(stokController.text.trim()) ?? 0;

              if (nama.isEmpty || harga <= 0 || stok < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mohon isi semua field dengan benar')),
                );
                return;
              }

              await _addBarang(nama, harga, stok);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _addBarang(String nama, double harga, int stok) async {
    try {
      final url = Uri.parse('http://localhost/api_aplikasi/crud_barang.php');
      final body = jsonEncode({
        'action': 'create',
        'nama_barang': nama,
        'harga': harga,
        'stok': stok,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil ditambahkan')),
        );
        fetchBarang(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah barang: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteBarang(int id) async {
    try {
      final url = Uri.parse('http://localhost/api_aplikasi/crud_barang.php?action=delete&id=$id');
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil dihapus')),
        );
        fetchBarang(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF9FAFB), // soft background
    appBar: AppBar(
      title: const Text(
        'Daftar Barang',
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFF90CAF9), // pastel blue
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: fetchBarang,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Tambah Barang',
          onPressed: _showAddForm,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.pinkAccent),
                SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                ),
              ],
            ),
          )
        : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontFamily: 'Quicksand'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: fetchBarang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              )
            : _barangList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada data barang',
                          style: TextStyle(fontSize: 18, fontFamily: 'Quicksand', color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: Colors.pinkAccent,
                    onRefresh: fetchBarang,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _barangList.length,
                      itemBuilder: (context, index) {
                        final barang = _barangList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.pink.shade200,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              barang['nama_barang'] ?? 'Barang',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Quicksand',
                                fontSize: 16,
                                color: Color(0xFF3A3D53),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Harga: Rp ${barang['harga'] ?? '0'}',
                                    style: const TextStyle(fontFamily: 'Quicksand'),
                                  ),
                                  Text(
                                    'Stok: ${barang['stok'] ?? '0'}',
                                    style: const TextStyle(fontFamily: 'Quicksand'),
                                  ),
                                  Text(
                                    'ID: ${barang['id_barang'] ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Konfirmasi'),
                                    content: const Text('Yakin ingin menghapus barang ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteBarang(barang['id_barang']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
  );
}
}