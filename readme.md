Grab Magic
==========

The best designed experiences make technology invisible and give people superpowers (what I call The Superman Effect). This is what I just made over the course of less a day in Cannes for #mipboathack 

You reach out to your TV and grab the current screen in your hand then transfer it to your phone by tapping its screen. Magic! :)

Videos
------

Here's an in-progress video from the boat, shot during the hackday: 
http://www.youtube.com/watch?v=eYveEdhTgBs&list=UUVVB1n-Gzhx85jnTzJCfEYQ&index=1&feature=plcp

…And my presentation to the judges at MipCube:
http://www.youtube.com/watch?feature=player_detailpage&v=VoykeSHTvSw#t=198s

…And my final presentation at the MipTV keynote after winning:

(Louisa's intro) http://www.youtube.com/watch?v=Y7UbOIKjd8U&feature=youtu.be&hd=1&t=56m3s 

(Direct link to my talk) http://www.youtube.com/watch?v=Y7UbOIKjd8U&feature=youtu.be&hd=1&t=58m22s

The Source
----------

Is straight from the hackday… it may not be the prettiest or best optimised - remember, it's a hack :)  

I just cleaned up the repository a bit and added the Processing libraries. I will make an effort to update these instructions in the coming days with links, etc.

To get the whole thing running you will need to install the following and have an XBox Kinect connected to your Mac (you'll need the Kinect with the power supply):

* Processing
* OpenNI
* NITE
* SimpleOpenNI

Copy the libraries folder to your ~/Processing/libraries folder.

To compile the iPhone client, you'll need the latest version of Xcode.

Interesting tid-bits
--------------------

Processing plays back video badly by default. The hack shows how to use the GLGraphics library with the GSVideo library to play back video with good performance via OpenGL (I was getting 1-3fps with the built-in video classes and 30fps with this.)

Also, the example hack shows you how to use WebSockets from both Processing  and a native iOS app.

Hope you find the code useful.

–Aral


