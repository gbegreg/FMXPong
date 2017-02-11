# FMXPong
Pong 3D with Delphi and Firemonkey (Windows, Mac OS, Android, IOS)
This is an example of using Firemonkey in 3D with Delphi. This project is a clone of the video game Pong. It is a tutorial made for the site (in French) http://gbegreg.developpez.com/tutoriels/delphi/firemonkey/creation-jeu-3d/

The project was made with Delphi Seattle Pro with mobile plugin and it works with Delphi Berlin. You can compile and deploy it on Windows, Mac OS, Android and IOS.

Note : On Windows, Firemonkey required DirectX 11 and the shader model 5. Some users have encountred graphic rendering issues on old Intel HD Graphics GPU. If you have this problem, you can force the software rendering by adding the line 
   fmx.types.GlobalUseDXSoftware := True;
in the project file before the line Application.Initialize;

Grégory Bersegeay : http://www.gbesoft.fr

<img src="https://github.com/gbegreg/FMXPong/blob/master/capture.jpg">
