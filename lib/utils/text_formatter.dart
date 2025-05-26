import 'package:flutter/material.dart';

class TextFormatter {
  static List<TextSpan> parseFormattedText(String text) {
    List<TextSpan> spans = [];
    int lastIndex = 0;

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
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      String matchedText = match.group(1)!;
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

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }
}
