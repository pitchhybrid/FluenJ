// Teste de widget do FluenJ (shell da IDE em shadcn_ui).

import 'package:fluenj/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Mostra a tela de boas-vindas sem pasta aberta',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // A tela inicial (welcome) deve oferecer o botão "Abrir pasta".
    expect(find.text('Abrir pasta'), findsOneWidget);
    expect(find.text('FluenJ — IDE para Java'), findsOneWidget);
  });
}
