import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_s3/simple_s3.dart';

const gridColor = Colors.blue;
const titleColor = Colors.blue;
const fashionColor = Color(0xffe15665);
const artColor = Color(0xff63e7e5);
const boxingColor = Color(0xff83dea7);
const entertainmentColor = Colors.white70;
const offRoadColor = Color(0xFFFFF59D);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColorDark: const Color(0xff201f39),
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedDataSetIndex = -1;
  double angleValue = 0;
  bool relativeAngleMode = true;

  SimpleS3 _simpleS3 = SimpleS3();
  File? selectedFile;

  //Global index values
  String areaindexname = "Área anatômica";

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = [
    Text(
      'Index 0: Global',
      style: optionStyle,
    ),
    Text(
      'Index 1: Index',
      style: optionStyle,
    ),
    Text(
      'Index 2: File',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        areaindexname = "Área anatômica";
      }

      if (index == 1) {
        areaindexname = "Index";
      }
    });

    if (index == 2) {
      PickedFile _pickedFile =
          (await ImagePicker().getImage(source: ImageSource.gallery))!;
      selectedFile = File(_pickedFile.path);
      String result = await _simpleS3.uploadFile(selectedFile!,
          Credentials.s3_bucketName, Credentials.s3_poolD, AWSRegions.apSouth1,
          debugLog: true,
          s3FolderPath: "test",
          accessControl: S3AccessControl.publicRead);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OpentDCS Desktop"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDataSetIndex = -1;
                  });
                },
                child: Text(
                  areaindexname.toUpperCase(),
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categorieData()
                    .asMap()
                    .map((index, value) {
                      final isSelected = index == selectedDataSetIndex;
                      return MapEntry(
                        index,
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDataSetIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            height: 26,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? gridColor.withOpacity(0.5)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(46),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInToLinear,
                                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                                  decoration: BoxDecoration(
                                    color: value.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInToLinear,
                                  style: TextStyle(
                                    color: isSelected ? value.color : gridColor,
                                  ),
                                  child: Text(value.title),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                    .values
                    .toList(),
              ),
              AspectRatio(
                aspectRatio: 1.3,
                child: RadarChart(
                  RadarChartData(
                    radarTouchData: RadarTouchData(
                        touchCallback: (FlTouchEvent event, response) {
                      if (!event.isInterestedForInteractions) {
                        setState(() {
                          selectedDataSetIndex = -1;
                        });
                        return;
                      }
                      setState(() {
                        selectedDataSetIndex =
                            response?.touchedSpot?.touchedDataSetIndex ?? -1;
                      });
                    }),
                    dataSets: showingDataSets(),
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData:
                        const BorderSide(color: Colors.transparent),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: const TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    getTitle: (index, angle) {
                      final usedAngle =
                          relativeAngleMode ? angle + angleValue : angleValue;
                      switch (index) {
                        case 0:
                          return RadarChartTitle(
                            text: _selectedIndex == 0 ? 'ALFA' : "FRONTAL",
                            angle: usedAngle,
                          );
                        case 2:
                          return RadarChartTitle(
                            text: _selectedIndex == 0 ? 'BETA' : "PARIENTAL",
                            angle: usedAngle,
                          );
                        case 3:
                          return RadarChartTitle(
                            text: _selectedIndex == 0 ? 'DELTA' : "OCCIPITAL",
                            angle: usedAngle,
                          );
                        case 1:
                          return RadarChartTitle(
                              text: _selectedIndex == 0 ? 'TETA' : "TEMPORAL",
                              angle: usedAngle);
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    tickCount: 1,
                    ticksTextStyle: const TextStyle(
                        color: Colors.transparent, fontSize: 10),
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    gridBorderData:
                        const BorderSide(color: gridColor, width: 2),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'Global relative power',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'EEG index',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Arquivo',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  List<RadarDataSet> showingDataSets() {
    return categorieData().asMap().entries.map((entry) {
      var index = entry.key;
      var rawDataSet = entry.value;

      final isSelected = index == selectedDataSetIndex
          ? true
          : selectedDataSetIndex == -1
              ? true
              : false;

      return RadarDataSet(
        fillColor: isSelected
            ? rawDataSet.color.withOpacity(0.2)
            : rawDataSet.color.withOpacity(0.05),
        borderColor:
            isSelected ? rawDataSet.color : rawDataSet.color.withOpacity(0.25),
        entryRadius: isSelected ? 3 : 2,
        dataEntries:
            rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: isSelected ? 2.3 : 2,
      );
    }).toList();
  }

  List<RawDataSet> categorieData() {
    if (_selectedIndex == 0) {
      return [
        RawDataSet(
          title: 'Frontal',
          color: fashionColor,
          values: [
            300,
            50,
            250,
            125,
          ],
        ),
        RawDataSet(
          title: 'Pariental',
          color: artColor,
          values: [
            250,
            100,
            200,
            45,
          ],
        ),
        RawDataSet(
          title: 'Occipital',
          color: entertainmentColor,
          values: [
            200,
            150,
            50,
            25,
          ],
        ),
        RawDataSet(
          title: 'Temporal',
          color: offRoadColor,
          values: [
            150,
            200,
            150,
            75,
          ],
        ),
        RawDataSet(
          title: 'Cerebelo',
          color: boxingColor,
          values: [
            100,
            250,
            100,
            50,
          ],
        ),
      ];
    } else {
      return [
        RawDataSet(
          title: 'Razão Delta/alfa',
          color: fashionColor,
          values: [
            300,
            50,
            250,
            125,
          ],
        ),
        RawDataSet(
          title: 'Power ratio index',
          color: artColor,
          values: [
            250,
            100,
            200,
            45,
          ],
        ),
        RawDataSet(
          title: 'Razão teta/beta',
          color: entertainmentColor,
          values: [
            200,
            150,
            50,
            25,
          ],
        ),
      ];
    }
  }

  List<RawDataSet> areasDataNew() {
    return [
      RawDataSet(
        title: 'Frontal',
        color: fashionColor,
        values: [
          300,
          50,
          250,
          125,
        ],
      ),
      RawDataSet(
        title: 'Pariental',
        color: artColor,
        values: [
          250,
          100,
          200,
          45,
        ],
      ),
      RawDataSet(
        title: 'Occipital',
        color: entertainmentColor,
        values: [
          200,
          150,
          50,
          25,
        ],
      ),
      RawDataSet(
        title: 'Temporal',
        color: offRoadColor,
        values: [
          150,
          200,
          150,
          75,
        ],
      ),
      RawDataSet(
        title: 'Cerebelo',
        color: boxingColor,
        values: [
          100,
          250,
          100,
          50,
        ],
      ),
    ];
  }
}

class RawDataSet {
  final String title;
  final Color color;
  final List<double> values;

  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });
}

class Credentials {
  static const String s3_poolD = "";
  static const String s3_bucketName = "";
}
