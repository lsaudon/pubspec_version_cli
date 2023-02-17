import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

/// {@template change_command}
/// {@endtemplate}
class ChangeCommand extends Command<int> {
  /// {@macro change_command}
  ChangeCommand({
    required final FileSystem fileSystem,
  }) : _fileSystem = fileSystem {
    argParser.addOption(
      _versionName,
      help: 'The version you want to put in the pubspec.yaml file.',
      valueHelp: '1.0.0+1',
    );
  }

  final FileSystem _fileSystem;

  @override
  String get description => 'Change version in pubspec.';

  /// commandName
  static const String commandName = 'change';

  @override
  String get name => commandName;

  static const _versionName = 'version';
  static const _pubspecYamlFileName = 'pubspec.yaml';
  static const _pattern = 'version: ';

  @override
  Future<int> run() async {
    final newVersion = argResults?[_versionName] as String?;
    if (newVersion == null) {
      return ExitCode.data.code;
    }

    final pubspecPath = p.join(
      _fileSystem.currentDirectory.path,
      argResults!.rest.isNotEmpty ? argResults?.rest.first : '',
      _pubspecYamlFileName,
    );
    final pubspecAsLines = await _fileSystem.file(pubspecPath).readAsLines();
    final versionIndex =
        pubspecAsLines.indexWhere((final e) => e.startsWith(_pattern));
    pubspecAsLines[versionIndex] = '$_pattern$newVersion';
    final pubspecAsString = pubspecAsLines
        .reduce((final value, final element) => '$value\n$element');
    await _fileSystem.file(pubspecPath).writeAsString(pubspecAsString);
    return ExitCode.success.code;
  }
}
