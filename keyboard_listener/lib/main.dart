import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CornerCollectorGame(),
    );
  }
}

class CornerItem {
  final String id;
  final Alignment alignment;
  final IconData icon;
  final Color color;
  bool isCollected;

  CornerItem({
    required this.id,
    required this.alignment,
    required this.icon,
    required this.color,
    this.isCollected = false,
  });
}

class CornerCollectorGame extends StatefulWidget {
  const CornerCollectorGame({super.key});

  @override
  State<CornerCollectorGame> createState() => _CornerCollectorGameState();
}

class _CornerCollectorGameState extends State<CornerCollectorGame> {
  final FocusNode _focusNode = FocusNode();

  // Character coordinate: -0.85 (top/left) to 0.85 (bottom/right)
  double _playerX = 0.0;
  double _playerY = 0.0;
  int _score = 0;
  String _message = 'Use Arrow Keys / WASD to move. Press Space to collect!';

  // The 4 corner targets
  late List<CornerItem> _corners;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _playerX = 0.0;
      _playerY = 0.0;
      _score = 0;
      _message = 'Collect all 4 corner gems!';
      _corners = [
        CornerItem(
          id: 'top-left',
          alignment: const Alignment(-0.85, -0.85),
          icon: Icons.diamond_outlined,
          color: Colors.amber,
        ),
        CornerItem(
          id: 'top-right',
          alignment: const Alignment(0.85, -0.85),
          icon: Icons.eco_outlined,
          color: Colors.greenAccent,
        ),
        CornerItem(
          id: 'bottom-left',
          alignment: const Alignment(-0.85, 0.85),
          icon: Icons.favorite_outline,
          color: Colors.redAccent,
        ),
        CornerItem(
          id: 'bottom-right',
          alignment: const Alignment(0.85, 0.85),
          icon: Icons.bolt,
          color: Colors.cyanAccent,
        ),
      ];
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _tryCollectItem() {
    bool collectedAny = false;

    for (var item in _corners) {
      if (!item.isCollected) {
        // Distance check between player and corner target
        double dx = _playerX - item.alignment.x;
        double dy = _playerY - item.alignment.y;
        double distance = sqrt(dx * dx + dy * dy);

        // Within collection radius (~0.3 in alignment space)
        if (distance < 0.3) {
          item.isCollected = true;
          collectedAny = true;
          _score++;
          break;
        }
      }
    }

    setState(() {
      if (collectedAny) {
        if (_score == _corners.length) {
          _message = '🎉 All collected! Great job! Press R to restart.';
        } else {
          _message = '✨ Item collected! ($_score / ${_corners.length})';
        }
      } else {
        _message = 'Get closer to a corner icon and press Space!';
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final key = event.logicalKey;
      const double step = 0.15;

      setState(() {
        // Move Left
        if (key == LogicalKeyboardKey.arrowLeft ||
            key == LogicalKeyboardKey.keyA) {
          _playerX = (_playerX - step).clamp(-0.85, 0.85);
        }
        // Move Right
        if (key == LogicalKeyboardKey.arrowRight ||
            key == LogicalKeyboardKey.keyD) {
          _playerX = (_playerX + step).clamp(-0.85, 0.85);
        }
        // Move Up
        if (key == LogicalKeyboardKey.arrowUp ||
            key == LogicalKeyboardKey.keyW) {
          _playerY = (_playerY - step).clamp(-0.85, 0.85);
        }
        // Move Down
        if (key == LogicalKeyboardKey.arrowDown ||
            key == LogicalKeyboardKey.keyS) {
          _playerY = (_playerY + step).clamp(-0.85, 0.85);
        }
      });

      // Spacebar collects
      if (key == LogicalKeyboardKey.space) {
        _tryCollectItem();
      }

      // R key restarts
      if (key == LogicalKeyboardKey.keyR) {
        _resetGame();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E222A),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header / Score
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gems Collected: $_score / 4',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _message,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Square Play Area
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0, // Strict square grid
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF282C34),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Render 4 Corner Targets
                          ..._corners.map((item) {
                            return Align(
                              alignment: item.alignment,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: item.isCollected ? 0.0 : 1.0,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: item.color,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.color,
                                    size: 26,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Player Object
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 90),
                            curve: Curves.easeOut,
                            alignment: Alignment(_playerX, _playerY),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.6),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Controls hint banner
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _KeyCap(label: 'W / ↑'),
                    const _KeyCap(label: 'A / ←'),
                    const _KeyCap(label: 'S / ↓'),
                    const _KeyCap(label: 'D / →'),
                    const SizedBox(width: 12),
                    const _KeyCap(label: 'SPACE: Collect', width: 120),
                    OutlinedButton.icon(
                      onPressed: () {
                        _resetGame();
                        _focusNode.requestFocus(); // Re-grab focus for keyboard events
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Minimal keyboard cap badge widget for visual hints
class _KeyCap extends StatelessWidget {
  final String label;
  final double width;

  const _KeyCap({required this.label, this.width = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF323640),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}