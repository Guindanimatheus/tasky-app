import 'package:flutter/material.dart';

/// Paleta do Tasky, inspirada na apresentação do projeto.
abstract final class TaskyColors {
  static const fundo = Color(0xFF07120E);
  static const superficieClara = Color(0xFFF6F2EA);
  static const superficieEscura = Color(0xFF12241C);
  static const superficieEscuraAlta = Color(0xFF1B3328);
  static const verde = Color(0xFF76C42B);
  static const roxo = Color(0xFF5C369B);
  static const vermelho = Color(0xFFE83834);
  static const laranja = Color(0xFFF39A16);

  /// "Dourado Conquista" no MIV (mesmo tom de [laranja]).
  static const dourado = laranja;
  static const amarelo = Color(0xFFFFCC00);
  static const verdeMusgo = Color(0xFF4F6E37);

  /// Roxo RPG clareado para ter contraste sobre o fundo Carvão.
  static const roxoClaro = Color(0xFF9B6BE0);
  static const textoSuave = Color(0xFFB9C4BD);
}

/// Fonte pixel usada só em títulos.
const kFontePixel = 'PressStart2P';

abstract final class TaskyTheme {
  static ThemeData get escuro {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: TaskyColors.verde,
      onPrimary: TaskyColors.fundo,
      secondary: TaskyColors.roxo,
      onSecondary: TaskyColors.superficieClara,
      tertiary: TaskyColors.amarelo,
      onTertiary: TaskyColors.fundo,
      error: TaskyColors.vermelho,
      onError: TaskyColors.superficieClara,
      surface: TaskyColors.fundo,
      onSurface: TaskyColors.superficieClara,
      onSurfaceVariant: TaskyColors.textoSuave,
      surfaceContainer: TaskyColors.superficieEscura,
      surfaceContainerHigh: TaskyColors.superficieEscuraAlta,
      outline: Color(0xFF3A5246),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final texto = base.textTheme;

    // Títulos em pixel com tamanhos contidos (a fonte é larga);
    // corpo e rótulos permanecem na fonte padrão para legibilidade.
    TextStyle? pixel(TextStyle? s, double tamanho) => s?.copyWith(
      fontFamily: kFontePixel,
      fontSize: tamanho,
      height: 1.5,
      letterSpacing: 0,
    );

    return base.copyWith(
      scaffoldBackgroundColor: TaskyColors.fundo,
      textTheme: texto.copyWith(
        displaySmall: pixel(texto.displaySmall, 24),
        headlineMedium: pixel(texto.headlineMedium, 18),
        headlineSmall: pixel(texto.headlineSmall, 16),
        titleLarge: pixel(texto.titleLarge, 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: TaskyColors.fundo,
        foregroundColor: TaskyColors.superficieClara,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: pixel(
          texto.titleLarge,
          16,
        )?.copyWith(color: TaskyColors.verde),
      ),
      cardTheme: CardThemeData(
        color: TaskyColors.superficieEscura,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF23392E)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TaskyColors.superficieEscura,
        indicatorColor: TaskyColors.verde,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? TaskyColors.fundo
                : TaskyColors.textoSuave,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: s.contains(WidgetState.selected)
                ? TaskyColors.superficieClara
                : TaskyColors.textoSuave,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
