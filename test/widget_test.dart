// Teste de widget do app myide (shell da IDE em Hux UI).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluenj/app.dart';

void main() {
  testWidgets('Mostra a tela de boas-vindas sem pasta aberta',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // A tela inicial (welcome) deve oferecer o botão "Abrir pasta".
    expect(find.text('Abrir pasta'), findsOneWidget);
    expect(find.text('myide — IDE para Java'), findsOneWidget);
  });
}
