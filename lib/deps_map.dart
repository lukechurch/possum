/**
 * Represents the core dependency dataflow graph
 */

abstract class DepNode<T> {
  final List<DepNode<T>> dependants = []; // Nodes that this depends on
  final List<DepNode<T>> dependees = []; // Nodes that depend on this one

  T value;
  DepNode(this.value);

  bool dirty = false;

  eval();
}

class DepGraph<T> {
  final List<DepNode<T>> nodes = [];

  setDirtyAndPropagate(DepNode node) {
    Set<DepNode> toMark = new Set();
    Set<DepNode> marked = new Set();

    toMark.add(node);

    while (toMark.length > 0) {
      DepNode nd = toMark.first;
      toMark.remove(nd);

      if (marked.contains(nd)) continue;

      nd.dirty = true;
      marked.add(nd);
      for (DepNode dep in nd.dependees) {
        if (!marked.contains(dep)) {
          toMark.add(dep);
        }
      }
    }
  }

  get eligable => nodes.where((n) => n.dirty && n.dependants.every((nd) => !nd.dirty));
  get dirtyNodes => nodes.where((n) => n.dirty);

  step() {
    var nodesToUpdate = eligable.toList();
    for (DepNode nd in nodesToUpdate) {
      nd.eval();
    }
  }

  update() {
    while (eligable.length > 0) {
      step();
    }
  }
}


