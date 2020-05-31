class DraggingEllipse extends UIElement
{
  float min_h, max_h;
  float min_w, max_w;
  float vh,vw, drawn_h,drawn_w; // current value and displayed/drawn value

 
  Callback onChange;
  
 int thumbd = 30; //diameter of circles
 

  DraggingEllipse(float mih, float mah, float miw, float maw) {
    min_h = mih;
    max_h = mah;
    min_w=miw;
    max_w=maw;
    onChange = null;
  }

  void setValue(float new_vh, float new_vw) {
    vh = constrain(vh, min_h, max_h);
    vw= constrain(vw, min_w, max_w);
    float old_vh = vh;
    float old_vw = vw;
    vh = new_vh;
    vw= new_vw;
    float [] old_value_c={old_vh,old_vw};
    float [] value_c={vh,vw};
    if (onChange != null && !value_c.equals(old_value_c))
      onChange.action(this);
  }

  void update() {
    if (isOver() && mousePressed)
       setValue(position2value(mouseY));
       setValue(position2value(mouseX));
       drawn_vh += (vh - drawn_vh);
       drawn_vw += (vw - drawn_vw);
  }


  float position2value(float posx,float posy ) {//corretta la sintassi???
    float startx = x + thumbd / 2;
    float endx = (x + w) - thumbd / 2;
    float starty = y + thumbd / 2;
    float endy = (y + h) - thumbd / 2;
    float ratiox = constrain((endx - posx) / (endx - startx), -1, 1);
    float ratioy = constrain((endy - posy) / (endy - starty), -1, 1);
    float [] values= {(max_h - min_h) * ratiox + min_h, (max_w - min_w) * ratioy + min_w};
    return values;
  }
  
  float value2position(float valx, float valy) {
    float ratiox = (valx - min_w) / (max_w - min_w);
    float ratioy = (valy - min_h) / (max_h - min_h);
    float startx = (x + w) - thumbd;
    float endx = x;
    float starty = (y + h) - thumbd;
    float endy = y;
    float [] positions= {ratiox * (endx - startx) + startx, ratioy * (endy - starty) + starty} ;
    return positions;
  }

  void draw() {
    update();
    float xpos = value2position(drawn_vw);
    float ypos = value2position(drawn_vh);
    noStroke();
    fill(205);
    rect(x, y, w, h);
    if (isOver()) {
      fill(80, 80, 80);
    } else {
      fill(102, 102, 102);
    }
    ellipse(x, ypos, thumbd, thumbd);
  }
 

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }
}






















/*int x;
  int y;
  int h;
  int wi;
  float by;
  float bx;
  boolean overBox = false;
  boolean locked = false;
  float xOffset = 0.0; 
  float yOffset = 0.0; 
  float d = dist(mouseX,mouseY,this.x,this.y);
  
  boolean clicked;
  public DraggingEllipse(int posx, int posy){
      x=posx;
      y=posy;
      h=30;
      wi=30;//da modificare poi con le dimensioni del quadrato

  }
  public void draw(){
 // Test if the cursor is over the box 
  stroke(10);
  fill(205);
  rect(325,243,150,150);
  fill(204, 102, 0);
  if (mouseX > bx-wi && mouseX < bx+wi && 
      mouseY > by-h && mouseY < by+h) {
    overBox = true;  
    if(!locked) { 
      stroke(255); 
      fill(153);
    } 
  } else {
    stroke(153);
    fill(153);
    overBox = false;
  }
    ellipse(x,y,h,wi);
  }
 
 
 void mousePressed() {
  if(overBox) { 
    locked = true; 
    fill(255, 255, 255);
  } else {
    locked = false;
  }
  xOffset = mouseX-bx; 
  yOffset = mouseY-by; 

}

void mouseDragged() {
  if(locked) {
    bx = mouseX-xOffset; 
    by = mouseY-yOffset; 
  }
}

void mouseReleased() {
  locked = false;
}
 
  /* public void mouseDragged(){ 
     if (d<h/2){
    x=mouseX;
    y=mouseY;
     }*/
