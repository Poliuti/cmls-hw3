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

  boolean isOver() {
    return mouseX > x && mouseX < (x + w)
        && mouseY > y && mouseY < (y + h);
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GROUP

class UIGroup extends UIElement {
  ArrayList<UIElement> elements;

  UIGroup() {
    elements = new ArrayList();
  }

  void draw() {
    for (UIElement e : elements)
      e.draw();
  }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// STACK

static enum Direction { HORIZONTAL, VERTICAL }

class UIStack extends UIGroup {
  float margin, spacing;
  Direction dir;
  
  UIStack(float m, float s, Direction d) {
    super();
    margin = m;
    spacing = s;
    dir = d;
  }
  
  float innerW() {
    return w - 2*margin;
  }
  
  float innerH() {
    return h - 2*margin;
  }
  
  void layout() {
    float curX = x + margin;
    float curY = y + margin;

    for (UIElement el : elements) {
      el.setPosition(curX, curY);
      if (dir == Direction.HORIZONTAL)
        curX += el.w + spacing;
      else
        curY += el.h + spacing;
    }
  }

}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// FLEXBOX

class UIFlexbox extends UIStack {

  UIFlexbox(float m, float s, Direction d) {
    super(m, s, d);
  }
  
  void layout() {
    float elemH, elemW;
    
    if (dir == Direction.HORIZONTAL) {
      elemH = innerH();
      elemW = (innerW() + spacing) / elements.size() - spacing;
    } else {
      elemW = innerW();
      elemH = (innerH() + spacing) / elements.size() - spacing;
    }
    
    for (UIElement el : elements)
      el.setSize(elemW, elemH);
    
    super.layout();    
  }

}
