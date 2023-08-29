import 'dart:io';

/*
TODO: scrivere funzione per scoprire tutti i file presenti nella cartella source
TODO: riscrivere le funzioni copy e move usando gli streams
TODO: le nuove funzioni copy e move devono avere callback per gli eventi 'onData', 'onError' e 'onDone'
*/


typedef ApplyFunction = void Function(File current, File destination);
typedef FileActionFunction = Future<void> Function({required Directory source, required Directory destination});

Future<void> copy({required Directory source, required Directory destination}) async {
  return _loopFiles(
    source: source,
    destination: destination,
    apply: (current, destination) {
      current.copySync(destination.path);
    }
  );
}

Future<void> move({required Directory source, required Directory destination}) async {
  return _loopFiles(
    source: source,
    destination: destination,
    apply: (current, destination) {
      current.renameSync(destination.path);
    }
  );
}


Future<void> _loopFiles({required Directory source, required Directory destination, required ApplyFunction apply }) async {
  await for (final entity in source.list(recursive: false)) {

    if(entity is Directory) {
      await Future.wait([_loopFiles(source: entity, destination: destination, apply: apply)]);
    }

    if(entity is File) {
      String fileName = _getFileFileName(entity);
      String fileExtention = _getFileFileExtention(entity);
      File destinationFile = File('${destination.path}\\$fileName.$fileExtention');

      if(await destinationFile.exists()) {
        destinationFile = await _rename(destination: destination, fileName: fileName, fileExtention: fileExtention);
      }

      apply(entity, destinationFile);
    }

  }
}

Future<File> _rename({required Directory destination, required String fileName, required String fileExtention}) async {
  int tryCount = 1;
  File destinationFile = File('${destination.path}\\${fileName}_$tryCount.$fileExtention');

  while (await destinationFile.exists()) {
    tryCount++;
    destinationFile = File('${destination.path}\\${fileName}_$tryCount.$fileExtention');
  }

  return destinationFile;
}

String _getFileFileName(File file) {
  String path = file.path;
  String fileName = path.split('\\').last;
  List<String> fileNameParts = fileName.split('.');
  fileNameParts.removeLast();
  return fileNameParts.join('.');
}

String _getFileFileExtention(File file) {
  String path = file.path;
  String fileName = path.split('\\').last;
  List<String> fileNameParts = fileName.split('.');
  return fileNameParts.removeLast();
}