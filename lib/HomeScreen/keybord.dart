import 'package:flutter/material.dart';

mixin KeyboardBehavior<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: buildWithKeyboardBehavior(context),
    );
  }

  Widget buildWithKeyboardBehavior(BuildContext context);
}

// Usage example:
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with KeyboardBehavior {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget buildWithKeyboardBehavior(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Page')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Enter some text',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}