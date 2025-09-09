import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/backtest_result_model.dart';

class ResultDetailPage extends StatelessWidget {
  final BacktestResult result;
  const ResultDetailPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text(result.scenarioName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 그래프 이미지
            Text('수익률 그래프', style: GoogleFonts.poppins(fontSize: 22, color: Colors.white)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Image.network은 URL로부터 이미지를 불러옵니다.
              child: Image.network(
                result.graphUrl,
                // 로딩 중에는 인디케이터, 에러 시 아이콘 표시
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, color: Colors.red, size: 50);
                },
              ),
            ),
            const SizedBox(height: 32),
            // 요약 결과 테이블
            Text('요약 결과', style: GoogleFonts.poppins(fontSize: 22, color: Colors.white)),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF1E2A47),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // result.summary Map 데이터를 순회하며 UI 생성
                child: Column(
                  children: result.summary.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
                          Text(entry.value.toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}