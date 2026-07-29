import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

// --- WEB CONFIGURATION ---
class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class AirlinesPage extends StatefulWidget {
  const AirlinesPage({super.key});

  @override
  State<AirlinesPage> createState() => _AirlinesPageState();
}

class _AirlinesPageState extends State<AirlinesPage> {
  final ScrollController _scrollController = ScrollController();

  // Premium color palette
  final Color _bgDark = const Color(0xFF090A0F);
  final Color _cardDark = const Color(0xFF14151B);
  final Color _accentGold = const Color(0xFFDFB15B);

  // Data in lowercase
  final List<Map<String, dynamic>> data = [
    {
      "destination": "cairo",
      "direct": ["air france", "egyptair", "transavia", "vueling"],
      "escale": ["royal jordanian", "saudia", "emirates", "qatar airways", "lufthansa", "swiss", "aegean", "turkish airlines", "ita airways", "tarom", "lot polish", "british airways", "etihad", "gulf air", "royal air maroc", "oman air", "jazeera airways", "austrian airlines", "wizz air"]
    },
    {
      "destination": "sharm el-sheikh",
      "direct": ["easyjet", "air cairo"],
      "escale": ["pegasus", "turkish airlines", "wizz air", "swiss", "egyptair", "etihad"]
    },
    {
      "destination": "hurghada",
      "direct": ["transavia france", "easyjet"],
      "escale": ["turkish airlines", "pegasus", "egyptair", "wizz air", "swiss", "condor", "eurowings"]
    },
    {
      "destination": "alexandria",
      "direct": [],
      "escale": ["turkish airlines", "pegasus"]
    },
  ];

  Color _getAirlineColor(String name) {
    int hash = name.hashCode;
    return Color((hash & 0xFFFFFF) + 0xFF000000).withOpacity(0.12);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: ScrollConfiguration(
        behavior: WebScrollBehavior(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- NAVIGATION BAR (Disappears on scroll) ---
            SliverAppBar(
              pinned: false, // Disappears on scroll
              floating: true, // Reappears as soon as we scroll up
              backgroundColor: _bgDark.withOpacity(0.9),
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
              title: Text(
                "airlines", // text in lowercase
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDestinationCard(data[index]),
                  childCount: data.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentGold.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _accentGold.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.flight_takeoff_rounded, color: _accentGold, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  item["destination"], // destination in lowercase
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 20),

            _buildAirlineList("direct flights", item["direct"], true), // title in lowercase
            const SizedBox(height: 25),
            _buildAirlineList("with stopover", item["escale"], false), // title in lowercase
          ],
        ),
      ),
    );
  }

  Widget _buildAirlineList(String title, List<dynamic> airlines, bool isDirect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            title,
            style: GoogleFonts.montserrat(
                color: isDirect ? _accentGold : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.2
            )
        ),
        const SizedBox(height: 12),
        airlines.isEmpty
            ? Text(
            "no direct flights", // text in lowercase
            style: GoogleFonts.montserrat(
                color: Colors.white12,
                fontSize: 12,
                fontStyle: FontStyle.italic
            )
        )
            : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: airlines.map((name) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getAirlineColor(name),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Text(
                name, // airline names in lowercase
                style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500
                )
            ),
          )).toList(),
        ),
      ],
    );
  }
}