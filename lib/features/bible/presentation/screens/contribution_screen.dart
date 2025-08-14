import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/verse.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ContributionsScreen extends StatelessWidget {
  final Verse verse;

  const ContributionsScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final contributionsRef = FirebaseFirestore.instance
        .collection('verse_contributions')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: contributionsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(    child: Text('Error loading contributions: ${snapshot.error}'
));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No contributions yet.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final content = data['content'] ?? '';
              final contributor = data['contributorName'] ?? 'Anonymous';
              final Timestamp timestamp = data['createdAt'];
              final date = timestamp.toDate();
              return ListTile(
                title: Text(content, style: AppTextStyles.bodyMedium),
                subtitle: Text('By $contributor - ${date.day}/${date.month}/${date.year}'),
              );
            },
          );
        },
      ),
    );
  }
}
