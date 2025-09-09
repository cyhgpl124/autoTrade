import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ⭐️ 시나리오 관리 페이지 import 추가
import 'package:stock/features/scenario_builder/view/scenario_home_page.dart';
import 'package:stock/features/back_testing/view/backtesting_home_page.dart';
import 'package:stock/features/data_collection/view/data_collection_page.dart';
import 'package:stock/features/live_trade/view/live_trade_control_page.dart';
import 'package:stock/features/settings/view/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 디바이스 화면 크기 정보
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 전체 배경색을 깊은 네이비 색상으로 설정
      backgroundColor: const Color(0xFF0A192F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A192F),
            pinned: true, // 스크롤 시 상단에 고정
            floating: true, // 스크롤을 내릴 때 바로 나타남
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Trading Dashboard',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            ),
            actions: [
              // 오른쪽 상단에 아이콘 버튼 추가
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                onPressed: () {
                   // ⭐️ 이 부분이 수정되었습니다 ⭐️
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),

          // 'Main Menu' 타이틀 부분
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Text(
                'Main Menu',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 기능 카드들을 보여주는 그리드
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 4 : 2, // 화면 너비에 따라 열 개수 조정
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.9, // 카드의 가로세로 비율
              ),
              delegate: SliverChildListDelegate(
                [
                  _FeatureCard(
                    icon: Icons.data_usage_rounded,
                    title: '데이터 수집',
                    description: '최신 주식 데이터를 수동으로 수집합니다.',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DataCollectionPage()),
                      );
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.create_rounded,
                    title: '시나리오 관리',
                    description: '매매 전략을 생성하고 관리합니다.',
                    onTap: () {
                      // ⭐️ 이 부분이 수정되었습니다 ⭐️
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ScenarioHomePage()),
                      );
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.history_toggle_off_rounded,
                    title: '백테스팅',
                    description: '시나리오의 과거 성과를 분석합니다.',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const BacktestingHomePage()),
                      );
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.play_circle_fill_rounded,
                    title: '실전 매매',
                    description: '선택한 시나리오로 실전 매매를 시작합니다.',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LiveTradeControlPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40), // 하단 여백
          )
        ],
      ),
    );
  }
}

/// 재사용 가능한 기능 카드 위젯
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: const Color(0xFF1E2A47), // 카드 배경색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF539DF3)), // 포인트 컬러
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}