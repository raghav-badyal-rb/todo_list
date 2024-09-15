import 'package:flutter/material.dart';

class TaskSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  TaskSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Suggestions can be added if needed
  }

  @override
  Widget buildResults(BuildContext context) {
    // Delay the call to onSearch to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSearch(query);
    });
    return Container(); // Optionally display results here if needed
  }
}
