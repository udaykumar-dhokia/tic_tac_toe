import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tic_tac_toe/main.dart';

class WinPage extends StatefulWidget {
  final String winner;

  WinPage(this.winner);

  @override
  State<WinPage> createState() => _WinPageState();
}

class _WinPageState extends State<WinPage> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _bannerAd = BannerAd(
      // adUnitId: "ca-app-pub-3940256099942544/6300978111",
      adUnitId:
          'ca-app-pub-3791381852971935/8090590467', // Replace with your AdMob banner ad unit ID
      size: AdSize.mediumRectangle,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("lib/assets/winner.jpg"), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 50,
          centerTitle: true,
          title: Text(
            '',
            style: GoogleFonts.inter(
              textStyle:
                  const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _isBannerAdLoaded
                  ? SizedBox(
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd),
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Player ${widget.winner} wins!',
                style: TextStyle(
                  fontSize: 20,
                  color: widget.winner == 'X' ? Colors.blue : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicTacToeApp(),
                    ),
                  ); // Pop the current page
                },
                child: Text(
                  'Play Again',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
