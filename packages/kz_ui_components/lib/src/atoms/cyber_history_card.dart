import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';

class CyberHistoryCard extends StatelessWidget {
  const CyberHistoryCard({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    required this.mainContent,
    this.stats = const {},
    this.accentColor = CyberTheme.defaultAccent,
  });

  final String title;
  final String statusLabel;
  final Color statusColor;
  final Widget mainContent;
  final Map<String, String> stats;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF03050A),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Border/Bar
              Container(width: 3.5, color: statusColor),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 9,
                              fontFamily: 'Courier',
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                                width: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              statusLabel.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Main Custom Content
                      mainContent,

                      // Stats Row (if not empty)
                      if (stats.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white10, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: stats.entries.map((entry) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.01),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      entry.key.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        fontSize: 7,
                                        fontFamily: 'Courier',
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: accentColor.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 10,
                                        fontFamily: 'Courier',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
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
