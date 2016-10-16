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