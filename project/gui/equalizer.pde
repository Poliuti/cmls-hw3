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

  void makeVerticalGradient(float x, float y, float w, float h, color c1, color c2) {
    noFill();

    for (float i = y; i <= y+h; i++) {
      float inter = map(i, y, y + h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }

}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// EQ SLIDER WITH METER FEEDBACK

class EQSlider extends UIElement {
  SliderValue thumb, meter;
  float thumb_h;
  Callback onChange;
  
  EQSlider(float miv, float mav, float ine, float th) {
    thumb = new SliderValue(miv, mav, ine);
    meter = new SliderValue(-60, 0, ine); // meter goes up to 0dB
    meter.setValue(meter.min_v); // reset meter to floor
    thumb_h = th;
    onChange = null;
  }

  EQSlider(float miv, float mav) {
    this(miv, mav, 5, 10);
  }

  void setValue(float vv) {
    boolean changed = thumb.setValue(vv);
    if (onChange != null && changed)
      onChange.action(this);
  }
  
  float getValue() {
    return thumb.v;
  }

  void setMeter(float mm) {
    meter.setValue(mm);
  }

  void update() {
    if (isOver() && mousePressed) {
      float start = (y + h) - thumb_h / 2; // high value → up
      float end = y + thumb_h / 2;  // low value → bottom
      setValue(thumb.position2value(mouseY, start, end));
    }
    thumb.update();
    meter.update();
  }
  
  void draw() {
    update();
    noStroke();

    // slider rectangle
    //fill(204);
    //rect(x, y, w, h);

    // slider meter
    fill(40);
    float hmet = meter.value2position(meter.drawn_v, h, 0);
    rect(x, y, w, hmet);

    // slider thumb
    if (isOver()) {
      fill(150);
    } else {
      fill(200);
    }
    float ythumb = thumb.value2position(thumb.drawn_v, y + h - thumb_h, y);
    rect(x, ythumb, w, thumb_h);
  }  

}
