// Love and Fear 2016  - an interactive visualisation for the Design Museum
// 2016-10-16 francesco.anselmo@arup.com
// http://lightlab.arup.com

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import processing.serial.*;
import java.util.List;
import java.util.Iterator;
import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;



//String fearSearchString = "source:aruplightlab fear";
//String loveSearchString = "source:aruplightlab love";

//String fearSearchString = "fear";
//String loveSearchString = "%23love";

int NUM_TWEETS = 800;  // number of big particles associated with messages
int MAX_TWEETS = 80;  // number of big particles associated with messages
int NUM_HASHTAGS = 2;  // number of invisible particles associated with hashtags, acting as attractors
int NUM_DOTS = 300; // number of small particles used to visualise the force field
//int MESSAGE_SIZE = 150; // pixel size of floating messages
//int MESSAGE_SCALE = 7;
int MESSAGE_W = 200;
int MESSAGE_H = 150;

int tweets_n = 0;

//boolean showFullscreen = true;   // switch to turn fullscreen on or off
boolean demo = true;         // switch to use signals from Synapse RF100 physical devices (false) or demo signals (true)
boolean debug = false;       // switch to display debug information on the screen 
boolean showLabels = true;  // switch to display particle labels
boolean doReset = true;      // switch to enable reset
boolean showLogo = false;    // show logo

float reset_time = 20;  // update time in seconds for reset - at reset time a central attractor is created
float smooth_time = 5;  // smoothing time in seconds - actuates an attraction behaviour if proximity is detected
float reinit_time = 133; 
float tweets_time = 59;

color bgcol = color(0, 0, 0);       // background colour
color lcol = color(200, 200, 255);  // line colour
color tcol = color(255,255,255);    // tweets colour
color rcol = color(90, 50, 10);     // hashtags colour

VerletPhysics2D physics;

PImage logo;

ArrayList tweets;
ArrayList hashtags;
ArrayList attractors_tweets;
ArrayList attractors_hashtags;
ArrayList springs_tweets;


int[][] signal;

PFont font;
PFont fontsmall;
PFont fontextrasmall;

//String peopleFile = "people.csv"; // edit this file inside the data folder to name and colour the people particles
//String placesFile = "places.csv"; // edit this file inside the data folder to name and locate the places particles

String hashtagsFile = "hashtags.csv";

Serial myPort;
String inString;  // input string from serial port 
int lf = 10;      // ASCII linefeed
float current_time;
float previous_time;
float current_smooth_time;
float previous_smooth_time;
float current_tweets_time;
float previous_tweets_time;
float current_reinit_time;
float previous_reinit_time;


int time = 0;

Vec2D mousePos;
AttractionBehavior mouseAttractor;
AttractionBehavior centreAttractor;
AttractionBehavior Attractor1;
AttractionBehavior Attractor2;
AttractionBehavior Attractor3;
AttractionBehavior Attractor4;

Twitter twitter;
List<Status> fear_tweets;
List<Status> love_tweets;
List<Status> home_tweets;
List<Status> all_tweets;

ArrayList<String> all_hashtags = new ArrayList(); 
ArrayList<String> other_hashtags = new ArrayList(); 


ArrayList<PImage> fear_pictures = new ArrayList();
ArrayList<PImage> love_pictures = new ArrayList();
ArrayList<PImage> home_pictures = new ArrayList();
ArrayList<PImage> tweets_pictures = new ArrayList();
int currentFearTweet;
int currentLoveTweet;
int currentHomeTweet;
//ArrayList<String> tWords = new ArrayList();

color fear_color = color(0,255,0);
color love_color = color(255,0,255);
color home_color = color(255,255,255);

String imgTemp = null;

void setup() {
  //size(1280, 1024);
  fullScreen();
  noCursor();
  
  //if (showFullscreen) {fullScreen();}
  //else {size(displayWidth, displayHeight);}
  logo = loadImage("ArupLogo2010_w.png");
  
  // twitter stuff
  ConfigurationBuilder cb = new ConfigurationBuilder();
  /*
  cb.setOAuthConsumerKey("tjkuTdwPXGZ3iSEFvqiQonVtE");
  cb.setOAuthConsumerSecret("jexA6felupzws9rQKUHmFClr2POdn7BDQ0Ay87S8G6bviEgKhd");
  cb.setOAuthAccessToken("2882966836-0Zp60El0zAkzHUIq132dqvJKqujRtvEBjbPOHWS");
  cb.setOAuthAccessTokenSecret("VB9sxqQUKqx4C5Fy7KdSVewGi5wJcW1TVZov7Sms8UuQi");
  */
  
  cb.setOAuthConsumerKey("8gwWMe6zG63lqmwYZaRUibf0a");
  cb.setOAuthConsumerSecret("Ibnnj7wjAwgiltf903iPJDiMxSzeREmCQURN7XnCTN9D1s96VV");
  cb.setOAuthAccessToken("793523469535350784-uYIBol8DMbNWdww3rRxs6oPNQ7dvh7u");
  cb.setOAuthAccessTokenSecret("cVzj7Klp8xCJphANaDO7PZoosi44UOUJjqHnNy9QfYiqr");
  
  
  TwitterFactory tf = new TwitterFactory(cb.build());
  twitter = tf.getInstance();
  
  currentFearTweet = 0;
  currentLoveTweet = 0;
  //thread("refreshTweets");

  // populate tweet pictures list
  for (int i=0; i<NUM_TWEETS;i++) {
    PImage img = createImage(100, 100, RGB);
    fear_pictures.add(img);
    love_pictures.add(img);
    home_pictures.add(img);
    tweets_pictures.add(img);
    //HashtagEntity h = new HashtagEntity();
    all_hashtags.add("");
    other_hashtags.add("");
  }
  //println(tweets_pictures.size());


  // physics stuff
  initPhysicsTest();

  signal = new int[hashtags.size()][tweets.size()];

  font = loadFont("SansSerif-48.vlw");
  fontsmall = loadFont("SansSerif-24.vlw");
  fontextrasmall = loadFont("SansSerif-12.vlw");
  textFont(font);

  // the Synapse system is not used for this installation, but keeping some legacy code in here just in case ...
  // if not in demo mode, the Synapse USB module is connected using the serial library
  if (!demo) {
    println(Serial.list()); // list all the available serial ports 
    //myPort = new Serial(this, Serial.list()[0], 9600); // comment out this line of code to take the first port in the serial list
    myPort = new Serial(this, "/dev/cu.SLAB_USBtoUART", 9600); // change the port to the one the Synapse USB module is connected to
    myPort.bufferUntil(lf);
  }

  current_time = millis();
  current_smooth_time = millis();
  smooth(3);

  // create the floating dots
  for (int i=0; i<NUM_DOTS; i++) {
    addDot(width/2, height/2);
  }
  
  
  getNewTweets();
  thread("refreshTweets");

  
}

void draw() {
  current_time = millis();
  current_smooth_time = millis();
  current_tweets_time = millis();
  current_reinit_time = millis();
  background(bgcol);
  
  tint(255, 255/4);  // display the Arup logo at 1/4 opacity
  //if (showLogo) image(logo, width/2-logo.width/2, height/2-logo.height/2);
  if (showLogo) image(logo, width/2-logo.width/2, height-logo.height-10);
  tint(255, 255);
  
  physics.update();    // update the toxiclibs particle system

  // draw springs
  for (VerletSpring2D s : physics.springs) {
    //print(s);
    stroke(255,255,255);
    strokeWeight(1);
    line(s.a.x,s.a.y,s.b.x,s.b.y);
  }

  //stroke(255, 255, 255);
  noStroke();

  // draw particles
  int j=0;
  for (VerletParticle2D p : physics.particles) {
    //ParticleMessage lp=(ParticleMessage)p;
    if (j<NUM_HASHTAGS) {
      // particles are messages, hashtags and particles dust
      // don't draw hashtags yet
      //fill(255,0,0);
      //ellipse(p.x, p.y, 30, 30);
    } 
    else if (j<(NUM_TWEETS+NUM_HASHTAGS)) {
      // don't draw messages yet
      //fill(0,0,255);
      //ellipse(p.x, p.y, 10, 10);
    } 
    else {
      // only draw small particles, all in white
      fill(255,255,255);
      ellipse(p.x, p.y, 4, 4);
    }
    j++;
    if (j>(NUM_TWEETS+NUM_HASHTAGS+NUM_DOTS)) j=0;
  }

  if (debug) text(current_time + " " + previous_time, 50, height - 50);

  if (demo) {
    // create random messages in demo mode to emulate proximity events
    long tag_n = int(random(tweets.size()));
    long reader_n = int(random(hashtags.size()));
    ParticleMessage t = (ParticleMessage) tweets.get(int(tag_n));
    ParticleHashtag r = (ParticleHashtag) hashtags.get(int(reader_n));
    inString=(t.label+","+r.label+","+random(1, 10)+"\n");
  }

  if (inString!=null)
  {
    // process the incoming message
    if (debug) print(" "+inString+" ");
    String[] p = splitTokens(inString, ",\n\r\t");
    if (debug) text("message: ["+p[0]+"] / place: ["+p[1]+"] / link quality: [" +p[2]+"]", 20, height-200);
    int q = ((PApplet.parseInt(p[2])));
    //println(q);

    // update the 2D particle simulation
    long tag_n = findTag(tweets, p[0]);  
    long reader_n = findReader(hashtags, p[1]);
    if (debug) print("tag: "+tag_n+" / reader: "+reader_n+" / link quality: " +q);
    if ((tag_n>=0) && (reader_n>=0)) {
      ParticleMessage t = (ParticleMessage) tweets.get(int(tag_n));
      ParticleHashtag r = (ParticleHashtag) hashtags.get(int(reader_n));
      t.setSignal(r.id, q);
      float lq = float(q);
      if (current_smooth_time > (previous_smooth_time + smooth_time*1000)) {
        if (lq<30) {
          if (debug) println("update");
          if (debug) print("attractor #");
          if (debug) println(reader_n);
          int ii = 0;
          for (Iterator i=physics.behaviors.iterator(); i.hasNext();) {
            AttractionBehavior a=(AttractionBehavior)i.next();
            if (ii==(reader_n)) {
              float strength = 2.0/lq;
              println(strength);
              a.setStrength(-strength);
              if (debug) println(a.getStrength());
            }
            ii++;
          }
          if (debug) println("["+lq+"] ["+p[2]+"]");
        }
        else {

          t.col=color(255, 255, 255);
          if (debug) print("attractor #");
          if (debug) println(reader_n);
          int ii = 0;
          for (Iterator i=physics.behaviors.iterator(); i.hasNext();) {
            AttractionBehavior a=(AttractionBehavior)i.next();
            if (ii==(reader_n)) {
              a.setStrength(0);
              if (debug) println(a.getStrength());
            }
            ii++;
          }

        }
        previous_smooth_time = current_smooth_time;
      }
      if (debug) text("tag: "+t.label+" / reader: "+r.location+" / distance: " +q, 20, height-100);
    }
  }
  
  if (current_time > (previous_time + reset_time*1000)) {

    if (doReset) {
      centreAttractor = new AttractionBehavior(new Vec2D(width/3, height/3), width, 10.0f);
      Attractor1 = new AttractionBehavior(new Vec2D(width-width/10, height-height/10), width, 1.0f);
      Attractor2 = new AttractionBehavior(new Vec2D(width/10, height/10), width, 1.0f);
      Attractor3 = new AttractionBehavior(new Vec2D(width/10, height-height/10), width, 1.0f);
      Attractor4 = new AttractionBehavior(new Vec2D(width-width/10, height/10), width, 1.0f);

      physics.addBehavior(centreAttractor);
      physics.addBehavior(Attractor1);
      physics.addBehavior(Attractor2);
      physics.addBehavior(Attractor3);
      physics.addBehavior(Attractor4);
      //initPhysicsTest();
      if (debug) println("reset");
    }
    //getNewTweets();
    previous_time = current_time;
  } 
  else {
    if (millis()>time) {
      time = millis() + 10000;
    } 
    else {
      physics.removeBehavior(centreAttractor);
    }
  }
  
  //if (current_tweets_time > (previous_tweets_time + tweets_time*1000)) {
  //  getNewTweets();
  //  previous_tweets_time = current_tweets_time;
  //  println("particles number = "+physics.particles.size());
  //}

  if (current_reinit_time > (previous_reinit_time + reinit_time*1000)) {
      println("reinit");
      initPhysicsTest();
      previous_reinit_time = current_reinit_time;
  }

  

  // draw simulation
  tint(255, 255); // opaque

  // draw particles
  int k=0;
  //for (VerletParticle2D p : physics.particles) {
  for(int i=physics.particles.size()-1; i>=0; i--){
    VerletParticle2D p=physics.particles.get(i);
    float t_scale = 1.8/(i/0.8+0.001)+0.3;
    //float t_scale = 0.8;
    //float t_scale = 1-i*i/4/physics.particles.size();
    //fill(rcol);

    // draw messages
    if (p instanceof ParticleMessage) {
      // we need to cast particle to be a ParticleMessagein order to access its properties
      //if (debug) println(physics.particles.get(k).distanceTo(physics.particles.get(NUM_TWEETS+NUM_HASHTAGS)));
      ParticleMessage lp=(ParticleMessage)p;
      //float dist = physics.particles.get(k).distanceTo(physics.particles.get(NUM_TWEETS+NUM_HASHTAGS+1));
      float dist = physics.particles.get(k).distanceTo(physics.particles.get(0));
      //lp.setColour(color(red(tcol)-red(tcol)*dist/width,green(tcol)*dist/width,blue(tcol)-blue(tcol)*dist/width));
      //lp.setColour(color(dist,0,dist));
      lp.setColour(tcol);
      fill(lp.col);
      Vec2D v = p.getVelocity();
      tint(255, 50);
      //ellipse(p.x, p.y, 50, 50);
      tint(255, 255);
      if (showLabels)
      {
        //println(lp.id);
        textFont(fontextrasmall);
        //Status messageStatus = fear_tweets.get(lp.id);
        //String what = "";
        //if (lp.id<NUM_TWEETS) {
        //  messageStatus = fear_tweets.get(lp.id);
        //  what = "fear";
        //  fill(fear_color);
        //}
        //if (lp.id>=NUM_TWEETS) {
        //  messageStatus = love_tweets.get(lp.id);
        //  what = "love";
        //  fill(love_color);
        //}
        try {
        Status messageStatus = all_tweets.get(lp.id);
        if (lp.id<MAX_TWEETS) drawTweet(messageStatus, "all", lp.id, p.x, p.y,t_scale);
        //println(lp.id);
        fill(255,255,255);
        
        //text(str(lp.id)+"-"+str(k), p.x-20, p.y+5);
        textFont(font);
        } 
        catch (IndexOutOfBoundsException e) {
        }
      }
      if (debug) {
        fill(255,0,0);
        textFont(fontsmall);
        //text(str(lp.id), p.x, p.y-2);
        text(str(dist), p.x, p.y-2);
        textFont(font);
      }
    }
    k++;
  }
  for (VerletParticle2D p : physics.particles) {
    // draw hashtags
    if (p instanceof ParticleHashtag) {
      // we need to cast particle to be a ParticleHashtag in order to access its properties
      ParticleHashtag lp=(ParticleHashtag)p;
      
      fill(lp.col);
      //ellipse(p.x, p.y, 10, 10);
      if (showLabels) {
        textFont(font);
        //text(lp.location, p.x-MESSAGE_SIZE/2, p.y-10);
        textFont(font);
      }
    }

    fill(255,255,255);
    
  }
  
  


  //k++;
  if (k>(NUM_TWEETS+NUM_HASHTAGS+NUM_DOTS)) k=0;
}

void initPhysicsTest() {
  physics=new VerletPhysics2D();
  physics.setDrag(0.05);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  getHashtags(hashtagsFile);
  getTweets();
  println("particles number = "+physics.particles.size());
  if (physics.particles.size()<(NUM_DOTS+NUM_TWEETS)) {
      for (int i=0; i<NUM_DOTS; i++) {
      addDot(width/2, height/2);
      

    }
  println("particles number = "+physics.particles.size());

  }
}

void serialEvent(Serial p) { 
  inString = p.readString();
}

void mousePressed() {
  mousePos = new Vec2D(mouseX, mouseY);
  // create a new positive attraction force field around the mouse position
  mouseAttractor = new AttractionBehavior(mousePos, width/3, 3f);
  physics.addBehavior(mouseAttractor);
}

void mouseDragged() {
  // update mouse attraction focal point
  mousePos.set(mouseX, mouseY);
}

void mouseReleased() {
  // remove the mouse attraction when button has been released
  physics.removeBehavior(mouseAttractor);
}

void keyPressed() {
  if (key=='r') {
    // refresh Tweets
    getNewTweets();
    // reset the particle simulation
    initPhysicsTest();
    for (int i=0; i<NUM_DOTS; i++) {
      addDot(width/2, height/2);
    }
  }
  if (key=='l') {
    showLabels = !showLabels;
  }
  if (key=='q') {
    exit();
  }
}

void refreshTweets()
{
    while (true)
    {
        getNewTweets();

        println("Updated Tweets");
        println("particles number = "+physics.particles.size());
        delay(int(tweets_time*1000));
    }
}


//boolean sketchFullScreen() {
//  return fullScreen;
//}