
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             SETUP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



#SingleInstance, Force
#NoEnv
CoordMode, Mouse, Screen
SetBatchLines, -1

#Persistent
#SingleInstance force


IfExist, %A_ScriptDir%\gimp-2.8.exe
{
	Menu Tray, Icon, %A_ScriptDir%\gimp-2.8.exe
}
Menu, Tray, Tip, gimp-animate

#Include, %A_ScriptDir%\Gdip.ahk 



; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gimp-animate Error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

; Get the dimensions of the primary monitor
SysGet, MonitorPrimary, MonitorPrimary
SysGet, WA, MonitorWorkArea, %MonitorPrimary%
WAWidth := WARight-WALeft
WAHeight := WABottom-WATop



;Clear tray menu
Menu, Tray, NoStandard 
Menu, Tray, DeleteAll


Menu, Tray, add, Edit
Menu, Tray, add ; separator
Menu, Tray, add, Hide
Menu, Tray, add, Exit

Menu, Tray,Default , Edit

Goto, WaitForGodot

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             WAIT FOR ANIM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



WaitforGodot:
;NOW WAIT FOR ANIMATION PLUGIN TO START
Process, Wait, animation-play.exe
NewPID = %ErrorLevel%
if NewPID = 0
{
	;ERROR! D:
	Return
}

;CLOSE THE ANIMATION PLUGIN IMMEDIATELY
WinWait, ahk_pid %NewPID%
WinClose, ahk_pid %NewPID%

;GET THE FILE PATH FROM GIMP TITLE BAR
SetTitleMatchMode, 2
WinGetTitle, FilePath , – GIMP ahk_class gdkWindowToplevel
SetTitleMatchMode, 1

;SPLIT ONLY THE PATH+FILENAME
StringLeft, check_for_star, FilePath, 1
if check_for_star = *
{
	StringTrimLeft, FilePath, FilePath, 1 ;REMOVE STAR
}
StringLeft, check_for_star, FilePath, 1
if check_for_star = [
{
	StringTrimLeft, FilePath, FilePath, 1 ;REMOVE [
}
StringReplace, FilePath, FilePath, .xcf, |, All
StringSplit, title_array, FilePath, |
FilePath = %title_array1%
StringSplit, title_array, FilePath, ]
FilePath = %title_array1%

IfExist, %FilePath%
{
	;XCF D:
	SplitPath, FilePath, , dir,,name
	FilePath = %dir%\%name%
}

	;NOT XCF MAYBE?
IfExist, %FilePath%.jpg
{
	FilePath = %Filepath%.jpg
}
IfExist, %FilePath%.bmp
{
	FilePath = %Filepath%.bmp
}
IfExist, %FilePath%.gif
{
	FilePath = %Filepath%.gif
}
IfExist, %FilePath%.ico
{
	FilePath = %Filepath%.ico
}
IfExist, %FilePath%.png
{
	FilePath = %Filepath%.png
}


IfNotExist, %FilePath%
{
	FileSelectFile, FirstFile, 3, %FilePath%, Select spritemap, Images (*.png; *.gif; *.bmp; *.jpg; *.ico)
}


Goto, Options
Return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

2GuiContextMenu:
Menu, Tray, Show
Return

Edit:
Options:
Gui,1: New 
Gui,1: Font, Bold
Gui,1: Add, Text, x16 y16 w120 h23, Spritemap
Gui,1: Font
Gui,1: Add, Edit, vEditPath x32 y40 w168 h21, %FilePath%
Gui,1: Add, Button, x203 y39 w57 h23, &Browse...
Gui,1: Font, Bold
Gui,1: Add, Text, x16 y80 w120 h23, Frame-Size
Gui,1: Font
Gui,1: Add, Text, x32 y104 w60 h23, Width
Gui,1: Add, Text, x120 y104 w60 h23, Height
Gui,1: Add, Text, x208 y123 w48 h23, Pixels
Gui,1: Font, Bold
Gui,1: Add, Text, x16 y160 w120 h23, Animation
Gui,1: Font
Gui,1: Add, Edit, vFFrames x32 y184 w168 h21, 0`,1`,2`,3
Gui,1: Font, Bold
Gui,1: Add, Text, x16 y224 w120 h23, Speed
Gui,1: Font
Gui,1: Add, Edit, vFHeight x120 y120 w80 h21 Number, Edit
Gui,1: Add, UpDown, x184 y120 w18 h21 Range1-2048 , 32
Gui,1: Add, Edit, vFWidth x32 y120 w80 h21 Number, 4
Gui,1: Add, UpDown, x96 y120 w18 h21 Range1-2048 , 32
Gui,1: Add, Edit, vFSpeed x32 y248 w80 h21, Edit
Gui,1: Add, UpDown, x96 y248 w18 h21 Range1-100, 4
Gui,1: Add, Text, x208 y187 w60 h23, Frames
Gui,1: Add, Text, x120 y251 w60 h23, FPS


Gui,1: Add, Button, x176 y304 w81 h26, Close
Gui,1: Add, Button, x88 y304 w81 h26 Default, Refresh

Gui,1: Show, w274 h341 , gimp-animate
Gui,1: +AlwaysOnTop -MinimizeBox



Return


;####


GuiDropFiles:
Loop, parse, A_GuiEvent, `n
{
    FirstFile = %A_LoopField%
    Break
}
GuiControl,, EditPath, %FirstFile%
Goto, ButtonRefresh
Return

ButtonBrowse...:
Gui 1:+OwnDialogs
FileSelectFile, FirstFile, 3, %EditPath%, Select spritemap, Images (*.png; *.gif; *.bmp; *.jpg; *.ico)
if FirstFile !=
{
	GuiControl,, EditPath, %FirstFile%
}
Goto, ButtonRefresh
Return


;####


ButtonRefresh:
Gui,1: Submit, NoHide

StringSplit, FrameArray, FFrames, `,

Goto, Start
Return

GuiClose:
ButtonClose:
Gui,1: Hide
Return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             CREATE SPRITE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Start:





; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
Gui, 2: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow

; Show the window
Gui, 2: Show, NA

; Get a handle to this window we have created in order to update it later
hwnd1 := WinExist()

; Get a bitmap from the image
pBitmap := Gdip_CreateBitmapFromFile(EditPath)

; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
If !pBitmap
{
	Return
}

; Get the width and height of the bitmap we have just created from the file
; This will be the dimensions that the file is
Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)

w := FWidth, h := FHeight
WidthCount := Width//w, HeightCount := Height//h
Loop, % HeightCount		;%
{
	j := A_Index
	Loop, % WidthCount		;%
	{
		pBitmap_%A_Index%_%j% := Gdip_CreateBitmap(w, h)
		G := Gdip_GraphicsFromImage(pBitmap_%A_Index%_%j%)
		Gdip_DrawImage(G, pBitmap, 0, 0, w, h, (A_Index-1)*w, (j-1)*h, w, h)
		Gdip_DeleteGraphics(G)
	}
}

Resize := 3
hbm := CreateDIBSection(Resize*w, Resize*h)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G := Gdip_GraphicsFromHDC(hdc)

; We do not need SmoothingMode as we did in previous examples for drawing an image
; Instead we must set InterpolationMode. This specifies how a file will be resized (the quality of the resize)
; Interpolation mode has been set to HighQualityBicubic = 7
Gdip_SetInterpolationMode(G, 5)

Gdip_DisposeImage(pBitmap)

if x =
{
	x := WALeft+((WAWidth-(Resize*w))//2), y := WATop+((WAHeight-(Resize*h))//2)
}

FileGetTime, oldtime, %EditPath%


Direction := 1
ImageNum := 1

thespeed := (1000 / FSpeed)

SetTimer, Walk, %thespeed%
SetTimer, DetectChange, 300
Return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             WATCH FOR CHANGES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



DetectChange:
FileGetTime, curtime, %EditPath%

IfNotEqual, curtime, %oldtime%
{
	;File modified!!
	Goto, Start
}
Return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             PLAYBACK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Walk:
if draggin != 1
{
	Gdip_GraphicsClear(G)
	
	bitX := Mod(FrameArray%ImageNum%, WidthCount)+1
	bitY := Floor(FrameArray%ImageNum% / WidthCount)+1

	Gdip_DrawImage(G, pBitmap_%bitX%_%bitY%, 0, 0, Resize*w, Resize*h, 0, 0, w, h)
	UpdateLayeredWindow(hwnd1, hdc, x, y, Resize*w, Resize*h)

	ImageNum := ImageNum + 1
	if (ImageNum > FrameArray0)
	{
		ImageNum := 1
	}
}
return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             DRAGGING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Alt & LButton::
CoordMode, Mouse  ; Switch to screen/absolute coordinates.
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
if EWD_MouseWin = %hwnd1%  ; Only if the window isn't maximized
{
	draggin := 1
    SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
}
return

EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U  ; Button has been released, so drag is complete.
{
    SetTimer, EWD_WatchMouse, off
	draggin := 0
    return
}
GetKeyState, EWD_EscapeState, Escape, P
if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
{
    SetTimer, EWD_WatchMouse, off
    WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
	draggin := 0
    return
}
; Otherwise, reposition the window to match the change in mouse coordinates
; caused by the user having dragged the mouse:
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, x, y,,, ahk_id %EWD_MouseWin%
SetWinDelay, -1   ; Makes the below move faster/smoother.
WinMove, ahk_id %EWD_MouseWin%,, x + EWD_MouseX - EWD_MouseStartX, y + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             HIDE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Hide:
SetTimer, Walk, Off
SetTimer, DetectChange, Off
Gui,1:Destroy
Gui,2:Destroy

Loop, % HeightCount		;%
{
	j := A_Index
	Loop, % WidthCount		;%
		Gdip_DisposeImage(pBitmap_%A_Index%_%j%)
}

SelectObject(hdc, obm)

; Now the bitmap may be deleted
DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc)

; The graphics may now be deleted
Gdip_DeleteGraphics(G)

; The bitmap we made from the image may be deleted
Gdip_DisposeImage(pBitmap)

Goto, WaitforGodot
Return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             EXIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Exit:
Loop, % HeightCount		;%
{
	j := A_Index
	Loop, % WidthCount		;%
		Gdip_DisposeImage(pBitmap_%A_Index%_%j%)
}

; Select the object back into the hdc
SelectObject(hdc, obm)

; Now the bitmap may be deleted
DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc)

; The graphics may now be deleted
Gdip_DeleteGraphics(G)

; The bitmap we made from the image may be deleted
Gdip_DisposeImage(pBitmap)

; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return