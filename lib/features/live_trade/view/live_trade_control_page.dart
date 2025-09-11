// live_trade/view/live_trade_control_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/features/live_trade/bloc/live_trade_bloc.dart';
import 'package:stock/features/live_trade/view/trade_log_page.dart';

class LiveTradeControlPage extends StatefulWidget {
  const LiveTradeControlPage({super.key});
  @override
  State<LiveTradeControlPage> createState() => _LiveTradeControlPageState();
}

class _LiveTradeControlPageState extends State<LiveTradeControlPage> {
  @override
  void initState() {
    super.initState();
    // Initial data load when the widget is first created
    context.read<LiveTradeBloc>().add(LiveTradeDataLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text('Real-time Trading', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'View Trading Log',
            onPressed: () {
              // Navigate to the trading log page
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                // Provide the BLoC to the new route
                return BlocProvider.value(
                  value: BlocProvider.of<LiveTradeBloc>(context),
                  child: const TradeLogPage(),
                );
              }));
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
            return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.white)));
          }
          if (state is LiveTradeLoadSuccess) {
            if (state.scenarios.isEmpty) {
              return const Center(child: Text('No scenarios created.', style: TextStyle(color: Colors.white70)));
            }
            // Display the list of scenarios
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.scenarios.length,
              itemBuilder: (context, index) {
                final scenario = state.scenarios[index];
                final isActive = state.isScenarioActive(scenario.id);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xFF1E2A47),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(
                      scenario.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      isActive ? 'Live trading in progress' : 'Waiting',
                      style: TextStyle(color: isActive ? Colors.greenAccent : Colors.white70),
                    ),
                    // ✨ Switch has been replaced with an ElevatedButton
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (isActive) {
                          // If active, send a deactivation request
                          context.read<LiveTradeBloc>().add(LiveTradeDeactivationRequested(scenario.id));
                        } else {
                          // If inactive, send an activation request
                          context.read<LiveTradeBloc>().add(LiveTradeActivationRequested(scenario.id));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? Colors.redAccent : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        isActive ? 'Stop' : 'Start',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
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