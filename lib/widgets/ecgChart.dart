import 'package:flutter/material.dart';
import 'package:health_care_iot/utilities/utilities.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class CartasianLine extends StatefulWidget {
  String ecg;
  List<String> arrECG=[];
  CartasianLine(this.ecg) {
    String newEcg = ecg.substring(6, ecg.length - 1);

    print(newEcg);
    arrECG = newEcg.split(",");
    print(arrECG[0]);
    print(arrECG[arrECG.length - 1]);
  }

  @override
  _CartasianLineState createState() => _CartasianLineState();
}

class _CartasianLineState extends State<CartasianLine> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCartesianChart(
          enableAxisAnimation: true,
          //backgroundColor: Colors.amber,
          plotAreaBorderWidth: 2,
          plotAreaBorderColor: Colors.white,
          title: ChartTitle(
              text: 'ECG Results',
              alignment: ChartAlignment.center,
              textStyle: TextStyle(color: Colors.white)),
          primaryXAxis: NumericAxis(
              labelStyle: TextStyle(color: Colors.white),
              minimum: 0,
              maximum: double.parse(widget.arrECG.length.toString()),
              interval: 10,
              rangePadding: ChartRangePadding.additional,
              axisLine: AxisLine(color: Colors.white),
              majorGridLines: MajorGridLines(width: 0),
              minorGridLines: MinorGridLines(width: 0),
              edgeLabelPlacement: EdgeLabelPlacement.hide),
          primaryYAxis: NumericAxis(
              labelStyle: TextStyle(color: Colors.white),
              // minimum: 0,
              // maximum: 100,
              // interval: 20,
              rangePadding: ChartRangePadding.additional,
              axisLine: AxisLine(color: Colors.white),
              majorGridLines: MajorGridLines(width: 0),
              minorGridLines: MinorGridLines(width: 0),
              edgeLabelPlacement: EdgeLabelPlacement.hide),
          annotations: <CartesianChartAnnotation>[
            CartesianChartAnnotation(
                x: 355,
                y: 22,
                coordinateUnit: CoordinateUnit.point,
                widget: Container(
                    // child: Text(
                    //   'High',
                    //   style: TextStyle(fontSize: 14),
                    // ),
                    ),
                region: AnnotationRegion.chart),
            CartesianChartAnnotation(
                x: 390,
                y: 0,
                coordinateUnit: CoordinateUnit.point,
                widget: Container(
                    // child: Text(
                    //   'low',
                    //   style: TextStyle(fontSize: 14),
                    // ),
                    ),
                region: AnnotationRegion.chart)
          ],
          series: <ChartSeries<EcgData, double>>[
            SplineSeries<EcgData, double>(
              color: redColor,
              dataSource: <EcgData>[
                for (int i = 0; i < widget.arrECG.length; i++)
                  EcgData(i.toDouble(), double.parse(widget.arrECG[i])),
              ],
              xValueMapper: (EcgData sales, _) => sales.value1,
              yValueMapper: (EcgData sales, _) => sales.value2,
            ),
            // SplineSeries<EcgData, double>(
            //   color: Colors.blue,
            //   dataSource: <EcgData>[
            //     EcgData(0, 1),
            //     EcgData(100, 1),
            //     EcgData(200, 1),
            //     EcgData(250, -1),
            //     EcgData(260, 2),
            //     EcgData(270, 4),
            //     EcgData(280, 2),
            //     EcgData(300, 3),
            //     EcgData(350, 13),
            //     EcgData(370, -4),
            //     EcgData(380, -2),
            //     EcgData(390, -3),
            //     EcgData(400, -4),
            //     EcgData(420, -1),
            //     EcgData(450, 1),
            //     EcgData(500, -3),
            //     EcgData(550, -3),
            //     EcgData(600, -3),
            //     EcgData(650, -3),
            //     EcgData(700, -1),
            //   ],
            //   xValueMapper: (EcgData sales, _) => sales.value1,
            //   yValueMapper: (EcgData sales, _) => sales.value2,
            // )
          ]),
    );
  }
}

class EcgData {
  EcgData(this.value1, this.value2);

  final double value1;
  final double value2;
}
