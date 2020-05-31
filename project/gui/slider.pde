// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// A SLIDER WITH METER FEEDBACK

class EQSlider extends UIElement {
  float min_v, max_v; // min and max values
  float v, drawn_v; // current value and displayed/drawn value
  float inertia; // speed factor for elasticity
  float meter; // value of meter TODO
  
  Callback onChange;

  int thumbh = 10; // height of the thumb of the slider
  
  EQSlider(float miv, float mav, float ine) {
    min_v = miv;
    max_v = mav;
    inertia = ine;
    onChange = null;
  }

  void update() {
    if (isOver() && mousePressed) {
      float old_v = v;
      v = position2value(mouseY);
      if (onChange != null && v != old_v)
        onChange.action(this);
    }
    drawn_v += (v - drawn_v) / inertia;
  }
  
  void draw() {
    update();
    float ypos = value2position(drawn_v);
    noStroke();
    fill(204);
    rect(x, y, w, h);
    if (isOver()) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(x, ypos, w, thumbh);
  }
  
  float position2value(float pos) {
    float start = y + thumbh / 2;
    float end = (y + h) - thumbh / 2;
    float ratio = constrain((end - pos) / (end - start), 0, 1);
    return (max_v - min_v) * ratio + min_v;
  }
  
  float value2position(float val) {
    float ratio = (val - min_v) / (max_v - min_v);
    float start = (y + h) - thumbh;
    float end = y;
    return ratio * (end - start) + start;
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }
  
}
