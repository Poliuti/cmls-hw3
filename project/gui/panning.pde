class DraggingEllipse extends UIElement {
  SliderValue thumb_x;
  SliderValue thumb_y;
  Callback onChange;
  
  float thumb_d = 30; //diameter of circles

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
      // set x slider
      float start_x = x + thumb_d / 2;
      float end_x = x + w - thumb_d / 2;
      thumb_x.setValue(thumb_x.position2value(mouseY, start_x, end_x));
      // set y slider
      float start_y = y + h - thumb_d / 2;
      float end_y = y + thumb_d / 2;
      thumb_y.setValue(thumb_y.position2value(mouseX, start_y, end_y));
    }
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
    float xpos = thumb_x.value2position(thumb_x.drawn_v, x, x + w - thumb_d);
    float ypos = thumb_y.value2position(thumb_y.drawn_v, y + h - thumb_d, y);
    ellipse(xpos, ypos, thumb_d, thumb_d);
  }
 
}
