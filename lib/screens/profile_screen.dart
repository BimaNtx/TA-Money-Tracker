import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Halaman profil (Tab 2) — info siswa dan versi aplikasi
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar — scale + fade dari tengah
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF009688).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: Color(0xFF009688),
                ),
              ),
            )
                .animate()
                .fade(duration: 500.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 16),

            // Nama — fade + slideY
            Text(
              'Bima Ananta',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212121),
              ),
            )
                .animate()
                .fade(duration: 400.ms, delay: 150.ms)
                .slideY(begin: 0.2, end: 0, delay: 150.ms, curve: Curves.easeOut),
            const SizedBox(height: 4),

            // Keterangan kelas
            Text(
              'Siswa RPL Kelas 11',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF9E9E9E),
              ),
            )
                .animate()
                .fade(duration: 400.ms, delay: 220.ms)
                .slideY(begin: 0.2, end: 0, delay: 220.ms, curve: Curves.easeOut),
            const SizedBox(height: 32),

            // Section header
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Tentang Aplikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms, delay: 300.ms),

            // Info cards — staggered slideX dari kanan
            ...[
              _buildInfoCard(
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFF009688),
                title: 'Project Ujian Akhir',
                subtitle: 'Versi 1.0',
              ),
              _buildInfoCard(
                icon: Icons.code_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Developer',
                subtitle: 'Bima Ananta',
              ),
              _buildInfoCard(
                icon: Icons.school_outlined,
                iconColor: const Color(0xFFFF7043),
                title: 'Sekolah',
                subtitle: 'Jurusan Rekayasa Perangkat Lunak',
              ),
              _buildInfoCard(
                icon: Icons.flutter_dash_rounded,
                iconColor: const Color(0xFF42A5F5),
                title: 'Dibuat dengan',
                subtitle: 'Flutter & Dart',
              ),
            ].asMap().entries.map((entry) {
              final delay = (350 + entry.key * 70).ms;
              return entry.value
                  .animate()
                  .fade(duration: 400.ms, delay: delay)
                  .slideX(
                    begin: 0.15,
                    end: 0,
                    delay: delay,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),

            const SizedBox(height: 24),

            // Footer badge — fade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF009688).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: Color(0xFF009688),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Money Tracker v1.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF009688),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fade(duration: 400.ms, delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF212121),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}
