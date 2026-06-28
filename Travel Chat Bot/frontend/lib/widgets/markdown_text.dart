import 'package:flutter/material.dart';

/// Markdown renderer đơn giản — không cần package
/// Hỗ trợ: **bold**, *italic*, \n newline, - bullet, số. list
class MarkdownText extends StatelessWidget {
  final String text;
  final Color color;

  const MarkdownText({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(line, color)).toList(),
    );
  }

  Widget _buildLine(String line, Color color) {
    // Dòng trống → khoảng cách
    if (line.trim().isEmpty) return const SizedBox(height: 6);

    // Bullet: dòng bắt đầu bằng "- " hoặc "* "
    final bulletMatch = RegExp(r'^[-*]\s+(.+)$').firstMatch(line.trim());
    if (bulletMatch != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 6),
              child: CircleAvatar(
                  radius: 3, backgroundColor: color.withValues(alpha: 0.6)),
            ),
            Expanded(child: _buildRichText(bulletMatch.group(1)!, color)),
          ],
        ),
      );
    }

    // Numbered list: "1. ", "2. ", v.v.
    final numMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line.trim());
    if (numMatch != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '${numMatch.group(1)}.',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    fontSize: 14),
              ),
            ),
            Expanded(child: _buildRichText(numMatch.group(2)!, color)),
          ],
        ),
      );
    }

    // Dòng thường
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: _buildRichText(line, color),
    );
  }

  /// Parse inline **bold** và *italic* thành TextSpan
  Widget _buildRichText(String line, Color color) {
    final spans = <TextSpan>[];
    // Regex: **bold** hoặc *italic*
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    int cursor = 0;

    for (final match in pattern.allMatches(line)) {
      // Text trước match
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: line.substring(cursor, match.start),
          style: TextStyle(color: color, height: 1.5, fontSize: 14),
        ));
      }

      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            height: 1.5,
            fontSize: 14,
          ),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(
            color: color,
            fontStyle: FontStyle.italic,
            height: 1.5,
            fontSize: 14,
          ),
        ));
      }
      cursor = match.end;
    }

    // Text còn lại sau match cuối
    if (cursor < line.length) {
      spans.add(TextSpan(
        text: line.substring(cursor),
        style: TextStyle(color: color, height: 1.5, fontSize: 14),
      ));
    }

    // Không có markdown gì — plain text
    if (spans.isEmpty) {
      return Text(line,
          style: TextStyle(color: color, height: 1.5, fontSize: 14));
    }

    return RichText(text: TextSpan(children: spans));
  }
}