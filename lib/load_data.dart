
import 'package:flutter/material.dart';

/// 数据加载器
class DataLoader {
  final LoadData loadData;
  final Reset reset;

  const DataLoader({@required this.loadData, @required this.reset});
}

/// 异步加载数据
typedef Future<List<dynamic>> LoadData();

/// 重置状态
typedef void Reset();