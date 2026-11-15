# Regras extras para o R8 (otimizador da versão release).
#
# O shared_preferences_android 2.5.x é chamado a partir do Dart pelo JNI,
# que procura classes e métodos pelo NOME e pela assinatura exata. O R8 não
# enxerga essas chamadas: ele renomeia tipos usados nas assinaturas (por
# exemplo kotlin.coroutines.Continuation virava "s4"), e o método
# SharedPreferencesApiRegistrar.getAll deixava de ser encontrado. O main()
# falhava ao abrir o armazenamento e o APK nunca passava da tela de abertura.
#
# Sem renomear nada, toda busca por nome via JNI continua valendo.
-dontobfuscate

# E o plugin inteiro fica, mesmo o que o R8 julgaria sem uso.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
