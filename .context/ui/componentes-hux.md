# Componentes Hux — referência rápida

Assinaturas confirmadas na versão **hux 1.2.1** (inspecionadas no pub-cache). Import: `package:hux/hux.dart`.

## HuxButton
```dart
HuxButton({
  required VoidCallback? onPressed,
  required Widget child,
  HuxButtonVariant variant = HuxButtonVariant.primary, // primary|secondary|outline|ghost
  HuxButtonSize size = HuxButtonSize.medium,           // small|medium|large
  double? width,
  bool isLoading = false,
  bool isDisabled = false,
  IconData? icon,
  Color? primaryColor,
  Color? textColor,
  // ... focusNode, autofocus
})
```
Exemplo:
```dart
HuxButton(
  onPressed: _increment,
  variant: HuxButtonVariant.primary,
  child: const Text('Incrementar'),
)
```

## HuxCard
```dart
HuxCard({
  required Widget child,
  String? title,
  String? subtitle,
  Widget? action,          // canto superior direito do header
  HuxCardSize? size,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  double elevation = 0,
  double? borderRadius,
  Color? backgroundColor,
  Color? borderColor,
  double? borderWidth,
  VoidCallback? onTap,
  // ... wrapSpacing, wrapRunSpacing
})
```

## HuxBadge
```dart
HuxBadge({
  required String label,
  HuxBadgeVariant variant = HuxBadgeVariant.primary, // primary|secondary|success|outline|error|destructive
  HuxBadgeSize size = HuxBadgeSize.medium,           // small|medium
  Color? customColor,
})
```

## HuxInput (antigo HuxTextField)
```dart
HuxInput({
  FocusNode? focusNode,
  TextEditingController? controller,
  String? label,            // texto acima do campo
  String? hint,             // placeholder quando vazio
  String? helperText,
  String? errorText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool obscureText = false,
  bool enabled = true,
  int maxLines = 1,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  String? Function(String?)? validator,
  double? iconSize,
  double? width,
})
```

## HuxTextarea
Multilinha com contagem de caracteres (`showCharacterCount`, `minLines`, `maxLines`, `maxLength`).

## HuxCheckbox / HuxSwitch / HuxSlider / HuxToggle / HuxRadio
Controles de formulário. (Ver docs para props específicos.)

## HuxDialog / pickers
```dart
showHuxDialog(context: ..., title: ..., content: ..., actions: [...]);
final DateTime? d = await showHuxDatePickerDialog(context: ..., initialDate: ..., firstDate: ..., lastDate: ...);
final TimeOfDay? t = await showHuxTimePickerDialog(context: ..., initialTime: ...);
```

## Snackbar (extensão em BuildContext)
```dart
context.showHuxSnackbar({
  required String message,
  HuxSnackbarVariant variant = HuxSnackbarVariant.info, // info|success|warning|error
  String? title,
  VoidCallback? onDismiss,
  bool showIcon = true,
  Duration duration = const Duration(seconds: 4),
  // ... action, backgroundColor, etc.
})
```

## Outros componentes disponíveis
`HuxAvatar`, `HuxAvatarGroup`, `HuxTabs`, `HuxTabBar`, `HuxTabView`, `HuxTooltip`, `HuxLoading`, `HuxLoadingOverlay`, `HuxChart` (.line/.bar), `HuxContextMenu`, `HuxDropdown`, `HuxProgress`, `HuxBreadcrumbs`, `HuxPagination`, `HuxSidebar`, `HuxBottomSheet`, `HuxActionSheet`, `HuxCommand`, `HuxKBD`, `HuxOtpInput`, `HuxDateInput`.

## Tema
```dart
HuxTheme.lightTheme   // ThemeData (light)
HuxTheme.darkTheme    // ThemeData (dark)
HuxColors             // paleta (ex.: HuxColors.primary)
HuxTokens             // design tokens adaptáveis ao tema (ex.: HuxTokens.primary(context))
```

## Veja também
- [[hux-ui]] · [[arquitetura]] · docs https://docs.thehuxdesign.com/
