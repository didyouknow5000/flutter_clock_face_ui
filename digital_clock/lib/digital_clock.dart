// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

// Contains all the Clock Face UI Widgets.
import 'package:digital_clock/widgets.dart';

/// ## Desccription
///
/// Parent class which encapsulates the Clock Face UI.
/// The UI consists of two animations made with Flare and UI to display time.
///
/// ### Animations
///
/// - `Disc Animation`: This is an ongoing animation which rotates after initialization.
/// A smooth animation adding calming effect to user experience.
///
/// ### Structure
///
/// All the UI widgets are layed out in a stack widget on top of each other.
/// - Stack
///   - Mars animation
///   - Falling Stars Animation
///   - Clock UI cards in Column of Rows and Column ;)
///
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    /// Initialize the animatinon controller and animation BEFORE the `_updateTime()` method
    /// as it depends on `_controller` to check the animations.
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.05),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.05),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.05, end: 1.0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(curve: Curves.easeInOut, parent: _controller),
    );

    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(
      () {
        // Call the animation controller logic function
        _animationLogic();

        _dateTime = DateTime.now();

        _timer = Timer(
          Duration(minutes: 1) -
              Duration(seconds: _dateTime.second) -
              Duration(milliseconds: _dateTime.millisecond),
          _updateTime,
        );
      },
    );
  }

  /// Reset and start animation controller if it is completed
  /// else start the animation (`Minute Card Animation`).
  void _animationLogic() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reset();
      _controller.forward();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d').format(_dateTime);
    final day = DateFormat('EEEE').format(_dateTime);
    final month = DateFormat('MMM').format(_dateTime);
    final year = DateFormat('y').format(_dateTime);
    final hour = DateFormat('hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.black,
          child: DiscAnim(),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: BlurBox(
                          text: "$date $month $year",
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Flexible(
                        child: BlurBox(
                          text: "$day",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: HourCard(
                          hour: hour,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: MinuteCard(
                          animation: _animation,
                          minute: minute,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
