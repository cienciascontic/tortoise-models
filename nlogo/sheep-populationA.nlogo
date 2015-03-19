globals [ year   year-length   avg-pop ]
breed [ males ]
breed [ females ]

turtles-own [ energy  teeth  age ]
males-own [  ]          
females-own [   ]  
patches-own [ countdown]
  
  
to startup
setup
end

to setup 
  ca
  set year 0
  set year-length 12
  ask patches [
      set pcolor green
      set countdown random (101 - grass-regrowth-rate) ;; initialize grass grow clocks randomly
      if (random 2) = 0  ;;half the patches start out with grass
          [ set pcolor brown ]
      create-fences
    ]
 
  set-default-shape females "ewes"
  set-default-shape males "rams2"
  create-males (initial-number / 2)  ;; create the males, then initialize their variables
  [ 
    set color white
    set size 3.5
    set age random 5
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    repeat 6 [if pcolor = red [rt 90 fd 3 ]]
  ] 
  
    create-females (initial-number / 2)  ;; create the females, then initialize their variables
  [ 
    set color white
    set size 3.5
    set age random 5
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    if pcolor = red [rt 180 fd 1] 
    repeat 6 [if pcolor = red [rt 90 fd 3 ]]
]  

  set avg-pop initial-number
  do-plot
end

to go
  repeat year-length [
  ask males [
        move
        eat-grass
        death
        ] 
  
    ask females [
        move
        eat-grass 
        death
        ]
    ask patches [ grow-grass ]
    display
    ] 
    
    ask males  [ 
      set age age + 1
    ]
    
    ask females [
      set age age + 1 
      if age > 1 and age <= 6 [reproduce]
    ]
    set year year + 1
    do-plot  ;; plot populations
  if not any? turtles [ stop ]
end

to move  ;; turtle procedure
  rt random-float 50 - random-float 50
  fd 1
  if pcolor = red [rt 180 fd 1] 
end

to eat-grass  ;; turtle procedure
  ;; sheep eat grass, turn the patch brown
    set energy energy - 1 ;; lose energy when they move 
    if pcolor = green 
      [ set energy  energy + gain-from-food 
      set pcolor brown]
end

to reproduce  ;;turtle procedure
  if random 100 < birthrate-%
    [ breed-and-birth ] ;; females mate with any ram in the whole field, "birth-rate" percent of the time 
end

to breed-and-birth ;; turtle procedure
  if count males > 0 [  ;; use this to prevent a runtime error if the population is near to extinction
    hatch 1 [
    fd 10
    set age 0
    set energy 3
    ifelse (random 2 = 1) 
      [set breed males] 
      [set breed females]
     ] ]
end


to death  ;; turtle procedure
  ;; when energy dips below zero, or sheep gets old, die
  if energy < 0 [ die ] 
  if age > 6 [die ]
end

to create-fences ;; patch procedure
if (abs pxcor) = max-pxcor   [set pcolor red]
if (abs pycor) = max-pycor [set pcolor red]
end

to grow-grass  ;; patch procedure
  ;; countdown on brown patches, if reach 0, grow some grass
  if pcolor = brown [ 
    ifelse countdown <= 0
      [ set pcolor green
        set countdown (102 - grass-regrowth-rate) ] 
      [ set countdown (countdown - 1) ] 
  ] 
end

to smooth
  set avg-pop (0.9 * avg-pop + 0.1 * count turtles)
end

to do-plot 
  smooth
  set-current-plot "populations"
  set-current-plot-pen "sheep" 
    plot (count turtles)       
;  set-current-plot-pen "avg-total"
;    plot avg-pop         
 
  ;; divide by four to keep it within similar range as sheep populations                                         
  set-current-plot-pen "grass"
    plot (count patches with [pcolor = green]) / 4
  
end


@#$#@#$#@
GRAPHICS-WINDOW
278
22
621
386
18
18
9.0
1
12
1
1
1
0
1
1
1
-18
18
-18
18
0
0
1
ticks

SLIDER
104
10
254
43
initial-number
initial-number
0
250
70
5
1
NIL
HORIZONTAL

SLIDER
105
84
254
117
gain-from-food
gain-from-food
0.0
4
2
0.5
1
NIL
HORIZONTAL

SLIDER
104
48
252
81
grass-regrowth-rate
grass-regrowth-rate
0
95
80
5
1
NIL
HORIZONTAL

BUTTON
15
11
84
44
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
14
52
95
85
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
17
223
269
414
populations
time
pop.
0.0
20.0
0.0
100.0
true
true
PENS
"sheep" 1.0 0 -16777216 true
"grass" 1.0 0 -10899396 true

MONITOR
91
163
164
208
population
count turtles
3
1
11

MONITOR
19
163
69
208
year
year
0
1
11

BUTTON
12
94
94
127
go/stop
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
105
121
253
154
birthrate-%
birthrate-%
0
100
100
1
1
NIL
HORIZONTAL

MONITOR
194
165
253
210
% grass
100 * (count patches with [pcolor = green]) / (count patches)
0
1
11

@#$#@#$#@

		Evolution:  Sheep-populationA
 This is a model of a flock of sheep whose survival depends on eating grass. One can study the effect on the population of initial number, grass regrowth rate, and birthrate.

Here are are some explorations:

1. Picture yourself as a rancher with a large field of sheep. You start with an equal number of males (horns) and females (no horns). They live for six years. The sheep move around the field and eat grass, which grows back at a certain rate. The patch is green if there is grass there, and brown if there is no grass. In the model, the sheep move and eat during the year. They use up energy as they move, and gain energy from eating grass. If their energy goes to zero, they die. 

2. Once a year, from age 3 to age 6, each female gives birth to a baby. 

3. To run the model, always first hit SETUP. Hit GO-ONCE to run the model for one year. Hit GO-FOREVER to run the model continuously. To stop, hit the same button again. The graph shows the amount of grass (green) and the total population (black) as time goes by.

4. Run the model for about 50 years. What do you observe about the relationship between the grass and the population? 
5. 
Use GO-ONCE instead of GO-FOREVER, and run one year at a time. Look more carefully at the relationship between sheep and grass. If you drag the cursor onto the graph, you can read values at the location of the cursor. Before you run the next year, try to predict whether the sheep and grass will go up or down. Describe what you observe.

6. What causes this pattern?

7. Using the GO-FOREVER button, run the model for 100 years. Even though the population always goes up and down, what is the ÒaverageÓ value that is roughly at the center of these fluctuations? 

8.  Look at the last 30 years (year 70 to year 100). How big are the fluctuations? 
Maximum population	
Minimum population	
Size of fluctuation	

9. Suppose you had thousands of sheep, in a much larger field, instead of a few hundred. Do you think the population would be steadier?
a. [ ] Yes, fluctuations not so big.
b. [  ] No, larger fluctuations.
c. [  ] It would make no difference.

10. Why do you think so?

11. The model allows you to adjust several factors. Try changing them one at a time, following the steps below. After that, you can do other experiments on your own. Here are the starting values:
¥ INITIAL-NUMBER = starting number of sheep = 100 
¥ GRASS-REGROWTH-RATE = how fast the grass grows back = 80
¥ GAIN-FROM-FOOD = amount of food they gain from eating a square of grass = 2.0
¥ BIRTHRATE-% = chance that a female will have a baby once a year = 100%

12. Suppose the starting number was 200, in the same field. What would happen to the average population after a period of time, compared to a starting number of 100? 
a. [  ] It would be greater
b. [  ] It would be less
c. [  ] It would be about the same

13. Now try it. You must hit SETUP each time you change INITIAL-NUMBER.
a. Set INITIAL-NUMBER = 200. Hit SETUP, then GO-FOREVER. Run it for 50 years. Notice the average long-term population. Fill in the table. 
b. Set INITIAL-NUMBER = 100 and again notice the average long-term population after 50 years. Fill in the table. 
c. Set INITIAL-NUMBER = 50. Fill in the table. 

INITIAL-NUMBER	Average long-term population
200	
100	
50	

14. Is there a pattern in the long-term population?
a. [  ] It is greater if the initial number is greater
b. [  ] It is less if the initial number is greater
c. [  ] It is about the same
d. [  ] It changes but there is no pattern  

15. How can you explain this result?

16. What would happen to the average population if you decreased GRASS-REGROWTH-RATE? This might be caused by a decrease in rainfall.
a. [  ] It would decrease
b. [  ] It would increase
c. [  ] It would stay the same

17. Now try it. Set INITIAL-NUMBER back to 100. Run the model and try different values of GRASS-REGROWTH-RATE. You can change GRASS-REGROWTH-RATE while the model is running. Fill in the table. 

GRASS-REGROWTH-RATE	Average long-term population
95	
80	
50	

18. What happens to the population?
a. [  ] It is greater if the grass growth rate is greater
b. [  ] It is less if the grass growth rate is greater
c. [  ] It is about the same  
d. [  ] There is no pattern

19. How can you explain this result?

20. What would happen to the average population if GAIN-FROM-FOOD (the energy sheep get from eating grass) were reduced? This might correspond to a grass that was less nutritious.
e. [  ] It would decrease
f. [  ] It would increase
g. [  ] It would stay the same

21. Now try it. Set GRASS-REGROWTH-RATE back to 80. Run the model and try different values of GAIN-FROM-FOOD. You can change GAIN-FROM-FOOD while the model is running. Fill in the table.

GAIN-FROM-FOOD	Average long-term population
3	
2.5	
2	
1.5	
1	

Describe the pattern you observe and explain why you think this happens.

To explore other features of this population, go on to sheep-populationB.

To explore evolutionary adaptation, go on to sheep-selection.



@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ewes
false
15
Polygon -1 true true 91 124 70 96 41 91 16 101 1 127 2 147 23 170 49 175 49 202 58 216 48 248 61 293 85 292 72 251 90 208 122 220 152 220 198 212 190 252 201 287 231 288 215 249 227 186 229 173 220 146 241 153 249 179 252 191 270 189 259 148 239 121 195 116 168 116 140 116 122 123
Polygon -1 true true 247 175 218 151 215 142 237 144
Polygon -1 true true 84 218 135 233 169 229 200 224 198 207 104 203 75 203
Polygon -1 true true 3 126 12 97 29 88 39 88 63 94
Polygon -1 true true 269 188 263 212 247 208 253 192

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

rams
false
15
Polygon -1 true true 93 94 226 95 246 101 271 126 283 161 286 190 269 195 256 176 240 151 221 139 232 185 230 221 219 250 240 295 205 295 185 238 192 197 158 193 110 195 91 199 80 248 90 294 60 296 38 232 60 177 51 165 46 149 45 140 20 136 6 115 2 101 2 85 3 68 18 55 45 38 71 33 105 43 114 68 108 83 98 81 100 65 90 58 70 56 55 66 73 71 83 90
Polygon -1 true true 93 93 157 81 194 81 233 95 177 122
Polygon -1 true true 90 196 135 203 193 199 152 186 103 189

rams2
false
15
Polygon -1 true true 92 102 157 97 238 108 266 146 274 183 270 199 260 197 248 159 229 137 242 184 242 208 232 250 251 292 225 295 204 240 208 195 155 202 92 181 56 206 67 252 39 252 30 199 72 157 59 127 35 125 15 120 3 100 1 68 12 46 47 35 13 47 52 28 78 22 110 25 126 39 129 53 116 73 103 74 111 55 99 39 69 42 64 50 82 66 92 90 126 91 155 97 156 98
Polygon -1 true true 69 55 83 41 58 40 57 56

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92
Rectangle -1 true true 35 108 38 119
Circle -1 true true 75 91 44
Circle -1 true true 73 98 108
Circle -1 true true 19 103 81
Circle -1 true true 39 81 64
Circle -1 true true 29 159 34
Circle -1 true true 20 147 24
Circle -16777216 true false 44 108 3
Circle -16777216 true false 52 120 3
Circle -16777216 true false 0 56 110
Rectangle -1 true true 80 227 137 289
Rectangle -1 true true 181 229 240 287
Circle -1 true true -2 56 115

sheep2
false
15
Rectangle -1 true true 64 116 243 214
Rectangle -1 true true 244 214 244 215
Rectangle -1 true true 244 215 245 216
Rectangle -1 true true 91 220 127 280
Rectangle -1 true true 189 221 224 283
Rectangle -1 true true 189 221 189 220
Circle -1 true true 12 65 105
Polygon -1 true true 129 116 195 105 257 124 246 175
Polygon -1 true true 258 128 271 193 264 195 251 157
Polygon -7500403 true false 58 69 90 72 94 111 76 118 59 110 63 84
Polygon -7500403 true false 63 93 50 115 76 117
Polygon -1 true true 224 219 190 218 191 225
Rectangle -1 true true 190 221 225 226
Rectangle -1 true true 92 220 127 225
Polygon -1 true true 250 164 253 196 264 198 276 195 274 159 257 128

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
setup
set grass? true
repeat 75 [ go ]
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
