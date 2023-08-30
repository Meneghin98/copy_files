import 'dart:io';

import 'package:copy_files/app_context.dart';
import 'package:copy_files/constants.dart';
import 'package:copy_files/system.dart';
import 'package:copy_files/widgets/console.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle(appName);
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppContext(),
      child: const CopyApp(),
    ),
  );
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
        scaffoldBackgroundColor: Colors.white.withOpacity(.93),
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
  Directory? _source;
  Directory? _target;
  FileActionFunction _actionFunction = copy;

  bool _isProcessing = false;
  int _fileCount = 0;
  int _fileProcessed = 0;

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppContext>();

    Future<void> start() async {
      state.clearMessages();
      setState(() {
        _fileCount = 0;
        _fileProcessed = 0;
      });
      if (_source == null) {
        state.addMessage('Cartella di origine mancante');
        return;
      }
      if (_target == null) {
        state.addMessage('Cartella di destinazione mancante');
        return;
      }
      if(isSubfolder(parent: _source!, child: _target!)){ 
        state.addMessage("La cartella di destinazione é una sotto cartella della cartella di origine. Per favore scegliere un'altra cartella");
        return;
      }

      setState(() {
        _isProcessing = true;
      });
      state.addMessage('Ricerca di tutti i files...');
      int fileCount = await filesLookup(source: _source!);
      state.addMessage('Trovati $fileCount files');
      setState(() {
        _fileCount = fileCount;
      });

      state.addMessage('Inizio a processare i file');
      Stopwatch stopwatch = Stopwatch()..start();
      _actionFunction(
        source: _source!,
        destination: _target!,
        onError: (error) {
          state.addMessage(error);
        },
        onData: (File file) {
          state.addMessage('Elaborato ${file.path}');
          setState(() {
            _fileProcessed++;
          });
        },
        onDone: () {
          stopwatch.stop();
          state.addMessage(
              'Elaborazione terminata. Tempo impiegato: ${stopwatch.elapsed}');
          setState(() {
            _isProcessing = false;
          });
        },
      );
    }

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
                  buttonText: _source?.path ?? "Seleziona la cartella",
                  onButtonPressed: () async {
                    final selection = await getDirectoryPath();
                    setState(() {
                      _source = selection != null ? Directory(selection) : null;
                    });
                  },
                ),
                tableRowWidget(
                  text: "Cartella di destinazione:",
                  buttonText: _target?.path ?? "Seleziona la cartella",
                  onButtonPressed: () async {
                    final selection = await getDirectoryPath();
                    setState(() {
                      _target = selection != null ? Directory(selection) : null;
                    });
                  },
                ),
              ],
            ),
            ListTile(
              title: const Text('Copia'),
              leading: RadioButton(
                checked: _actionFunction == copy,
                onChanged: (value) {
                  setState(() {
                    _actionFunction = copy;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Sposta'),
              leading: RadioButton(
                checked: _actionFunction == move,
                onChanged: (value) {
                  setState(() {
                    _actionFunction = move;
                  });
                },
              ),
            ),
            FilledButton(
              onPressed: start,
              child: const Text('Start'),
            ),
            const SizedBox(height: 10),
            const Console(),
            SizedBox(
              height: 10,
              width: double.infinity,
              child: _isProcessing
                  ? ProgressBar(
                      value: _fileCount > 0
                          ? _fileProcessed / _fileCount * 100
                          : null,
                    )
                  : null,
            ),
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
