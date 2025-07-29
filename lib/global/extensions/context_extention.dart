import 'package:flutter/material.dart';

extension ContextExtention on BuildContext {
  ThemeData get theme => Theme.of(this);
}
