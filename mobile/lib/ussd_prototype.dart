import 'package:flutter/material.dart';

/// An in-app preview of the menu intended for a future network USSD channel.
/// It does not dial or claim a live shortcode.
class UssdPrototypePage extends StatefulWidget {
  const UssdPrototypePage({super.key});

  @override
  State<UssdPrototypePage> createState() => _UssdPrototypePageState();
}

class _UssdPrototypePageState extends State<UssdPrototypePage> {
  final _input = TextEditingController();
  String _path = '';

  String get _menu => switch (_path) {
    '' =>
      'CON Serenity Hub\n1. I need to feel calmer\n2. Daily wellbeing tip\n3. Find support\n0. About this service',
    '1' =>
      'CON Breathe in gently for 4 counts, hold for 2, and breathe out for 6. Repeat 4 times.\n1. Another exercise\n0. Main menu',
    '1*1' =>
      'END Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, and 1 you taste.',
    '2' =>
      'END Today, make the next step small: drink water, stretch, or message someone you trust.',
    '3' =>
      'CON Choose support\n1. Talk to someone I trust\n2. Professional care information\n3. Immediate danger',
    '3*1' =>
      'END Consider calling or visiting a trusted friend, relative, teacher, faith leader, or community health worker.',
    '3*2' =>
      'END A future registered service can list verified local providers here. This prototype does not book care.',
    '3*3' =>
      'END If you or someone else is in immediate danger, contact local emergency services or go to the nearest health facility now.',
    '0' =>
      'END Serenity Hub provides general wellbeing information, not diagnosis, treatment, or emergency response.',
    _ => 'END Invalid option. Start again to return to the main menu.',
  };

  void _send() {
    final value = _input.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _path =
          value == '0' && _path.isNotEmpty
              ? ''
              : (_path.isEmpty ? value : '$_path*$value');
      _input.clear();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('USSD prototype')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Prototype only — no shortcode is active. A real rollout requires MACRA and mobile-network/aggregator approval and integration.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _menu,
              style: const TextStyle(color: Colors.white, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          if (_menu.startsWith('CON'))
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reply with a number',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _send, child: const Text('Send')),
              ],
            )
          else
            ElevatedButton(
              onPressed: () => setState(() => _path = ''),
              child: const Text('Start another session'),
            ),
        ],
      ),
    );
  }
}
