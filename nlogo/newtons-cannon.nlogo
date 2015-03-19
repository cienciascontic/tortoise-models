
breed [mountains mountain]
breed [arrows arrow]
breed [ISSs ISS]       ;;ISS=International Space Station
breed [puffs puff]
breed [junkpiles junkpile]

puffs-own [x0 y0] ;; (x0,y0) are the coordinates of the puff relative to the earth's center.  
junkpiles-own [x1 y1 ] ;;(x1,y1) are the coordinates of the junkpile relative to the earth's center.  

Globals [scale eRadK gHP mOffP cycleCount rX rY rVX rVY rMass b1 b2 alive? Gm running? oldLS launchHeight montainHeight time nextPuffTime puffInterval]
;; scale is the overall scale used in the main view in patches per km--that is scale is the number of patches on the screen to km in the simulation
;; eRadK is the earth's radius in km
;; gHP is the ground height in patches, the hight of the mounain base above the bottom of the screen measured in patches
;; mOffP is the offset from the left edge of the main sceen of the base of the mountain (and the launch site) in patches
;; cycleCount is the number of times the computation has gone though the main look since start
;; rX is the x-coordinate of current location of the SSI (used to be a rocket) in km where the center of the Earth is (0,0)
;; ry is the y-coordinate ....
;; rVX is the current x-component of the velocity of the SSI in km/s
;; rVY is the y-component
;; rMass is the mass of the SSI
;; b1-b2 are the offsets of the x and y coordinate origins for the screen. Hence scale * x + b1 is the screen location in patches of x measured in km
;; alive? is a logical that is true between launch and crash
;; Gm is the universal gravitational constant G times the mass of the earth
;; running? is a logical that is true between launch and crash if the simulation is not paused. 
;; oldLS stores the old value of the LS the log of the scale. Used to make the scale slider always active
;; oldIScale ditto for the insert scale slider
;; launchHeight stores the height of the launch
;; time is the elapsed time since launch in sec
;; nextPuffTime stores the time when the next puff will be emitted
;; puffInterval is the time between puffs in sec

to startup
  initialize
  run_simulation
end

to Run_Simulation                     ;; executed repeatedly when the 'Run Simulation' button is pressed
  if cycleCount = 0                   ;; cycleCount is a global variable that is zero when NetLogo is first started
     [initialize ]                    ;; only on the first time through, initialize all the globals and create turtles. 
  if running?                         ;; 'running?" is a logical that is true after firing the ISS until paused or crashed
     [stepISS                      ;; if running? is true then move the ISS    
        set cyclecount cyclecount + 1 ]      ;; cycleCount counts the number of steps executed              
  every .2 [updateUI ]                           ;; monitor the user interface every .2 second
end

to updateUI                           ;; this adjusts scene for changes in arrows, scales, and mountain height
  if not (oldLS = MainScale)           ;; check for a change in the MainScale slider
     [drawScene set oldLS MainScale ]  ;; redraw the entire scene if the scale is changed. Remember the current setting  
  placeArrows                       ;; in the future, this might also respond to other changes in the UI
  handlePuffs
end

to reset                            ;; this is handy for debugging, but shouldn't be necessary in the production version
  set Cyclecount 0
  cp ct                           ;; clear patches and turtles
end

to initialize
  set time 0
  set CycleCount 1               ;; this ensures that initialize is execued only once
  set running? false             ;; start in the non running mode
  set alive? false               ;; start with the ISS not alive 
  set eRadK 6378                 ;; earth radius in km
  set rVX 0                      ;; the initial ISS x-velocity (km/s)
  set rVY 0                      ;; the initial ISS y-velocity
  set rX 0                       ;; the initial ISS x-position relative to the earth center (km)
  set rY eRadK + LaunchHeight    ;; the initial ISS y-position in km
  set rMass 3.44e5                  ;; the ISS mass in kg
  ;; note there are additional globals created in the UI
  set montainHeight  8.8            ;; the height of the mountain in km
  set launchHeight  8.8              ;; the height of the launching arrow in km
  set Gm 398600                  ;; the universal gravitational constant times the mass of the earth in km-kg-sec system
  create-ISSs 1 [set size 0 set shape "ISS" ]  ;; the ISS will show up in the main scene and the insert
  create-arrows 1 [set size 0 set shape "arrow" set color red ]
  create-mountains 1 [set shape "mountain" set heading 0]
  drawScene
end

to placeArrows ;; keep the arrows up-to-date with changes in the sliders
  ask arrows [
    set heading launchHeading ;; aim it in the right direction
    let xx min-pxcor + mOffP
    let yy min-pycor + gHP + scale * launchHeight
    ifelse yy < max-pycor [setxy xx yy set size 15 ] [set size 0]]
end

to launch  ; move the ISS to the launcher and give it an initial velocity
  set rVX launchSpeed * sin launchHeading
  set rVY launchSpeed * cos launchHeading
  set rX 0                       ;; the initial location of the ISS is at the origin of the x-axis, directly above the center of the earth
  set rY eRadK + LaunchHeight    ;; the y-coordinate is the radius of the earth plus the launch height in km.
  set alive? true                ;; turn on the ISS. 
  set running? true   
  set time 0                     ;; times the launch
  set nextPuffTime 0  handlePuffs           ;; create a puff
  set puffInterval .04 * max-pxcor / (scale * launchSpeed) ;; sets 50 puffs across screen given launch speed
end

to stepISS
  ;; move the ISS forward one dt step. All calcuations done in KMKS system. 
  let dt 10 ^ Model_Speed       ;; Model Speed is set by a slider
  let xx rx + rvx * dt / 2      ;; move forward a half-step to (xx,yy) (local variables)
  let yy ry + rvy * dt / 2
  let r2 xx ^ 2 + yy ^ 2        ;; compute the square of the distance to the center of the earth
  let r sqrt r2                 ;; compute the distance to the center of the earth at this half-step location
  set time time + dt
  ifelse  r > eRadK 
    [ let r3 r * r2             ;; compute r-cubed
      let ax 0 -  Gm * xx / r3   ;; use the force at the mid-point to determine the acceleration
      let ay 0 -  Gm * yy / r3  ;; a-vector = -G*me*r-vector / r-magnitude^3
      set rvx rvx + ax * dt     ;; use the acceleration to change the velocity
      set rvy rvy + ay * dt
      set rx rx + rvx * dt      ;; use the velocity to change the position
      set ry ry + rvy * dt
      placeISS              ;; show the ISSs if they are visible
      handlePuffs]              ;; make and remove puffs 
   [showresults                 ;; type results into output box
     explode ]                   ;; if the ISS collides with the earth, explode
end

to showresults
  let r eRadK * 2 * pi * (atan rx ry) / 360  ;; distance on surface of earth from launch
  my-output-type round r
  my-output-type "km   "
  my-output-type launchHeading
  my-output-type "°   "
  my-output-type launchSpeed
  my-output-print "km/s"
end

to handlePuffs
  if time > nextPuffTime [           ;; if it is time for a new puff...
    create-puffs 1 [                 ;; create a new puff
      set nextPuffTime nextPuffTime + puffInterval  ;; set the time for the next puff
      set x0 rx                      ;; the location of this puff is taken from the current ISS location
      set y0 ry
      set shape "circle"
      set color red
      let temp main x0 y0           ;; compute the screen position of each puff
      ifelse last temp              ;; last item in temp is a logical that tells whether this puff is in the main screen. 
         [setxy first temp item 1 temp     ;; if it is on-screen update the location of the puff
           set size 2 ]
         [set size 0]]]                ;; if outside the main scene make it vanish but don't kill it.
end
  
to placePuffs     
    ask puffs [
       let temp main x0 y0           ;; compute the screen position of each puff
       ifelse last temp              ;; last item in temp is a logical that tells whether this puff is in the main screen. 
         [setxy first temp item 1 temp     ;; if it is on-screen update the location of the puff
           set size 2 ]
         [set size 0]]                ;; if outside the main scene make it vanish but don't kill it--yet
end

to placeISS   ;; show the ISS at its location rx,ry if visible
   if alive? 
     [ask ISSs [
     set heading atan rvx rvy 
                       ;; if it is visible in the main scene, show it
     let temp main rx ry          ;; temp contains the screen coordinates of rx,ry (items 0 and 1) and whether this is visible (item 2)
       ifelse last temp             ;; if the ISS is visible in the main screen.........
           [setxy first temp item 1 temp           ;; update the location of the ISS
               set size 16 ]        ;; turn it on in case it has been off
           [set size 0 ]         ;; turn if off if it is outside the main scene
     ]]
end

to placeJunk       ;; show the junkpiles that are visible
  ask junkpiles [
    let temp main x1 y1          ;; convert the earth coordinates to screen coordinates. 
    ifelse last temp             ;; if this point is visible on the main screen...
      [setxy first temp item 1 temp set size 16 ]  ;;place it and turn it on
      [set size 0]               ;; otherwise turn it off
  ]
end

to-report main [u v]             ;; checks whether the location u,v in earth coordinates is visible in the main scene.
   let x scale * u + b1          ;; transform u,v to screen coordinates
                                 ;; returns the screen coordinates and a logical telling whether it is currently visible.
   let y scale * v + b2          ;; (x,y) are the patch locations of the ISS relative to the center of the scene
                                 ;; first check to see whether it the point is inside the main scene
   ifelse  x < max-pxcor and x > min-pxcor and y < max-pycor and y > min-pycor 
         [report (list x y true)]
         [report (list x y false)]                ;; return false if it is outside the main screen
end

to explode
    let sz 10
    ask ISSs [set shape "explosion"]  ;; turn ISSs into explosions
    repeat 20 [                          ;; slowly increase the size of each for 50 steps of .1 sec each
       ask ISSs [if size > 0 [set size sz ]]
       set sz sz + 2.2
       pause .1 ]      
   ask ISSs [set size 0 set shape "ISS"]  ;; turn them back into ISSs
   create-junkpiles 1                      ;; create a junkpile where the ISS crashes
     [set shape "junk" 
     set color white 
     set heading atan rx ry                ;; its heading is away from the center of the earth
     set x1 rx                             ;; give it the currnet coordinates of the ISS. 
     set y1 ry]
   placeJunk  ;; shows all the junkpiles, including the last
   set running? false                    ;; after colliding with the earth, pause the integration engine
   set alive? false                      ;; after colliding with the earth, the ISS is not alive
   ;; the difference between running? and alive? is that a ISS may be alive but paused, not running
end

to drawScene  ;; Draws everything--updates the screen
  ;; first some parameters for the main drawing
  ;; scale is a global, the number of patchs per km in the main scene -- the main scaling number
  set scale  10 ^ MainScale       ;; scale is the number of patchs per km in the main scene--the slider is logarithmic
  let v 1  
  if MainScale > -3 
    [set v (1 - MainScale ) / 4 ] ;; goes from 0 to 1 as the MainScale goes from 1 to -3. Stop moving earth when MainScale gets below -3 
  set gHP 10 + max-pycor * v     ;; height of the ground above bottom of the main scene, in patchs. Moves up for smaller scales
  set mOffP 90 + (max-pxcor - 100) * v      ;; mountain offset from left of scene, in patchs. Moves to center for smaller scales
  set b1 mOffP + min-pxcor       ;; the constant in the conversion of x to patchs in the main scene
  set b2 gHP + min-pycor - scale * eRadK ;; the constant in the conversion of y to patchs in the main scene
  ;; the conversion is (h,v) in patchs in the main scene = (scale*x + b1, scale*y + b2) where x,y are in km relative to the earth center
  let TropoTop 10 ;; the top of the tropospehere in km above the earth's surface
  let StratoTop 50 ;; the top of the stratosphere in km above the earth's surface
  let earthTopP min-pycor + gHP ;; the top of the earth in the main scene in patchs 
  let mountainSizeP montainHeight * scale ;; measured in patchs
  let mountainX min-pxcor + mOffP ;; locates the x-center of the mountain

  ;; Begin the drawing
  cp ;; clear all the patches--sets them to black
  ask patches [
    let x (pxcor - b1) / scale                     ;; x-coordinate of patch relative to earth's center
    let y (pycor - b2) / scale                     ;; y-coordinate of patch relative to earth's center
    let alt sqrt (x ^ 2 + y ^ 2 ) - eRadK          ;; altitude of patch above earth in km
    ifelse alt + .6 * eRadK < 0 [set pcolor white] ;; a polar cap 
      [ifelse alt < 0 
       [ ifelse y < 0 [ set pcolor blue ][ set pcolor green ]]    ;; if altitude is negative, make green or blue depending on the side of the earth
         [ifelse alt < tropoTop [set pcolor 108 ]  ;; otherwise if the altitude is less than the troposphere, make blue sky
          [if alt < StratoTop                      ;; if it is below the stratosphere...
            [set pcolor 100 + 8 * (StratoTop - alt) / (StratoTop - TropoTop )]]]]]  ;; fade to black
  ask mountains [                                  ;; create one mountain
    setxy mountainX earthTopP + ( mountainSizeP / 2  - 1) ;; center the mountain just below half its diameter above the earth
    set size mountainSizeP ]
  placeArrows                                      ;; put the arrows in their new position
  placeISS 
  placePuffs
  placeJunk
end

to my-output-type [string]
  ;; output-type string
end

to my-output-print [string]
  ;; output-print string
end

to my-clear-output
  ;; clear-output
end

to pause [t]
  ;; wait t
end
@#$#@#$#@
GRAPHICS-WINDOW
199
17
811
466
150
104
2.0
1
10
1
1
1
0
1
1
1
-150
150
-104
104
0
0
1
ticks
30.0

SLIDER
2
104
196
137
launchHeading
launchHeading
0
100
20
1
1
°
HORIZONTAL

SLIDER
2
170
196
203
MainScale
MainScale
-3.7
1
1
.05
1
NIL
HORIZONTAL

BUTTON
11
12
187
45
Turn On before launching
Run_Simulation
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
18
62
98
95
Launch!
Launch
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
2
138
196
171
LaunchSpeed
LaunchSpeed
0
15
0.3
.1
1
km/s
HORIZONTAL

MONITOR
5
219
92
264
time (minutes)
time / 60
1
1
11

SLIDER
379
10
626
43
Model_Speed
Model_Speed
-1.0
1.0
0
.05
1
NIL
HORIZONTAL

MONITOR
93
220
197
265
SSI Altitude (km)
round (sqrt (Rx ^ 2 + ry ^ 2) - eRadK)
1
1
11

BUTTON
114
62
185
95
Erase Dots
ask puffs [die]\nask junkpiles [die]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
7
298
199
431
12

BUTTON
57
433
158
466
Clear Table
my-clear-output
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
7
283
187
311
Distance  Heading  Launch Speed
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

earth
true
0
Circle -7500403 true true 0 0 300
Circle -1 true false 96 96 108
Polygon -14835848 true false 45 45 75 60 75 75 120 75 135 60 195 75 225 105 240 135 270 120 255 90 240 60 240 30 210 15 165 0 120 0 90 15 60 30
Polygon -14835848 true false 75 135 45 105 30 105 30 135 15 135 0 120 0 150 0 180 30 240 60 270 105 285 135 270 150 240 150 210 120 210 90 195 75 165 60 165 60 150 75 135

explosion
true
0
Polygon -1184463 true false 90 150 15 135 90 135 75 105 150 135 90 30 150 90 180 15 165 120 240 105 180 135 270 195 150 150 165 210 135 165 75 255 90 150
Polygon -2674135 true false 120 90 75 75 105 105 60 120 120 150 30 195 120 165 150 285 150 165 240 240 195 165 270 120 180 120 210 45 150 90 135 30

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

iss
true
0
Rectangle -1 true false 120 45 180 255
Polygon -1 true false 120 45 150 0 180 45
Circle -1 true false 135 255 30
Rectangle -1 true false 0 135 300 150
Rectangle -1 true false 30 45 45 240
Rectangle -1 true false 60 45 75 240
Rectangle -1 true false 225 45 240 240
Rectangle -1 true false 255 45 270 240

junk
true
0
Polygon -1 true false 60 150 240 150 180 135 210 90 180 75 180 15 165 15 150 105 135 90 105 45 60 90 90 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

mountain
true
0
Polygon -6459832 true false 0 300 120 15 180 15 300 300
Polygon -1 true false 120 15 60 165 105 105 105 135 135 45 165 180 165 105 195 150 195 60 180 15 120 15

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

rocket
true
0
Polygon -7500403 true true 120 165 75 285 135 255 165 255 225 285 180 165
Polygon -1 true false 135 285 105 135 105 105 120 45 135 15 150 0 165 15 180 45 195 105 195 135 165 285
Rectangle -7500403 true true 147 176 153 288
Polygon -7500403 true true 120 45 180 45 165 15 150 0 135 15
Line -7500403 true 105 105 135 120
Line -7500403 true 135 120 165 120
Line -7500403 true 165 120 195 105
Line -7500403 true 105 135 135 150
Line -7500403 true 135 150 165 150
Line -7500403 true 165 150 195 135

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
