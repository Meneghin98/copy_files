import 'dart:async';
import 'dart:io';

import 'package:copy_files/system.dart';
import 'package:copy_files/widgets/big_card.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Copy');
  }
  runApp(const CopyApp());
}

class CopyApp extends StatelessWidget {
  const CopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      body: Center(
        child: Column(
          children: [
            const BigCard('Copy'),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  2: IntrinsicColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      const Text('Cartella di origine:'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () async {
                            final selection = await getDirectoryPath();
                            setState(() {
                              source = selection != null
                                  ? Directory(selection)
                                  : null;
                              status = Status.missingTarget;
                            });
                          },
                          child: Text(source?.path ?? "Seleziona la cartella"),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Cartella di destinazione:'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () async {
                            final selection = await getDirectoryPath();
                            setState(() {
                              target = selection != null
                                  ? Directory(selection)
                                  : null;
                              status = Status.ready;
                            });
                          },
                          child: Text(target?.path ?? "Seleziona la cartella"),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text('Copia'),
              leading: Radio<FileActionFunction>(
                value: copy,
                groupValue: actionFunction,
                onChanged: (value) {
                  setState(() {
                    actionFunction = value ?? copy;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Sposta'),
              leading: Radio<FileActionFunction>(
                value: move,
                groupValue: actionFunction,
                onChanged: (value) {
                  setState(() {
                    actionFunction = value ?? move;
                  });
                },
              ),
            ),
            FilledButton(
              onPressed: () async {
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
                });

                unawaited(actionFunction(source: source!, destination: target!).then((_) {
                  setState(() {
                    status = Status.finished;
                  });
                }));
              },
              child: const Text('Start'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Stato:'),
                const SizedBox(width: 10),
                Text(status.description),
              ],
            )
          ],
        ),
      ),
    );
  }
}

enum Status {
  missingSource(description: "Selezionare una cartella di origine"),
  missingTarget(description: "Selezionare una certella di destinazione"),
  ready(description: "Pronto ad eseguire"),
  loading(description: "Caricamento"),
  finished(description: "Terminato");

  const Status({required this.description});
  final String description;
}
