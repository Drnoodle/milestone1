void setup() {
  size (1000, 1000, P2D);
}

float scale = 1.0;
float angleX = 0.0;
float angleY = 0.0;

void draw() {
background(255, 255, 255);
My3DPoint eye = new My3DPoint(0, 0, -5000);
My3DPoint origin = new My3DPoint(0, 0, 0);
My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
input3DBox = transformBox(input3DBox, scaleMatrix(scale,scale,scale));
input3DBox = transformBox(input3DBox, rotateXMatrix(angleX));
input3DBox = transformBox(input3DBox, rotateYMatrix(angleY));
//rotated around x

float[][] transform2 = translationMatrix(200, 200, 0);
input3DBox = transformBox(input3DBox, transform2);
projectBox(eye, input3DBox).render();

}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  return new My2DPoint(eye.z*(p.x - eye.x)/(-p.z + eye.z), eye.z*(p.y-eye.y)/(-p.z + eye.z));
}

void makeLine(My2DPoint a, My2DPoint b) {
  line (a.x, a.y, b.x, b.y);
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s=s;
  }
  void render() {
    makeLine(s[0], s[1]);
    makeLine(s[0], s[3]);
    makeLine(s[2], s[3]);
    makeLine(s[2], s[1]);
    makeLine(s[4], s[5]);
    makeLine(s[4], s[7]);
    makeLine(s[6], s[7]);
    makeLine(s[6], s[5]);
    makeLine(s[2], s[6]);
    makeLine(s[3], s[7]);
    makeLine(s[0], s[4]);
    makeLine(s[1], s[5]);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[] {
      new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }

}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] lama = new My2DPoint[8];
  for (int i=0; i < box.p.length; i++) {
    lama[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(lama);
}

float[] homogeneous3DPoint (My3DPoint p){
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle){
  return(new float[][] {{1,0,0,0},
  {0, cos(angle), sin(angle), 0},
  {0,-sin(angle), cos(angle), 0},
  {0,0,0,1}});
}

float[][] rotateYMatrix(float angle){
  return(new float[][] {{cos(angle),0,-sin(angle),0},
  {0,1,0,0},
  {sin(angle),0,cos(angle),0},
  {0,0,0,1}});
}

float[][] rotateZMatrix(float angle){
  return(new float[][] {{cos(angle), sin(angle),0,0},
  {-sin(angle),cos(angle),0,0},
  {0,0,1,0},
  {0,0,0,1}});
}

float[][] scaleMatrix(float x, float y, float z){
  return(new float[][] {{x,0,0,0},
  {0,y,0,0},
  {0,0,z,0},
  {0,0,0,1}});
}

float[][] translationMatrix(float x, float y, float z){
  return(new float[][] {{1,0,0,x},
  {0,1,0,y},
  {0,0,1,z},
  {0,0,0,1}});  
}

float[] matrixProduct(float[][] a, float[] b){
  float[] c = new float[4];
  
  for(int i = 0; i <4; i++){
     c[i] = 0;
    for(int j=0; j<4; j++){
      c[i] += a[i][j]*b[j];
    }   
  }
  return c;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix){
  My3DPoint[] q = new My3DPoint[box.p.length];
  for(int i=0;i <box.p.length; i++){
    q[i] = euclidian3DPoint(matrixProduct(transformMatrix,homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(q);
}

My3DPoint euclidian3DPoint (float[] a){
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
return result;
}

void mouseDragged(){
  scale = (float)mouseY/1000; 
}

void keyPressed(){
  if(key == CODED){
    if (keyCode == UP){
      angleX += PI/12.0;
    }else if(keyCode == DOWN) {
      angleX += -PI/12.0;
    }
    if (keyCode == RIGHT){
      angleY += PI/12.0;
    }else if(keyCode == LEFT){
      angleY += -PI/12.0;
    }   
  }
}
