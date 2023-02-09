class Point<T extends num> {
  T x;
  T y;

  Point(this.x, this.y) {
    this.x = x;
    this.y = y;
  }

  @override
  String toString() {
    return 'Point{x: $x, y: $y}';
  }


}