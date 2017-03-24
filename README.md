# gimp-animate
A simple (and unfinished) helper tool for creating spritesheet animations in GIMP.

![gif](https://cloud.githubusercontent.com/assets/2915643/18808697/ba6873c2-8269-11e6-9935-74e8d1340ed9.gif)

## How?
This is an [AutoHotkey](https://autohotkey.com/) script that can load a spritesheet image and display it as an animation.
The frames get drawn as a small, transparent window and whenever you change and export your spritesheet in GIMP, the animation is updated.

To run it you have to install AutoHotkey and open gimp-animate.ahk. It will show up in your taskbar.

## Why?
To make drawing and previewing sprite animations much less of a hassle.

Aka~ Why isn't there a plugin for this already?

## Todo
- [ ] Add easy way to select which frames to animate (maybe a small preview with a clickable grid to select frames)
- [ ] Automatically detect changes to grid size / animations frame -> get rid of the `Refresh` button
- [ ] Save animations as an ini-file besides the spritesheet image to make loading easier -> remember settings
- [ ] Multiple tabs or `Add animation` button to quickly switch between animation previews?
- [ ] Make this an actual plugin for GIMP

## nonlicense
```
This work is dedicated to the public domain under CC0. https://creativecommons.org/publicdomain/zero/1.0/  
All code of this project is licensed under the Unlicense. http://unlicense.org/UNLICENSE
 
You are free to use any of my code, art, writing, data, etc. in any way you like.  
A credit acknowledgment is appreciated but not necessary.
I'd love to hear from you if you use_remix any of this work: banach-tarski 📧 posteo.net
 
This dedication excludes any work not created by me, which is copyrighted to their respective creators. Including:
* Gdip
```
