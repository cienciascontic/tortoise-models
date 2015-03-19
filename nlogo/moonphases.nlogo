globals [moonsize moon-angle orbit-radius phase moon-done-moving]

turtles-own [ sun-step]
to startup
  setup
end


to setup
  ca
  reset-ticks
  set moonsize 15
  set moon-angle 0
  set moon-done-moving 0
  set orbit-radius max-pxcor * .65
  ask patches [
    if pxcor = max-pxcor  [
      set pcolor white
    ]
    
  ]
  crt 1 [  ;;moon showing phases is turtle 0
    setxy max-pxcor * -.7 max-pycor * .7
    set shape "new" 
    set size moonsize
    set heading 90
  ]
  crt 1 [  ;; earth is turtle 1
    set shape "earth-half"
    set heading 0
    set size 5
    set color blue - 4.5

    ]
  crt 1 [   ;;moon circling earth is turtle 2
    set size 3
    set shape "half"
    setxy orbit-radius 0 
    set color white
    pd
  ]

crt 1 [    ;beam of sunlight is turtle 3
  set sun-step 1
  set color white
  set xcor max-pxcor
  set ycor 0
  set heading 270
]
end  
  
to go
  if ticks >= moon-done-moving [
    move-moon
    set-moon-phase
  ]
  tick
end

to move-moon
  set moon-angle (moon-angle + 1) mod 360
  ask turtle 2 [
    setxy orbit-radius * cos moon-angle orbit-radius * sin moon-angle
  ]
  ;;0.05 seconds
  set moon-done-moving (ticks + 2)
end


to set-moon-phase
  set phase round (moon-angle + 7) / 15
  ask turtle 0 [
 if phase = 0 [set shape  "new"] 
 if phase = 1 [set shape  "crescent1"] 
 if phase = 2 [set shape  "crescent2"] 
 if phase = 3 [set shape  "crescent3"] 
 if phase = 4 [set shape  "crescent4"] 
 if phase = 5 [set shape  "crescent5"]
 if phase = 6 [set shape  "half"]
 
 if phase = 7 [set shape  "gibbous5"]
 if phase = 8 [set shape  "gibbous4"]
 if phase = 9 [set shape  "gibbous3"]
 if phase = 10 [set shape  "gibbous2"]
 if phase = 11 [set shape  "gibbous1"]
 if phase = 12 [set shape  "full"]
  
  if phase = 13 [set shape  "gibbous1wane"] 
 if phase = 14 [set shape  "gibbous2wane"] 
 if phase = 15 [set shape  "gibbous3wane"] 
 if phase = 16 [set shape  "gibbous4wane"] 
 if phase = 17 [set shape  "gibbous5wane"] 
 if phase = 18 [set shape  "halfwane"]
 
 if phase = 19 [set shape  "crescent5wane"]
 if phase = 20 [set shape  "crescent4wane"] 
 if phase = 21 [set shape  "crescent3wane"] 
 if phase = 22 [set shape  "crescent2wane"] 
 if phase = 23 [set shape  "crescent1wane"] 
 if phase = 24 [set shape  "new"] 
  ]
end

to trace-sunlight
  ask turtle 3 [
    if sun-step = 1
    [set ycor [ycor] of turtle 2
     pd
     set heading 270
     fd 1 ;;wait .04
     if xcor < ([xcor] of turtle 2 + 1)
       [set sun-step 2]
    ]
    if sun-step = 2
    [set heading towardsxy 0 0
      fd 1 ;;wait .04
      if abs xcor < 2 and abs ycor < 2
        [set sun-step 3]
    ]
    
    if sun-step = 3
      [pu 
       setxy max-pxcor [ycor] of turtle 2
       ht
       set sun-step 1
      ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
137
10
537
431
32
32
6.0
1
10
1
1
1
0
1
1
1
-32
32
-32
32
0
0
1
ticks

BUTTON
12
10
78
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
12
60
75
93
Run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
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

crescent1
false
0
Circle -1 true false 6 6 288
Polygon -16777216 true false 150 4 209 21 250 56 272 92 285 149 277 199 247 249 203 282 151 297 96 289 40 249 7 193 2 156 13 90 36 54 66 27 117 8

crescent1wane
false
0
Circle -1 true false 6 6 288
Polygon -16777216 true false 150 4 91 21 50 56 28 92 15 149 23 199 53 249 97 282 149 297 204 289 260 249 293 193 298 156 287 90 264 54 234 27 183 8

crescent2
false
0
Circle -1 true false 4 3 288
Polygon -16777216 true false 146 1 183 17 217 42 251 87 266 147 255 200 224 247 193 274 147 294 85 280 36 246 3 190 -2 153 9 87 32 51 62 24 113 5

crescent2wane
false
0
Circle -1 true false 8 3 288
Polygon -16777216 true false 154 1 117 17 83 42 49 87 34 147 45 200 76 247 107 274 153 294 215 280 264 246 297 190 302 153 291 87 268 51 238 24 187 5

crescent3
false
0
Circle -1 true false 4 3 288
Polygon -16777216 true false 146 1 179 21 207 51 231 102 240 150 235 200 214 245 187 273 147 294 85 280 36 246 3 190 -2 153 9 87 32 51 62 24 113 5

crescent3wane
false
0
Circle -1 true false 8 3 288
Polygon -16777216 true false 154 1 121 21 93 51 69 102 60 150 65 200 86 245 113 273 153 294 215 280 264 246 297 190 302 153 291 87 268 51 238 24 187 5

crescent4
false
0
Circle -1 true false 4 3 288
Polygon -16777216 true false 146 1 166 27 188 62 206 114 210 150 205 191 191 240 172 268 147 294 85 280 36 246 3 190 -2 153 9 87 32 51 62 24 113 5

crescent4wane
false
0
Circle -1 true false 8 3 288
Polygon -16777216 true false 154 1 134 27 112 62 94 114 90 150 95 191 109 240 128 268 153 294 215 280 264 246 297 190 302 153 291 87 268 51 238 24 187 5

crescent5
false
0
Circle -1 true false 4 3 288
Polygon -16777216 true false 148 2 156 27 165 56 172 90 181 135 181 181 171 236 161 269 149 295 87 281 38 247 5 191 0 154 11 88 34 52 64 25 115 6

crescent5wane
false
0
Circle -1 true false 8 3 288
Polygon -16777216 true false 152 2 144 27 135 56 128 90 119 135 119 181 129 236 139 269 151 295 213 281 262 247 295 191 300 154 289 88 266 52 236 25 185 6

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

earth-half
true
0
Circle -13345367 true false -4 -5 304
Polygon -7500403 true true 150 0 150 30 150 60 150 90 150 135 150 180 150 240 150 270 148 302 86 291 34 255 2 200 -7 143 5 90 26 51 60 15 105 0

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

full
false
0
Circle -1 true false 6 6 288

gibbous1
false
0
Circle -16777216 true false 6 6 288
Polygon -1 true false 150 4 91 21 50 56 28 92 15 149 23 199 53 249 97 282 149 297 204 289 260 249 293 193 298 156 287 90 264 54 234 27 183 8

gibbous1wane
false
0
Circle -16777216 true false 6 6 288
Polygon -1 true false 150 4 209 21 250 56 272 92 285 149 277 199 247 249 203 282 151 297 96 289 40 249 7 193 2 156 13 90 36 54 66 27 117 8

gibbous2
false
0
Circle -16777216 true false 8 3 288
Polygon -1 true false 154 1 117 17 83 42 49 87 34 147 45 200 76 247 107 274 153 294 215 280 264 246 297 190 302 153 291 87 268 51 238 24 187 5

gibbous2wane
false
0
Circle -16777216 true false 4 3 288
Polygon -1 true false 146 1 183 17 217 42 251 87 266 147 255 200 224 247 193 274 147 294 85 280 36 246 3 190 -2 153 9 87 32 51 62 24 113 5

gibbous3
false
0
Circle -16777216 true false 8 3 288
Polygon -1 true false 154 1 121 21 93 51 69 102 60 150 65 200 86 245 113 273 153 294 215 280 264 246 297 190 302 153 291 87 268 51 238 24 187 5

gibbous3wane
false
0
Circle -16777216 true false 4 3 288
Polygon -1 true false 146 1 179 21 207 51 231 102 240 150 235 200 214 245 187 273 147 294 85 280 36 246 3 190 -2 153 9 87 32 51 62 24 113 5

gibbous4
false
0
Circle -16777216 true false 8 3 288
Polygon -1 true false 154 1 134 27 112 62 94 114 90 150 95 191 109 240 128 268 153 294 215 280 264 246 297 190 302 153 291 87 268 51 238 24 187 5

gibbous4wane
false
0
Circle -16777216 true false 4 3 288
Polygon -1 true false 146 1 166 27 188 62 206 114 210 150 205 191 191 240 172 268 147 294 85 280 36 246 3 190 -2 153 9 87 32 51 62 24 113 5

gibbous5
false
0
Circle -16777216 true false 8 3 288
Polygon -1 true false 152 2 144 27 135 56 128 90 119 135 119 181 129 236 139 269 151 295 209 284 262 247 295 191 300 154 289 88 266 52 236 25 191 5

gibbous5wane
false
0
Circle -16777216 true false 4 3 288
Polygon -1 true false 148 2 156 27 165 56 172 90 181 135 181 181 171 236 161 269 149 295 91 284 38 247 5 191 0 154 11 88 34 52 64 25 109 5

half
false
0
Circle -1 true false 4 3 288
Polygon -16777216 true false 148 2 150 30 150 60 150 90 150 135 150 180 150 240 150 270 149 295 87 281 38 247 5 191 0 154 11 88 34 52 64 25 115 6

halfwane
false
0
Circle -16777216 true false 4 3 288
Polygon -1 true false 148 2 150 30 150 60 150 90 150 135 150 180 150 240 150 270 149 295 87 281 38 247 5 191 0 154 11 88 34 52 64 25 115 6

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

new
false
0
Circle -1 true false 0 0 300
Circle -16777216 true false 1 1 298

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

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
