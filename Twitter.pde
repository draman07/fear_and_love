void getNewTweets()
{
  try
  {
      // try to get tweets here
      Query fearQuery = new Query(fearSearchString);
      fearQuery.setCount(30);
      Query loveQuery = new Query(loveSearchString);
      loveQuery.setCount(30);
      QueryResult fearResult = twitter.search(fearQuery);
      QueryResult loveResult = twitter.search(loveQuery);
      fear_tweets = fearResult.getTweets();
      love_tweets = loveResult.getTweets();
      println("Got new tweets");
      println(fear_pictures);
      // put tweets first image into list of pictures / fear
      for (int i=0; i<fear_tweets.size();i++) {
        Status fearStatus = fear_tweets.get(i);
        MediaEntity[] media_entity = fearStatus.getMediaEntities();
        if (media_entity.length>0) {
          MediaEntity media = media_entity[0];
          String imageURL = media.getMediaURL();
          PImage img = loadImage(imageURL); 
          //fear_pictures.set(i,img);
          //if (fear_pictures.size()>i) {
          //  fear_pictures.set(i,img);
          //} else {
          //  fear_pictures.add(i,img);
          //}
        }
      }
  }
  catch (TwitterException te)
  {
      // deal with the case where we can't get them here
      System.out.println("Failed to search tweets: " + te.getMessage());
      //System.exit(-1);
  }


}

void refreshTweets()
{
    while (true)
    {
        getNewTweets();

        println("Updated Tweets");

        delay(int(reset_time*1000));
    }
}

void drawTweet(Status thisStatus, float x, float y)
{
  MediaEntity[] media_entity = thisStatus.getMediaEntities();
  if (media_entity.length>0) {
    //println(fear_media.Size);
    
    //MediaEntity media = media_entity[0];
    //String imageURL = media.getMediaURL();
    //PImage img = loadImage(imageURL); 
    //int w = media.getSizes().get(1).getWidth();
    //int h = media.getSizes().get(1).getHeight();
    //image(img, x, y, w/4, h/4);
    text(thisStatus.getText(), x-75, y-75, 150, 150);
    //println("Array: "+fear_media);
    //println(fear_media.length);
  } else {
    text(thisStatus.getText(), x-75, y-75, 150, 150);
  }
}

/*
void getNewTweets()
{
    try 
    {
        Query query = new Query(searchString);

        QueryResult result = twitter.search(query);

        tweets = result.getTweets();
    } 
    catch (TwitterException te) 
    {
        System.out.println("Failed to search tweets: " + te.getMessage());
        System.exit(-1);
    } 
    println(tweets.size());
    
    
    for (int i = 0; i < tweets.size(); i++) {
      Status t = (Status) tweets.get(i);
      String user = t.getUser().getName();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet by " + user + " at " + d + ": " + msg);

      tWords.add("@" + user + ": " + msg);
 
      
      if (i<numlights) {
           tWords.set(i, "@" + user + ": " + msg);
           println(tWords.get(i));
      }
     
      //Break the tweet into words
      //String[] input = msg.split(" ");
      //for (int j = 0;  j < input.length; j++) {
       //Put each word into the words ArrayList
       //words.add(input[j]);
      //}
    };
    
}

void refreshTweets()
{
    while (true)
    {
        getNewTweets();

        println("Updated Tweets"); 
        
         println();
    print( next+" ");

//    String testWords = tWords.get(0);
//    if( testWords.equals(lights[0].text) ) { testWords = tWords.get(next); }

//    loadTL(next, testWords);

    next++;
    if( next == numlights ) { next = 0; }

        delay(10000);
        
        
        
    }
}
*/