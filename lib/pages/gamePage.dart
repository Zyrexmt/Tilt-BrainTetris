import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modulo_a1_v1/appController.dart';
import 'package:modulo_a1_v1/services/rankingEntry.dart';
import 'package:modulo_a1_v1/services/tetrisLogic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _countdown = 3;
  bool _saved = false;
  bool _gameStarted = false;
  double _dragAccumX = 0;

  String _playerName = globalName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) _playerName = args;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdown();
    });
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown == 1) {
        timer.cancel();
        setState(() {
          _gameStarted = true;
          _countdown = 0;
        });

        Provider.of<TetrisGameProvider>(
          context,
          listen: false,
        ).startGamme();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _onDragUpdate(
    DragUpdateDetails details,
    TetrisGameProvider game,
  ) {
    if (!_gameStarted) return;

    _dragAccumX += details.delta.dx;
    const threshold = 20.0;

    if (_dragAccumX > threshold) {
      game.moveRight();
      _dragAccumX = 0;
    } else if (_dragAccumX < -threshold) {
      game.moveLeft();
      _dragAccumX = 0;
    }

    if (details.delta.dy > 3) {
      game.setFastDrop(true);
    }
  }

  void _onDragEnd(TetrisGameProvider game) {
    _dragAccumX = 0;
    game.setFastDrop(false);
  }

  Future<void> saveAndExit(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existing = prefs.getString('ranking');
    List<RankingEntry> list = [];

    if (existing != null) {
      final jsonList = jsonDecode(existing) as List<dynamic>;
      list = jsonList.map((e) => RankingEntry.fromJson(e)).toList();
    }

    list.add(
      RankingEntry(playerName: _playerName.trim(), score: score),
    );

    await prefs.setString(
      'ranking',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void onEncerrar() {
    final game = Provider.of<TetrisGameProvider>(
      context,
      listen: false,
    );
    game.stopGame();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Consumer<TetrisGameProvider>(
            builder: (context, game, _) {
              if (_gameStarted && game.isGameOver && !_saved) {
                _saved = true;
                Future.microtask(() {
                  saveAndExit(game.score);
                });
              }

              return GestureDetector(
                onPanUpdate: (details) =>
                    _onDragUpdate(details, game),
                onPanEnd: (_) => _onDragEnd(game),
                onTap: () => game.rotate(),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _countdown > 0
                        ? Text(
                            '$_countdown',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            'JÁ!',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xff333333),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${game.score.toString().padLeft(3, '0')} pts',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(width: 15),
                        Column(
                          children: [
                            Icon(Icons.arrow_circle_left, size: 30),
                            Text('Arraste'),
                            Text('Esquerda'),
                          ],
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 240,
                              height: 480,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff333333),
                                  width: 2,
                                ),
                              ),
                              child: GridView.builder(
                                itemCount:
                                    TetrisGameProvider.totalCells,
                                physics:
                                    NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          TetrisGameProvider.colCount,
                                    ),
                                itemBuilder: (context, index) {
                                  Color? cellColor = game.grid[index];

                                  if (game.currentPiece != null &&
                                      game.currentPiece!.position
                                          .contains(index)) {
                                    cellColor =
                                        game.currentPiece!.color;
                                  }
                                  return Container(
                                    margin: EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      color:
                                          cellColor ??
                                          Colors.transparent,
                                      border: Border.all(
                                        color: Color(0xffededed),
                                        width: 0.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Icon(Icons.arrow_circle_right, size: 30),
                            Text('Arraste'),
                            Text('Direita'),
                          ],
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                    SizedBox(height: 10),
                    Icon(Icons.arrow_circle_down, size: 30),
                    Text('Arraste para baixo: acelera'),
                    Text('Toque rápido: gira a peça'),
                    TextButton(
                      onPressed: () {
                        onEncerrar();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xff333333),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(
                            8,
                          ),
                          side: BorderSide(
                            color: Color(0xff333333),
                            width: 2,
                          ),
                        ),
                        elevation: 4,
                        fixedSize: Size(
                          MediaQuery.sizeOf(context).width,
                          60,
                        ),
                      ),
                      child: Text(
                        'ENCERRAR',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
