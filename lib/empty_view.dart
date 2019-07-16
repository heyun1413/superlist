import 'package:flutter/material.dart';

/// @author ron 2019.06.22 空内容视图
class EmptyView extends StatelessWidget {
  EmptyView({Key key, @required this.tip, this.retry}) : super(key: key);

  final String tip;

  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GestureDetector(
      child: Text(tip),
      onTap: retry,
    ));
  }
}
