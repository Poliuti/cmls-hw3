// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// BASE CLASSES

interface Callback {
  void action(UIElement caller);
}

abstract class UIElement {
  float w, h; // width and height
  float x, y; // position
  
  abstract void draw();
  
  UIElement setSize(float ww, float hh) {
    w = ww;
    h = hh;
    return this;
  }
  
  UIElement setPosition(float xx, float yy) {
    x = xx;
    y = yy;
    return this;
  }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// FLEXBOX

static enum Direction { HORIZONTAL, VERTICAL }

class UIFlexbox extends UIElement {
  float margin, spacing; // surrounding margin and space between elements
  Direction dir;
  
  ArrayList<UIElement> elements;
  
  UIFlexbox(float m, float s, Direction d) {
    margin = m;
    spacing = s;
    dir = d;
    elements = new ArrayList();
  }
  
  void layout() {
    int N = elements.size();
    
    float innerW = w - 2*margin;
    float innerH = h - 2*margin;
    float curX = x + margin;
    float curY = y + margin;
    
    float elemH, elemW;
    
    if (dir == Direction.HORIZONTAL) {
      elemH = innerH;
      elemW = (innerW + spacing) / N - spacing;
    } else {
      elemW = innerW;
      elemH = (innerH + spacing) / N - spacing;
    }
    
    for (int i = 0; i < N; i++) {
      elements.get(i)
        .setSize(elemW, elemH)
        .setPosition(curX, curY);
      if (dir == Direction.HORIZONTAL)
        curX += elemW + spacing;
      else
        curY += elemH + spacing;
    }
  }
  
  void draw() {
    for (UIElement e : elements)
      e.draw();
  }
}
