import 'package:flutter/cupertino.dart';
import 'package:flutter_thermometer/thermometer.dart';
import 'package:flutter/material.dart';
import 'package:health_care_iot/utilities/utilities.dart';

class CustomScaleProvider implements ScaleProvider {
  @override
  List<ScaleTick> calcTicks(double minValue, double maxValue) {
    return [
      ScaleTick(minValue,
          label: 'LOW', length: 10, labelSpace: 5, thickness: 3),
      ScaleTick((maxValue - minValue) / 2 + minValue,
          label: 'MED', length: 5, labelSpace: 10, thickness: 3),
      ScaleTick(maxValue,
          label: 'HIGH',
          textStyle: TextStyle(color: redColor),
          length: 10,
          thickness: 3)
    ];
  }
}
