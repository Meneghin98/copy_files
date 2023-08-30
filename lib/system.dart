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
    event.copySync(destinationFile.path);
    onData?.call(event);
  }, cancelOnError: false, onError: onError, onDone: onDone);
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
    event.rename(destinationFile.path);
    onData?.call(event);
  }, cancelOnError: false, onError: onError, onDone: onDone);
}

File _getDestinationFile({required File file, required Directory destination}) {
  String fileName = _getFileFileName(file);
  String fileExtention = _getFileFileExtention(file);
  File destinationFile = File('${destination.path}\\$fileName.$fileExtention');

  if (destinationFile.existsSync()) {
    int tryCount = 1;
    while (destinationFile.existsSync()) {
      destinationFile =
          File('${destination.path}\\${fileName}_$tryCount.$fileExtention');
      tryCount++;
    }
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


bool isSubfolder({required Directory parent, required Directory child})
{
  return child.path.contains(parent.path);
}