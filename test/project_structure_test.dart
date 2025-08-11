import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Project Structure Tests', () {
    test('Core directories exist', () {
      expect(Directory('lib/core').existsSync(), true);
      expect(Directory('lib/core/constants').existsSync(), true);
      expect(Directory('lib/core/theme').existsSync(), true);
      expect(Directory('lib/core/utils').existsSync(), true);
    });

    test('Data directories exist', () {
      expect(Directory('lib/data').existsSync(), true);
      expect(Directory('lib/data/models').existsSync(), true);
      expect(Directory('lib/data/repositories').existsSync(), true);
      expect(Directory('lib/data/services').existsSync(), true);
    });

    test('Features directories exist', () {
      expect(Directory('lib/features').existsSync(), true);
      expect(Directory('lib/features/auth').existsSync(), true);
      expect(Directory('lib/features/delegates').existsSync(), true);
      expect(Directory('lib/features/shipments').existsSync(), true);
      expect(Directory('lib/features/parcels').existsSync(), true);
    });

    test('Shared directories exist', () {
      expect(Directory('lib/shared').existsSync(), true);
      expect(Directory('lib/shared/widgets').existsSync(), true);
      expect(Directory('lib/shared/providers').existsSync(), true);
    });

    test('UI directories exist', () {
      expect(Directory('lib/ui').existsSync(), true);
      expect(Directory('lib/ui/dashboard').existsSync(), true);
      expect(Directory('lib/ui/mobile').existsSync(), true);
      expect(Directory('lib/ui/visitor').existsSync(), true);
    });

    test('Documentation files exist', () {
      expect(File('lib/README.md').existsSync(), true);
      expect(File('lib/project_structure.md').existsSync(), true);
      expect(File('lib/implementation_plan.md').existsSync(), true);
      expect(File('lib/migration_guide.md').existsSync(), true);
    });
  });
}