import 'package:flutter/material.dart';
import 'tambahan/entridatabarang.dart';
import 'tambahan/laporankantin.dart'; 
import 'loginpage.dart';    

class KantinPage extends StatefulWidget {
  final String username;
  final int idUser;

  const KantinPage({
    super.key,
    required this.username,
    required this.idUser,
  });

  @override
  State<KantinPage> createState() => _KantinPageState();
}

class _KantinPageState extends State<KantinPage> {
  final Color primaryBlue = const Color(0xFF3B76D8);
  final Color softBlue = const Color(0xFFD7E6FF);
  final Color lightBlueIcon = const Color(0xFF9CC1FF);

  void _confirmLogout() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text('Yakin ingin logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // tutup dialog dulu
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserLoginPage()),
            );
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: softBlue,
    appBar: AppBar(
      backgroundColor: primaryBlue,
      elevation: 0,
      title: const Text(
        'Dashboard Kantin',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          fontFamily: 'Quicksand',
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
          onPressed: _confirmLogout,
        ),
      ],
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌸 Greeting Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.pinkAccent, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fastfood_rounded,
                        color: Colors.pinkAccent,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hai, ${widget.username}! ✨',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Quicksand',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Selamat datang di dunia manis kantin 💖',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: 'Quicksand',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🍭 Menu Cards
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _menuCard(
                    icon: Icons.inventory_2_rounded,
                    iconBackground: Colors.blue.shade100,
                    iconColor: primaryBlue,
                    title: 'Entri Data Barang',
                    subtitle: 'Kelola barang-barang lucu di kantin 🍪',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DaftarBarangPage()),
                      );
                      setState(() {});
                    },
                  ),
                  _menuCard(
                    icon: Icons.receipt_long_rounded,
                    iconBackground: Colors.green.shade100,
                    iconColor: Colors.green,
                    title: 'Riwayat Transaksi',
                    subtitle: 'Lihat jejak manis pembelianmu 🧁',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LaporanKantinPage(idUser: widget.idUser),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _menuCard({
  required IconData icon,
  required Color iconBackground,
  required Color iconColor,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    splashColor: iconColor.withOpacity(0.25),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    fontFamily: 'Quicksand',
                    color: Color(0xFF44476A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    fontFamily: 'Quicksand',
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
}
