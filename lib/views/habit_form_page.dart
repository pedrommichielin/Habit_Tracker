import 'package:flutter/material.dart';

class HabitFormPage extends StatefulWidget {
  final Map<String, String>? habit;

  const HabitFormPage({super.key, this.habit});

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _frequency = 'Diário';
  int _targetCount = 1;

  final List<String> _frequencies = [
    'Diário',
    'Semanal',
    'Mensal',
    '1 Minuto',
    '15 Minutos',
    '30 Minutos',
    '1 Hora',
    '12 Horas',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!['name'] ?? '';
      _descController.text = widget.habit!['description'] ?? '';
      _frequency = widget.habit!['frequency'] ?? 'Diário';
      _targetCount = int.tryParse(widget.habit!['targetCount'] ?? '1') ?? 1;
    }
  }

  void _updateSuggestedFrequency(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('leitura') || lower.contains('ler')) {
      _frequency = 'Diário';
    } else if (lower.contains('academia') || lower.contains('exercício')) {
      _frequency = 'Semanal';
    } else if (lower.contains('limpeza') || lower.contains('organização')) {
      _frequency = 'Mensal';
    }
    setState(() {});
  }

  Widget _buildTargetField() {
    if (_frequency == 'Semanal' || _frequency == 'Mensal') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Meta de vezes ${_frequency == 'Semanal' ? 'por semana' : 'por mês'}:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Slider(
            value: _targetCount.toDouble(),
            min: 1,
            max: _frequency == 'Semanal' ? 7 : 30,
            divisions: _frequency == 'Semanal' ? 6 : 29,
            label: '$_targetCount',
            onChanged: (value) {
              setState(() {
                _targetCount = value.toInt();
              });
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'description': _descController.text,
        'frequency': _frequency,
        'targetCount': _targetCount.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Novo Hábito' : 'Editar Hábito'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nome do Hábito',
                  labelStyle: TextStyle(color: labelColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: labelColor),
                  ),
                ),
                onChanged: _updateSuggestedFrequency,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Insira o nome do hábito' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: labelColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: labelColor),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Insira uma descrição' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(
                  labelText: 'Frequência',
                  labelStyle: TextStyle(color: labelColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: labelColor),
                  ),
                ),
                items: _frequencies
                    .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                    if (_frequency != 'Semanal' && _frequency != 'Mensal') {
                      _targetCount = 1;
                    }
                  });
                },
              ),
              _buildTargetField(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Salvar Hábito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: labelColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
