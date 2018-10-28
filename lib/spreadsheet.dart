/**
 * Adds a Spreadsheet style overlay to the dependency graph
 */

import 'deps_map.dart';

class Spreadsheet {
  Map<Location, SpreadsheetDep> cells = {};
  DepGraph depGraph = new DepGraph();

  toString() {
    StringBuffer sb = new StringBuffer();
    cells.forEach((k, v) => sb.writeln("$k: ${v.value} ${v.computedValue} ${v.dirty}"));
    return sb.toString();
  }

  // The node should have correct dependants
  // This function will fix up the node that is being
  // removed
  setNode(Location location, SpreadsheetDep node) {

    if (node.dependees.length > 0) throw "Don't set dependees on nodes before adding them";

    SpreadsheetDep existingNode = cells[location];

    // Remove existing node
    if (existingNode != null) {
      depGraph.nodes.remove(existingNode);
      
      // Remove the existing node from the graph
      for (var dpNode in existingNode.dependees) {
        dpNode.dependants..remove(existingNode)..add(node);
        node.dependees.add(dpNode);
      }
      for (var dpNode in existingNode.dependants) {
        dpNode.dependees.remove(existingNode);
      }
    }

    depGraph.nodes.add(node);

    for (var dependant in node.dependants) {
      dependant.dependees.add(node);
    }
    cells[location] = node;

    depGraph.setDirtyAndPropagate(node);
  }
}

class SpreadsheetDep extends DepNode<CellValue> {
  Spreadsheet sheet;
  SpreadsheetDep(this.sheet, CellValue cv) : super(cv) { }
  
  int computedValue;

  eval() {
    if (!this.dirty) {
      print ("Invariant violated: executing clean cell");
    }

    if (value is LiteralValue) {
      computedValue = (value as LiteralValue).value;
      dirty = false;
      return;
    } 

    if (value is FuncCallValue) {
      var funcCall = value as FuncCallValue;

      // Look up the values
      List<int> locationValues = [];
      for (var location in funcCall.arguments) {
        locationValues.add(sheet.cells[location].computedValue);
      }

      // eval
      switch (funcCall.functionName) {
        case "add":
          computedValue = add(locationValues[0], locationValues[1]);
          break;
        case "sub":
          computedValue = sub(locationValues[0], locationValues[1]);
          break;
      }

      dirty = false;
      return;
    }
  }
}

add(x, y) => x + y;
sub(x, y) => x - y;

class Location {
  final int row;
  final int col;

  const Location(this.row, this.col);
  toString() => "R$row:C$col";

  bool operator ==(other) {
    return other is Location && row == other.row && col == other.col;
  }

  int get hashCode => 10000 * row + col; // TODO: Fix dumb hashcode

  
}

abstract class CellValue { }

class LiteralValue extends CellValue {
  int value;

  LiteralValue(this.value);
}

class FuncCallValue extends CellValue {
  String functionName;
  List<Location> arguments = [];

  FuncCallValue(this.functionName, this.arguments) {
    
  }
}