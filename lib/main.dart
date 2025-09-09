import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // FlutterFire CLI로 자동 생성된 파일

// --- Data Layer ---
// Repositories
import 'data/repositories/command_repository.dart';
import 'data/repositories/scenario_repository.dart';
import 'data/repositories/result_repository.dart';
import 'data/repositories/live_status_repository.dart';
import 'data/repositories/trade_log_repository.dart';

// --- Feature: Data Collection ---
import 'features/data_collection/bloc/data_collection_bloc.dart';

// --- Feature: Scenario ---
import 'features/scenario_builder/bloc/scenario_bloc.dart';

// --- Feature: Backtesting ---
import 'features/back_testing/bloc/backtesting_bloc.dart';

// --- Feature: Live Trade ---
import 'features/live_trade/bloc/live_trade_bloc.dart';

// --- UI ---
import 'features/home_page.dart'; // 앱의 메인 화면

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 데이터 계층(Repository) 제공
    return MultiRepositoryProvider(
      providers: [
        // 기존 Repository
        RepositoryProvider<CommandRepository>(create: (context) => CommandRepository()),

        // ⭐️ 새로 추가된 Repositories ⭐️
        RepositoryProvider<ScenarioRepository>(create: (context) => ScenarioRepository()),
        RepositoryProvider<ResultRepository>(create: (context) => ResultRepository()),
        RepositoryProvider<LiveStatusRepository>(create: (context) => LiveStatusRepository()),
        RepositoryProvider<TradeLogRepository>(create: (context) => TradeLogRepository()),
      ],
      // 2. 비즈니스 로직 계층(BLoC) 제공
      child: MultiBlocProvider(
        providers: [
          // 기존 BLoC
          BlocProvider<DataCollectionBloc>(
            create: (context) => DataCollectionBloc(
              commandRepository: context.read<CommandRepository>(),
            ),
          ),

          // ⭐️ 새로 추가된 BLoCs ⭐️
          BlocProvider<ScenarioBloc>(
            create: (context) => ScenarioBloc(
              // 시나리오 BLoC은 Command와 Scenario Repository를 모두 사용합니다.
              scenarioRepository: context.read<ScenarioRepository>(),
            ),
          ),
          BlocProvider<BacktestingBloc>(
            create: (context) => BacktestingBloc(
              commandRepository: context.read<CommandRepository>(),
              scenarioRepository: context.read<ScenarioRepository>(),
              resultRepository: context.read<ResultRepository>(),
            ),
          ),
          BlocProvider<LiveTradeBloc>(
            create: (context) => LiveTradeBloc(
              commandRepo: context.read<CommandRepository>(),
              scenarioRepo: context.read<ScenarioRepository>(),
              statusRepo: context.read<LiveStatusRepository>(),
              logRepo: context.read<TradeLogRepository>(),
            ),
          ),
        ],
        // 3. UI 계층
        child: MaterialApp(
          title: 'Stock Trading App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark, // 다크 테마를 기본으로 설정
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}