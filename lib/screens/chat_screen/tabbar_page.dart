import 'package:flutter/material.dart';
import 'package:jeas/screens/chat_screen/chats_page.dart';
import 'package:jeas/screens/chat_screen/search_page.dart';

class TabbedPage extends StatelessWidget {
  final String personality;
  const TabbedPage({required this.personality, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Chats'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Search'),
              Tab(text: 'Chats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserSearchPage(personality: personality),
            ChatsPage(personality: personality),
          ],
        ),
      ),
    );
  }
}
