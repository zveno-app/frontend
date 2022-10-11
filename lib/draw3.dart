import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

enum BlockOrientation {
  h, v
}
extension OrientationExt on BlockOrientation {
  BlockOrientation other() {
    if (this == BlockOrientation.h) {
      return BlockOrientation.v;
    } else {
      return BlockOrientation.h;
    }
  }
}

class Block {
  // TODO better probability distribution
  static const double nextDivisionP = 0.7; // Exponential probability decrease
  static const double maxChildren = 4;
  static const double tempMultiplier = 0.6;
  static const double startingTemp = 2.0;
  static const double resistorP = 1.5;
  static const double resistanceMultiplier = 0.5;
  static const int resistanceMax = 10;
  static const double resistorLengthRelative = 0.5;
  static const double resistorSizeRatio = 3/1; // Length/Diameter
  static const double maxResistorLen = 50;

  BlockOrientation or;
  List<Block> children = [];

  double leftR = 0.0;
  double rightR = 0.0;
  double upR = 0.0;
  double downR = 0.0;

  bool freeRight = false;
  bool freeLeft = false;
  bool freeUp = false;
  bool freeDown = false;

  double startV = 0.0;
  double endV = 0.0;

  double complexity;

  Block(this.or, this.complexity);

  void populate(double temp, Random prng) {
    while (prng.nextDouble() < complexity * nextDivisionP * temp / (children.length + 1) && children.length < maxChildren) {
      var newB = Block(or.other(), complexity);
      var newB2 = Block(or.other(), complexity);
      newB.populate(temp * tempMultiplier, prng);
      newB2.populate(temp * tempMultiplier, prng);
      children.add(newB);
      children.add(newB2);
    }
 }

  void placeResistors(double temp, Random prng) {
    if (children.isNotEmpty) {
      if (or == BlockOrientation.v) {
        for (int i = 0; i < children.length - 1; i++) {
          if (children[i+1].children.length < children[i].children.length) {
            children[i].freeRight = true;
          } else {
            children[i+1].freeLeft = true;
          }
        }
        children.first.freeLeft = freeLeft;
        children.last.freeRight = freeRight;

        for (var child in children) {
          child.freeUp = freeUp;
          child.freeDown = freeDown;

          child.placeResistors(temp * tempMultiplier, prng);
        }
      } else {
        for (int i = 0; i < children.length - 1; i++) {
          if (children[i+1].children.length < children[i].children.length) {
            children[i].freeDown = true;
          } else {
            children[i+1].freeUp = true;
          }
        }
        children.first.freeUp = freeUp;
        children.last.freeDown = freeDown;

        for (var child in children) {
          child.freeLeft = freeLeft;
          child.freeRight = freeRight;
          
          child.placeResistors(temp, prng);
        }
      }
    } else {
      if (freeLeft && prng.nextDouble() < resistorP) leftR = 1.0;
      if (freeRight && prng.nextDouble() < resistorP) rightR = 1.0;
      if (freeUp && prng.nextDouble() < resistorP) upR = 1.0;
      if (freeDown && prng.nextDouble() < resistorP) downR = 1.0;
    }
  }

  void draw(Canvas canvas, Offset offset, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    var resistorPaint = Paint()
      ..style = PaintingStyle.fill;

    if (children.isEmpty) {
      canvas.drawRect(offset & size, paint);
    }

    double childWidth = size.width / children.length;
    double childHeight = size.height / children.length;
    for (int i = 0; i < children.length; i++) {
      if (or == BlockOrientation.h) {
        var childStartOffset = offset + Offset(0.0, childHeight * i);
        children[i].draw(canvas, childStartOffset, Size(size.width, childHeight));
      } else {
        var childStartOffset = offset + Offset(childWidth * i, 0.0);
        children[i].draw(canvas, childStartOffset, Size(childWidth, size.height));
      }
    }

    {
      double resW = min(maxResistorLen, size.width * resistorLengthRelative);
      double resH = resW / resistorSizeRatio;
      if (upR > 0.0) {
        canvas.drawRect(offset + Offset((size.width - resW) / 2, -resH / 2) & Size(resW, resH), resistorPaint);
      }

      if (downR > 0.0) {
        canvas.drawRect(offset + Offset((size.width - resW) / 2, size.height - resH / 2) & Size(resW, resH), resistorPaint);
      }
    }

    {
      double resH = min(maxResistorLen, size.height * resistorLengthRelative);
      double resW = resH / resistorSizeRatio;
      if (leftR > 0.0) {
        canvas.drawRect(offset + Offset(-resW / 2, (size.height - resH) / 2) & Size(resW, resH), resistorPaint);
      }
      if (rightR > 0.0) {
        canvas.drawRect(offset + Offset(size.width - resW / 2, (size.height - resH) / 2) & Size(resW, resH), resistorPaint);
      }
    }
  }

  static Block create(BlockOrientation or, Random prng, double complexity) {
    var newB = Block(or, complexity);
    newB.populate(startingTemp, prng);
    newB.freeUp = true;
    newB.freeDown = true;
    newB.freeLeft = true;
    newB.freeRight = true;
    newB.placeResistors(startingTemp, prng);
    return newB;
  }

  factory Block.fromJson(Map<String, dynamic> json) {
    var or = json['orient'] == 'v' ? BlockOrientation.v : BlockOrientation.h;
    var it = Block(or, json['complexity'])
      ..leftR = json['leftR']
      ..rightR = json['rightR']
      ..upR = json['upR']
      ..downR = json['downR']
      ..startV = json['startV']
      ..endV = json['endV'];
    for (var child in json['children']) {
      it.children.add(Block.fromJson(child));
    }
    return it;
  }
}

class BlockPainter extends CustomPainter {
  Block block;

  BlockPainter(this.block);

  @override
  void paint(Canvas canvas, Size size) {
    block.draw(canvas, const Offset(20.0, 20.0), Size(min(size.height, size.width) - 40, min(size.height, size.width) - 40));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
