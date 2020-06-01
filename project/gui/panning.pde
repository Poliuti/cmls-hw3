class DraggingEllipse extends UIElement {
  SliderValue thumb_x;
  SliderValue thumb_y;
  Callback onChange;
  
  float thumb_d = 30; // diameter of circle

  DraggingEllipse(float miv, float mav, float ine, float td) {
    thumb_x = new SliderValue(miv, mav, ine);
    thumb_y = new SliderValue(miv, mav, ine);
    thumb_d = td;
    onChange = null;
  }

  void setValue(float new_vx, float new_vy) {
    boolean changed_x = thumb_x.setValue(new_vx);
    boolean changed_y = thumb_y.setValue(new_vy);
    if (onChange != null && (changed_x || changed_y))
      onChange.action(this);
  }

  void update() {
    if (isOver() && mousePressed) {
      setValue(thumb_x.position2value(mouseX, getStartX(), getEndX()),
               thumb_y.position2value(mouseY, getStartY(), getEndY()));
    }
    thumb_x.update();
    thumb_y.update();
  }

  void draw() {
    update();
    noStroke();
    
    // Rectangle
    fill(205);
    rect(x, y, w, h);
    
    // Circle
    if (isOver()) {
      fill(80, 80, 80);
    } else {
      fill(102, 102, 102);
    }
    float xpos = thumb_x.value2position(thumb_x.drawn_v, getStartX(), getEndX());
    float ypos = thumb_y.value2position(thumb_y.drawn_v, getStartY(), getEndY());
    ellipseMode(CENTER);
    ellipse(xpos, ypos, thumb_d, thumb_d);
  }
  
  float getStartX() {
    // left
    return x + thumb_d / 2;
  }
  
  float getEndX() {
    // right
    return x + w - thumb_d / 2;
  }
  
  float getStartY() {
    // down
    return y + h - thumb_d / 2;
  }
  
  float getEndY() {
    // up
    return y + thumb_d / 2;
  }
 
}
