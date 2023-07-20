
import 'dart:collection';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pearl_certification/core/models/homeBuyer.dart';
import 'package:pearl_certification/core/models/neighborHood.dart';

class AppHelpers {


  //getHomeBuyers
  Map<String?, HomeBuyer?> getHomeBuyers(List<String> lines) {
    var homeBuyers = HashMap<String, HomeBuyer>();

    for (var line in lines) {
      if (line.startsWith('H')) {
        var parts = line.split(' ');
        var id = parts[1];
        var goals = { for (var item in parts.sublist(2, parts.length - 1)) item.split(':')[0] : int.parse(item.split(':')[1]) };
        var preferences = parts.last.split('>');
        homeBuyers[id] = HomeBuyer(id, goals, preferences);
      }
    }

    return homeBuyers;
  }

  //getNeighborHoods
  Map<String?, NeighborHood?> getNeighborHoods(List<String> lines) {
    var neighborHoods = HashMap<String, NeighborHood>();

    for (var line in lines) {
      if (line.startsWith('N')) {
        var parts = line.split(' ');
        var id = parts[1];
        var scores = { for (var item in parts.sublist(2)) item.split(':')[0] : int.parse(item.split(':')[1]) };
        neighborHoods[id] = NeighborHood(id, scores);
      }
    }

    return neighborHoods;
  }

  //getFitScore
  int getFitScore(Map<String?, int?> goals, Map<String?, int?> scores) {
    int fitScore = 0;
    for (var key in goals.keys) {
      fitScore += goals[key]! * scores[key]!;
    }
    return fitScore;
  }

  //writeOutput
  Future<void> writeOutput(String filePath, Map<String, List<HomeBuyer>> assignedHomeBuyers) async {
    // Get the documents directory path
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String documentsPath = documentsDirectory.path;

    // Create a new file
    var file = File('$documentsPath/output.txt').openWrite();

    // Write data to the file
    assignedHomeBuyers.forEach((neighborhood, buyers) {
      var outputLine = '$neighborhood: ';
      outputLine += buyers
          .map((buyer) => '${buyer.id}(${buyer.fitScore})')
          .join(' ');
      file.writeln(outputLine);
    });

    print('File saved successfully.');
  }
}

