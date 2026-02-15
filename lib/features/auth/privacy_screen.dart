import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  final ScrollController scrollController;

  const PrivacyScreen({super.key, required this.scrollController});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
    with TickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                /// Expandable Text
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Text(
                    _privacyText,
                    maxLines: isExpanded ? null : 8,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.fade,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),

                const SizedBox(height: 8),

                /// Arrow Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });

                    if (!isExpanded) {
                      // Scroll to top when collapsing
                      widget.scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded ? "Show less" : "Show more",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String _privacyText = """
TuniWays Privacy Policy

Last Updated: 2026

At TuniWays, your privacy matters.

1. Information We Collect
We collect basic account information such as email and preferences to personalize your travel experience.

2. How We Use Your Data
Your data is used to:
• Provide personalized trip recommendations
• Improve AI-powered itinerary suggestions
• Enhance app performance

3. Data Protection
We implement secure authentication and encrypted storage to protect your information.

4. Third-Party Services
We may use external APIs (maps, hotel data, transport services) to provide functionality.

5. Your Rights
You may request deletion of your data at any time.

Contact: support@tuniways.com

Thank you for trusting TuniWays.
""";
