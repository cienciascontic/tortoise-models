globals [ year   year-length  avg-pop ]
breed [ males ]
breed [ females ]

turtles-own [ energy  teeth  age ]
males-own [  ]            
females-own [  ]  
patches-own [ countdown]

to startup
setup
end
  
to setup 
  ca
  set year 0
  set year-length 12
  ask patches [ set pcolor green ]
  if limited-grass? [
      ;; indicates whether the grass switch is on  
      ;; if it is true, then grass grows and the sheep eat it  
      ;; if it false, then the grass grows back instantly 
    ask patches [
      set countdown random (101 - grass-regrowth-rate) ;; initialize grass grow clocks randomly
      if (random 2) = 0  ;;half the patches start out with grass
          [ set pcolor brown ]
    ]
  ]
    ask patches [create-fences]
    
  set-default-shape females "ewes"
  set-default-shape males "rams2"
  create-males (initial-number / 2)  ;; create the males, then initialize their variables
  [ 
    set color white
    set size 2.5
    set age random 5
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    repeat 6 [if pcolor = red [rt 90 fd 3 ]]
  ] 
  
    create-females (initial-number / 2)  ;; create the females, then initialize their variables
  [ 
    set color white
    set size 2.5
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
       
    if limited-grass? [ ask patches [ grow-grass ] ]
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
  if limited-grass? [
    set energy energy - 1 ;; deduct energy for sheep only if limited-grass? switch is on 
    if pcolor = green [ 
      set pcolor brown 
    set energy energy + gain-from-food  ] ;; sheep gain more energy if they have better teeth
     ] 
     
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

to grow-grass  ;; patch procedure
  ;; countdown on brown patches, if reach 0, grow some grass
  if pcolor = brown [ 
    ifelse countdown <= 0
      [ set pcolor green
        set countdown (102 - grass-regrowth-rate) ] 
      [ set countdown (countdown - 1) ] 
  ] 
end

to reaper
   ifelse (count turtles > number-removed) [
   ask n-of number-removed turtles [die]
   ]
   [ask turtles [die]]
end

to create-fences; patch procedure
if (abs pxcor) = max-pxcor   [set pcolor red]
if (abs pycor) = max-pycor [set pcolor red]
;; if pxcor = 0 [set pcolor red]
end

to smooth
set avg-pop (0.95 * avg-pop + 0.05 * count turtles)
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
301
10
662
392
19
19
9.0
1
14
1
1
1
0
1
1
1
-19
19
-19
19
0
0
1
ticks

SLIDER
96
11
246
44
initial-number
initial-number
0
250
70
10
1
NIL
HORIZONTAL

SLIDER
97
85
246
118
gain-from-food
gain-from-food
0.0
4
2
0.5
1
NIL
HORIZONTAL

SWITCH
9
169
139
202
limited-grass?
limited-grass?
0
1
-1000

SLIDER
96
49
247
82
grass-regrowth-rate
grass-regrowth-rate
.5
95
80.5
5
1
NIL
HORIZONTAL

BUTTON
12
10
81
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
11
51
92
84
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
9
328
290
525
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
75
269
148
314
population
count turtles
3
1
11

MONITOR
13
270
63
315
year
year
0
1
11

BUTTON
185
178
257
211
reaper
reaper
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

TEXTBOX
10
205
156
264
ON: grass slowly regrows after it is eaten.\nOFF: grass grows back instantly. 
11
0.0
0

SLIDER
155
216
286
249
number-removed
number-removed
0
100
30
1
1
NIL
HORIZONTAL

TEXTBOX
171
256
278
284
reduce the herd by number-removed
11
0.0
0

BUTTON
9
93
91
126
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
97
122
245
155
birthrate-%
birthrate-%
0
100
100
1
1
NIL
HORIZONTAL

@#$#@#$#@
		Evolution:  Sheep-populationB
 This is a model of a flock of sheep whose survival depends on eating grass. One can study the effect on the population of initial number, grass regrowth rate, and birthrate. PopulationB focuses on uncontrolled growth.

Here are are some explorations:

1. Picture yourself as a rancher with a large field of sheep. You start with an equal number of males (horns) and females (no horns). They live for six years. The sheep move around the field and eat grass, which grows back at a certain rate. The patch is green if there is grass there, and brown if there is no grass. In the model, the sheep move and eat during the year. They use up energy as they move, and gain energy from eating grass. If their energy goes to zero, they die. 

2. Once a year, from age 3 to age 6, each female gives birth to a baby. 

3. To run the model, always first hit SETUP. Hit GO-ONCE to run the model for one year. Hit GO-FOREVER to run the model continuously. To stop, hit the same button again. The graph shows the amount of grass (green) and the total population (black) as time goes by.

4. What would happen to the population if the sheep had as much grass as they wanted?

5. Try this with the model. Change the LIMITED-GRASS? Switch to OFF. Then there is unlimited grass for the sheep to eat. Click on SETUP. Click on GO-ONCE five times. As the number of sheep gets very large, the model will run more slowly! What happens to the population?

6. Start again by clicking on SETUP. Try using the REAPER button, which reduces the herd at the end of each year. The NUMBER-REMOVED slider sets how many sheep are removed by the REAPER button. Run the model with the GO-FOREVER button. Can you keep the population under control? How?

7. What you just did with the REAPER button is what must happen in nature to keep a population stable. Many animals die every year!

8. Now try changing the variable BIRTHRATE-%. This is the chance that a female will have a baby once a year. Try to keep the population stable even when the GO-FOREVER button is on. If the population gets out of control, stop, hit SETUP, and start again. What is a value of BIRTHRATE-% that keeps the population roughly steady when the grass growth is unlimited? 

9. Notice that the effect of changing the birthrate is delayed. Why is this?

10. What is the lowest value of BIRTHRATE-% for which the herd doesn�t die off?

11. If the sheep only died of old age, the birthrate for a constant population � called the �replacement rate� � should be about 50%. Here�s why.
a. For a 100% birthrate, each female has one baby a year for four years � a total of 4 babies in her lifetime.
b. For a 50% birthrate, each female has 2 babies in her lifetime. 
c. Since the male doesn�t have babies, the 2 babies just replace the mother and the father.
Is your minimum birthrate greater or less than 50%? 

12. Many animals � for example, mosquitoes and fish � may lay thousands of eggs in one year. Why might this be a good survival strategy. Why don�t they take over the world?

To explore extinction, go on to sheep-populationC.

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
