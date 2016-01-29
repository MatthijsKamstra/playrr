#How to build


So you ended up here... Must be a developer.  
This project is a Haxe project, uses NPM, Node.js, Javascript, jQuery, etc.

If you are not familiar with [Haxe](http://www.haxe.org), I suggest visiting something I wrote about [learning Haxe](http://matthijskamstra.github.io/haxenode/haxe/learn-haxe.html). 

So if you are a JavaScript/Node.js developer, you will have to learn a little about Haxe. But I am sure it's not that difficult and you will love it. Check out two books I wrote about the subject: [HaxeJs](http://matthijskamstra.github.io/haxejs) and [HaxeNode](http://matthijskamstra.github.io/haxenode)




# Install Haxe

There are more then one way to install Haxe ([read more about that](http://matthijskamstra.github.io/haxejs/haxe/installation.html)).

But I will only talk about the most obvious one:  
**Installer (original) from [haxe.org](http://www.haxe.org)**

You can find installers and binaries for Windows, OS X and Linux on <http://haxe.org/download>.

# Install Node.js

You can find installers and binaries for Windows, OS X and Linux on <https://nodejs.org>


# Install via haxelib

Once you installed Haxe, you will automatically have installed [haxelib](http://lib.haxe.org/).

Use haxelib to install: 

- `jQueryExtern`
- `js-kit`
- `hxnodejs`
- `electron`


Type in you terminal:

```
haxelib install jQueryExtern
haxelib git js-kit https://github.com/clemos/haxe-js-kit.git haxelib
haxelib install hxnodejs
haxelib install electron

```
# Separated Haxe and JavaScript

Because Haxe generates JavaScript, I have separated the two.


In the git repository you will find these folders

```
- assets
- bin (JavaSrript/Node.js source)
- download
- images 
- src (Haxe source)
- wiki
```

In the root folder you will find the `.hxml` files which are used for generating the `.js` files.

In the `src` folder you will find all stuff related to Haxe.

In the `bin` folder you will find the generated `.js` files.
(if you are only interested in generating this project, this is the folder you will be using)

Once you start building, there will be more folders but they are only for local use and are ignored in git.


# Update node modules

Once you installed Node.js, you will automatically have install NPM.

There are two `node_modules` that need to be updated!  
One we use for the Haxe source and one for building the Electron wrapper.


Type in you terminal:

```
# cd to the correct folder (change:'/path/to/playrr/folder')
cd /path/to/playrr/folder
# update `node_modules`
npm install
# update `node_modules` for electron build
cd bin
npm install
# bam! ready!
```

# Start building with Haxe

I use the NPM watch for automated build! 
And for the observant reader: yes update is included again (just copy the parts you need).

**Start npm-watch and open browser (debug)**

```
# cd to the correct folder (change:'/path/to/playrr/folder')
cd /path/to/playrr/folder
# update `node_modules`
npm install
# force to open a browser window
open http://localhost:3000
# start watching using NPM
npm run watch
# yeah!
```

# Build Electron

I have two build scripts

- debug.hxml
- release.hxml

there is not a lot different, but with debug you will have a debug window with your electron wrapper.

**Package your Electron app into OS-specific bundles (debug)**

```
# cd to the correct folder (change:'/path/to/playrr/folder')
cd /path/to/playrr/folder
# build a debug version 
haxe debug.hxml
# open bin folder
cd /path/to/playrr/folder/bin/
# update `node_modules`
npm install
# package your Electron app into OS-specific bundles 
electron-packager . Playrr[d]  --out /path/to/playrr/folder/out --all=true --version=0.36.4 --app-version=0.0.1 --overwrite --icon /path/to/playrr/folder/assets/playrr
# go!
```

The same build, but now without debug (aka release).

**Package your Electron app into OS-specific bundles (release)**

```
# cd to the correct folder (change:'/path/to/playrr/folder')
cd /path/to/playrr/folder
# build a debug version 
haxe release.hxml
# open bin folder
cd /path/to/playrr/folder/bin/
# update `node_modules`
npm install
# package your Electron app into OS-specific bundles 
electron-packager . Playrr  --out /path/to/playrr/folder/out --all=true --version=0.36.4 --app-version=0.0.1 --overwrite --icon /path/to/playrr/folder/assets/playrr
# go!
```
----

happy coding
