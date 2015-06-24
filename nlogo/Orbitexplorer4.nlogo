;; Orbit Explorer
;; A model for exploring orbits
;; June 17, 2010

breed [earths earth]
breed [arrows arrow]
breed [Rockets Rocket]    
breed [puffs puff]

puffs-own [x0 y0 countdown] ;; (x0,y0) are the coordinates of the puff relative to the earth's center.  

Globals 
  [scale ;; scale is the overall scale used in the main view in patches per km--that is scale is the number of patches on the screen to km in the simulation
  eRadK ;; eRadK is the earth's radius in km
  gHP ;; gHP is the ground height in patches, the hight of the mounain base above the bottom of the screen measured in patches
  mOffP ;; mOffP is the offset from the left edge of the main sceen of the base of the mountain (and the launch site) in patches
  cycleCount ;; cycleCount is the number of times the computation has gone though the main loop since start
  rX ;; rX is the x-coordinate of current location of the rocket in km where the center of the Earth is (0,0)
  rY ;; ry is the y-coordinate ....
  rVX ;; rVX is the current x-component of the velocity of the rocket in km/s
  rVY ;; rVY is the y-component
  b1 b2 ;; the offsets of the x and y coordinate origins for the scene. Hence scale * x + b1 is the screen location in patches of x measured in km
  alive? ;; alive? is a logical that is true between launch and crash
  Gm ;; Gm is the universal gravitational constant G times the mass of the earth
  running? ;; running? is a logical that is true between launch and crash if the simulation is not paused. 
  launchHeight ;; launchHeight stores the height of the launch
  time ;; time is the elapsed time since launch in sec
  nextPuffTime ;; nextPuffTime stores the time when the next puff will be emitted
  puffInterval ;; puffInterval is the time between puffs in sec
  speed 
  launch-heading
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; Start and Initialize ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to startup
  my-hide-speed-slider
  setup
end


to setup
  set Cyclecount 0
  cp ct                               ;; clear patches and turtles
  clear-all-plots
  set running? false             ;; start in the paused mode
  set alive? false               ;; start with the Rocket not alive 
  set eRadK 12000                 ;; earth radius in km should be 6378
  set LaunchHeight 30e4          ;; the initial height of the rocket
  set Gm 398600                  ;; the universal gravitational constant times the mass of the earth in km-kg-sec system
  set puffInterval 600           ;; determines how many seconds between puffs
  set launch-heading 90          ;;take away this slider in this model
  create-Rockets 1 [ set shape "dot" ht]  ;; the Rocket will show up in the main scene as a circle
  create-arrows 1 [set size 3 set shape "arrow" set color red ht]
  create-earths 1 [set size 20 set shape "earth" set color blue set heading 0]
  drawScene

end

to drawScene  ;; Draws everything--updates the screen
  set scale  3e-4        ;; scale is the number of patchs per km in the main scene--the slider is logarithmic
  ;; the conversion is (h,v) in patchs in the main scene = (scale*x , scale*y ) where x,y are in km relative to the earth center
  ;; Begin the drawing
  cp ;; clear all the patches--sets them to black
  ask earths [                                     ;; create one earth
    setxy 0 0
    set size 2 * scale * eRadK ]                  ;; the size (diameter) is the twice the scaled radius of the earth in km
  ask arrows 
    [set heading Launch-Heading  ;; aim it in the right direction                                     
      setxy 0 scale * LaunchHeight  st ];; put the arrows in their new position
  ask rockets 
    [set heading Launch-Heading  ;; aim it in the right direction                                     
      setxy 0 scale * LaunchHeight  st ];; put the arrows in their new position
end

to placeArrow ;; keep the arrow up-to-date with changes in the sliders
  ask arrows [set heading Launch-Heading]  ;; aim it in the right direction

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; Animate  ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to Run_Simulation                      ;; executed repeatedly when the 'Run' button is on
  if running?                          ;; 'running?" is a logical that is true after firing the Rocket until paused or crashed
     [stepRocket                          ;; if running? is true then move the Rocket    
     set cyclecount cyclecount + 1 ]   ;; cycleCount counts the number of steps executed              
  every .1 [
     ask earths [set heading .0027778 * time  ]        ;; rotate the earth  
     placeArrow                         ;; plot altitude and speed vrs time in days
     let days time / 86400
     set-current-plot "Altitude"
     plotxy  days (sqrt (rx ^ 2 + ry ^ 2))
     plot-pen-down                      ;; may have been put up at launch to avoid a long line from the end of the prior run. 
     set-current-plot "Speed"
     plotxy days speed
     plot-pen-down
     ]
end

to launch  ; move the Rocket to the launcher and give it an initial velocity
  if count turtles < 1
    [ setup ]
  clear-all-plots
  set-current-plot "Altitude"
  plot-pen-up
  set-current-plot "Speed"
  plot-pen-up
  set rVX Launch-Speed * sin (Launch-Heading)                      ;; the initial Rocket x-velocity (km/s)
  set rVY Launch-Speed * cos (Launch-Heading)                       ;; the initial Rocket y-velocity
  set rX 0                       ;; the initial location of the Rocket is at the origin of the x-axis, directly above the center of the earth
  set rY LaunchHeight            ;; the y-coordinate is the launch height in km.
  set alive? true                ;; turn on the Rocket. 
  set running? true              ;; This determines whether it is advanced
  set time 0                     ;; times the launch
  set nextPuffTime 0  
  handlePuffs                    ;; create a puff
  set puffInterval .04 * max-pxcor / (scale * Launch-Speed ) ;; sets 50 puffs across screen given launch speed
  ask rockets [st                 ;; show the rocket if it was hidden by an explosion
    set size 20               
    set heading Launch-Heading]   ;; keep the rocket aligned with the arrow. 
end

to stepRocket
  ;; move the Rocket forward one dt step. All calcuations done in KMKS system. 
  let dt 10 ^ Model_Speed       ;; Model Speed is set by a slider
  let xx rx + rvx * dt / 2      ;; move forward a half-step to (xx,yy) (local variables)
  let yy ry + rvy * dt / 2
  let r2 xx ^ 2 + yy ^ 2        ;; compute the square of the distance to the center of the earth
  let r sqrt r2                 ;; compute the distance to the center of the earth at this half-step location
  set time time + dt
  ifelse  r > eRadK [
      let r3 r * r2             ;; compute r-cubed
      let ax 0 - ( Gm * xx / r3 )  ;; use the force at the mid-point to determine the acceleration
      let ay 0 - ( Gm * yy / r3 )   ;; a-vector = -G*me*r-vector / r-magnitude^3
      set rvx rvx + ax * dt     ;; use the acceleration to change the velocity
      set rvy rvy + ay * dt
      set speed sqrt ( (rvx ^ 2) + (rvy ^ 2 ) )
      set rx rx + rvx * dt      ;; use the velocity to change the position
      set ry ry + rvy * dt
      placeRockets              ;; show the Rockets if they are visible
      handlePuffs]              ;; make and remove puffs 
   [ explode ]                   ;; if the Rocket collides with the earth, explode
end

to handlePuffs
  if time > nextPuffTime [           ;; if it is time for a new puff...
    create-puffs 1 [                 ;; create a new puff
      set nextPuffTime nextPuffTime + puffInterval  ;; set the time for the next puff
      set x0 rx                      ;; the location of this puff is taken from the current Rocket location
      set y0 ry
      set shape "circle"
      set color red
      set countdown 400              ;; allow 400 puffs maximum
      let temp main x0 y0            ;; Place the latest puff only. Compute the screen position of each puff
      ifelse last temp              ;; last item in temp is a logical that tells whether this puff is in the main screen. 
         [setxy first temp item 1 temp     ;; if it is on-screen update the location of the puff
           st ]                      ;; show the puff
         [ht] ]                      ;; hide the puff
    ask puffs [                      ;; when one puff is created decrement all the countdown variable in all
      set countdown countdown - 1
      if countdown < 0 [die]]        ;; kill off any with non-positive countdown.
  ]
end

to placeRockets   ;; show the Rockets at their location rx,ry if visible
   ask Rockets [                     ;; this is the Rocket in the main scene
     let temp main rx ry             ;; temp contains the screen coordinates of rx,ry (items 0 and 1) and whether this is visible (item 2)
     ifelse last temp                ;; if the Rocket is visible in the main screen.........
         [setxy first temp item 1 temp           ;; update the location of the Rocket
           st  ]             ;; show turtle
         [ht]             ;; hide if it is outside the main scene
   ]
end

to-report main [u v]             ;; checks whether the location u,v in earth coordinates is visible in the main scene.
   let x scale * u               ;; transform u,v to screen coordinates
                                 ;; returns the screen coordinates and a logical telling whether it is currently visible.
   let y scale * v               ;; (x,y) are the patch locations of the Rocket relative to the center of the scene
                                 ;; check to see whether it the point is inside the main scene
   ifelse  x < max-pxcor and x > min-pxcor and y < max-pycor and y > min-pycor 
         [report (list x y true)]
         [report (list x y false)]           ;; return false if it is not outside the screen
end

to explode
    let sz 10
    ask Rockets [set shape "explosion"  ;; turn Rockets into explosions
       repeat 30 [                          ;; slowly increase the size of each for 50 steps of .1 sec each
         if size > 0 [set size sz ]
         set sz sz + 2
         pause .1 ]      
       ht set shape "dot"]  ;; turn them back into Rockets
   set running? false                    ;; after colliding with the earth, pause the integration engine
   set alive? false                      ;; after colliding with the earth, the Rocket is not alive
   ;; the difference between running? and alive? is that a Rocket may be alive but paused, not running
end

to pause [t]
  ;;wait t
end

to my-hide-speed-slider
end
@#$#@#$#@
GRAPHICS-WINDOW
265
60
677
493
100
100
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
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
92
19
172
52
Run/Pause
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
171
19
239
52
Launch
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

MONITOR
116
110
168
155
minutes
time / 60 mod 60
1
1
11

SLIDER
349
21
596
54
Model_Speed
Model_Speed
2
4
3
.05
1
NIL
HORIZONTAL

MONITOR
162
464
257
509
Altitude (km)
round (sqrt (Rx ^ 2 + ry ^ 2) - eRadK)
1
1
11

BUTTON
239
19
317
52
Erase Dots
ask puffs [die]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
13
110
65
155
days
int (time / 86400)
2
1
11

MONITOR
18
465
108
510
Speed (km/s)
Speed
2
1
11

MONITOR
65
110
117
155
hours
int (time / 3600) mod 24
0
1
11

TEXTBOX
14
95
164
113
Time since launch:
11
0.0
1

SLIDER
7
58
160
91
Launch-Speed
Launch-Speed
0
3
1
.1
1
Km/s
HORIZONTAL

PLOT
13
160
258
310
Altitude
Time (days)
Altitude (km)
0.0
10.0
0.0
10000.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" ""

PLOT
14
310
257
460
Speed
Time (days)
Speed (km/s)
0.0
10.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" ""

BUTTON
7
18
71
51
Reset
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
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
Circle -2674135 true false 135 255 30
Rectangle -1 true false 15 165 315 180
Rectangle -1 true false 30 90 45 270
Rectangle -1 true false 60 75 75 270
Rectangle -1 true false 225 90 240 270
Rectangle -1 true false 255 105 270 270
Polygon -13345367 false false 150 15 135 45 165 45
Polygon -13345367 true false 150 15 135 45 165 45

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
