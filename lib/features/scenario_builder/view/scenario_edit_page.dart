import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/scenario_model.dart';
import '../bloc/scenario_bloc.dart';

// --- UI에서 선택 가능한 옵션 목록 ---
const List<String> _barTypeOptions = ['일봉', '60분봉', '30분봉', '10분봉', '5분봉', '1분봉'];
const List<String> _indicatorOptions = ['종가', '시가', '고가', '저가', 'ma_5', 'ma_10', 'ma_20', 'ma_60', 'ma_120'];
const List<String> _operatorOptions = ['cross_above', 'cross_below', 'is_greater_than', 'is_less_than'];
const Map<int, String> _barOffsetOptions = { 0: '현재봉', 1: '1봉전', 2: '2봉전', 3: '3봉전', 4: '4봉전', 5: '5봉전' };
const Map<TrailingStopType, String> _trailingStopTypeOptions = {
  TrailingStopType.fromPurchase: '매수가 대비',
  TrailingStopType.fromHigh: '최고가 대비',
};

class ScenarioEditPage extends StatefulWidget {
  final Scenario? existingScenario;
  const ScenarioEditPage({super.key, this.existingScenario});

  @override
  State<ScenarioEditPage> createState() => _ScenarioEditPageState();
}

class _ScenarioEditPageState extends State<ScenarioEditPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late TabController _tabController;

  late StrategyPart _kodex200Part;
  late StrategyPart _kodexInversePart;

  bool get isEditMode => widget.existingScenario != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.existingScenario?.name ?? '');
    _kodex200Part = widget.existingScenario?.kodex200 ?? StrategyPart();
    _kodexInversePart = widget.existingScenario?.kodexInverse ?? StrategyPart();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _saveScenario() {
    if (_formKey.currentState!.validate()) {
      final event = isEditMode
          ? ScenarioUpdated(
              id: widget.existingScenario!.id, name: _nameController.text,
              kodex200: _kodex200Part, kodexInverse: _kodexInversePart,
            )
          : ScenarioCreated(
              name: _nameController.text,
              kodex200: _kodex200Part, kodexInverse: _kodexInversePart,
            );
      context.read<ScenarioBloc>().add(event);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Text(isEditMode ? '시나리오 수정' : '새 시나리오', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.save_rounded), tooltip: '저장', onPressed: _saveScenario)],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(),
          indicatorColor: Colors.blueAccent,
          tabs: const [Tab(text: 'KODEX 200'), Tab(text: 'KODEX 인버스')],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('시나리오 이름'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? '이름을 입력하세요.' : null,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _StrategyEditor(
                    key: const ValueKey('kodex200'),
                    strategyPart: _kodex200Part,
                    onChanged: (newPart) => setState(() => _kodex200Part = newPart),
                  ),
                  _StrategyEditor(
                    key: const ValueKey('kodexInverse'),
                    strategyPart: _kodexInversePart,
                    onChanged: (newPart) => setState(() => _kodexInversePart = newPart),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: Colors.white70),
      filled: true, fillColor: const Color(0xFF1E2A47),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF539DF3), width: 2),
      ),
    );
  }
}

/// 한 종목의 매수/매도 조건을 편집하는 재사용 가능한 위젯
class _StrategyEditor extends StatelessWidget {
  final StrategyPart strategyPart;
  final ValueChanged<StrategyPart> onChanged;

  const _StrategyEditor({super.key, required this.strategyPart, required this.onChanged});

  void _updateBuyGroups(List<BuyConditionGroup> newGroups) {
    onChanged(StrategyPart(buyConditionGroups: newGroups, sellConditionGroups: strategyPart.sellConditionGroups));
  }

  void _updateSellGroups(List<SellConditionGroup> newGroups) {
    onChanged(StrategyPart(buyConditionGroups: strategyPart.buyConditionGroups, sellConditionGroups: newGroups));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _ConditionGroupSection<BuyConditionGroup, IndicatorCondition>(
            title: '매수 조건',
            groups: strategyPart.buyConditionGroups,
            onGroupAdd: () {
              final newGroups = List<BuyConditionGroup>.from(strategyPart.buyConditionGroups)..add(BuyConditionGroup());
              _updateBuyGroups(newGroups);
            },
            onGroupRemove: (groupIndex) {
              final newGroups = List<BuyConditionGroup>.from(strategyPart.buyConditionGroups)..removeAt(groupIndex);
              _updateBuyGroups(newGroups);
            },
            onConditionAdd: (groupIndex, {type}) { // type is ignored for buy
              final newGroups = List<BuyConditionGroup>.from(strategyPart.buyConditionGroups);
              final newConditions = List<IndicatorCondition>.from(newGroups[groupIndex].conditions)..add(IndicatorCondition(indicator1: 'ma_5', operator: 'cross_above', indicator2: 'ma_20'));
              newGroups[groupIndex] = BuyConditionGroup(conditions: newConditions);
              _updateBuyGroups(newGroups);
            },
            onConditionRemove: (groupIndex, conditionIndex) {
              final newGroups = List<BuyConditionGroup>.from(strategyPart.buyConditionGroups);
              final newConditions = List<IndicatorCondition>.from(newGroups[groupIndex].conditions)..removeAt(conditionIndex);
              newGroups[groupIndex] = BuyConditionGroup(conditions: newConditions);
              _updateBuyGroups(newGroups);
            },
            onConditionChanged: (groupIndex, conditionIndex, newCondition) {
               final newGroups = List<BuyConditionGroup>.from(strategyPart.buyConditionGroups);
              final newConditions = List<IndicatorCondition>.from(newGroups[groupIndex].conditions);
              newConditions[conditionIndex] = newCondition;
              newGroups[groupIndex] = BuyConditionGroup(conditions: newConditions);
              _updateBuyGroups(newGroups);
            },
            rowBuilder: (condition, onChanged, onDeleted) =>
                _BuyConditionRow(initialCondition: condition, onChanged: onChanged, onDeleted: onDeleted),
          ),
          const SizedBox(height: 32),
          _ConditionGroupSection<SellConditionGroup, SellCondition>(
            title: '매도 조건',
            groups: strategyPart.sellConditionGroups,
            onGroupAdd: () {
              final newGroups = List<SellConditionGroup>.from(strategyPart.sellConditionGroups)..add(SellConditionGroup());
              _updateSellGroups(newGroups);
            },
            onGroupRemove: (groupIndex) {
               final newGroups = List<SellConditionGroup>.from(strategyPart.sellConditionGroups)..removeAt(groupIndex);
              _updateSellGroups(newGroups);
            },
            // ⭐️ [수정] type이 nullable일 수 있음을 명시하고, null일 경우 기본값 사용
            onConditionAdd: (groupIndex, {type}) {
              final nonNullableType = type ?? SellConditionType.indicator;
              SellCondition newCondition;
              switch(nonNullableType) {
                case SellConditionType.indicator: newCondition = SellCondition(type: nonNullableType, indicatorCondition: IndicatorCondition(indicator1: 'ma_5', operator: 'cross_below', indicator2: 'ma_20')); break;
                case SellConditionType.trailingStop: newCondition = SellCondition(type: nonNullableType, value: -3.0, trailingStopType: TrailingStopType.fromHigh); break;
              }
              final newGroups = List<SellConditionGroup>.from(strategyPart.sellConditionGroups);
              final newConditions = List<SellCondition>.from(newGroups[groupIndex].conditions)..add(newCondition);
              newGroups[groupIndex] = SellConditionGroup(conditions: newConditions);
              _updateSellGroups(newGroups);
            },
            onConditionRemove: (groupIndex, conditionIndex) {
              final newGroups = List<SellConditionGroup>.from(strategyPart.sellConditionGroups);
              final newConditions = List<SellCondition>.from(newGroups[groupIndex].conditions)..removeAt(conditionIndex);
              newGroups[groupIndex] = SellConditionGroup(conditions: newConditions);
              _updateSellGroups(newGroups);
            },
            onConditionChanged: (groupIndex, conditionIndex, newCondition) {
              final newGroups = List<SellConditionGroup>.from(strategyPart.sellConditionGroups);
              final newConditions = List<SellCondition>.from(newGroups[groupIndex].conditions);
              newConditions[conditionIndex] = newCondition;
              newGroups[groupIndex] = SellConditionGroup(conditions: newConditions);
              _updateSellGroups(newGroups);
            },
            rowBuilder: (condition, onChanged, onDeleted) =>
                _SellConditionRow(initialCondition: condition, onChanged: onChanged, onDeleted: onDeleted),
            isSellSection: true,
          ),
        ],
      ),
    );
  }
}

/// 조건 그룹 전체(제목, 그룹 목록, 그룹 추가 버튼)를 그리는 재사용 위젯
class _ConditionGroupSection<G, C> extends StatelessWidget {
  final String title;
  final List<G> groups;
  final VoidCallback onGroupAdd;
  final void Function(int) onGroupRemove;
  // ⭐️ [수정] onConditionAdd의 'type'을 nullable로 변경하여 타입 에러 해결
  final void Function(int, {SellConditionType? type}) onConditionAdd;
  final void Function(int, int) onConditionRemove;
  final void Function(int, int, C) onConditionChanged;
  final Widget Function(C, ValueChanged<C>, VoidCallback) rowBuilder;
  final bool isSellSection;

  const _ConditionGroupSection({
    super.key, required this.title, required this.groups,
    required this.onGroupAdd, required this.onGroupRemove,
    required this.onConditionAdd, required this.onConditionRemove,
    required this.onConditionChanged, required this.rowBuilder,
    this.isSellSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          const Center(child: Text('아래 버튼을 눌러 조건 그룹을 추가하세요.', style: TextStyle(color: Colors.white54))),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            final group = groups[groupIndex];
            final conditions = (G == BuyConditionGroup) ? (group as BuyConditionGroup).conditions : (group as SellConditionGroup).conditions;
            return _ConditionGroupCard(
              title: '$title ${groupIndex + 1}',
              onGroupRemove: () => onGroupRemove(groupIndex),
              onConditionAdd: ({type}) => onConditionAdd(groupIndex, type: type),
              isSellSection: isSellSection,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conditions.length,
                itemBuilder: (context, conditionIndex) {
                  return rowBuilder(
                    conditions[conditionIndex] as C,
                    (newCondition) => onConditionChanged(groupIndex, conditionIndex, newCondition),
                    () => onConditionRemove(groupIndex, conditionIndex),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: OutlinedButton.icon(
            onPressed: onGroupAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text('$title 그룹 추가'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white30)),
          ),
        ),
      ],
    );
  }
}

/// 조건 그룹 하나를 감싸는 카드 위젯
class _ConditionGroupCard extends StatelessWidget {
  final String title;
  final VoidCallback onGroupRemove;
  // ⭐️ [수정] onConditionAdd의 'type'을 nullable로 변경
  final void Function({SellConditionType? type}) onConditionAdd;
  final bool isSellSection;
  final Widget child;

  const _ConditionGroupCard({
    required this.title, required this.onGroupRemove,
    required this.onConditionAdd, this.isSellSection = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF102A43),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 20), onPressed: onGroupRemove, tooltip: '그룹 삭제'),
              ],
            ),
            const Divider(color: Colors.white12),
            child,
            const SizedBox(height: 8),
            isSellSection ? _buildAddSellMenu((type) => onConditionAdd(type: type))
            : OutlinedButton.icon(
              onPressed: () => onConditionAdd(), // ⭐️ 매수 조건 추가 시 'type'을 보내지 않음
              icon: const Icon(Icons.add, size: 16), label: const Text('상세 조건 추가'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white54, side: const BorderSide(color: Colors.white24)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddSellMenu(Function(SellConditionType) onSelect) {
    return PopupMenuButton<SellConditionType>(
      onSelected: onSelect,
      itemBuilder: (context) => [
        const PopupMenuItem(value: SellConditionType.indicator, child: Text('지표 조건 추가')),
        const PopupMenuItem(value: SellConditionType.trailingStop, child: Text('트레일링 스탑 추가 (%)')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.add, size: 16, color: Colors.white54), SizedBox(width: 8), Text('상세 조건 추가', style: TextStyle(color: Colors.white54))
        ]),
      ),
    );
  }
}

/// 매수 조건 한 줄 UI
class _BuyConditionRow extends StatefulWidget {
  final IndicatorCondition initialCondition;
  final ValueChanged<IndicatorCondition> onChanged;
  final VoidCallback onDeleted;
  const _BuyConditionRow({super.key, required this.initialCondition, required this.onChanged, required this.onDeleted});
  @override
  State<_BuyConditionRow> createState() => _BuyConditionRowState();
}
class _BuyConditionRowState extends State<_BuyConditionRow> {
  late String _barType;
  late int _barOffset1, _barOffset2;
  late String _indicator1, _indicator2, _operator;
  @override
  void initState() {
    super.initState();
    _barType = widget.initialCondition.barType;
    _barOffset1 = widget.initialCondition.barOffset1;
    _indicator1 = widget.initialCondition.indicator1;
    _operator = widget.initialCondition.operator;
    _barOffset2 = widget.initialCondition.barOffset2;
    _indicator2 = widget.initialCondition.indicator2;
  }
  void _updateParent() {
    widget.onChanged(IndicatorCondition(
      barType: _barType, barOffset1: _barOffset1, indicator1: _indicator1,
      operator: _operator, barOffset2: _barOffset2, indicator2: _indicator2,
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E2A47).withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: _buildDropdown(_barType, _barTypeOptions, (val) => setState(() { _barType = val!; _updateParent(); }))),
              _buildVerticalDivider(),
              Expanded(flex: 3, child: _buildBarOffsetDropdown(_barOffset1, (val) => setState(() { _barOffset1 = val!; _updateParent(); }))),
              _buildVerticalDivider(),
              Expanded(flex: 4, child: _buildDropdown(_indicator1, _indicatorOptions, (val) => setState(() { _indicator1 = val!; _updateParent(); }))),
              _buildVerticalDivider(),
              Expanded(flex: 4, child: Center(child: _buildDropdown(_operator, _operatorOptions, (val) => setState(() { _operator = val!; _updateParent(); })))),
              _buildVerticalDivider(),
              Expanded(flex: 3, child: _buildBarOffsetDropdown(_barOffset2, (val) => setState(() { _barOffset2 = val!; _updateParent(); }))),
              _buildVerticalDivider(),
              Expanded(flex: 4, child: _buildDropdown(_indicator2, _indicatorOptions, (val) => setState(() { _indicator2 = val!; _updateParent(); }))),
              IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 20), onPressed: widget.onDeleted, splashRadius: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// 매도 조건 한 줄 UI (타입에 따라 다른 UI 표시)
class _SellConditionRow extends StatefulWidget {
  final SellCondition initialCondition;
  final ValueChanged<SellCondition> onChanged;
  final VoidCallback onDeleted;
  const _SellConditionRow({super.key, required this.initialCondition, required this.onChanged, required this.onDeleted});
  @override
  State<_SellConditionRow> createState() => _SellConditionRowState();
}
class _SellConditionRowState extends State<_SellConditionRow> {
  late SellCondition _currentCondition;
  final TextEditingController _valueController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _currentCondition = widget.initialCondition;
    _valueController.text = _currentCondition.value?.toString() ?? '';
  }
  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    switch (_currentCondition.type) {
      case SellConditionType.indicator:
        return _BuyConditionRow(
          initialCondition: _currentCondition.indicatorCondition!,
          onChanged: (newIndicatorCondition) {
            widget.onChanged(SellCondition(type: SellConditionType.indicator, indicatorCondition: newIndicatorCondition));
          },
          onDeleted: widget.onDeleted,
        );
      case SellConditionType.trailingStop:
        return Card(
          color: const Color(0xFF1E2A47).withOpacity(0.5),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('트레일링 스탑', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 4,
                  child: _buildDropdown<TrailingStopType>(
                    _currentCondition.trailingStopType ?? TrailingStopType.fromHigh,
                    _trailingStopTypeOptions,
                    (newType) {
                      if (newType != null) {
                        final newCondition = SellCondition(type: _currentCondition.type, value: _currentCondition.value, trailingStopType: newType);
                        setState(() => _currentCondition = newCondition);
                        widget.onChanged(newCondition);
                      }
                    },
                    isTrailingStopType: true,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _valueController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      suffixText: ' %',
                      suffixStyle: TextStyle(color: Colors.white70),
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      if(parsedValue != null) {
                        widget.onChanged(SellCondition(type: _currentCondition.type, value: parsedValue, trailingStopType: _currentCondition.trailingStopType));
                      }
                    },
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 20), onPressed: widget.onDeleted, splashRadius: 20),
              ],
            ),
          ),
        );
    }
  }
}

// --- 공용 위젯 및 헬퍼 함수들 (State 클래스 밖) ---
Widget _buildVerticalDivider() => const VerticalDivider(color: Colors.white12, thickness: 1, width: 8);

Widget _buildBarOffsetDropdown(int currentValue, ValueChanged<int?> onChanged) {
  return _buildDropdown<int>(
    currentValue, _barOffsetOptions, onChanged, isBarOffset: true,
  );
}

Widget _buildDropdown<T>(T value, dynamic items, ValueChanged<T?> onChanged, {bool isBarOffset = false, bool isTrailingStopType = false}) {
  List<DropdownMenuItem<T>> dropdownItems;

  if (isBarOffset || isTrailingStopType) {
    dropdownItems = (items as Map<T, String>).entries.map((entry) {
      return DropdownMenuItem<T>(value: entry.key, child: Text(entry.value, style: const TextStyle(fontSize: 12)));
    }).toList();
  } else {
     dropdownItems = (items as List<String>).map((item) {
      return DropdownMenuItem<T>(value: item as T, child: Text(item, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis));
    }).toList();
  }
  return DropdownButtonHideUnderline(
    child: DropdownButton<T>(
      value: value, items: dropdownItems, onChanged: onChanged,
      isExpanded: true, dropdownColor: const Color(0xFF1E2A47),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white70,
      icon: const Icon(Icons.arrow_drop_down, size: 20),
      alignment: Alignment.center,
    ),
  );
}