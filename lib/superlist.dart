library superlist;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'list_bloc.dart';

import 'empty_view.dart';
import 'load_data.dart';

/// @author ron 2019.06.22 通用列表组件
class SuperList extends StatefulWidget {
  final DataLoader dataLoader;
  final RowBuilder builder;

  /// 想要保持状态
  final bool wantKeepAlive;

  SuperList({Key key,
    @required this.dataLoader,
    @required this.builder,
    this.wantKeepAlive = true})
      : super(key: key);

  @override
  _ListState createState() => _ListState(ListBloc(dataLoader));
}

typedef void LoadData();

/// 行构建器
typedef Widget RowBuilder(BuildContext context, dynamic data);

/// 状态定义
class _ListState extends State<SuperList> with AutomaticKeepAliveClientMixin {
  final ScrollController _controller = new ScrollController();

  final ListBloc _listBloc;

  _ListState(this._listBloc);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixel = _controller.position.pixels;
      if (maxScroll == pixel) {
        _listBloc.loadMore();
      }
    });
    _listBloc.refresh();
  }

  @override
  void dispose() {
    super.dispose();
    _listBloc.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: _listBloc.refreshStream,
      initialData: RefreshStatus.REFRESHING,
      builder: (_, AsyncSnapshot<RefreshStatus> snapshot) {
        switch (snapshot.data) {
          case RefreshStatus.EMPTY_DATA:
            return _emptyWidget();
          case RefreshStatus.REFRESHING:
            return _refreshWidget();
          case RefreshStatus.NORMAL:
            return _listWidget(_listBloc.dataGroup);
        }
        throw AssertionError();
      },
    );
  }

  /// 空内容的展示部件
  Widget _emptyWidget() {
    return EmptyView(tip: "内容为空，点击重新加载", retry: _listBloc.retry);
  }

  /// 刷新中展示部件
  Widget _refreshWidget() {
    return Center(
      child: SpinKitPouringHourglass(color: Colors.blue),
    );
  }

  /// 列表展示部件
  Widget _listWidget(List<dynamic> dataGroup) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      //下拉刷新
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: dataGroup.length + 1,
        itemBuilder: (BuildContext context, int index) =>
        index == dataGroup.length
            ? _buildFooter()
            : widget.builder(context, dataGroup[index]),
        controller: _controller, //指明控制器加载更多使用
      ),
      onRefresh: _listBloc.refresh,
    );
  }

  Widget _buildLoadMore() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitCircle(
            color: Colors.blue,
            size: 25,
          ),
          Text("获取数据中...")
        ]);
  }

  /// 加载更多进度条
  Widget _buildFooter() {
    return new Padding(
      padding: const EdgeInsets.all(15.0),
      child: new Center(
        child: StreamBuilder(
          stream: _listBloc.loadMoreStream,
          initialData: LoadMoreStatus.NORMAL,
          builder: (_, AsyncSnapshot<LoadMoreStatus> snapshot) {
            switch (snapshot.data) {
              case LoadMoreStatus.LOADING_MORE:
                return _buildLoadMore();
              case LoadMoreStatus.NO_MORE:
                return new Text("没有数据啦");
              case LoadMoreStatus.NORMAL:
                return SizedBox.shrink();
            }
            throw AssertionError();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}
