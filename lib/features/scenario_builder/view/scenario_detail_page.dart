import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/scenario_model.dart';

// scenario_edit_page.dart 에서 가져온 옵션 목록 (표시용)
const Map<int, String> _barOffsetOptions = {
  0: '현재봉', 1: '1봉전', 2: '2봉전', 3: '3봉전', 4: '4봉전', 5: '5봉전',
};

class ScenarioDetailPage extends StatefulWidget {
  final Scenario scenario;
  const ScenarioDetailPage({super.key, required this.scenario});

  @override
  State<ScenarioDetailPage> createState() => _ScenarioDetailPageState();
}

class _ScenarioDetailPageState extends State<ScenarioDetailPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text(widget.scenario.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(),
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(text: 'KODEX 200'),
            Tab(text: 'KODEX 인버스'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StrategyDetailView(strategyPart: widget.scenario.kodex200),
          _StrategyDetailView(strategyPart: widget.scenario.kodexInverse),
        ],
      ),
    );
  }
}

/// 한 종목의 전략 상세를 보여주는 재사용 가능한 위젯
class _StrategyDetailView extends StatelessWidget {
  final StrategyPart strategyPart;
  const _StrategyDetailView({required this.strategyPart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupSection(
            '매수 조건',
            strategyPart.buyConditionGroups,
            (group) => ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: group.conditions.length,
              itemBuilder: (context, index) => _buildIndicatorConditionTile(group.conditions[index]),
            ),
          ),
          const SizedBox(height: 32),
          _buildGroupSection(
            '매도 조건',
            strategyPart.sellConditionGroups,
            (group) => ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: group.conditions.length,
              itemBuilder: (context, index) => _buildSellConditionTile(group.conditions[index]),
            ),
          ),
        ],
      ),
    );
  }

    /// 매도 조건 타입에 따라 다른 UI를 보여주는 타일 위젯
  Widget _buildSellConditionTile(SellCondition condition) {
    switch (condition.type) {
      case SellConditionType.indicator:
        return _buildIndicatorConditionTile(condition.indicatorCondition!);
      case SellConditionType.trailingStop:
        // ⭐️ [수정] 트레일링 스탑 UI
        final typeText = (condition.trailingStopType == TrailingStopType.fromPurchase) ? '매수가 대비' : '최고가 대비';
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A47),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '트레일링 스탑',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                typeText, // 기준 표시
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${condition.value?.toStringAsFixed(2) ?? 'N/A'} %',
                style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildGroupSection<T>(String title, List<T> groups, Widget Function(T) groupContentBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          const Text('설정된 조건 그룹이 없습니다.', style: TextStyle(color: Colors.white70))
        else
          ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return Card(
                color: const Color(0xFF102A43),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$title ${index + 1}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white12),
                      groupContentBuilder(groups[index]),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// 지표 비교 조건을 시각적으로 보여주는 타일 위젯
  Widget _buildIndicatorConditionTile(IndicatorCondition condition) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A47),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildChip(condition.barType, Colors.purpleAccent),
              const SizedBox(width: 8),
              _buildChip(_barOffsetOptions[condition.barOffset1] ?? '', Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Center(child: Text(condition.indicator1, style: GoogleFonts.poppins(color: Colors.lightBlueAccent, fontWeight: FontWeight.w600, fontSize: 16)))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(condition.operator, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
          ),
          Row(
            children: [
              _buildChip(condition.barType, Colors.purpleAccent),
              const SizedBox(width: 8),
              _buildChip(_barOffsetOptions[condition.barOffset2] ?? '', Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Center(child: Text(condition.indicator2, style: GoogleFonts.poppins(color: Colors.amberAccent, fontWeight: FontWeight.w600, fontSize: 16)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}