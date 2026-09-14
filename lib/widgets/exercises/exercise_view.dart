import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/exercise.dart';

typedef AnswerChanged = void Function(dynamic answer);

class ExerciseView extends StatefulWidget {
  const ExerciseView({
    super.key,
    required this.exercise,
    required this.onAnswerChanged,
  });

  final Exercise exercise;
  final AnswerChanged onAnswerChanged;

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  int? _mc;
  final _numCtrl = TextEditingController();
  late List<int> _order;
  bool? _tf;
  int? _just;
  int _step = 0;
  final List<dynamic> _stepAnswers = [];
  int _hintIndex = 0;

  @override
  void initState() {
    super.initState();
    _resetLocal();
  }

  @override
  void didUpdateWidget(covariant ExerciseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _resetLocal();
    }
  }

  void _resetLocal() {
    _mc = null;
    _numCtrl.clear();
    final items = widget.exercise.orderItems;
    if (items == null) {
      _order = <int>[];
    } else {
      _order = List<int>.generate(items.length, (i) => i);
      // Zamíchej startovní pořadí (deterministicky podle id)
      final seed = widget.exercise.id.hashCode;
      _order.shuffle(Random(seed));
      // pokud náhodou vyšlo správně, prohoď první dva
      final correct = widget.exercise.correctOrder;
      if (correct != null &&
          _order.length > 1 &&
          listEquals(_order, correct)) {
        final tmp = _order[0];
        _order[0] = _order[1];
        _order[1] = tmp;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAnswerChanged(List<int>.from(_order));
      });
    }
    _tf = null;
    _just = null;
    _step = 0;
    _stepAnswers.clear();
    _hintIndex = 0;
    widget.onAnswerChanged(null);
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ex.prompt,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
        ),
        const SizedBox(height: 16),
        ..._buildBody(ex),
        if (ex.hints != null && ex.hints!.isNotEmpty) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _hintIndex = (_hintIndex + 1).clamp(0, ex.hints!.length);
              });
            },
            icon: const Icon(Icons.lightbulb_outline),
            label: Text(
              _hintIndex == 0
                  ? 'Nápověda'
                  : 'Další nápověda ($_hintIndex/${ex.hints!.length})',
            ),
          ),
          if (_hintIndex > 0)
            ...List.generate(
              _hintIndex.clamp(0, ex.hints!.length),
              (i) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('💡 ${ex.hints![i]}'),
              ),
            ),
        ],
      ],
    );
  }

  List<Widget> _buildBody(Exercise ex) {
    switch (ex.type) {
      case ExerciseType.multipleChoice:
        return _mcBody(ex);
      case ExerciseType.numericFill:
        return _numBody();
      case ExerciseType.orderSteps:
        return _orderBody(ex);
      case ExerciseType.trueFalse:
        return _tfBody(ex);
      case ExerciseType.multiStep:
        return _multiBody(ex);
    }
  }

  List<Widget> _mcBody(Exercise ex) {
    return List.generate(ex.options!.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RadioListTile<int>(
          value: i,
          groupValue: _mc,
          title: Text(ex.options![i]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          onChanged: (v) {
            setState(() => _mc = v);
            widget.onAnswerChanged(v);
          },
        ),
      );
    });
  }

  List<Widget> _numBody() {
    return [
      TextField(
        controller: _numCtrl,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\-]')),
        ],
        decoration: const InputDecoration(
          labelText: 'Odpověď',
          border: OutlineInputBorder(),
          hintText: 'Např. 3.14 nebo 3,14',
        ),
        onChanged: (s) {
          final v = double.tryParse(s.replaceAll(',', '.'));
          widget.onAnswerChanged(v);
        },
      ),
    ];
  }

  List<Widget> _orderBody(Exercise ex) {
    return [
      Text(
        'Přesuň položky do správného pořadí (dlouhý stisk a táhni):',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _order.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _order.removeAt(oldIndex);
            _order.insert(newIndex, item);
            widget.onAnswerChanged(List<int>.from(_order));
          });
        },
        itemBuilder: (context, index) {
          final itemIndex = _order[index];
          return Card(
            key: ValueKey('ord-$itemIndex'),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(ex.orderItems![itemIndex]),
              trailing: const Icon(Icons.drag_handle),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _tfBody(Exercise ex) {
    return [
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('Pravda'), icon: Icon(Icons.check)),
          ButtonSegment(value: false, label: Text('Nepravda'), icon: Icon(Icons.close)),
        ],
        selected: _tf == null ? {} : {_tf!},
        emptySelectionAllowed: true,
        onSelectionChanged: (s) {
          setState(() => _tf = s.isEmpty ? null : s.first);
          _emitTf(ex);
        },
      ),
      if (ex.justificationPrompt != null) ...[
        const SizedBox(height: 16),
        Text(ex.justificationPrompt!,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        ...List.generate(ex.justificationOptions!.length, (i) {
          return RadioListTile<int>(
            value: i,
            groupValue: _just,
            title: Text(ex.justificationOptions![i]),
            onChanged: (v) {
              setState(() => _just = v);
              _emitTf(ex);
            },
          );
        }),
      ],
    ];
  }

  void _emitTf(Exercise ex) {
    if (ex.justificationPrompt != null) {
      widget.onAnswerChanged({'value': _tf, 'justification': _just});
    } else {
      widget.onAnswerChanged(_tf);
    }
  }

  List<Widget> _multiBody(Exercise ex) {
    final steps = ex.steps!;
    final part = steps[_step];
    return [
      Text('Krok ${_step + 1} / ${steps.length}',
          style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      Text(part.prompt, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      if (part.hint != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('💡 ${part.hint}',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      if (part.type == ExerciseType.multipleChoice)
        ...List.generate(part.options!.length, (i) {
          return RadioListTile<int>(
            value: i,
            groupValue: _mc,
            title: Text(part.options![i]),
            onChanged: (v) {
              setState(() => _mc = v);
              _setStepAnswer(v);
            },
          );
        })
      else
        TextField(
          controller: _numCtrl,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Odpověď kroku',
            border: OutlineInputBorder(),
          ),
          onChanged: (s) {
            final v = double.tryParse(s.replaceAll(',', '.'));
            _setStepAnswer(v);
          },
        ),
      const SizedBox(height: 8),
      Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _step--;
                  _stepAnswers.removeLast();
                  _mc = null;
                  _numCtrl.clear();
                  widget.onAnswerChanged(
                    _stepAnswers.length == steps.length
                        ? List.from(_stepAnswers)
                        : null,
                  );
                });
              },
              child: const Text('Zpět'),
            ),
          const Spacer(),
          if (_step < steps.length - 1)
            FilledButton.tonal(
              onPressed: _mc != null || _numCtrl.text.isNotEmpty
                  ? () {
                      setState(() {
                        _stepAnswers.add(
                          part.type == ExerciseType.multipleChoice
                              ? _mc
                              : double.tryParse(
                                  _numCtrl.text.replaceAll(',', '.'),
                                ),
                        );
                        _step++;
                        _mc = null;
                        _numCtrl.clear();
                        widget.onAnswerChanged(null);
                      });
                    }
                  : null,
              child: const Text('Další krok'),
            ),
        ],
      ),
    ];
  }

  void _setStepAnswer(dynamic v) {
    final steps = widget.exercise.steps!;
    if (_step == steps.length - 1) {
      final all = List<dynamic>.from(_stepAnswers)..add(v);
      if (all.length == steps.length) {
        widget.onAnswerChanged(all);
      } else {
        widget.onAnswerChanged(null);
      }
    }
  }
}
