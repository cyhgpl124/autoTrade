import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text('설정', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionTitle('정보'),
          _buildInfoTile(
            context: context,
            icon: Icons.info_outline_rounded,
            title: '앱 버전',
            trailingText: '1.0.0', // TODO: package_info_plus로 동적 버전 관리
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.code_rounded,
            title: '오픈소스 라이선스',
            onTap: () {
              // Flutter에 내장된 라이선스 페이지를 보여줍니다.
              showLicensePage(
                context: context,
                applicationName: 'Trading App',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const Divider(color: Colors.white10, height: 32, indent: 16, endIndent: 16),
          _buildSectionTitle('법적 고지'),
          _buildInfoTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            onTap: () {
              // TODO: 개인정보처리방침 웹페이지 URL로 이동
            },
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.description_outlined,
            title: '서비스 이용약관',
            onTap: () {
              // TODO: 서비스 이용약관 웹페이지 URL로 이동
            },
          ),
           const Divider(color: Colors.white10, height: 32, indent: 16, endIndent: 16),
           _buildSectionTitle('계정'),
           ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text('로그아웃', style: GoogleFonts.poppins(color: Colors.redAccent)),
            onTap: (){
              // TODO: 로그아웃 로직 구현
            },
           )
        ],
      ),
    );
  }

  // 섹션 제목을 그리는 private 헬퍼 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // 각 설정 항목을 그리는 private 헬퍼 위젯
  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      trailing: (trailingText != null)
          ? Text(trailingText, style: const TextStyle(color: Colors.white54, fontSize: 14))
          : (onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white30) : null),
      onTap: onTap,
    );
  }
}