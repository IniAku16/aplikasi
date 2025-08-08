import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambahan/topup.dart';
import 'tambahan/transaksi.dart';
import 'loginpage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SiswaPage extends StatelessWidget {
  final String username;
  final int idUser;

  const SiswaPage({
    super.key,
    required this.username,
    required this.idUser,
  });

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah kamu yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
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
  final primaryBlue = const Color(0xFF4A90E2);
  final softBlue = const Color(0xFFF2F7FF);
  final cardWhite = Colors.white;
  final shadowColor = Colors.blueGrey.withOpacity(0.12);

  return Scaffold(
    backgroundColor: softBlue,
    appBar: AppBar(
      backgroundColor: primaryBlue,
      elevation: 0,
      title: Text(
        'Dashboard Siswa',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _confirmLogout(context),
        )
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, const Color(0xFF6EB6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 12),
                  blurRadius: 25,
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=$username',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $username 👋',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selamat datang kembali!',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

          // Menu Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Top Up Saldo',
                  subtitle: 'Isi saldo dengan mudah dan cepat',
                  iconColor: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TopUpPage(idUser: idUser)),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 16),

                _buildMenuCard(
                  context,
                  icon: Icons.shopping_cart_checkout_rounded,
                  title: 'Lakukan Transaksi',
                  subtitle: 'Belanja langsung dari kantin',
                  iconColor: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TransaksiPage(idUser: idUser)),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMenuCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
        ],
      ),
    ),
  );
}
}