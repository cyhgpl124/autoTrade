import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/features/live_trade/bloc/live_trade_bloc.dart';
import 'package:stock/features/live_trade/view/trade_log_page.dart';
// ... 필요한 import

class LiveTradeControlPage extends StatefulWidget {
  const LiveTradeControlPage({super.key});
  @override
  State<LiveTradeControlPage> createState() => _LiveTradeControlPageState();
}

class _LiveTradeControlPageState extends State<LiveTradeControlPage> {
  @override
  void initState() {
    super.initState();
    context.read<LiveTradeBloc>().add(LiveTradeDataLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text('실전 매매', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: '매매 기록 보기',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TradeLogPage()));
            },
          ),
        ],
      ),
      body: BlocBuilder<LiveTradeBloc, LiveTradeState>(
        builder: (context, state) {
          if (state is LiveTradeLoadInProgress || state is LiveTradeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LiveTradeLoadFailure) {
            return Center(child: Text('에러: ${state.error}', style: const TextStyle(color: Colors.white)));
          }
          if (state is LiveTradeLoadSuccess) {
            if(state.scenarios.isEmpty) return const Center(child: Text('생성된 시나리오가 없습니다.', style: TextStyle(color: Colors.white70)));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.scenarios.length,
              itemBuilder: (context, index) {
                final scenario = state.scenarios[index];
                final isActive = state.isScenarioActive(scenario.id);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xFF1E2A47),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(scenario.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(isActive ? '실시간 매매 진행 중' : '대기 중', style: TextStyle(color: isActive ? Colors.greenAccent : Colors.white70)),
                    trailing: Switch(
                      value: isActive,
                      onChanged: (value) {
                        if (value) {
                          context.read<LiveTradeBloc>().add(LiveTradeActivationRequested(scenario.id));
                        } else {
                          context.read<LiveTradeBloc>().add(LiveTradeDeactivationRequested(scenario.id));
                        }
                      },
                      activeTrackColor: Colors.green.withOpacity(0.5),
                      activeColor: Colors.greenAccent,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}