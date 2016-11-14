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

String fearSearchString = "designmuseum";
String loveSearchString = "arupgroup";

int NUM_MESSAGES = 10;  // number of big particles associated with messages
int NUM_HASHTAGS = 2;  // number of invisible particles associated with hashtags, acting as attractors
int NUM_DOTS = 1200; // number of small particles used to visualise the force field
int MESSAGE_SIZE = 100; // pixel size of floating messages

//boolean showFullscreen = true;   // switch to turn fullscreen on or off
boolean demo = true;         // switch to use signals from Synapse RF100 physical devices (false) or demo signals (true)
boolean debug = false;       // switch to display debug information on the screen 
boolean showLabels = true;  // switch to display particle labels
boolean doReset = true;      // switch to enable reset
boolean showLogo = false;    // show logo

float reset_time = 20;  // update time in seconds for reset - at reset time a central attractor is created
float smooth_time = 2;  // smoothing time in seconds - actuates an attraction behaviour if proximity is detected

color bgcol = color(0, 0, 0);       // background colour
color lcol = color(200, 200, 255);  // line colour
color tcol = color(50, 50, 120);    // people colour
color rcol = color(90, 50, 10);     // places colour

VerletPhysics2D physics;

PImage logo;

ArrayList people;
ArrayList places;
ArrayList attractors_people;
ArrayList attractors_places;

int[][] signal;

PFont font;
PFont fontsmall;
PFont fontextrasmall;

String peopleFile = "people.csv"; // edit this file inside the data folder to name and colour the people particles
String placesFile = "places.csv"; // edit this file inside the data folder to name and locate the places particles

Serial myPort;
String inString;  // input string from serial port 
int lf = 10;      // ASCII linefeed
float current_time;
float previous_time;
float current_smooth_time;
float previous_smooth_time;

int time = 0;

Vec2D mousePos;
AttractionBehavior mouseAttractor;
AttractionBehavior centreAttractor;

Twitter twitter;
List<Status> fear_tweets;
List<Status> love_tweets;
List<Status> home_tweets;
ArrayList<PImage> fear_pictures = new ArrayList();
ArrayList<PImage> love_pictures = new ArrayList();
ArrayList<PImage> home_pictures = new ArrayList();
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

  // physics stuff
  initPhysicsTest();

  signal = new int[places.size()][people.size()];

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
  smooth();

  // create the floating dots
  for (int i=0; i<NUM_DOTS; i++) {
    addDot(width/2, height/2);
  }
  
  // populate tweet pictures list
  for (int i=0; i<NUM_MESSAGES;i++) {
    PImage img = createImage(100, 100, RGB);
    fear_pictures.add(img);
    love_pictures.add(img);
    home_pictures.add(img);

  }
  println(fear_pictures);
  
  getNewTweets();
  
}

void draw() {
  current_time = millis();
  current_smooth_time = millis();
  background(bgcol);
  
  tint(255, 255/4);  // display the Arup logo at 1/4 opacity
  //if (showLogo) image(logo, width/2-logo.width/2, height/2-logo.height/2);
  if (showLogo) image(logo, width/2-logo.width/2, height-logo.height-10);
  tint(255, 255);
  
  physics.update();    // update the toxiclibs particle system
  stroke(255, 255, 255);
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
    else if (j<(NUM_MESSAGES+NUM_HASHTAGS)) {
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
    if (j>(NUM_MESSAGES+NUM_HASHTAGS+NUM_DOTS)) j=0;
  }

  if (debug) text(current_time + " " + previous_time, 50, height - 50);

  if (demo) {
    // create random messages in demo mode to emulate proximity events
    long tag_n = int(random(people.size()));
    long reader_n = int(random(places.size()));
    ParticleMessage t = (ParticleMessage) people.get(int(tag_n));
    ParticleHashtag r = (ParticleHashtag) places.get(int(reader_n));
    inString=(t.label+","+r.label+","+random(20, 50)+"\n");
  }

  if (inString!=null)
  {
    // process the incoming message
    if (debug) print(" "+inString+" ");
    String[] p = splitTokens(inString, ",\n\r\t");
    if (debug) text("message: ["+p[0]+"] / place: ["+p[1]+"] / link quality: [" +p[2]+"]", 20, height-200);
    int q = ((PApplet.parseInt(p[2])));

    // update the 2D particle simulation
    long tag_n = findTag(people, p[0]);  
    long reader_n = findReader(places, p[1]);
    if (debug) print("tag: "+tag_n+" / reader: "+reader_n+" / link quality: " +q);
    if ((tag_n>=0) && (reader_n>=0)) {
      ParticleMessage t = (ParticleMessage) people.get(int(tag_n));
      ParticleHashtag r = (ParticleHashtag) places.get(int(reader_n));
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
              a.setStrength(10.0/lq);
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
      centreAttractor = new AttractionBehavior(new Vec2D(width/2, height/2), width, 20.0f);
      physics.addBehavior(centreAttractor);
      if (debug) println("reset");
    }
    getNewTweets();
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

  // draw simulation
  tint(255, 255); // opaque

  // draw particles
  int k=0;
  for (VerletParticle2D p : physics.particles) {
    
    fill(rcol);
    // draw hashtags
    if (p instanceof ParticleHashtag) {
      // we need to cast particle to be a ParticleHashtag in order to access its properties
      ParticleHashtag lp=(ParticleHashtag)p;
      
      fill(lp.col);
      //ellipse(p.x, p.y, 10, 10);
      if (showLabels) {
        textFont(font);
        text(lp.location, p.x-20, p.y-10);
        textFont(font);
      }
    }

    // draw messages
    if (p instanceof ParticleMessage) {
      // we need to cast particle to be a ParticleMessagein order to access its properties
      //if (debug) println(physics.particles.get(k).distanceTo(physics.particles.get(NUM_MESSAGES+NUM_HASHTAGS)));
      ParticleMessage lp=(ParticleMessage)p;
      //float dist = physics.particles.get(k).distanceTo(physics.particles.get(NUM_MESSAGES+NUM_HASHTAGS+1));
      float dist = physics.particles.get(k).distanceTo(physics.particles.get(0));
      lp.setColour(color(255-255*dist/width,255*dist/width,255-255*dist/width));
      //lp.setColour(color(dist,0,dist));
      fill(lp.col);
      Vec2D v = p.getVelocity();
      tint(255, 50);
      //ellipse(p.x, p.y, 50, 50);
      tint(255, 255);
      if (showLabels)
      {
        //println(lp.id);
        textFont(fontextrasmall);
        Status messageStatus = fear_tweets.get(lp.id);
        String what = "";
        if (lp.id<NUM_MESSAGES) {
          messageStatus = fear_tweets.get(lp.id);
          what = "fear";
          fill(fear_color);
        }
        if (lp.id>=NUM_MESSAGES) {
          messageStatus = love_tweets.get(lp.id);
          what = "love";
          fill(love_color);
        }
        drawTweet(messageStatus, what, lp.id, p.x-20, p.y+5);
        fill(255,255,255);
        
        //text(str(lp.id)+"-"+str(k), p.x-20, p.y+5);
        textFont(font);
      }
      if (debug) {
        fill(255,0,0);
        textFont(fontsmall);
        //text(str(lp.id), p.x, p.y-2);
        text(str(dist), p.x, p.y-2);
        textFont(font);
      }
    }
    fill(255,255,255);
    k++;
  }
  
  if (k>(NUM_MESSAGES+NUM_HASHTAGS+NUM_DOTS)) k=0;
}

void initPhysicsTest() {
  physics=new VerletPhysics2D();
  physics.setDrag(0.05);
  physics.setWorldBounds(new Rect(0, 0, width, height));
  getPlaces(placesFile);
  getPeople(peopleFile);
}

void serialEvent(Serial p) { 
  inString = p.readString();
}

void mousePressed() {
  mousePos = new Vec2D(mouseX, mouseY);
  // create a new positive attraction force field around the mouse position
  mouseAttractor = new AttractionBehavior(mousePos, 250, 0.9f);
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

//boolean sketchFullScreen() {
//  return fullScreen;
//}