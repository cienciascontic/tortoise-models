globals [ year   year-length  fence?  grass? teeth-avg]
breed [ males ]
breed [ females ]

turtles-own [ energy  teeth  age ]
males-own [  geneA geneB geneC geneD ]     
    ;; A and B are the two chromosomes that have the teeth allele on them.
    ;; C and D are the two chromosomes with some other allele on them.         
females-own [   geneA geneB geneC geneD  ]  ;;
patches-own [ countdown ]
  
  to startup
  setup
  end
  
to setup 
  clear-all
  set year 0
  set year-length 12
  ask patches [ set pcolor green ]
  set fence? false    ;;this is not in use
  set grass? true ;; grass is always on
  if grass? [
      ;; indicates whether the grass switch is on  
      ;; if it is true, then grass grows and the sheep eat it  
      ;; if it false, then the sheep don't need to eat  
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
    set size 3
    set age random 5
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    repeat 6 [if pcolor = red [rt 90 fd 3 ]]
;;set each gene to 0 or 1, randomly 
    set geneA random 2
    set geneB random 2
    set geneC random 2
    set geneD random 2
  ] 
  
    create-females (initial-number / 2)  ;; create the females, then initialize their variables
  [ 
    set color white
    set size 3
    set age random 5
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    if pcolor = red [rt 180 fd 1] 
    repeat 6 [if pcolor = red [rt 90 fd 3 ]]
;;set each gene to 0 or 1, randomly 
    set geneA random 2
    set geneB random 2
    set geneC random 2
    set geneD random 2
]  

;;if selection? = true, make better teeth dominant (TT = best teeth, tT, Tt = better teeth; tt = worse teeth)
;; if selection? = false, the teeth size doesn't affect energy from eating
  ask turtles [ 
      if (geneA + geneB = 2)   [set teeth 1.2]   ;; TT condition
      if (geneA + geneB = 1)   [set teeth 1.0]   ;; tT and Tt condition
      if (geneA + geneB = 0)   [set teeth 0.8]   ;; tt condition

      ]
  ;;display-labels
  set teeth-avg (sum [teeth] of turtles) / count turtles
  setup-histogram
  do-plot
end

to go
;   ask patches [
;      if pxcor = 0 and (abs pycor  < screen-edge-y)
;         [if fence?  [set pcolor red] ]    
;        ]
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
        
    if grass? [ ask patches [ grow-grass ] ]
    ask turtles [set size 3 * teeth]
    display
    ] 
    
    ask males  [ 
      set age age + 1
    ]
    
    ask females [
      set age age + 1 
      if age > 1 and age <= 6 [reproduce]
    ]
   ;; if auto-reap?  [reaper]
    set year year + 1
    if count turtles >  0 [
    set teeth-avg (sum [teeth] of turtles) / count turtles
    do-plot ] ;; plot populations
    remove-some
 ;;   ask turtles [set size (teeth * 2)]
  if not any? turtles [ stop ]
end

to move  ;; turtle procedure
  rt random-float 50 - random-float 50
  fd 1
  if pcolor = red [rt 180 fd 1] 
end

to eat-grass  ;; turtle procedure
  ;; sheep eat grass, turn the patch brown
  if grass? [
      set energy energy - 1 ;; deduct energy for sheep only if grass? switch is on
      
    if pcolor = green [ 
      set pcolor brown 
      ifelse selection? ;;no selection pressure on teeth if selection? = false
        [set energy energy + (gain-from-food * teeth) ] ;; sheep gain more energy if they have better teeth
        [set energy energy + (gain-from-food * 1) ] ;; all sheep gain the same energy
     ] ]
end

to reproduce
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
      [set breed males ] 
      [set breed females ]
 
 ;; geneA and geneB match the mother's by default. Choose baby's geneA to match one
 ;; of mother's genes.
    ifelse (random 2 = 1) ;;
      [set geneA geneA ];; same as mother's first chromosome
      [set geneA geneB];; same as mother's second chromosome
      
;;; set geneB to match one of father's genes.
    ifelse (random 2 = 1)
      [set geneB [geneA] of one-of males]
      [set geneB [geneB] of one-of males]
  ;; T is dominant for better teeth
      if (geneA + geneB = 2)   [set teeth 1.2]   ;; TT condition
      if (geneA + geneB = 1)   [set teeth 1.0]   ;; tT and Tt condition
      if (geneA + geneB = 0)   [set teeth 0.8]   ;; tt condition
     ] ]
end

to remove-some
   ifelse ((count turtles with [teeth = 1.2]) > remove-number) [
   ask n-of remove-number turtles with [teeth = 1.2] [die]
   ]
   [ask turtles with [teeth = 1.2] [die]]
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


to create-fences; patch procedure
if (abs pxcor) = max-pxcor   [set pcolor red]
if (abs pycor) = max-pycor [set pcolor red]
if pxcor = 0 and fence? [set pcolor red]
end

to setup-histogram
 ; set-current-plot "alleles: tt--tT--TT"
 ; set-plot-x-range -.5  2.5
 ; set-plot-y-range 0 initial-number-sheep
 ; set-histogram-num-bars 3
end

to do-plot 
  set-current-plot "Teeth Average"
  set-current-plot-pen "teeth" 
    plot teeth-avg
   
  set-current-plot "worse-avg-better"
  histogram [(geneA + geneB)] of  turtles   
  
  set-current-plot "teeth type percentage"
  set-current-plot-pen "better teeth"
    plot 100 * (count turtles with [teeth = 1.2]) / count turtles
      set-current-plot-pen "average teeth"
    plot 100 * (count turtles with [teeth = 1.0]) / count turtles
     set-current-plot-pen "worse teeth"
    plot 100 * (count turtles with [teeth = 0.8]) / count turtles
 
    
end

@#$#@#$#@
GRAPHICS-WINDOW
339
10
677
369
20
20
8.0
1
14
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

SLIDER
165
10
323
43
initial-number
initial-number
0
250
100
1
1
NIL
HORIZONTAL

SLIDER
166
78
322
111
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
165
44
323
77
grass-regrowth-rate
grass-regrowth-rate
5
95
80
5
1
NIL
HORIZONTAL

BUTTON
49
10
118
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
1

BUTTON
38
51
119
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
1

PLOT
301
390
497
610
Teeth Average
time
teeth
0.0
20.0
0.8
1.2
true
true
"" ""
PENS
"teeth" 1.0 0 -16777216 true "" ""

MONITOR
70
302
120
347
sheep
count turtles
3
1
11

MONITOR
11
302
61
347
year
year
0
1
11

TEXTBOX
15
207
157
266
Each year, reduce the herd by remove-number, chosen from those with best teeth
11
0.0
0

BUTTON
41
93
123
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
1

SWITCH
183
160
301
193
selection?
selection?
1
1
-1000

PLOT
508
390
675
610
worse-avg-better
NIL
NIL
-0.5
2.5
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

MONITOR
134
304
224
349
Teeth Average
teeth-avg
2
1
11

SLIDER
175
215
301
248
remove-number
remove-number
0
10
0
1
1
NIL
HORIZONTAL

TEXTBOX
14
156
164
204
if selection? is ON, animals with better teeth get more energy from grass
11
0.0
0

PLOT
10
390
290
610
Teeth type percentage
NIL
NIL
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"better teeth" 1.0 0 -2674135 true "" ""
"average teeth" 1.0 0 -6459832 true "" ""
"worse teeth" 1.0 0 -16777216 true "" ""

TEXTBOX
232
304
340
360
better teeth = 1.2\nstandard teeth = 1\nworse teeth = 0.8
11
0.0
0

SLIDER
166
115
322
148
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

		Evolution:  Sheep-selection
 This is a model of a flock of sheep whose survival depends on eating grass. The babies inherit traits from their parents according to Mendelian genetics. One can study the effect on the population of a trait that changes the energy they get from eating grass.

Here are are some explorations:  
1. Picture yourself as a farmer with a large field of sheep. You start with an equal number of males (horns) and females (no horns). They live for six years. The sheep move around the field and eat grass, which grows back at a certain rate. The patch is green if there is grass there, and brown if there is no grass. In the model, the sheep move and eat during each year. They use up energy as they move, and they gain energy from eating grass. If their energy goes to zero, they die. 

2. The sheep have one variable trait � the quality of their teeth. The ones with better teeth get more energy from the grass they eat, so they are less likely to lose energy and die as they wander around the field. This trait is turned on if SELECTION? = ON. It has no effect if SELECTION? = OFF.   
There are three levels of teeth:  
TEETH = 1.2		better  
TEETH = 1.0		standard	  
TEETH = 0.8		worse	

3. Once a year, from age 3 to age 6, each female mates with a randomly chosen male and gives birth to a baby. The baby inherits its TEETH trait from both its parents. 

4. If SELECTION? = ON, what do you think will happen to the average value of TEETH over time?

5. if SELECTION? = OFF, what do you think will happen to the average value of TEETH over time?

6. Run the model several times with the initial settings. Make sure SELECTION? = OFF. Note that the average value of TEETH, which is shown in the monitor above the graph, starts at 1.0.Watch the three graphs and notice what happens to the proportions of better, standard, and worse teeth. Also record the average value of TEETH after 50 years.

Run #	Value of TEETH after 50 years  
1	  
2	  
3	  
4	

7. What can you conclude about evolution of teeth in the herd?

8. Why do you think it�s not the same every time?

9. Set SELECTION? = ON. Now sheep with better teeth will get more food from grass and have less chance of starving to death. Run the model several times. Watch the three graphs and notice what happens to the proportions of better, standard, and worse teeth. Also record the average value of TEETH after 50 years.

10.  What can you conclude about the evolution of teeth in the herd?

11.  Here�s a challenge, designed to test our theory that the sheep population evolves better teeth because the ones with worse teeth starve to death more often. If that�s true, think about the effect of the value of GRASS-REGROWTH-RATE. As this value decreases (grass grows back more slowly), what would happen to how fast this adaptation becomes predominant in the population?   
a. [   ] Better teeth would evolve more quickly.  
b. [   ] Better teeth would evolve more slowly.  
c. [   ] The evolution rate would not change.  
d. [   ] The result would be unpredictable.

12. Explain your answer.

13. Now test this idea by running the model. Try changing GRASS-REGROWTH-RATE and record the average value of TEETH after 50 years. Keep all of the other variables constant. (INITIAL-NUMBER=100, BIRTHRATE-%=60, GAIN-FROM-FOOD=2)

## GRASS-REGROWTH-

RATE	Value of TEETH after 50 years  
85	  
70	  
55	  
40	

14. Combine your results with other teams. What can you conclude about the effect of a scarcity of grass on evolution of teeth? 

To watch a mutation in the sheep population, go on to sheep-mutation.
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
NetLogo 5.1.0
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
