import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class PrivacyScreen extends StatefulWidget {
  final ScrollController scrollController;

  const PrivacyScreen({super.key, required this.scrollController});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // --- 1. Header (Static) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 30),
              ],
            ),
          ),

          // --- 2. Scrollable Body ---
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text(
                  "Last Updated: February 2026",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // --- EXPANDABLE SECTION ---
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOut,
                  child: ConstrainedBox(
                    constraints: isExpanded
                        ? const BoxConstraints() // No height limit when expanded
                        : const BoxConstraints(maxHeight: 200), // Fixed height when collapsed

                    // FIX: Wrap Column in SingleChildScrollView to prevent overflow error
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildPolicySections(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // --- SHOW MORE / SHOW LESS TEXT ---
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                    if (!isExpanded) {
                      // Optional: Scroll to top when collapsing
                      widget.scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? "Show less" : "Show more",
                          style: TextStyle(
                            color: HexColor("#14746f"),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: HexColor("#14746f"),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom padding
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Content Builder ---
  List<Widget> _buildPolicySections() {
    return [
      _sectionTitle("1. Information We Collect"),
      _sectionBody("We collect basic account information such as email and preferences to personalize your travel experience."),

      _sectionTitle("2. How We Use Your Data"),
      _sectionBody("Your data is used to:\n• Provide personalized trip recommendations\n• Improve AI-powered itinerary suggestions\n• Enhance app performance"),

      _sectionTitle("3. Data Protection"),
      _sectionBody("We implement secure authentication and encrypted storage to protect your information."),

      _sectionTitle("4. Third-Party Services"),
      _sectionBody("We may use external APIs (maps, hotel data, transport services) to provide functionality."),

      _sectionTitle("5. Your Rights"),
      _sectionBody("You may request deletion of your data at any time."),

      const SizedBox(height: 10),
      const Text(
        "Contact: support@tuniways.com",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    ];
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _sectionBody(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.grey[700],
      ),
    );
  }
}