import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tic_tac_toe/WinPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  bool isCellAnimationActive = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _bannerAd = BannerAd(
      // adUnitId: "ca-app-pub-3940256099942544/6300978111",
      adUnitId: 'ca-app-pub-3791381852971935/6764765032',
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );

    // Load the banner ad
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  List<List<String>> board = List.generate(3, (i) => List.filled(3, ""));

  bool player1Turn = true;
  String currentPlayer = 'X';
  bool isWinnerDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: player1Turn
          ? Colors.lightBlueAccent.shade100
          : Colors.pinkAccent.shade100,
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        backgroundColor: player1Turn
            ? Colors.lightBlueAccent.shade100
            : Colors.pinkAccent.shade100,
        title: Text(
          'Tic Tac Toe',
          style: GoogleFonts.inter(
            textStyle:
                const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Player: $currentPlayer',
              style: GoogleFonts.inter(
                textStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            buildGameBoard(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetGame,
              child: Text(
                'Reset Game',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdLoaded
          ? SizedBox(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : const SizedBox(), // Display an empty container if the banner ad is not loaded yet
    );
  }

  Widget buildGameBoard() {
    return Column(
      children: List.generate(3, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (col) {
            return GestureDetector(
              onTap: () {
                if (board[row][col] == "") {
                  setState(() {
                    board[row][col] = currentPlayer;
                    checkWinner(row, col);
                    player1Turn = !player1Turn;
                    currentPlayer = player1Turn ? 'X' : 'O';
                  });
                }
              },
              child: Material(
                elevation: 30.0,
                borderRadius: BorderRadius.circular(10),
                color: board[row][col] == 'X'
                    ? Colors.blue.withOpacity(0.7)
                    : board[row][col] == 'O'
                        ? Colors.red.withOpacity(0.7)
                        : Colors.white,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      board[row][col],
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: board[row][col] == 'X'
                                ? Colors.blue.withOpacity(0.8)
                                : Colors.red.withOpacity(0.8),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // Widget buildGameBoard() {
  //   return Column(
  //     children: List.generate(3, (row) {
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: List.generate(3, (col) {
  //           return GestureDetector(
  //             onTap: () {
  //               if (board[row][col] == "") {
  //                 setState(() {
  //                   board[row][col] = currentPlayer;
  //                   checkWinner(row, col);
  //                   player1Turn = !player1Turn;
  //                   currentPlayer = player1Turn ? 'X' : 'O';
  //                 });
  //               }
  //             },
  //             child: Container(
  //               width: 100,
  //               height: 100,
  //               decoration: BoxDecoration(
  //                 border: Border.all(),
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   board[row][col],
  //                   style: const TextStyle(fontSize: 30),
  //                 ),
  //               ),
  //             ),
  //           );
  //         }),
  //       );
  //     }),
  //   );
  // }

  void checkWinner(int row, int col) {
    // Check row
    if (board[row][0] == currentPlayer &&
        board[row][1] == currentPlayer &&
        board[row][2] == currentPlayer) {
      showWinnerDialog(currentPlayer);
      resetGame();
      log(isWinnerDialogVisible.toString());
    }

    // Check column
    if (board[0][col] == currentPlayer &&
        board[1][col] == currentPlayer &&
        board[2][col] == currentPlayer) {
      showWinnerDialog(currentPlayer);
      resetGame();
      log(isWinnerDialogVisible.toString());
    }

    // Check diagonals
    if ((board[0][0] == currentPlayer &&
            board[1][1] == currentPlayer &&
            board[2][2] == currentPlayer) ||
        (board[0][2] == currentPlayer &&
            board[1][1] == currentPlayer &&
            board[2][0] == currentPlayer)) {
      showWinnerDialog(currentPlayer);
      resetGame();
      log(isWinnerDialogVisible.toString());
    }

    // Check for a tie
    if (!board.any((row) => row.any((cell) => cell == "")) &&
        !isWinnerDialogVisible) {
      showTieDialog();
    }
  }

  void showWinnerDialog(String player) {
    setState(() {
      isWinnerDialogVisible = true;
    });
    resetGame();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WinPage(player)),
    );
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: const Text('Game Over'),
    //       content: Text('Player $player wins!'),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             resetGame();
    //           },
    //           child: const Text('Play Again'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  // void showWinnerDialog(String player) {
  //   resetGame();
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(16),
  //             color: Colors.white,
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const Text(
  //                 'Congratulations!',
  //                 style: TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.green,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               Text(
  //                 'Player $player wins!',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   color: player == 'X' ? Colors.blue : Colors.red,
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                   resetGame();
  //                 },
  //                 style: ElevatedButton.styleFrom(),
  //                 child: Text(
  //                   'Play Again',
  //                   style: GoogleFonts.inter(
  //                     textStyle: const TextStyle(
  //                         color: Colors.black, fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void showTieDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: const Text('It\'s a tie!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TicTacToeApp()),
    );
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (i) => List.filled(3, ""));
      player1Turn = true;
      currentPlayer = 'X';
    });
  }
}
