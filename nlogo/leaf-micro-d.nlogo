globals [ sugarcount sugarcount-old sugar-rate oxygencount O2-temp-count 
        sugar-temp-count step time-unit  day?
        vapor-temp-count
          sugarsmoothed sugarsmoothed-old sugar-rate-smoothed 
          smoothness smoothness-2 percent-excited
          waiting wait-for-sugar wait-for-oxygen wait-for-vapor
          wait-for-photosynthesis ]
turtles-own [ water-in-leaf?   ]
patches-own [     ]
breed [light  ]
breed [sun]
breed [sugar]
sun-own [   old-xcor ]
breed [ CO2 ]
breed [ oxygen ]
breed [ water ]
breed [vapor]
breed [ chloroplast ]
chloroplast-own [ NADPH? ]

to startup
setup
end

to setup
clear-all
my-import-drawing "aspenleaftrans.png"
createplant
createsun
createchloroplast
ask water [ set water-in-leaf? false]
set sun-brightness 30
set CO2-amount 14
set water-flow 8
set waiting false
set wait-for-photosynthesis false
set wait-for-vapor false
set wait-for-sugar false
set wait-for-oxygen false
reset-ticks
end

to my-import-drawing [src]
end

to go 
  set step step + 1   tick
  shine-light
  takeup-water
  move-chloroplast
  color-sky
  set-CO2
  resolve-wait
  if waiting = false [ photosynthesize ]
  if waiting = false [ make-oxygen ]
  if waiting = false [ make-sugar ]
  if waiting = false [ make-water-vapor ]
  ask sugar [
    fd 0.1
    if ycor < min-pycor + 1 
       [die]
    ]
  ask oxygen [
    
    fd 0.2 
    set heading heading - 10 + random 20
    if abs xcor > max-pxcor - 1 or abs ycor > max-pycor - 1
      [die]
  ]
  ask vapor [
    fd 0.2 
    set heading heading - 10 + random 20
    if abs xcor > max-pxcor - 1 or abs ycor > max-pycor - 1
      [die]
      ]
;; plot-stuff
  ;;tick
end

;;SETUP PROCEDURES

to createplant
ask patches [
  set  pcolor 103
  if pycor <= -15 and pycor > -17 [set pcolor 31]
  if pycor <= -17 [set pcolor 36 ]
]
end

to createsun
create-sun 1 [
  set xcor -7
  set ycor max-pycor - 3
  set heading 90
  set color yellow
  set size 5
  set shape "circle"
  ]
end

to createchloroplast
create-chloroplast 1 
  [setxy 0  0
  set color 64
  set shape "circle 3"
  set color black
  set size 14
  set NADPH? false
  ]
end

;;GO PROCEDURES

to move-chloroplast
ask chloroplast 
  [fd .05
  set heading heading + (10 - random 20)
  if distancexy 0 0 > 3 [ rt 180 ] 
  ]
end

to shine-light
if random 100 < sun-brightness [
    create-light 1
        [set color yellow + 3
        set size 2
        setxy [xcor] of (turtle 0) [ycor] of (turtle 0)
        set heading 240 - random 120
        set xcor xcor + random 5 - 2
        fd 1
        ]
     ]
ask light [
    fd .5
    if abs xcor > max-pycor - 1 [die]
    if ycor < -14 [die]
     ]
end

to takeup-water
if random 100 < water-flow [
create-water 1
  [set color blue
  set shape "circle"
  set size 2
  setxy min-pxcor (- 16 - random 4) 
  set heading 90
  fd 1
  ]]
ask water [
  if xcor > max-pxcor - 1 [die]
  if abs xcor < 3 and ycor < -15 and random 100 < 5  and (count water with [ycor > -5]) < 20 
    [set heading 0]
  if ycor > -7
    [set water-in-leaf? true]
  if water-in-leaf? = true and distancexy 0 0 > 8 [
    rt 180
    fd 1
    ]
  if distancexy 0 0 < 7 [set heading heading + (10 - random 20)]
    fd .3
    
  ]
end

to set-CO2
if count CO2 < CO2-amount [
   create-CO2 1
    [
     set shape "CO2"
     set size 3
     setxy random max-pxcor random max-pycor
     set heading random 360
    ]
]
ask CO2 [
    set heading heading + (10 - random 20)
   
    fd 0.5
    if ycor > (max-pycor - 1) or ycor < min-pycor + 6 [
    rt 180
    fd 1
    ] 
  ]
end

to photosynthesize
ask chloroplast [
   if NADPH? = false 
   and count (light in-radius 5) > 0
   and count (water in-radius 5) > 0 [
        
        set O2-temp-count O2-temp-count + 1
        ask one-of (water in-radius 5) [set size 6  set label-color white set label  "water" ] 
        ask one-of (light in-radius 5) [set size 6 set label-color black set label  "light" ] 
        ;; pause 1
          set NADPH? true
          set size 16 
          set color red
        ;; pause 1
        set waiting true

      ]
      

  If NADPH? = true 
    and count (CO2 in-radius 4) > 0 
    and count (water in-radius 4) > 0 [
      set sugar-temp-count sugar-temp-count + 1
      set vapor-temp-count vapor-temp-count + 1

      ask one-of (CO2 in-radius 4) [set size 6 set label-color white set label  "CO2" ]
     ask one-of (water in-radius 4) [set size 6 set label-color white set label  "water" ] 
        ;; pause 1
          set NADPH? false
          set size 14
          set color black
        ;; pause 1
        set waiting true

      ]
]
  if waiting = true [ set wait-for-photosynthesis true ]
end

to make-oxygen
if O2-temp-count > 0 [
  create-oxygen 1
    [set color gray
    set shape "oxygen"
    set size 5 set label-color black set label  "oxygen"
    set heading random 360 
    ]
  set waiting true
  set wait-for-oxygen true
  set O2-temp-count O2-temp-count - 1
]

end

to  make-sugar 
if sugar-temp-count > 0 [
  create-sugar 1
    [setxy 0 0
    set shape "sugar"
    set color white
    set size 5 set label-color black set label  "sugar"
    set heading 180
    ]
  set waiting true
  set wait-for-sugar true
  set sugar-temp-count sugar-temp-count - 1 
]
end

to   make-water-vapor
if vapor-temp-count > 0 [
  create-vapor 1
    [setxy 0 3   
    set shape "vapor"
    set color blue + 2
    set size 5 set label-color black set label  "water vapor"
    set heading random 360
    ]
  set waiting true
  set wait-for-vapor true
  set vapor-temp-count vapor-temp-count - 1 
]
end

to color-sky
if step mod 10 = 0 [
ask patches [
  if pycor > -15 
    [set pcolor (scale-color blue (count light) -30 60)]
   ]
]
end

to plot-stuff
set-current-plot "Production Rates"
  set-current-plot-pen "oxygen"
      plot count oxygen
    set-current-plot-pen "Sugar"
      plot count sugar
   ;; set-current-plot-pen "Vapor"
    ;;  plot count vapor
end

to resolve-wait
  if waiting = true [
    pause 1
    set waiting false
  ]

  if wait-for-photosynthesis = true [
    ask turtles with [size = 6] [die]
    set wait-for-photosynthesis false
  ]
  
  if wait-for-vapor = true [
    ask turtles with [shape = "vapor"] with [size = 5] [
      set size 3 set label ""
    ]
    set wait-for-vapor false
  ]
  
  if wait-for-sugar = true [
    ask turtles with [shape = "sugar"] with [size = 5] [
      set size 3 set label ""
    ]
    set wait-for-sugar false
  ]
  
  if wait-for-oxygen = true [
    ask turtles with [shape = "oxygen"] with [size = 5] [
      set size 3 set label ""
    ]
    set wait-for-oxygen false
  ]
end
    

to pause [time]
  ;; custom wait code here
  ;; wait time
end
@#$#@#$#@
GRAPHICS-WINDOW
134
10
552
369
25
20
8.0
1
10
1
1
1
0
1
1
1
-25
25
-20
20
0
0
1
ticks
30.0

BUTTON
9
11
115
44
Setup/Reset
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

BUTTON
23
63
104
96
Run/Stop
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
239
127
272
water-flow
water-flow
0
20
8
1
1
NIL
HORIZONTAL

SLIDER
10
182
126
215
CO2-amount
CO2-amount
0
30
14
1
1
NIL
HORIZONTAL

SLIDER
9
126
128
159
sun-brightness
sun-brightness
0
100
30
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a model of photosynthesis in a chloroplast which is inside a leaf. 

## HOW IT WORKS

The following inputs can be adjusted with sliders:  
-- light rays radiating from the sun (yellow arrowheads)  
-- water supplied to the stem (blue circles)  
-- carbon dioxide (CO2) molecules in the atmosphere (orange and black)

In the center of the leaf is a black circle representing a chloroplast. The rules for the model are as follows:  
1. Water in the stem is drawn up into the leaf as it goes by, up to a maximum of 30 water molecules.  
2. If a light ray and a water molecule are both inside the chloroplast, it goes into an excited state (NADPH). The circle gets larger and turns orange. One water is used up and one oxygen (gray circle) is created.  
3. If a CO2 and a water are both inside the chloroplast when it is in an excited state,  
it returns to an unexcited state. The circle gets smaller and turns black. One CO2 is used up and one sugar (white jagged shape) is created.  
4. The sugars go down the leaf stem and disappear. The sugar production rate on the graph is the number of sugars on the screen at any moment.  
5. The oxygens go out in all directions and disappear when they get to the edge of the screen. The oxygen production rate on the graph is the number of oxygens on the screen at any moment.

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

circle 3
false
1
Circle -2674135 false true 8 8 283
Circle -2674135 false true 12 12 277
Circle -2674135 false true 16 16 268
Circle -2674135 false true 16 16 268
Circle -2674135 false true 21 21 258
Circle -2674135 false true 8 8 285
Circle -2674135 false true 12 12 277
Circle -2674135 false true 14 14 272
Circle -2674135 false true 12 12 277

circle-edge
false
14
Circle -16777216 false true 12 12 277
Circle -16777216 false true 21 21 258
Circle -16777216 false true 23 23 255
Circle -16777216 false true 30 30 240

circle-edge2
false
1
Circle -2674135 false true 2 2 295
Circle -2674135 false true 16 16 268
Circle -2674135 false true 26 26 247
Circle -2674135 false true 60 60 180
Circle -2674135 false true 103 103 95
Circle -2674135 false true 23 23 255
Circle -2674135 false true 8 8 285
Circle -2674135 false true 15 15 270
Circle -2674135 false true 0 0 300
Circle -2674135 false true 12 12 277
Circle -2674135 false true 2 2 297

co2
true
0
Circle -955883 true false 26 116 67
Circle -955883 true false 26 116 67
Circle -955883 true false 191 116 67
Circle -7500403 false true 75 75 150
Circle -16777216 true false 101 101 67
Circle -16777216 true false 73 73 152
Circle -955883 false false 18 108 85
Circle -955883 false false 183 108 85

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

oxygen
true
0
Circle -7500403 true true 5 65 170
Circle -7500403 true true 125 65 170

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

sugar
true
15
Polygon -1 true true 75 60 135 15 165 60 255 60 225 120 285 165 195 180 240 255 150 255 135 210 75 255 75 210 15 195 105 150 15 90 90 75 75 60

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

vapor
true
0
Circle -1 true false 63 198 85
Circle -1 true false 78 3 85
Circle -7500403 true true 48 33 234

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
