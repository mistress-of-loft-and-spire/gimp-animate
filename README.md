# gimp-animate
A simple (and unfinished) helper tool for creating spritesheet animations in GIMP.

![gif](https://cloud.githubusercontent.com/assets/2915643/18808697/ba6873c2-8269-11e6-9935-74e8d1340ed9.gif)

##How?
This is an [AutoHotkey](https://autohotkey.com/) script that can load a spritesheet as an image file and display individual frames. The frame animation gets drawn as a small, cropped window on top and whenever the spritesheet is exported in GIMP the image is updated.

To run it you have to install AutoHotkey and open the script. It will show up in your taskbar.

##Why?
To make drawing and previewing sprite animations much less of a hassle.

Aka~ Why isn't there a plugin for this already?

##Todo
- [ ] Add easy way to select which frames to animate (maybe a small preview with a clickable grid to select frames)
- [ ] Automatically detect changes to grid size / animations frame -> get rid of the `Refresh` button
- [ ] Save animations as an ini-file besides the spritesheet image to make loading easier -> remember settings
- [ ] multiple tabs or `Add animation` button to quickly switch between animation previews?
- [ ] Make this an actual plugin for GIMP
