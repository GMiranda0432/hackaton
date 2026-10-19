
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bem_te_ver/main.dart';

void main() {
  testWidgets(
    'exibe o cadastro profissional',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const BemTeVerApp(),
      );

      expect(
        find.text('cadastro do profissional'),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('campo_nome')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('campo_email')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('campo_registro')),
        findsOneWidget,
      );
    },
  );
}
