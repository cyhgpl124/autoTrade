import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/features/live_trade/bloc/live_trade_bloc.dart';
// ... 필요한 import

class TradeLogPage extends StatelessWidget {
  const TradeLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text('매매 기록', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1E2A47),
      ),
      body: BlocBuilder<LiveTradeBloc, LiveTradeState>(
        builder: (context, state) {
          if (state is LiveTradeLoadSuccess) {
            if (state.tradeLogs.isEmpty) {
              return Center(child: Text('매매 기록이 없습니다.', style: GoogleFonts.poppins(color: Colors.white70)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.tradeLogs.length,
              itemBuilder: (context, index) {
                final log = state.tradeLogs[index];
                final isBuy = log.action == 'buy';
                final format = NumberFormat.decimalPattern('ko_KR');

                return Card(
                  color: const Color(0xFF1E2A47),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isBuy ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                      child: Icon(isBuy ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: isBuy ? Colors.redAccent : Colors.blueAccent),
                    ),
                    title: Text('${log.scenarioName} - ${log.code}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${isBuy ? '매수' : '매도'}: ${log.quantity}주 x ${format.format(log.price)}원',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      DateFormat('MM/dd HH:mm').format(log.timestamp.toDate()),
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              },
            );
          }
          // 이전 화면에서 데이터를 로드했으므로, 이 화면에서는 로딩 상태가 거의 보이지 않음
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}