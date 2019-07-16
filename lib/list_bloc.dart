import 'dart:async';

import 'load_data.dart';

/// @author ron 2019.07.07 登录业务组件
class ListBloc {
  final StreamController<LoadMoreStatus> _listController =
      new StreamController.broadcast();
  final StreamController<RefreshStatus> _pageController =
      new StreamController.broadcast();

  Stream<LoadMoreStatus> get loadMoreStream => _listController.stream;

  Stream<RefreshStatus> get refreshStream => _pageController.stream;

  final List<dynamic> dataGroup = List();

  final DataLoader _dataLoader;

  ListBloc(this._dataLoader);

  void loadMore() {
    _listController.add(LoadMoreStatus.LOADING_MORE);
    _fetchData(false);
  }

  /// 刷新
  Future<void> refresh() async {
    _pageController.add(RefreshStatus.REFRESHING);
    this.dataGroup.clear();
    _dataLoader.reset();
    _fetchData(true);
  }

  void _fetchData(bool isRefresh) {
    _dataLoader.loadData().then((dataGroup) {
      this.dataGroup.addAll(dataGroup);
      if (_listController.isClosed) return;
      if (isRefresh) {
        _pageController.add(dataGroup.isEmpty ? RefreshStatus.EMPTY_DATA : RefreshStatus.NORMAL);
      } else {
        _listController.add(dataGroup.isEmpty ? LoadMoreStatus.NO_MORE : LoadMoreStatus.NORMAL);
      }
    });
  }

  /// 重试
  void retry() {
    _pageController.add(RefreshStatus.REFRESHING);
    _fetchData(true);
  }

  void dispose() {
    _listController.close();
    _pageController.close();
  }
}

/// 列表状态
enum LoadMoreStatus {
  /// 正常状态
  NORMAL,

  /// 加载更多
  LOADING_MORE,

  /// 没有更多
  NO_MORE,
}

enum RefreshStatus {
  /// 正常状态
  NORMAL,

  /// 没有数据
  EMPTY_DATA,

  /// 刷新数据中
  REFRESHING
}
