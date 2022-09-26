import 'package:flutter/material.dart';

enum NodeType {
  resistor, wire, blank, input, output
}

enum Dir {
  h, v
}

class CircuitNode {
  NodeType type = NodeType.wire;

  int? start;
  int? startLU;
  int? startRD;
  
  int? end;
  int? endLU;
  int? endRD;
}

class Circuit {
  List<CircuitNode> nodes;
  int start;
  Dir startDir = Dir.v;
  
  Circuit(this.nodes, this.start);

  void swapTo(int fromI, int oldI, int newI) {
    var tgt = nodes[fromI];
    if (tgt.start == oldI) tgt.start = newI;
    if (tgt.startRD == oldI) tgt.startRD = newI;
    if (tgt.startLU == oldI) tgt.startLU = newI;
    if (tgt.end == oldI) tgt.end = newI;
    if (tgt.endRD == oldI) tgt.endRD = newI;
    if (tgt.endLU == oldI) tgt.endLU = newI;
  }

  //            +
  // +          | startI
  // | nodeI -> | nodeI
  // +          | endI
  //            +
  void surround(int nodeI) {
    var old = nodes[nodeI];
    nodes.add(
      CircuitNode()
        ..start = old.start
        ..startRD = old.startRD
        ..startLU = old.startLU
    );
    var startI = nodes.length - 1;
    nodes.add(
      CircuitNode()
        ..end = old.end
        ..endRD = old.endRD
        ..endLU = old.endLU
    );
    var endI = nodes.length - 1;

    if (old.start != null) swapTo(old.start ?? 0, nodeI, startI);
    if (old.startLU != null) swapTo(old.startLU ?? 0, nodeI, startI);
    if (old.startRD != null) swapTo(old.startRD ?? 0, nodeI, startI);
    if (old.end != null) swapTo(old.end ?? 0, nodeI, endI);
    if (old.endLU != null) swapTo(old.endLU ?? 0, nodeI, endI);
    if (old.endRD != null) swapTo(old.endRD ?? 0, nodeI, endI);

    nodes[startI].end = nodeI;
    nodes[endI].start = nodeI;
    nodes[nodeI] = CircuitNode()
      ..start = startI
      ..end = endI;
  }

  //  +      +---+
  //  |      |   |
  // *** -> ***  |
  //   |     |   |
  //   +     +---+
  void extendRight(int upI, int downI) {

  }

  void permute() {
    
  }

  //  +--1Wire--+
  //  |         |
  // 0In      3Out
  //  |         |
  //  +--2Wire--+
  static Circuit default1() => Circuit(
    [
      CircuitNode()
        ..type = NodeType.input
        ..endRD = 1
        ..startRD = 2,
      CircuitNode()
        ..endRD = 3
        ..startRD = 0,
      CircuitNode()
        ..endLU = 3
        ..startLU = 0,
      CircuitNode()
        ..type = NodeType.output
        ..startLU = 2
        ..endLU = 1,
    ], 
    0
  );
}
