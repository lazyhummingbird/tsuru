//number n of vertices in the polygon (on a circle) we're weaving on 
int vertices = 100;

//array counting the times each vertex has been hit (punishes recurrence to increase diversity)
int[] vcount = new int[vertices];

//an array of the x and y values of the vertices
float[] points = new float[vertices*3];

//number of lines to draw (can calculate the length of your thread and divide)
int weaves = 500;

int diversity = 100;

//a history of the best lines between those vertices for rendering a pic
int[] pattern = new int[weaves];

//which step in the pattern we're determining (which line we're saving next into pattern[])
int step = 0;


//index of the current and last peg numbers, used in drawing lines between pegs
//these act as indices to refer to the x and y values in the points[] array
//they also make it easy to generate instructions for our numbered pegs
int endpoint = 0;
int origin;

//record the best line to draw next
int bestpoint = 0;
float highscore = 0; 

PImage pic;

void setup(){
  size(800,800);
  stroke(0);
  strokeWeight(1);
  background(255);

  //get image ready for use
  pic = loadImage("test.png");
  //image(pic,0,0);

  //draw and store all pegs
  for (int i = 0; i < vertices; i++) {
    float sx = width/2 + cos((TWO_PI/vertices)*i) * (width/2-10);
    float sy = height/2 + sin((TWO_PI/vertices)*i) * (height/2-10);
    ellipse(sx,sy,10,10);
    points[i*2] = sx;
    points[i*2+1] = sy;
  }
 
}


void draw(){
  
}

void keyReleased() {
  if (key == TAB) {
    step = 0;
    
    //auto-weave however many times we've dictated
    for (int weavecount=0; weavecount < weaves; weavecount++){
      
      //turn the best endpoint from the last round into the new origin
      origin = bestpoint;
      //println("New origin is peg " + origin);
      
      highscore = -100000000;
      bestpoint = origin + 1;
      for (int i=0; i < vertices; i++){
        
        endpoint = i;
        
        if (endpoint != origin){
        
             //calculate the darkness value harvested by this line
             //scans from left to right always (so we check if the current peg's x starts on the left)
             //if this line has a higher dscore than the highscore, it's our new best
             if (points[endpoint*2]<points[origin*2]){
               nod(points[endpoint*2], points[endpoint*2+1], points[origin*2], points[origin*2+1]);
             } else {
               nod(points[origin*2], points[origin*2+1], points[endpoint*2], points[endpoint*2+1]);
             }         
         }
      }
    
    //move on to the next line and draw this one
    println("Best line detected (from peg " + origin + " to peg " + bestpoint + "), dscore: " + highscore);
    vcount[bestpoint] = vcount[bestpoint]+1;
    pattern[step] = bestpoint;
    step ++;
    line(points[bestpoint*2],points[bestpoint*2+1],points[origin*2],points[origin*2+1]);
    }
  }
  
  for (int i = 0; i< vertices; i++){
    print(vcount[i]+ ", ");
  }
}

//adds up all the darkness values (sum RGB) of pixels from our pic that fall on that line and print

void nod(float x1, float y1, float x2, float y2) {
  

    //get the slope
    float m = ((y2-y1)/(x2-x1));
    
    //get intercept
    float s = y1-(m*x1);

      //scan the integerized x values of the whole line segment to find correspondying y values, and sum up those pixels
      float dscore = 0;
      pic.loadPixels();
      
     //println("For peg " + endpoint + ", the equation is y = m (" + m + ") * x + b (" + s + ")");
      
      for (int scanx = floor(x1); scanx < floor(x2); scanx++){
        //using point slope to find what the y value of a pixel is given an x and the line it falls on
        int scany = floor(m*scanx+s);
        
        //println("x,y:" + scanx + ", " + scany);
        
          int pixindex = scany*800+scanx;
          
          if (pixindex > -1 && pixindex < 800*800){
            //use those coordinates to test a single pixel on the line
            float r = red(pic.pixels[pixindex]);
            float g = green(pic.pixels[pixindex]);
            float b = blue(pic.pixels[pixindex]);
            
            //the darker the pixel, the more it adds to the dscore
            dscore = dscore + (765-(r+g+b));
          }
          //penalize a line's dscore for hitting pegs that are too common
            //to do this we make a histogram of hit pegs and subtract from the dscore of lines near them
          dscore = dscore - vcount[endpoint]*diversity;
          if (endpoint>0) {dscore = dscore - vcount[endpoint-1]*diversity/2;}
          if (endpoint<vertices-1) {dscore = dscore - vcount[endpoint+1]*diversity/2;}

        }
        
      //if this is the best line so far
      if (dscore > highscore){
        //make sure we haven't drawn it yet
        boolean redalert = false;
        for (int i = 0; i<step; i++) {
          //testing pairs against the current pair -- you gotta flip em like dad said
            if (origin == pattern[i] && endpoint == pattern[i+1]){
            redalert = true;
          }
          if (i>0 && origin == pattern[i] && endpoint == pattern[i-1]){
            redalert = true;
          }
          if (endpoint == origin){
            redalert = true;
          }
        }
        
        if (redalert == false){
          highscore = dscore;
          //keep committing the best line we've found to our weave memory
          bestpoint = endpoint;
        }
      }
}
