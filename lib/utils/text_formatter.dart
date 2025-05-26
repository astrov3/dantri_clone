import 'package:flutter/material.dart';

class TextFormatter {
  static List<TextSpan> parseFormattedText(String text) {
    print('Parsing formatted text: $text');
    List<TextSpan> spans = [];
    int lastIndex = 0;
    Set<String> processedSegments = {};

    // Pattern for bold text: **text**
    RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    // Pattern for italic text: *text*
    RegExp italicPattern = RegExp(r'\*(.*?)\*');

    // Combine all matches and sort by start position
    List<Match> allMatches = [
      ...boldPattern.allMatches(text),
      ...italicPattern.allMatches(text),
    ];
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    for (Match match in allMatches) {
      if (match.start > lastIndex) {
        String plainText = text.substring(lastIndex, match.start);
        if (!processedSegments.contains(plainText)) {
          spans.add(TextSpan(text: plainText));
          processedSegments.add(plainText);
        }
      }

      String matchedText = match.group(1)!;
      if (!processedSegments.contains(matchedText)) {
        if (match.pattern == boldPattern) {
          spans.add(
            TextSpan(
              text: matchedText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else if (match.pattern == italicPattern) {
          spans.add(
            TextSpan(
              text: matchedText,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        }
        processedSegments.add(matchedText);
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      String remainingText = text.substring(lastIndex);
      if (!processedSegments.contains(remainingText)) {
        spans.add(TextSpan(text: remainingText));
        processedSegments.add(remainingText);
      }
    }

    return spans;
  }
}
