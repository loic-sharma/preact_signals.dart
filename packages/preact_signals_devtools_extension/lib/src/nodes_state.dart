import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:preact_signals/preact_signals.dart';

typedef Node = ({
  int id,
  String type,
  String? label,
  String? value,
});

final nodes = signal<List<Node>>([]);
final selectedIndex = signal(-1);

Future<void> refreshNodes() async {
  try {
    final response = await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.preact_signals.getAllNodes',
    );
    final items = (response.json?['nodes'] as List?) ?? [];
    final results = <Node>[];
    for (final item in items) {
      results.add((
        id: item['id'] as int,
        type: item['type'] as String,
        label: item['label'] as String?,
        value: item['value'] as String?,
      ));
    }
    nodes.value = results;
    if (selectedIndex.peek() == -1) {
      selectedIndex.value = 0;
    }
  } catch (e) {
    print('Error fetching all signals: $e');
  }
}

void changeId({required bool increment}) {
  int index = selectedIndex.value;
  if (increment) {
    index++;
  } else {
    index--;
  }
  final length = nodes.value.length;
  if (index >= length) {
    index = length - 1;
  } else if (index < 0) {
    index = 0;
  }
  selectedIndex.value = index;
}
