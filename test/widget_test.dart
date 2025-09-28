// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('Test stat item layout', (WidgetTester tester) async {
    // Build a test widget that mimics the fixed stat item structure
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 4.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildStatItem('Total Runs', '150', Icons.sports_cricket),
                _buildStatItem('Total Wickets', '5', Icons.sports_baseball),
                _buildStatItem('Total 4s', '12', Icons.crop_free),
                _buildStatItem('Total 6s', '3', Icons.crop_3_2),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that the widgets are rendered without overflow
    expect(find.text('Total Runs'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.text('Total Wickets'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    // Check that no render overflow occurs
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test team score display layout', (WidgetTester tester) async {
    // Build a test widget that mimics the fixed team score display
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTeamScoreDisplay('Team A', '150/5', 'RR: 7.5', true),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('VS'),
                ),
                _buildTeamScoreDisplay('Team B', '120/3', 'RR: 6.0', false),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that the widgets are rendered without overflow
    expect(find.text('Team A'), findsOneWidget);
    expect(find.text('150/5'), findsOneWidget);
    expect(find.text('Team B'), findsOneWidget);
    expect(find.text('120/3'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);

    // Check that no render overflow occurs
    expect(tester.takeException(), isNull);
  });
}

Widget _buildStatItem(String label, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.deepOrange,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Colors.grey.shade800,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTeamScoreDisplay(
  String teamName,
  String score,
  String runRate,
  bool isLeft,
) {
  return Expanded(
    flex: 1,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teamName,
            style: GoogleFonts.nunito(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: isLeft ? TextAlign.start : TextAlign.end,
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: GoogleFonts.nunito(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: isLeft ? TextAlign.start : TextAlign.end,
          ),
          if (runRate.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              runRate,
              style: GoogleFonts.nunito(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: isLeft ? TextAlign.start : TextAlign.end,
            ),
          ],
        ],
      ),
    ),
  );
}
