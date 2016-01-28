# Playrr

Open source audio playrr!  
No illegal technical tricks, so completely legal!  
No audio adds :D  


<!--
![](http://matthijskamstra.github.io/playrr/images/playrr_osx.png)
-->

![Playrr OSX](images/screenshot_osx.png)

It's very **beta**, which means that its fare from a bug-free product.  
Use it with this in mind (and help or create an issue). 


## Uses:

- [Haxe](http://www.haxe.org) (Haxe is awesome! One codebase, many targets, no platform specific code.)
- Spotify artist search and most popular tracks
- Youtube for the music (videos)


## Limitations

- Artist you are looking for must be on Spotify.
- Top track from that artist needs to be on Youtube.



## Install OSX

To make the install of Playrr smoother, I need a license from Apple.  
Don't have that (yet), so we need to make sure your highly tuned OSX allows us to install the app. Follow the instructions below (till the last point) 

1. Download [`Playrr.app.zip`](https://github.com/MatthijsKamstra/playrr/raw/master/download/Playrr.app.zip) and unzip
2. Open "System preferences" [screenshot](#install1)
	- Click on "Security & Privacy" 
3. Choose tab "General" [screenshot](#install2)
	- Click on lock at the bottom left: "Click the lock to make changes"
	- Change "Allow apps downloaded from" to "Anywhere"
	- Keep this window open
4. Now open `Playrr.app` you just unzipped
5. Kablammmm you are a brand new `Playrr` user, thank you!
6. **Important:** Go back to the "Security & Privacy" 
	- **Change "Allow apps downloaded from" back to "Mac App Store and identified developers" or stricter.**

-----

<a name="install1"></a>
![](images/osx_install1.png)

<a name="install2"></a>
![](images/osx_install2.png)



## With a little help

[Haxe](http://www.haxe.org) obviously!

##### Haxelibs

- https://github.com/clemos/haxe-js-kit
- https://github.com/fponticelli/hxelectron

##### Electron

- http://electron.atom.io/
- https://github.com/maxogden/electron-packager