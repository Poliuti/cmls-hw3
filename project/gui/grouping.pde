interface UIElement {
  int w = 10, h = 100; // width and height
  float x = 0, y = 0; // position
  void draw();
}

static enum Direction { HORIZONTAL, VERTICAL }

class UIGroup implements UIElement {
  float margin, spacing; // surrounding margin and space between elements
  Direction dir;
  
  ArrayList<UIElement> elements;
  
  UIGroup(float m, float s) {
    margin = m;
    spacing = s;
  }
  
  void layout() {
    // TODO: use margin and spacing to adjust positions and sizes of elements
  }
  
  void addElement(UIElement el) {
    elements.add(el);
    layout();
  }
  
  void draw() {
    for (UIElement e : elements)
      e.draw();
  }
}
