import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/scenario_model.dart';
import '../bloc/scenario_bloc.dart';
import 'scenario_edit_page.dart';
import 'scenario_detail_page.dart';

class ScenarioHomePage extends StatefulWidget {
  const ScenarioHomePage({super.key});

  @override
  State<ScenarioHomePage> createState() => _ScenarioHomePageState();
}

class _ScenarioHomePageState extends State<ScenarioHomePage> {
  @override
  void initState() {
    super.initState();
    // 페이지가 로드될 때 시나리오 목록을 불러오는 이벤트를 발생시킴
    context.read<ScenarioBloc>().add(ScenariosLoaded());
  }

  // 삭제 확인 다이얼로그를 띄우는 함수
  Future<void> _showDeleteConfirmDialog(BuildContext context, Scenario scenario) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2A47),
          title: Text('시나리오 삭제', style: GoogleFonts.poppins(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("'${scenario.name}' 시나리오를 정말 삭제하시겠습니까?", style: GoogleFonts.poppins(color: Colors.white70)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('취소'), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                // BLoC에 삭제 이벤트 전달
                context.read<ScenarioBloc>().add(ScenarioDeleted(scenario.id));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text('시나리오 관리', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 생성 모드로 페이지 이동 (existingScenario를 null로 전달)
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScenarioEditPage()),
          ).then((_) => context.read<ScenarioBloc>().add(ScenariosLoaded()));
        },
        backgroundColor: const Color(0xFF539DF3),
        tooltip: '새 시나리오 추가',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<ScenarioBloc, ScenarioState>(
        listener: (context, state) {
          if (state is ScenarioSaveSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('✅ 작업이 성공적으로 요청되었습니다.'), backgroundColor: Colors.green));
          }
          if (state is ScenarioOperationFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('❌ 작업 실패: ${state.error}'), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is ScenarioLoadInProgress || state is ScenarioInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScenarioLoadSuccess) {
            if (state.scenarios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_stories_outlined, color: Colors.white24, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      '저장된 시나리오가 없습니다.',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '하단 + 버튼을 눌러 새 매매 전략을 추가하세요.',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // FAB에 가려지지 않도록 하단 패딩
              itemCount: state.scenarios.length,
              itemBuilder: (context, index) {
                final scenario = state.scenarios[index];
                return _buildScenarioCard(context, scenario);
              },
            );
          }
          return const Center(child: Text('알 수 없는 오류가 발생했습니다.', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, Scenario scenario) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF1E2A47),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: const Icon(Icons.auto_stories_rounded, color: Color(0xFF539DF3), size: 30),
        title: Text(scenario.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        // ⭐️⭐️⭐️ 이 부분이 수정되었습니다 ⭐️⭐️⭐️
        subtitle: Text(
          'KODEX 200: 매수 ${scenario.kodex200.buyConditionGroups.length}개 / 매도 ${scenario.kodex200.sellConditionGroups.length}개\nKODEX 인버스: 매수 ${scenario.kodexInverse.buyConditionGroups.length}개 / 매도 ${scenario.kodexInverse.sellConditionGroups.length}개',
          style: const TextStyle(color: Colors.white70, height: 1.5), // 줄 간격(height) 추가
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              // 수정 모드로 페이지 이동 (existingScenario 데이터 전달)
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ScenarioEditPage(existingScenario: scenario)),
              ).then((_) => context.read<ScenarioBloc>().add(ScenariosLoaded()));
            } else if (value == 'delete') {
              _showDeleteConfirmDialog(context, scenario);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('수정'))),
            const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.redAccent), title: Text('삭제', style: TextStyle(color: Colors.redAccent)))),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScenarioDetailPage(scenario: scenario)));
        },
      ),
    );
  }
}