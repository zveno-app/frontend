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
  static const double nextDivisionP = 0.5; // Exponential probability decrease
  static const double maxChildren = 4;
  static const double tempMultiplier = 0.5;
  static const double startingTemp = 4.0;
  static const double resistorP = 2.0;
  static const double resistanceMultiplier = 0.5;
  static const int resistanceMax = 10;
  static const double resistorLengthRelative = 0.5;
  static const double resistorSizeRatio = 3/1; // Length/Diameter
  static const double maxResistorLen = 50;

  BlockOrientation or;
  List<Block> children = [];

  double startR = 0.0;
  double endR = 0.0;
  double leftDownR = 0.0;
  double rightUpR = 0.0;

  double startV = 0.0;
  double endV = 0.0;

  Block(this.or);

  void populate(double temp, Random prng) {

    // if (prng.nextDouble() < nextDivisionP * temp) {
        // var newB = Block(or.other());
        // newB.populate(temp * tempMultiplier, prng);
        // children.add(newB);
        // var newB2 = Block(or.other());
        // newB2.populate(temp * tempMultiplier, prng);
        // children.add(newB2);
      // while (children.length < maxChildren && prng.nextDouble() < nextDivisionP * temp / (children.length + 1)) {
        // var newB = Block(or.other());
        // newB.populate(temp * tempMultiplier, prng);
        // children.add(newB);
      // }
    // }

    while (prng.nextDouble() < nextDivisionP * temp / (children.length + 1) && children.length < maxChildren) {
      var newB = Block(or.other());
      var newB2 = Block(or.other());
      newB.populate(temp * tempMultiplier, prng);
      newB2.populate(temp * tempMultiplier, prng);
      children.add(newB);
      children.add(newB2);
    }

    for (int i = 0; i < children.length; i++) {
      if ((i == 0 || children[i-1].children.isEmpty) && children[i].children.isEmpty && prng.nextDouble() < resistorP) {
        children[i].startR = prng.nextInt(resistanceMax) * resistanceMultiplier;
      }
    }
    if (children.isNotEmpty && children.last.children.isEmpty && prng.nextDouble() < resistorP) {
       children.last.endR = prng.nextInt(resistanceMax) * resistanceMultiplier;
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
        double resW = min(maxResistorLen, size.width * resistorLengthRelative);
        double resH = min(resW / resistorSizeRatio, childHeight / 3);
        resW = resH * resistorSizeRatio;
        var childStartOffset = offset + Offset(0.0, childHeight * i);
        children[i].draw(canvas, childStartOffset, Size(size.width, childHeight));
        if (children[i].startR > 0.0) {
          canvas.drawRect(childStartOffset + Offset((size.width - resW) / 2, -(resH / 2)) & Size(resW, resH), resistorPaint);
        } 
        if (children[i].endR > 0.0) {
          canvas.drawRect(childStartOffset + Offset((size.width - resW) / 2, childHeight - resH / 2) & Size(resW, resH), resistorPaint);
        }
      } else {
        double resH = min(maxResistorLen, size.height * resistorLengthRelative);
        double resW = min(resH / resistorSizeRatio, childWidth / 3);
        resH = resW * resistorSizeRatio;
        var childStartOffset = offset + Offset(childWidth * i, 0.0);
        children[i].draw(canvas, childStartOffset, Size(childWidth, size.height));
        if (children[i].startR > 0.0) {
          canvas.drawRect(childStartOffset + Offset(-resW / 2, (size.height - resH) / 2) & Size(resW, resH), resistorPaint);
        } 
        if (children[i].endR > 0.0) {
          canvas.drawRect(childStartOffset + Offset(childWidth - resW / 2, (size.height - resH) / 2) & Size(resW, resH), resistorPaint);
        }
      }
    }
  }

  static Block create(BlockOrientation or, Random prng) {
    var newB = Block(or);
    newB.populate(startingTemp, prng);
    // TODO fix kostyl'
    if (newB.children.isNotEmpty) {
      newB.children[0].children = [];
    }
    return newB;
  }
}

class BlockPainter extends CustomPainter {
  Block block;

  BlockPainter(this.block);

  @override
  void paint(Canvas canvas, Size size) {
    block.draw(canvas, const Offset(10.0, 10.0), const Size(500, 500));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
