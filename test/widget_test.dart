import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bem_te_ver/main.dart';

void main() {
  testWidgets('Exibe o cadastro profissional', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BemTeVerApp());
    await tester.pumpAndSettle();

    expect(find.text('Cadastro do profissional'), findsOneWidget);

    expect(find.byKey(const Key('campo_nome')), findsOneWidget);

    expect(find.byKey(const Key('campo_email')), findsOneWidget);

    expect(find.byKey(const Key('campo_registro')), findsOneWidget);
  });
}
