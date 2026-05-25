import 'package:flutter/material.dart';

PageRoute<T> appRoute<T>({required WidgetBuilder builder}) {
  return MaterialPageRoute<T>(builder: builder);
}
