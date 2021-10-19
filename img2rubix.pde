//-------------------------------------------------------
// img2rubix, converts an image to rubix cube.
// nearest color, no dithering, dirt simple.
// 2021-10-17 dan@marginallyclever.com
//-------------------------------------------------------
//white, red, blue, orange, green, and yellow.
color white = color(255,255,255);
color red = color(255,0,0);
color blue = color(0,0,255);
color orange = color(255,127,0);
color green = color(0,255,0);
color yellow = color(255,255,0);

color [] list = { white, red, blue, orange, green, yellow };

class Cube {
  int px;
  int py;
  public int [] colors = {0,1,2, 3,4,5, 4,3,2};
  
  public void draw() {
    stroke(0,0,0);
    int j=0;
    for(int y=0;y<3;++y) {
      for(int x=0;x<3;++x) {
        fill(list[colors[j++%colors.length]]);
        rect(px+x*SQUARE_SIZE,
             py+y*SQUARE_SIZE,
             SQUARE_SIZE,
             SQUARE_SIZE);
      }
    }
  }
};

final int SQUARE_SIZE = 4;
final int CUBE_WIDTH = SQUARE_SIZE*3;
final int CUBES_PER_SIDE = (int)Math.ceil(800 / CUBE_WIDTH); 
PImage img;
boolean ready=false;
Cube [] cubeList = new Cube[CUBES_PER_SIDE*CUBES_PER_SIDE];

void setup() {
  size(800,800);

  ready=false;
  selectInput("Select an image file","inputSelected");
}


void inputSelected(File selection) {
  if(selection == null) {
    exit();
    return;
  }
  
  img = loadImage(selection.getAbsolutePath());
  cropImageToSquare();
  resizeImageToFillWindow();
  img.loadPixels();
  
  quantizeImageToCubes();
  ready=true;
}


void quantizeImageToCubes() {
  int j=0;
  for(int y=0;y<CUBES_PER_SIDE;++y) {
    for(int x=0;x<CUBES_PER_SIDE;++x) {
      cubeList[j] = new Cube();
      quantizeCube( x*CUBE_WIDTH,
                    y*CUBE_WIDTH,
                    cubeList[j]);
      ++j;
    }
  }
}


void quantizeCube(int px,int py,Cube cube) {
  cube.px=px;
  cube.py=py;
  int j=0;
  for(int y=0;y<3;++y) {
    for(int x=0;x<3;++x) {
      color c = getAverageColorInSquare(px+x*SQUARE_SIZE,py+y*SQUARE_SIZE);
      cube.colors[j++]=getNearestCubeColorTo(c);
    }
  }
}

int getNearestCubeColorTo(color c) {
  float d = Integer.MAX_VALUE;
  int best=0;
  for(int i=0;i<list.length;++i) {
    float diff = colorDifference(c,list[i]);
    if(d>diff) {
      d=diff;
      best=i;
    }
  }
  return best;
}


float colorDifference(color a,color b) {  
  float dr = red(a)-red(b);
  float dg = green(a)-green(b);
  float db = blue(a)-blue(b);
  
  return sq(dr) + sq(dg) + sq(db);
}


color rgb2hsv(color a) {
  float r = red(a)/255.0;
  float g = green(a)/255.0;
  float b = blue(a)/255.0;

  float cmax = Math.max(r,Math.max(g,b));
  float cmin = Math.min(r,Math.min(g,b));
  float delta = cmax-cmin;
  
  float h=0;
  if(delta!=0) {
    if(cmax==r) h = ((g-b)/delta % 6) *60;
    if(cmax==g) h = ((b-r)/delta + 2) *60;
    if(cmax==b) h = ((r-g)/delta + 4) *60;
  }
  
  float s = (cmax==0 ? 0 : delta/cmax);
  
  float v = cmax;
  
  return color(h,s * 100.0,v * 100.0);
}


color getAverageColorInSquare(int px,int py) {
  float r=0;
  float g=0;
  float b=0;
  
  for(int y=0;y<SQUARE_SIZE;++y) {
    for(int x=0;x<SQUARE_SIZE;++x) {
      color c = getColorAt(px+x,py+y);
      r+=red(c);
      g+=green(c);
      b+=blue(c);
    }
  }
  float v = SQUARE_SIZE*SQUARE_SIZE;
  
  return color(r/v,g/v,b/v);
}


color getColorAt(int px,int py) {
  return img.pixels[img.width*py+px];
}


void resizeImageToFillWindow() {
  img.resize(width,width);
}


void cropImageToSquare() {
  if(img.height<img.width) {
    img = img.get(0,0,img.height, img.height);
  } else {
    img = img.get(0,0,img.width, img.width);
  }
}


void draw() {
  background(255,255,255);
  //drawRandomColors();
  if(ready) {
    drawAllCubes();
  }
}

void drawAllCubes() {
  for( Cube c : cubeList ) c.draw();
}

void drawRandomColors() {
  int j=0;
  for(int y=0;y<3;++y) {
    for(int x=0;x<3;++x) {
      fill(list[j++%list.length]);
      stroke(0,0,0);
      rect(x*SQUARE_SIZE,y*SQUARE_SIZE,SQUARE_SIZE,SQUARE_SIZE);
    }
  }
}
