import 'package:flutter/material.dart';

import 'package:trufi_app/plan/plan_itinerary_tabs.dart';
import 'package:trufi_app/plan/plan_map.dart';
import 'package:trufi_app/trufi_models.dart';
import 'package:trufi_app/widgets/visible.dart';

class PlanPage extends StatefulWidget {
  final Plan plan;

  PlanPage(this.plan) : assert(plan != null);

  @override
  PlanPageState createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> with TickerProviderStateMixin {
  PlanItinerary _selectedItinerary;
  TabController _tabController;
  VisibilityFlag _visibleFlag = VisibilityFlag.visible;

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween(begin: 200.0, end: 60.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    if (widget.plan.itineraries.length > 0) {
      _selectedItinerary = widget.plan.itineraries.first;
    }
    _tabController = TabController(
      length: widget.plan.itineraries.length,
      vsync: this,
    )..addListener(() {
        _setItinerary(widget.plan.itineraries[_tabController.index]);
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildItinerariesVisible(BuildContext context) {
    return Container(
      height: _animation.value,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: PlanItineraryTabPages(
        _tabController,
        widget.plan.itineraries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: PlanMapPage(
                plan: widget.plan,
                onSelected: _setItinerary,
                selectedItinerary: _selectedItinerary,
              ),
            ),
            VisibleWidget(
              child: _buildItinerariesVisible(context),
              visibility: _visibleFlag,
              removedChild: _buildItinerariesGone(context),
            ),
          ],
        ),
        Positioned(
          bottom: _animation.value - 28.0,
          right: 16.0,
          child: _buildFloatingActionButton(context),
        ),
      ],
    );
  }

  Widget _buildItinerariesGone(BuildContext context) {
    return Container(
      height: _animation.value,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4.0)],
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: _toggleInstructions,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildItinerarySummary(
                    context,
                    _selectedItinerary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return FloatingActionButton(
      child: _visibleFlag == VisibilityFlag.visible
          ? Icon(Icons.keyboard_arrow_down, color: Colors.black)
          : Icon(Icons.keyboard_arrow_up, color: Colors.black),
      onPressed: _toggleInstructions,
      backgroundColor: theme.primaryColor,
    );
  }

  void _setItinerary(PlanItinerary value) {
    setState(() {
      _selectedItinerary = value;
      _tabController.animateTo(widget.plan.itineraries.indexOf(value));
    });
  }

  void _toggleInstructions() {
    setState(() {
      _visibleFlag = _visibleFlag == VisibilityFlag.visible
          ? VisibilityFlag.gone
          : VisibilityFlag.visible;
      if (_visibleFlag == VisibilityFlag.gone) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildItinerarySummary(BuildContext context, PlanItinerary itinerary) {
    ThemeData theme = Theme.of(context);
    List<Widget> summary = List();
    var legs = itinerary.legs;
    for (var i = 0; i < legs.length; i++) {
      var leg = legs[i];
      summary.add(
        Row(
          children: <Widget>[
            Icon(leg.iconData()),
            leg.mode == 'BUS'
                ? Text(
                    leg.route,
                    style: theme.textTheme.body2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    (leg.duration.ceil() ~/ 60).toString(),
                    style: theme.textTheme.body1,
                  ),
            i < (legs.length - 1)
                ? Icon(Icons.keyboard_arrow_right)
                : Container(),
          ],
        ),
      );
    }
    return Row(
      children: summary,
    );
  }
}
