import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/backtest_result_model.dart';
import '../../../../data/models/scenario_model.dart';
import '../bloc/backtesting_bloc.dart';
import 'result_detail_page.dart';

class BacktestingHomePage extends StatefulWidget {
  const BacktestingHomePage({super.key});

  @override
  State<BacktestingHomePage> createState() => _BacktestingHomePageState();
}

class _BacktestingHomePageState extends State<BacktestingHomePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedScenarioId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365 * 5)); // 5년 전
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때 데이터 로딩 이벤트를 BLoC에 전달
    context.read<BacktestingBloc>().add(BacktestingDataLoaded());
  }

  // 날짜 선택 팝업을 띄우는 함수
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // 백테스팅 실행 버튼을 눌렀을 때 호출되는 함수
  void _submitBacktest() {
    if (_formKey.currentState!.validate()) {
      context.read<BacktestingBloc>().add(
            BacktestRequested(
              scenarioId: _selectedScenarioId!,
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
      // 사용자에게 명령이 전송되었음을 알림
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('백테스팅 명령을 전송했습니다. 결과는 잠시 후 목록에 나타납니다.'),
            backgroundColor: Colors.blue,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text('백테스팅', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<BacktestingBloc, BacktestingState>(
        builder: (context, state) {
          if (state is BacktestingLoadInProgress || state is BacktestingInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BacktestingLoadFailure) {
            return Center(child: Text('데이터 로딩 실패: ${state.error}', style: const TextStyle(color: Colors.white)));
          }
          if (state is BacktestingLoadSuccess) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildNewBacktestCard(state.scenarios),
                const SizedBox(height: 32),
                Text('과거 결과 목록', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                if (state.results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: Text('백테스팅 결과가 없습니다.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16))),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      return _buildResultTile(state.results[index]);
                    },
                  ),
              ],
            );
          }
          return const Center(child: Text('알 수 없는 상태입니다.', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  /// 새로운 백테스팅을 시작하는 UI 카드 위젯
  Widget _buildNewBacktestCard(List<Scenario> scenarios) {
    return Card(
      elevation: 4.0,
      color: const Color(0xFF1E2A47),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('새로운 백테스팅 시작', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              // 시나리오 선택 드롭다운
              DropdownButtonFormField<String>(
                value: _selectedScenarioId,
                hint: const Text('시나리오 선택', style: TextStyle(color: Colors.white70)),
                items: scenarios
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedScenarioId = value),
                decoration: _buildInputDecoration(),
                dropdownColor: const Color(0xFF1E2A47),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null ? '시나리오를 선택하세요.' : null,
              ),
              const SizedBox(height: 20),
              // 날짜 선택
              Row(
                children: [
                  Expanded(child: _buildDateSelector("시작일", _startDate, () => _selectDate(context, true))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateSelector("종료일", _endDate, () => _selectDate(context, false))),
                ],
              ),
              const SizedBox(height: 24),
              // 실행 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('백테스팅 실행', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _submitBacktest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF539DF3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 날짜 선택기 UI 위젯
  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(color: Colors.white)),
                const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 과거 결과 목록의 각 항목을 그리는 타일 위젯
  Widget _buildResultTile(BacktestResult result) {
    final profitRate = result.summary['수익률 (%)'] ?? 0.0;
    final isProfit = profitRate > 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: const Color(0xFF1E2A47),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: isProfit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          child: Icon(isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: isProfit ? Colors.green : Colors.red),
        ),
        title: Text(result.scenarioName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(DateFormat('yyyy년 MM월 dd일 HH:mm').format(result.testedAt.toDate()), style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          '${profitRate.toStringAsFixed(2)}%',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isProfit ? Colors.greenAccent : Colors.redAccent),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ResultDetailPage(result: result)),
          );
        },
      ),
    );
  }

  /// TextFormField, DropdownButtonFormField의 공통 데코레이션
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF0A192F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF539DF3), width: 1.5),
      ),
    );
  }
}