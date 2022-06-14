import 'package:flutter/material.dart';
import 'package:flutter_thermometer/label.dart';
import 'package:flutter_thermometer/scale.dart';
import 'package:flutter_thermometer/setpoint.dart';
import 'package:flutter_thermometer/thermometer_widget.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../utilities/custom_scale_provider.dart';
import '../utilities/utilities.dart';

class Cards {
  static Widget cardBpm(
      {required BuildContext context,
      required double width,
      required String val,
      required Function() onTap}) {
    return buildgestureDetector(context, val, onTap, width, "BPM", false, true);
  }

  static Widget cardSpo(
      {required BuildContext context,
      required double width,
      required String val,
      required Function() onTap}) {
    return buildgestureDetector(
        context, val, onTap, width, "SpO2", false, false);
  }

  static Widget cardTempC(
      {required BuildContext context,
      required double width,
      required String val,
      required Function() onTap}) {
    return buildgestureDetector(
        context, val, onTap, width, "Temp C", true, true);
  }

  static Widget cardTempF(
      {required BuildContext context,
      required double width,
      required String val,
      required Function() onTap}) {
    return buildgestureDetector(
        context, val, onTap, width, "Temp F", true, false);
  }

  static Widget settingsCard({
    required BuildContext context,
    required String title,
    required IconData iconData,
    required Function() function,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
              blurRadius: 2,
              offset: Offset(0, 5),
              color: Theme.of(context).shadowColor)
        ],
      ),
      margin: EdgeInsets.only(
        bottom: 10,
        left: 20,
        right: 20,
      ),
      //   padding: EdgeInsets.all(20),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        onTap: function,
        leading: Icon(
          iconData,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.navigate_next,
          color: Colors.white,
        ),
      ),
    );
  }

  static GestureDetector buildgestureDetector(BuildContext context, String val,
      Function() onTap, double width, String name, bool isTemp, bool isFrst) {
    return GestureDetector(
      child: Container(
        width: ((width - 30) / 2),
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2,
                  offset: Offset(0, 5),
                  color: Theme.of(context).shadowColor)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    val,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                height: 100,
                width: 100,
                child: isTemp
                    ? buildThermometer(double.parse(val), isFrst ? 15 : 55,
                        isFrst ? 55 : 120, isFrst ? 0 : 1)
                    : buildRadialGuage(double.parse(val), isFrst),
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  static Container buildRadialGuage(double val, bool isBpm) => Container(
        child: SfRadialGauge(
          animationDuration: 3000,
          enableLoadingAnimation: true,
          axes: [
            RadialAxis(
                showTicks: false,
                showLabels: false,
                minimum: 0,
                maximum: 200,
                interval: 100,
                ranges: [
                  GaugeRange(
                    startValue: 0,
                    endValue: 200,
                    color: Colors.white,
                  ),
                ],
                pointers: [
                  RangePointer(
                    value: val,
                    color: isBpm ? redColor : blueColor,
                    cornerStyle: CornerStyle.endCurve,
                    enableAnimation: true,
                  ),
                ],
                annotations: [
                  GaugeAnnotation(
                      positionFactor: 0.1,
                      widget: Text(
                        val.round().toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ))
                ]),
          ],
        ),
      );

  static buildThermometer(
      double value, double minValue, double maxValue, double labelType) {
    bool useCustomScale = false;
    bool mirrorScale = false;
    bool setpointEnabled = false;
    double scaleInterval = 10;
    bool isLess = false;
    bool isNormal = false;
    if (labelType == 0) {
      if (value < 36.5) {
        isLess = true;
      } else {
        if (value < 37.6) {
          isNormal = true;
        }
      }
    } else {
      if (value < 97.5) {
        isLess = true;
      } else {
        if (value < 95.5) {
          isNormal = true;
        }
      }
    }

    Setpoint setpoint =
        Setpoint(60, size: 9, color: blueColor, side: SetpointSide.both);

    return Thermometer(
        value: value,
        minValue: minValue,
        maxValue: maxValue,
        radius: 15.0,
        barWidth: 15.0,
        outlineThickness: 2.0,
        outlineColor: Colors.white,
        mercuryColor: isLess
            ? blueColor
            : isNormal
                ? greenColor
                : redColor,
        backgroundColor: Colors.transparent,
        scale: useCustomScale
            ? CustomScaleProvider()
            : IntervalScaleProvider(scaleInterval),
        mirrorScale: mirrorScale,
        label: labelType == 0
            ? ThermometerLabel.celsius()
            : labelType == 1
                ? ThermometerLabel.farenheit()
                : ThermometerLabel('Custom',
                    textStyle: TextStyle(
                        color: blueColor,
                        fontSize: 10,
                        fontStyle: FontStyle.italic)),
        setpoint: setpointEnabled ? setpoint : null);
  }
}
