import 'dart:io';

import 'package:copy_files/app_status.dart';
import 'package:copy_files/constants.dart';
import 'package:copy_files/system.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle(appName);
  }
  runApp(const CopyApp());
}

class CopyApp extends StatelessWidget {
  const CopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: appName,
      theme: FluentThemeData(
        accentColor: Colors.orange,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white.withOpacity(.95),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Directory? source;
  Directory? target;
  FileActionFunction actionFunction = copy;

  Status status = Status.missingSource;
  Duration? timeTook;

  void _start() async {
    if (source == null) {
      setState(() {
        status = Status.missingSource;
      });
      return;
    }

    if (target == null) {
      setState(() {
        status = Status.missingTarget;
      });
      return;
    }

    setState(() {
      status = Status.loading;
      timeTook = null;
    });

    Stopwatch stopwatch = Stopwatch()..start();
    await actionFunction(source: source!, destination: target!);
    stopwatch.stop();

    setState(() {
      status = Status.finished;
      timeTook = stopwatch.elapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: Text(
          appName,
          style: TextStyle(color: FluentTheme.of(context).accentColor),
        ),
      ),
      content: Center(
        child: Column(
          children: [
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                2: IntrinsicColumnWidth(),
              },
              children: [
                tableRowWidget(
                  text: "Cartella di origine:",
                  buttonText: source?.path ?? "Seleziona la cartella",
                  onButtonPressed: () async {
                    final selection = await getDirectoryPath();
                    setState(() {
                      source = selection != null ? Directory(selection) : null;
                      status = Status.missingTarget;
                    });
                  },
                ),
                tableRowWidget(
                  text: "Cartella di destinazione:",
                  buttonText: target?.path ?? "Seleziona la cartella",
                  onButtonPressed: () async {
                    final selection = await getDirectoryPath();
                    setState(() {
                      target = selection != null ? Directory(selection) : null;
                      status = Status.ready;
                    });
                  },
                ),
              ],
            ),
            ListTile(
              title: const Text('Copia'),
              leading: RadioButton(
                checked: actionFunction == copy,
                onChanged: (value) {
                  setState(() {
                    actionFunction = copy;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Sposta'),
              leading: RadioButton(
                checked: actionFunction == move,
                onChanged: (value) {
                  setState(() {
                    actionFunction = move;
                  });
                },
              ),
            ),
            FilledButton(
              onPressed: _start,
              child: const Text('Start'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Stato:'),
                const SizedBox(width: 10),
                Text(status.description),
              ],
            ),
            ...(timeTook != null ? [Text('Tempo impiegato: $timeTook')] : [])
          ],
        ),
      ),
    );
  }
}

TableRow tableRowWidget(
    {required String text,
    required void Function()? onButtonPressed,
    required String buttonText}) {
  return TableRow(
    children: [
      Text(text),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Button(
          onPressed: onButtonPressed,
          child: Builder(
            builder: (var context) => Text(
              buttonText,
              style: TextStyle(color: FluentTheme.of(context).accentColor),
            ),
          ),
        ),
      )
    ],
  );
}
