import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Ent {
  bool draw = true;
  bool resistor = false;
  bool right = true;
  bool down = true;

  Ent(this.draw, this.right, this.down);

  static Ent full() => Ent(true, true, true);
}

class GraphPainter extends CustomPainter {
  int randomSeed = 0;
  GraphPainter(this.randomSeed);
  void traverseCircuit(int x, int y, List<List<Ent>> grid, List<List<bool>> visited) {
    final n = grid.length;
    final m = grid[0].length;
    visited[x][y] = true;
    if (x < n - 1 && grid[x][y].right && !visited[x + 1][y]) {
      traverseCircuit(x + 1, y, grid, visited);
    }
    if (y < m - 1 && grid[x][y].down && !visited[x][y + 1]) {
      traverseCircuit(x, y + 1, grid, visited);
    }
    if (x > 0 && grid[x - 1][y].right && !visited[x - 1][y]) {
      traverseCircuit(x - 1, y, grid, visited);
    }
    if (y > 0 && grid[x][y - 1].down && !visited[x][y - 1]) {
      traverseCircuit(x, y - 1, grid, visited);
    }
  }
  int getDegree(int x, int y, List<List<Ent>> grid) {
    final n = grid.length;
    final m = grid[0].length;
    int res = 0;
    if (grid[x][y].right) res += 1;
    if (grid[x][y].down) res += 1;
    if (x > 0 && grid[x - 1][y].right) res += 1;
    if (y > 0 && grid[x][y - 1].down) res += 1;
    return res;
  }
  bool removeEdge(int x, int y, bool facing_down, bool ignoreSelf, List<List<Ent>> grid) {
    final n = grid.length;
    final m = grid[0].length;
    if (!ignoreSelf && getDegree(x, y, grid) == 2) {
      return false;
    }
    if (facing_down) {
      if (getDegree(x, y + 1, grid) == 2) {
        return false;
      }
      grid[x][y].down = false;
    } else {
      if (getDegree(x + 1, y, grid) == 2) {
        return false;
      }
      grid[x][y].right = false;
    }
    List<List<bool>> visited = List.generate(n, (_) => List.generate(m, (_) => false));
    bool vertexFound = false;
    for (int i = 0; i < n && !vertexFound; ++i) {
      for (int j = 0; j < m && !vertexFound; ++j) {
        if (grid[i][j].draw) {
          vertexFound = true;
          traverseCircuit(i, j, grid, visited);
        }
      }
    }
    assert(vertexFound);
    bool allVisited = true;
    for (int i = 0; i < n && allVisited; ++i) {
      for (int j = 0; j < m && allVisited; ++j) {
        if (grid[i][j].draw && !visited[i][j]) {
          allVisited = false;
        }
      }
    }
    if (allVisited) {
      return true;
    }
    if (facing_down) {
      grid[x][y].down = true;
    } else {
      grid[x][y].right = true;
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

//    const int n = 4, m = 3;
//    const int n = 20, m = 20;
    const int n = 20, m = 20;

    List<List<Ent>> grid = List.generate(n, (i) => List.generate(m, (j) => Ent(true, i != n - 1, j != m - 1)));
    var rand = Random(randomSeed);

//    const int removeEdgesCount = 3, removeVertexCount = 0;
//    const int removeEdgesCount = 90, removeVertexCount = 70;
    const int resistorCount = 10, removeEdgesCount = 100, removeVertexCount = 100;
    
    for (int i = 0, j = 0; i < removeVertexCount && j < 50000; j++) {
      int x = rand.nextInt(n - 1);
      int y = rand.nextInt(m - 1);
      if (!grid[x][y].draw) {
        continue;
      }

      if (x > 0 && getDegree(x - 1, y, grid) < 3) continue;
      if (x < n - 1 && getDegree(x + 1, y, grid) < 3) continue;
      if (y > 0 && getDegree(x, y - 1, grid) < 3) continue;
      if (y < m - 1 && getDegree(x, y + 1, grid) < 3) continue;


      grid[x][y].draw = false;
      grid[x][y].down = false;
      grid[x][y].right = false;

      if (x != 0) grid[x-1][y].right = false;
      if (y != 0) grid[x][y-1].down = false;
      ++i;
    }

    for (int i = 0, j = 0; i < removeEdgesCount && j < 50000; ++j) {
      int x = rand.nextInt(n - 1);
      int y = rand.nextInt(m - 1);
      if (!grid[x][y].draw) {
        continue;
      }
      bool facingDown = rand.nextBool();
      if (facingDown && !grid[x][y].down) {
        continue;
      }
      if (!facingDown && !grid[x][y].right) {
        continue;
      }
      if (removeEdge(x, y, facingDown, false, grid)) {
        ++i;
      }
    }

    for (int i = 0, j = 0; i < resistorCount && j < 50000;j++) {
      int x = rand.nextInt(n - 1);
      int y = rand.nextInt(m - 1);

      if (grid[x][y].draw && getDegree(x, y, grid) == 2) {
        grid[x][y].resistor = true;
        i++;
      }
      else continue;
    }
    
    // canvas.drawRect(const Offset(0.0, 0.0) & const Size(100.0, 100.0), paint);
    
    const int offset = 100;

    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j].draw) {
          if (grid[i][j].resistor) {
            canvas.drawRect(Offset(offset + i * 30.0 - 10.0, offset + j * 30.0 - 10.0) & const Size(20, 20), paint);
          }
          else {
            canvas.drawCircle(Offset(offset + i * 30.0, offset + j * 30.0), 4, paint);
          }
        }
        if (grid[i][j].right && i < grid.length - 1) {
          canvas.drawLine(Offset(offset + i * 30.0, offset + j * 30.0), Offset(offset + i * 30.0 + 30.0, offset + j * 30.0), paint);
        }
        if (grid[i][j].down && j < grid[i].length - 1) {
          canvas.drawLine(Offset(i * 30.0 + offset, j * 30.0 + offset), Offset(i * 30.0 + offset, offset + j * 30.0 + 30.0), paint);
        }
      }
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridGraph {
  
}

class AdjList {
  int numVertices;
  
  List<List<int>> adjList = [];

  AdjList(this.numVertices);
}
