import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

// --- CONFIGURACIÓN POR DEFECTO (Fallback si pywal falla) ---
class AppColors {
  static Color accent = const Color(0xFF4f94e8);
  static Color bg = const Color(0xFF081938);
  static Color text = const Color(0xFFd5e3ec);

  // Método para parsear colores de Pywal (#RRGGBB -> Color(0xFFRRGGBB))
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// --- SERVICIO DE PYWAL (El "Stream" de colores) ---
class WalService extends ValueNotifier<Map<String, Color>> {
  // Singleton para acceder fácil
  static final WalService instance = WalService._();

  WalService._() : super({}) {
    _init();
  }

  void _init() {
    final home = Platform.environment['HOME'];
    final file = File('$home/.cache/wal/flutter_colors.json');

    if (file.existsSync()) {
      _updateColors(file);
    }

    // Vigilar cambios en el archivo (Stream)
    // Usamos watch en el directorio porque algunos editores/scripts reemplazan el archivo
    // rompiendo el watcher si se hace directo al archivo.
    file.parent.watch(events: FileSystemEvent.modify).listen((event) {
      if (event.path.endsWith('flutter_colors.json')) {
        // Pequeño delay para asegurar que la escritura terminó
        Future.delayed(
          const Duration(milliseconds: 100),
          () => _updateColors(file),
        );
      }
    });
  }

  void _updateColors(File file) async {
    try {
      final content = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);

      final newColors = <String, Color>{};
      json.forEach((key, value) {
        newColors[key] = AppColors.fromHex(value as String);
      });

      value = newColors; // Esto notifica a los listeners (la UI)
    } catch (e) {
      debugPrint("Error leyendo colores de Pywal: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: "WaybarSpotifyWidget",
    size: Size(300, 480),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setBackgroundColor(Colors.transparent);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos ValueListenableBuilder para reconstruir TODA la app si cambian los colores
    return ValueListenableBuilder<Map<String, Color>>(
      valueListenable: WalService.instance,
      builder: (context, walColors, child) {
        // Asignamos colores dinámicos o fallback
        final accent =
            walColors['color4'] ??
            AppColors.accent; // color4 suele ser el acento en pywal
        final text = walColors['foreground'] ?? AppColors.text;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WaybarSpotifyWidget',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.transparent,
            sliderTheme: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: accent,
              inactiveTrackColor:
                  (walColors['color8'] ?? const Color(0xFF1e2030)).withAlpha(
                    150,
                  ),
              thumbColor: text,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
            ),
          ),
          home: const SpotifyWidget(),
        );
      },
    );
  }
}

class SpotifyWidget extends StatefulWidget {
  const SpotifyWidget({super.key});

  @override
  State<SpotifyWidget> createState() => _SpotifyWidgetState();
}

class _SpotifyWidgetState extends State<SpotifyWidget> {
  // Estado
  String _title = "Cargando...";
  String _artist = "...";
  String _artUrl = "";
  double _position = 0;
  double _duration = 100;
  double _volume = 0;
  bool _isPlaying = false;
  bool _isShuffle = false;
  String _loopStatus = "None";
  bool _isSeeking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSeeking) _updateInfo();
    });
    _updateInfo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LÓGICA DE PLAYERCTL ---
  Future<String> _runPlayerCtl(List<String> args) async {
    try {
      final result = await Process.run('playerctl', [
        '--player=spotify',
        ...args,
      ]);
      return result.stdout.toString().trim();
    } catch (e) {
      return "";
    }
  }

  Future<void> _sendCommand(List<String> args) async {
    await Process.run('playerctl', ['--player=spotify', ...args]);
    Future.delayed(const Duration(milliseconds: 150), _updateInfo);
  }

  void _updateInfo() async {
    final title = await _runPlayerCtl(['metadata', 'title']);
    final artist = await _runPlayerCtl(['metadata', 'artist']);
    final artUrl = await _runPlayerCtl(['metadata', 'mpris:artUrl']);
    final status = await _runPlayerCtl(['status']);

    final posStr = await _runPlayerCtl(['position']);
    final lenStr = await _runPlayerCtl(['metadata', 'mpris:length']);
    final volStr = await _runPlayerCtl(['volume']);

    final shufStr = await _runPlayerCtl(['shuffle']);
    final loopStr = await _runPlayerCtl(['loop']);

    if (mounted) {
      setState(() {
        _title = title.isNotEmpty ? title : "No music";
        _artist = artist;
        _artUrl = artUrl;
        _isPlaying = status == "Playing";
        _isShuffle = shufStr == "On";
        _loopStatus = loopStr;

        if (posStr.isNotEmpty) _position = double.tryParse(posStr) ?? 0;
        if (lenStr.isNotEmpty) {
          _duration = (double.tryParse(lenStr) ?? 0) / 1000000;
        }
        if (volStr.isNotEmpty) _volume = double.tryParse(volStr) ?? 0;
      });
    }
  }

  String _formatTime(double seconds) {
    final int mins = seconds ~/ 60;
    final int secs = (seconds % 60).toInt();
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final walColors = WalService.instance.value;

    // Asignación de colores desde Pywal
    // 'background' suele ser muy oscuro en pywal, perfecto para el tinte
    final bgColor = walColors['background'] ?? AppColors.bg;
    final accentColor =
        walColors['color4'] ??
        AppColors.accent; // Color 4 suele ser azul/acento
    final textColor = walColors['foreground'] ?? AppColors.text;
    final secondaryTextColor = (walColors['color7'] ?? Colors.grey).withAlpha(
      200,
    );

    return Scaffold(
      backgroundColor: bgColor.withAlpha(130),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => windowManager.close(),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      color: secondaryTextColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // IMAGEN
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black26,
                image: _artUrl.isNotEmpty
                    ? DecorationImage(
                        image: _getImageProvider(_artUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _artUrl.isEmpty
                  ? const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white24,
                      size: 80,
                    )
                  : null,
            ),

            const SizedBox(height: 15),

            // INFO
            Text(
              _title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _artist,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),

            const Spacer(),

            // SLIDER
            Slider(
              activeColor: ,
              value: _position.clamp(0, _duration),
              min: 0,
              max: _duration > 0 ? _duration : 1,
              onChanged: (val) {
                setState(() {
                  _isSeeking = true;
                  _position = val;
                });
              },
              onChangeEnd: (val) {
                _sendCommand(['position', val.toString()]);
                _isSeeking = false;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_position),
                  style: TextStyle(color: secondaryTextColor, fontSize: 11),
                ),
                Text(
                  _formatTime(_duration),
                  style: TextStyle(color: secondaryTextColor, fontSize: 11),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // CONTROLES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn(
                  icon: Icons.shuffle_rounded,
                  color: _isShuffle ? accentColor : textColor,
                  textColor: textColor.withAlpha(100),
                  size: 20,
                  onTap: () =>
                      _sendCommand(['shuffle', _isShuffle ? 'Off' : 'On']),
                ),
                _buildBtn(
                  icon: Icons.skip_previous_rounded,
                  color: textColor,
                  textColor: textColor.withAlpha(100),
                  size: 28,
                  onTap: () => _sendCommand(['previous']),
                ),

                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  color: textColor,
                  hoverColor: textColor.withAlpha(100),

                  iconSize: 30,
                  onPressed: () => _sendCommand(['play-pause']),
                ),

                _buildBtn(
                  icon: Icons.skip_next_rounded,
                  color: textColor,
                  textColor: textColor.withAlpha(100),
                  size: 28,
                  onTap: () => _sendCommand(['next']),
                ),
                _buildBtn(
                  icon: Icons.loop_rounded,
                  color: _loopStatus != "None" ? accentColor : textColor,
                  textColor: textColor.withAlpha(100),
                  size: 20,
                  onTap: () => _sendCommand([
                    'loop',
                    _loopStatus == "None" ? 'Playlist' : 'None',
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // VOLUMEN
            Row(
              children: [
                Icon(Icons.volume_up_rounded, color: textColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 20,
                    child: Slider(
                      value: _volume.clamp(0, 1),
                      onChanged: (val) {
                        setState(() => _volume = val);
                        _sendCommand(['volume', val.toString()]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      hoverColor: textColor,
      onPressed: onTap,
    );
  }

  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('file://')) {
      final path = Uri.decodeFull(url.replaceFirst('file://', ''));
      return FileImage(File(path));
    } else {
      return NetworkImage(url);
    }
  }
}
