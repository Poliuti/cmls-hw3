class DraggingEllipse
{
  int x;
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
}
