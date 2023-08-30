import 'dart:io';

typedef FileActionFunction = void Function(
    {required Directory source,
    required Directory destination,
    required Function onError,
    required void Function() onDone,
    Function? onData});

Future<int> filesLookup({required Directory source}) async {
  return await source
      .list(recursive: true)
      .where((event) => event is File)
      .length;
}

List<String> _filesUnderProcess = [];

void copy(
    {required Directory source,
    required Directory destination,
    required Function onError,
    required void Function() onDone,
    Function? onData}) {
  source
      .list(recursive: true)
      .where((event) => event is File)
      .map((event) => event as File)
      .listen((event) {
    File destinationFile =
        _getDestinationFile(file: event, destination: destination);
    _filesUnderProcess.add(destinationFile.path);
    event.copy(destinationFile.path).then((value) => _filesUnderProcess.remove(destinationFile.path));
    onData?.call(event);
  }, cancelOnError: false, onError: onError, onDone: () {
    onDone();
    _filesUnderProcess.clear();
  });
}

void move(
    {required Directory source,
    required Directory destination,
    required Function onError,
    required void Function() onDone,
    Function? onData}) {
  source
      .list(recursive: true)
      .where((event) => event is File)
      .map((event) => event as File)
      .listen((event) {
    File destinationFile =
        _getDestinationFile(file: event, destination: destination);
    _filesUnderProcess.add(destinationFile.path);
    event.rename(destinationFile.path).then((value) => _filesUnderProcess.remove(destinationFile.path));
    onData?.call(event);
  }, cancelOnError: false, onError: onError, onDone: () {
    onDone();
    _filesUnderProcess.clear();
  });
}

File _getDestinationFile({required File file, required Directory destination}) {
  String fileName = _getFileName(file);
  String fileExtention = _getFileExtention(file);
  File destinationFile = File('${destination.path}\\$fileName.$fileExtention');

  if (destinationFile.existsSync() || _filesUnderProcess.contains(destinationFile.path)) {
    int tryCount = 1;
    while (destinationFile.existsSync() || _filesUnderProcess.contains(destinationFile.path)) {
      destinationFile =
          File('${destination.path}\\${fileName}_$tryCount.$fileExtention');
      tryCount++;
    }
  }

  return destinationFile;
}

String _getFileName(File file) {
  String path = file.path;
  String fileName = path.split('\\').last;
  List<String> fileNameParts = fileName.split('.');
  fileNameParts.removeLast();
  return fileNameParts.join('.');
}

String _getFileExtention(File file) {
  String path = file.path;
  String fileName = path.split('\\').last;
  List<String> fileNameParts = fileName.split('.');
  return fileNameParts.removeLast();
}

bool isSubfolder({required Directory parent, required Directory child}) {
  return child.path.contains(parent.path);
}
