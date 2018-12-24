import 'package:flutter/material.dart';
import 'dart:math' as M;

enum MenuLocation {
  BottomRight, //The lower right corner
  BottomLeft //The lower left corner
}

// ignore: must_be_immutable
class FabMenu extends StatefulWidget {
  FloatingActionButton _centerBtn;

  List<FloatingActionButton> _fabList = [];
  AnimationController _animationController;
  VoidCallback menuCallback;
  _FabMenuState fs;
  MenuLocation _location;

  @override
  State<StatefulWidget> createState() {
    if (_centerBtn == null) {
      throw FormatException('Expected centerBtn can not be null');
    }
    fs = _FabMenuState(
        centerBtn: _centerBtn, fabItems: _fabList, location: _location);
    return fs;
  }

  FabMenu addCenterFab(IconData icon, {String tooltip, bool mini = false}) {
    _centerBtn = FloatingActionButton(
        onPressed: () => fs._menuCallback(),
        child: Icon(icon),
        tooltip: tooltip,
        mini: mini);
    return this;
  }

  FabMenu addActionFab(IconData icon,
      {String tooltip, VoidCallback onPressed, bool mini = false}) {
    if (_fabList.length > 3) {
      throw FormatException('Expected up to three floatingActionButton');
    }
    _fabList.add(FloatingActionButton(
        onPressed: onPressed, child: Icon(icon), tooltip: tooltip, mini: mini));
    return this;
  }

  FabMenu setLocation(MenuLocation location) {
    _location = location;
    return this;
  }
}

class _FabMenuState extends State<FabMenu> with TickerProviderStateMixin {
  static const String menuBtn = 'menuBtn';
  static const String actionBtn = 'actionBtn';
  AnimationController _animationController;
  List<LayoutId> _fabItems = [];
  VoidCallback _menuCallback;
  MenuLocation location;
  bool _isOpen = false;

  _FabMenuState(
      {@required FloatingActionButton centerBtn,
      @required List<FloatingActionButton> fabItems,
      this.location}) {
    _menuCallback = () => _changeMenu();
    for (int i = 0; i < fabItems.length; i++) {
      _fabItems.add(LayoutId(id: '$actionBtn$i', child: fabItems[i]));
    }
    _fabItems.add(LayoutId(id: "$menuBtn", child: centerBtn));
  }

  void _changeMenu() {
    if (!_isOpen)
      _animationController.forward();
    else
      _animationController.reverse();

    _isOpen = !_isOpen;
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        return CustomMultiChildLayout(
          delegate: _FabMenuDelegate(
              controller: _animationController.view,
              menuLocation:
                  location == null ? MenuLocation.BottomRight : location,
              count: _fabItems.length),
          children: _fabItems,
        );
      },
    );
  }
}

class _FabMenuDelegate extends MultiChildLayoutDelegate {
  static const double margin = 16.0;
  final Animation<double> _animation;
  final Animation<double> controller;
  MenuLocation menuLocation;
  final int count;

  _FabMenuDelegate({@required this.controller, this.menuLocation, this.count})
      : _animation = Tween<double>(begin: 0.0, end: 100).animate(
            CurvedAnimation(curve: Curves.elasticOut, parent: controller));

  Offset _calcMenuLocation(Size size, Size widget) {
    switch (this.menuLocation) {
      case MenuLocation.BottomLeft:
        double h = size.height - widget.height - margin;
        return Offset(margin, h);
      case MenuLocation.BottomRight:
      default:
        double w = size.width - widget.width - margin;
        double h = size.height - widget.height - margin;
        return Offset(w, h);
    }
  }

  Offset _calcItemLocation(int index, Size size, Size widget) {
    Offset location = _calcMenuLocation(size, widget);
    //        var itemAngle1 = (_animation.value) * M.cos(180 * (M.pi / 180));
//        var itemAngle11 = (_animation.value) * M.sin(180 * (M.pi / 180));
    switch (this.menuLocation) {
      case MenuLocation.BottomLeft:
        double radians = -index * 45 * (M.pi / 180);
        double cos = _animation.value * M.cos(radians);
        double sin = _animation.value * M.sin(radians);
        return Offset(location.dx + cos, location.dy + sin);
      case MenuLocation.BottomRight:
      default:
        double radians = ((index * 45) - 180) * (M.pi / 180);
        double cos = _animation.value * M.cos(radians);
        double sin = _animation.value * M.sin(radians);
        return Offset(location.dx + cos, location.dy + sin);
    }
  }

  Size centerSize;

  @override
  void performLayout(Size size) {
    if (hasChild(_FabMenuState.menuBtn)) {
      centerSize =
          layoutChild(_FabMenuState.menuBtn, BoxConstraints.loose(size));
      positionChild(_FabMenuState.menuBtn, _calcMenuLocation(size, centerSize));
    }
    for (int i = 0; i < count; i++) {
      String btn = '${_FabMenuState.actionBtn}$i';
      if (hasChild(btn)) {
        var itemSize = layoutChild(btn, BoxConstraints.loose(size));
        positionChild(btn, _calcItemLocation(i, size, itemSize));
      }
    }
  }

  @override
  bool shouldRelayout(_FabMenuDelegate oldDelegate) => true;
}
