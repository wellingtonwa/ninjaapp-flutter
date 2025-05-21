import 'package:flutter/material.dart';

class CommentView extends StatefulWidget {
  const CommentView({super.key});
  @override
  State<StatefulWidget> createState() => CommentViewState();
}

class CommentViewState extends State<CommentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentario '),
      ),
      body: const Text('Body'),
    );
  }
}
