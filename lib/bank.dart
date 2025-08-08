import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'tambahan/topup_bank.dart';
import 'tambahan/tarik_tunai.dart';

class BankPage extends StatelessWidget {
  final String username;
  final int idUser;

  const BankPage({
    super.key,
    required this.username,
    required this.idUser,
  });

  void _confirmLogout(BuildContext context) {
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
    final Color primaryBlue = const Color(0xFF3B76D8);
    final Color softBlue = const Color(0xFFD7E6FF);
    final Color darkBlue = const Color(0xFF3B76D8);
    final Color lightBlueIcon = const Color(0xFF9CC1FF);

    return Scaffold(
      backgroundColor: softBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Dashboard Bank',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
            fontFamily: 'Quicksand', // Kalau pakai Google Fonts Quicksand misal
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card atas - greeting
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar lingkaran
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_circle_rounded,
                          color: Colors.white70,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Text greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $username! 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Senang melihatmu kembali!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                              fontFamily: 'Quicksand',
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // List menu cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _menuCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconBackground: lightBlueIcon.withOpacity(0.3),
                      iconColor: lightBlueIcon,
                      title: 'Top Up Saldo',
                      subtitle: 'Isi saldo dengan cepat dan mudah',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TopUpBankPage()),
                      ),
                    ),
                    _menuCard(
                      icon: Icons.attach_money_rounded,
                      iconBackground: lightBlueIcon.withOpacity(0.3),
                      iconColor: lightBlueIcon,
                      title: 'Tarik Tunai',
                      subtitle: 'Ambil saldo secara tunai',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TarikTunaiPage (idUser: idUser)),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Shadow lembut sesuai gambar, jangan terlalu tajam
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                      color: Colors.black87,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Colors.black54,
                      fontFamily: 'Quicksand',
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
