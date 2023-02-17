import 'dart:io' show Platform;

import 'package:file/memory.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_version_cli/src/command_runner.dart';
import 'package:pubspec_version_cli/src/commands/commands.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group('change', () {
    group('version', () {
      const pubspecFileContent = '''
name: example
version: 1.0.0+1
environment:
  sdk: ">=2.19.2 <3.0.0"''';

      test('no version', () async {
        final mfs = MemoryFileSystem.test(
          style: Platform.isWindows
              ? FileSystemStyle.windows
              : FileSystemStyle.posix,
        );

        const pubspecPath = 'pubspec.yaml';
        mfs.file(pubspecPath)
          ..createSync()
          ..writeAsStringSync(pubspecFileContent);

        final exitCode = await PubspecVersionCliCommandRunner(
          fileSystem: mfs,
        ).run([ChangeCommand.commandName]);

        final actual = mfs.file(pubspecPath).readAsStringSync();

        expect(actual, pubspecFileContent);

        expect(exitCode, ExitCode.data.code);
      });

      test('without path', () async {
        final mfs = MemoryFileSystem.test(
          style: Platform.isWindows
              ? FileSystemStyle.windows
              : FileSystemStyle.posix,
        );

        const pubspecPath = 'pubspec.yaml';
        mfs.file(pubspecPath)
          ..createSync()
          ..writeAsStringSync(pubspecFileContent);

        final logger = _MockLogger();
        const newVersion = '2.1.1+2';
        final exitCode = await PubspecVersionCliCommandRunner(
          logger: logger,
          fileSystem: mfs,
        ).run([
          ChangeCommand.commandName,
          '--version',
          newVersion,
        ]);

        final actual = mfs.file(pubspecPath).readAsStringSync();

        expect(actual, '''
name: example
version: $newVersion
environment:
  sdk: ">=2.19.2 <3.0.0"''');

        expect(exitCode, ExitCode.success.code);
      });

      test('with path before', () async {
        final mfs = MemoryFileSystem.test(
          style: Platform.isWindows
              ? FileSystemStyle.windows
              : FileSystemStyle.posix,
        );

        const directory = 'example';
        final pubspecPath = p.join(directory, 'pubspec.yaml');
        mfs.file(pubspecPath)
          ..createSync(recursive: true)
          ..writeAsStringSync(pubspecFileContent);

        final logger = _MockLogger();
        const newVersion = '2.1.1+2';
        final exitCode = await PubspecVersionCliCommandRunner(
          logger: logger,
          fileSystem: mfs,
        ).run([
          ChangeCommand.commandName,
          directory,
          '--version',
          newVersion,
        ]);

        final actual = mfs.file(pubspecPath).readAsStringSync();

        expect(actual, '''
name: example
version: $newVersion
environment:
  sdk: ">=2.19.2 <3.0.0"''');

        expect(exitCode, ExitCode.success.code);
      });

      test('with path after', () async {
        final mfs = MemoryFileSystem.test(
          style: Platform.isWindows
              ? FileSystemStyle.windows
              : FileSystemStyle.posix,
        );

        const directory = 'example';
        final pubspecPath = p.join(directory, 'pubspec.yaml');
        mfs.file(pubspecPath)
          ..createSync(recursive: true)
          ..writeAsStringSync(pubspecFileContent);

        final logger = _MockLogger();
        const newVersion = '2.1.1+2';
        final exitCode = await PubspecVersionCliCommandRunner(
          logger: logger,
          fileSystem: mfs,
        ).run([
          ChangeCommand.commandName,
          '--version',
          newVersion,
          directory,
        ]);

        final actual = mfs.file(pubspecPath).readAsStringSync();

        expect(actual, '''
name: example
version: $newVersion
environment:
  sdk: ">=2.19.2 <3.0.0"''');

        expect(exitCode, ExitCode.success.code);
      });
    });
  });
}
