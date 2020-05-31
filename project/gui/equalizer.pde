// ~~~~~~~~~~~
// MIXER
class Mixer extends UIFlexbox {

  Mixer(float m, float s) {
    super(m, 0, Direction.HORIZONTAL);
  }

  void draw() {
    makeVerticalGradient(x + margin, y + margin, w - 2*margin - 1, h - 2*margin, color(255, 0, 0), color(0, 200, 0));
    super.draw();
  }

}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GRADIENT

void makeVerticalGradient(float x, float y, float w, float h, color c1, color c2) {
  noFill();

  for (float i = y; i <= y+h; i++) {
    float inter = map(i, y, y + h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, x+w, i);
  }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// A SLIDER WITH METER FEEDBACK

class EQSlider extends UIElement {
  float min_v, max_v;        // min and max values
  float v, drawn_v;          // current value and displayed/drawn value
  float inertia;             // intertia of the slider (higher → heavier/slower)
  float thumbh;              // height of the thumb of the slider
  float meter, drawn_meter;  // value of meter and displayed/draw value
  Callback onChange;         // called when slider's value is changed through setValue()
  
  EQSlider(float miv, float mav, float ine, float th) {
    min_v = miv;
    max_v = mav;
    inertia = ine;
    thumbh = th;
    onChange = null;
  }

  EQSlider(float miv, float mav) {
    this(miv, mav, 5, 10);
  }

  void setValue(float vv) {
    vv = constrain(vv, min_v, max_v);
    float old_v = v;
    v = vv;
    if (onChange != null && v != old_v)
      onChange.action(this);
  }

  void setMeter(float mm) {
    meter = constrain(mm, min_v, max_v);
  }

  void update() {
    if (isOver() && mousePressed)
       setValue(position2value(mouseY));
    drawn_v += (v - drawn_v) / inertia;
    drawn_meter += (meter - drawn_meter) / inertia;
  }
  
  void draw() {
    update();
    noStroke();

    // slider rectangle
    //fill(204);
    //rect(x, y, w, h);

    // slider meter
    fill(40);
    float hmet = value2position(drawn_meter, false) - y;
    rect(x, y, w, hmet);

    // slider thumb
    if (isOver()) {
      fill(150, 150, 150);
    } else {
      fill(200, 200, 200);
    }
    float ythumb = value2position(drawn_v, true);
    rect(x, ythumb, w, thumbh);
  }

  float position2value(float pos) {
    float start = y + thumbh / 2;
    float end = (y + h) - thumbh / 2;
    float ratio = constrain((end - pos) / (end - start), 0, 1);
    return (max_v - min_v) * ratio + min_v;
  }

  float value2position(float val, boolean thumb) {
    float ratio = (val - min_v) / (max_v - min_v);
    float start = (y + h) - (thumb ? thumbh : 0);
    float end = y;
    return ratio * (end - start) + start;
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

}
