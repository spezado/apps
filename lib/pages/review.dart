// SPDX-License-Identifier: MIT
// What needs review, each issue in a sentence.

import 'package:flutter/material.dart';

import '../widgets/common.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return PageFrame(
      title: t.review,
      children: [
        Loaded<List<String>>(
          load: (api, books, state) => api.review(books: books, lang: state.lang),
          builder: (context, issues) => issues.isEmpty
              ? Text(t.nothingToReview)
              : Card(
                  child: Column(
                    children: [
                      for (final issue in issues)
                        ListTile(leading: const Icon(Icons.error_outline, size: 20), title: Text(issue)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
