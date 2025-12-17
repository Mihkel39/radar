import 'package:flutter/material.dart';

void main() {
  runApp(const KontrolltooRadarApp());
}

class KontrolltooRadarApp extends StatelessWidget {
  const KontrolltooRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kontrolltöö Radar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// -------------------- MODEL --------------------
class Task {
  final String id;
  final String subject;
  final String type;
  final String description;
  final String date;
  bool completed;

  Task({
    required this.id,
    required this.subject,
    required this.type,
    required this.description,
    required this.date,
    this.completed = false,
  });
}

// -------------------- HOME --------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> todayTasks = [
    Task(
      id: '1',
      subject: 'Matemaatika',
      type: 'Kontrolltöö',
      description: 'Võrrandid, paragr. 5–7',
      date: '10. detsember 2025',
    ),
    Task(
      id: '2',
      subject: 'Inglise keel',
      type: 'Sõnavara test',
      description: 'Unit 3: Travel & Tourism',
      date: '10. detsember 2025',
    ),
  ];

  final List<Task> weekTasks = [
    Task(
      id: '3',
      subject: 'Keemia',
      type: 'Kontrolltöö',
      description: 'Reaktsioonivõrrandid',
      date: 'Kolmapäev, 11. detsember',
    ),
    Task(
      id: '4',
      subject: 'Ajalugu',
      type: 'Esitluse tähtaeg',
      description: 'Esitlus II maailmasõjast',
      date: 'Reede, 13. detsember',
    ),
    Task(
      id: '5',
      subject: 'Füüsika',
      type: 'Kodutöö',
      description: 'Ülesanded 12–18',
      date: 'Neljapäev, 12. detsember',
      completed: true,
    ),
  ];

  void toggleTask(Task task) {
    setState(() {
      task.completed = !task.completed;
    });
  }

  void addTask(Task task, bool isToday) {
    setState(() {
      if (isToday) {
        todayTasks.add(task);
      } else {
        weekTasks.add(task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrolltöö Radar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<TaskResult>(
                context: context,
                builder: (_) => const AddTaskDialog(),
              );

              if (result != null) {
                addTask(result.task, result.isToday);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: 'Täna', subtitle: '10. detsember 2025'),
          ...todayTasks.map((task) => TaskCard(task: task, onToggle: toggleTask)),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Sel nädalal'),
          ...weekTasks.map((task) => TaskCard(task: task, onToggle: toggleTask)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💡 Kui töö on tehtud, märgi see tehtuks'),
          ),
        ],
      ),
    );
  }
}

// -------------------- UI COMPONENTS --------------------
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (subtitle != null)
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(Task) onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => onToggle(task),
        ),
        title: Text(task.subject),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.type),
            Text(task.description),
            Text(task.date, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// -------------------- ADD TASK DIALOG --------------------
class TaskResult {
  final Task task;
  final bool isToday;

  TaskResult(this.task, this.isToday);
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final subjectCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool isToday = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lisa töö'),
      content: SingleChildScrollView(
        child: Column(children: [
          TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Aine')),
          TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Tüüp')),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Kirjeldus')),
          SwitchListTile(
            title: const Text('Täna'),
            value: isToday,
            onChanged: (v) => setState(() => isToday = v),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Loobu')),
        ElevatedButton(
          onPressed: () {
            final task = Task(
              id: DateTime.now().toString(),
              subject: subjectCtrl.text,
              type: typeCtrl.text,
              description: descCtrl.text,
              date: isToday ? 'Täna' : 'Sel nädalal',
            );
            Navigator.pop(context, TaskResult(task, isToday));
          },
          child: const Text('Salvesta'),
        ),
      ],
    );
  }
}
