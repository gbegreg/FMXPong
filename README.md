# FMXPong
Pong 3D with Delphi and Firemonkey (Windows, Mac OS, Android, IOS)
This is an example of using Firemonkey in 3D with Delphi. This project is a clone of the video game Pong. It is a tutorial made for the site (in French) http://gbegreg.developpez.com/tutoriels/delphi/firemonkey/creation-jeu-3d/

The project was made with Delphi Seattle Pro with mobile plugin and it works with Delphi Berlin. You can compile and deploy it on Windows, Mac OS, Android and IOS.

<b>Note :</b> On Windows, Firemonkey required DirectX 11 and the shader model 5. Some users have encountred graphic rendering issues on old Intel HD Graphics GPU. If you have this problem, you can force the software rendering by adding the line 
   fmx.types.GlobalUseDXSoftware := True;
in the project file before the line Application.Initialize;

You can download the Android version on the <a href="https://play.google.com/store/apps/details?id=fr.gbesoft.FMXPong">Google Play Store</a>.
The Windows 32 bits version is available : <a href="http://www.gbesoft.fr/test/FMXPong.zip">http://www.gbesoft.fr/test/FMXPong.zip</a> and the 64 bits version : <a href="http://www.gbesoft.fr/test/FMXPong64.zip">http://www.gbesoft.fr/test/FMXPong64.zip</a>

See my other games with Delphi and Firemonkey :<br>
https://github.com/gbegreg/FMXCorridor<br>
https://github.com/gbegreg/demoParis<br>

A small open 3D world :
https://github.com/gbegreg/FMXISland

Grégory Bersegeay : http://www.gbesoft.fr

<img src="https://github.com/gbegreg/FMXPong/blob/master/capture.jpg">


<u>History :</u><br>
11/02/2017 : Add a new feature : control the racket with the gyroscope<br>
21/01/2017 : New interface, options menu and save/restore parameters<br>
