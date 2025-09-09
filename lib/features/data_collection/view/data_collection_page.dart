import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/data_collection_bloc.dart';

class DataCollectionPage extends StatefulWidget {
  const DataCollectionPage({super.key});

  @override
  State<DataCollectionPage> createState() => _DataCollectionPageState();
}

class _DataCollectionPageState extends State<DataCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  String _selectedBarType = '일봉'; // 기본값

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: '069500'); // 기본값
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<DataCollectionBloc>().add(
            DataCollectionRequested(
              code: _codeController.text,
              barType: _selectedBarType,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text('데이터 수집', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<DataCollectionBloc, DataCollectionState>(
        listener: (context, state) {
          if (state is DataCollectionSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('✅ 데이터 수집 명령을 성공적으로 전송했습니다.'),
                  backgroundColor: Colors.green,
                ),
              );
          }
          if (state is DataCollectionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('❌ 명령 전송에 실패했습니다: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('수집 정보 입력', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 32),

                // 종목 코드 입력 필드
                TextFormField(
                  controller: _codeController,
                  decoration: _buildInputDecoration('수집 종목 코드'),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value == null || value.isEmpty ? '종목 코드를 입력하세요' : null,
                ),
                const SizedBox(height: 24),

                // 수집 봉 종류 선택 필드
                DropdownButtonFormField<String>(
                  value: _selectedBarType,
                  items: ['일봉', '10분봉', '5분봉']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedBarType = value;
                      });
                    }
                  },
                  decoration: _buildInputDecoration('수집 봉 종류'),
                  dropdownColor: const Color(0xFF1E2A47),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 48),

                // 데이터 수집 요청 버튼
                BlocBuilder<DataCollectionBloc, DataCollectionState>(
                  builder: (context, state) {
                    // InProgress 상태일 때 로딩 인디케이터 표시
                    if (state is DataCollectionInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF539DF3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          '데이터 수집 요청',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E2A47),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF539DF3), width: 2),
      ),
    );
  }
}