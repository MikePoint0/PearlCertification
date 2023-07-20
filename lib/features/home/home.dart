import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pearl_certification/core/models/homeBuyer.dart';
import 'package:pearl_certification/core/models/neighborHood.dart';
import 'package:pearl_certification/core/utils/appColors.dart';
import 'package:pearl_certification/core/utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _pickedFile;
  var perLines;
  bool isWorking = false; //loader monitor variable

  //select file
  void _openFileFolder() async {
    setState(() {
      _pickedFile = null;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'], // Only allow .txt files
    );

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
      processFile();
    }
  }

  //extract input info
  void processFile() {
    setState(() {
      isWorking = true;
    });

    perLines = File(_pickedFile!.path).readAsLinesSync();

    var neighborHoods = AppHelpers().getNeighborHoods(perLines);
    var homeBuyers = AppHelpers().getHomeBuyers(perLines);

    for (var buyer in homeBuyers.values) {
      buyer!.fitScore = AppHelpers().getFitScore(
          buyer.goals, neighborHoods[buyer.preferences[0]]!.scores);
    }

    tryToAssignHomeBuyers(neighborHoods, homeBuyers);
  }

  //try to manipulate the input as stated in the AC
  void tryToAssignHomeBuyers(var neighborHoods, var homeBuyers) {
    var assignedHomeBuyers = assignHomeBuyers(neighborHoods, homeBuyers);
    beginWriteOutput(assignedHomeBuyers);
  }

  Map<String, List<HomeBuyer>> assignHomeBuyers(
      Map<String?, NeighborHood?> neighborhoods,
      Map<String, HomeBuyer> homeBuyers) {
    var assignedHomeBuyers = HashMap<String, List<HomeBuyer>>();
    var neighborhoodSlots = HashMap<String, int>();

    for (var neighborHoodId in neighborhoods.keys) {
      assignedHomeBuyers[neighborHoodId!] = [];
      neighborhoodSlots[neighborHoodId] = homeBuyers.length ~/ neighborhoods.length;
    }

    // Sort home buyers based on fit scores in descending order
    var sortedHomeBuyers = homeBuyers.values.toList()
      ..sort((a, b) => b.fitScore!.compareTo(a.fitScore!));

    for (var buyer in sortedHomeBuyers) {
      //print('Remaining Slots: $neighborhoodSlots');
      var preferences = buyer.preferences;
      for (var preference in preferences) {
        if (neighborhoodSlots[preference]! > 0) {
          assignedHomeBuyers[preference]!.add(buyer);
          buyer.assignedNeighborHood = preference;
          neighborhoodSlots[preference!] = neighborhoodSlots[preference]! - 1;
          break;
        }
      }
    }

    return assignedHomeBuyers;

  }

  void beginWriteOutput(var assignedHomeBuyers) {
    //TODO: Remove for Debug
    // assignedHomeBuyers.forEach((neighborhood, buyers) {
    //   var outputLine = '$neighborhood: ';
    //   outputLine += buyers
    //       .map((buyer) => '${buyer.id}(${buyer.fitScore})')
    //       .join(' ');
    //   print("::::---" + outputLine.toString() + "\n");
    // });

    AppHelpers().writeOutput('output.txt', assignedHomeBuyers);
    ///TODO: Remove delay (this is just to demo the busy UI, execution is too fast hence this will slow it down)
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          isWorking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Home",
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isWorking)
              const CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            if (_pickedFile == null && !isWorking)
              Text(
                'Click + to select a .txt file',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            if (_pickedFile != null && !isWorking)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Selected File: ${_pickedFile!.absolute}',
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _openFileFolder,
          tooltip: 'select a .txt file',
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add,
              color: Colors.white,
              weight:
                  10)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
