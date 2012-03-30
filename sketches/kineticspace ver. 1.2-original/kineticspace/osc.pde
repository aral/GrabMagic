void sendOSCEvent(int event, int person)
{
    /* ==============================================================================
        part to define OSC messages 
       ============================================================================== */
    switch(event)
    {
        case 1:
            myMessage = new OscMessage("/layer1/clip1/connect");        
        break; 

        case 2:
            myMessage = new OscMessage("/layer1/clip2/connect");        
        break;                   
        
        case 3:
            if (person == 0)
            {
                myMessage = new OscMessage("/layer2/clip2/connect");
            }
            else
            {
                myMessage = new OscMessage("/layer3/clip3/connect");
            }
        break;
        
        default: 
            myMessage = new OscMessage("/layer1/clip3/connect");        
        break;  
    }    

    int temp = 1;
    myMessage.add(temp);
    myBundle.add(myMessage);
    myMessage.clear();
    oscP5.send(myBundle, myRemoteLocation); 
    myBundle.clear();  
}
