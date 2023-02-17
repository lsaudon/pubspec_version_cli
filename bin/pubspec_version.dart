import 'dart:io';

import 'package:pubspec_version_cli/src/command_runner.dart';

Future<void> main(final List<String> args) async {
  await _flushThenExit(await PubspecVersionCliCommandRunner().run(args));
}

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<void> _flushThenExit(final int status) =>
    Future.wait<void>([stdout.close(), stderr.close()])
        .then<void>((final _) => exit(status));
