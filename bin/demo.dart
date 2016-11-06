/**
 * Demonstrates usage of the spreadsheet and dependency API
 */

import 'package:possum/spreadsheet.dart';

main() {
  Spreadsheet ss = new Spreadsheet();

  ss.setNode(new Location(0, 0), new SpreadsheetDep(ss, new LiteralValue(41)));
  ss.setNode(new Location(0, 1), new SpreadsheetDep(ss, new LiteralValue(1)));
  
  var arguments = [
    new Location(0, 0),
    new Location(0, 1)
  ];

  {
    var ssDep = new SpreadsheetDep(ss, 
      new FuncCallValue("add", arguments)); 
    ssDep.dependants.addAll(arguments.map((location) => ss.cells[location]));
    ss.setNode(new Location(2, 0), ssDep);
  }

  print (ss);
  ss.depGraph.update();
  print (ss);

  {
    var ssDep = new SpreadsheetDep(ss, 
      new FuncCallValue("sub", arguments)); 
    ssDep.dependants.addAll(arguments.map((location) => ss.cells[location]));
    ss.setNode(new Location(2, 0), ssDep);
  }
  print (ss);
  ss.depGraph.update();
  print (ss);

  {
    ss.setNode(new Location(0, 1), new SpreadsheetDep(ss, new LiteralValue(0)));
  }

  print (ss);
  ss.depGraph.update();
  print (ss);
  
}