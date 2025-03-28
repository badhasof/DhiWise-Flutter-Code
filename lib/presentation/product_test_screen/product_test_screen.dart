import 'package:flutter/material.dart';
import '../../test_product_connection.dart';
import '../../core/app_export.dart';

class ProductTestScreen extends StatelessWidget {
  const ProductTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProductConnectionTest();
  }

  static Widget builder(BuildContext context) {
    return const ProductTestScreen();
  }
} 