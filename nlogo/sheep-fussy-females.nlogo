globals [ year   year-length  fence? teeth-avg gain-from-food ]
breed [ males ]
breed [ females ]

turtles-own [ energy  teeth  age   geneA geneB geneC geneD   ]   
    ;; A and B are the two chromosomes that have the teeth allele on them.
    ;; C and D are the two chromosomes with the cyan allele on them.         
patches-own [ countdown ]
  
to startup
setup
end

to setup 
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  clear-all
  set year 0
  set year-length 12
  set gain-from-food 2
  ask patches [ set pcolor green ]
  set fence? false    ;;this is not in use  
    ask patches [
      set countdown random (101 - grass-regrowth-rate) ;; initialize grass grow clocks randomly
      if (random 2) = 0  ;;half the patches start out with grass
          [ set pcolor brown ]
    ]
    ask patches [create-fences]
    
  set-default-shape females "ewes"
  set-default-shape males "rams2"
  create-males (initial-number-sheep / 2)  ;; create the males, then initialize their variables
  [ 
    set color white
    set size 2.5
    set age random 5
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    repeat 6 [if pcolor = red [rt 90 fd 3 ]]
;;set each gene to 0 or 1, randomly 
    set geneA random 2
    set geneB random 2
    set geneC 0 ;;random 2
    set geneD  0 ;; random 2
  ] 
  
    create-females (initial-number-sheep / 2)  ;; create the females, then initialize their variables
  [ 
    set color white
    set size 2.5
    set age random 5
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    if pcolor = red [rt 180 fd 1] 
    repeat 6 [if pcolor = red [rt 90 fd 3 ]]
;;set each gene to 0 or 1, randomly 
    set geneA random 2
    set geneB random 2
    set geneC  0 ;;random 2
    set geneD 0 ;;random 2
]  


;; geneA and geneB arene't expressed in this model
  ask turtles [ 
      if (geneA + geneB = 2)   [set teeth 1.0]   ;; TT condition
      if (geneA + geneB = 1)   [set teeth 1.0]   ;; tT and Tt condition
      if (geneA + geneB = 0)   [set teeth 1.0]   ;; tt condition

      ]
  ;;display-labels
  set teeth-avg (sum [teeth] of turtles) / count turtles
  setup-histogram
  do-plot
  reset-ticks
end

to go
   ask patches [
      if pxcor = 0 and (abs pycor  < max-pycor)
         [if fence?  [set pcolor red] ]    
        ]
        
  ;; make CD very favorable -- regardless of what geneA and geneB are
    ask turtles [if color = cyan [set teeth 2]]
 
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
   ;; if auto-reap?  [reaper]
    set year year + 1
    if count turtles >  0 [set teeth-avg (sum [teeth] of turtles) / count turtles]
    do-plot  ;; plot populations
 
   ;;express the mutation CD (not Cd,cD, or cd) as changing colo
    ask turtles [    
     if (geneC + geneD = 2) 
       [set color cyan]  
       ]
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
      set energy energy - 1 ;; deduct energy for sheep only if grass? switch is on
      
    if pcolor = green [ 
      set pcolor brown 
      ifelse selection? ;;no selection pressure on teeth if selection? = false
        [set energy energy + (gain-from-food * teeth) ] ;; sheep gain more energy if they have better teeth
        [set energy energy + (gain-from-food * 1) ] ;; all sheep gain the same energy
      ]
end

to reproduce
    breed-and-birth  ;; females mate with any ram in the whole field  
end

to breed-and-birth ;; turtle procedure
  if count males with [color = white] > 0  [   ;; use this to prevent a runtime error if the population is near to extinction
    hatch 1 [
    fd 10
    set age 0
    set energy 3
    ifelse (random 2 = 1) 
      [set breed males ] 
      [set breed females ]
; 
; ;; geneA and geneB match the mother's by default. Choose baby's geneC to match one
; ;; of mother's genes.

     ifelse (random 2 = 1) ;;
      [set geneC geneC ];; same as mother's first chromosome
      [set geneC geneD];; same as mother's second chromosome
  
;;;; set geneD to match one of father's genes.

  ifelse fussyfemales? = true 
    [ifelse (random 2 = 1)
      [set geneD [geneC] of (one-of males with [color = white ])]
      [set geneD [geneD] of (one-of males with [color = white ])]
    ]
   [ifelse (random 2 = 1)
      [set geneD [geneC] of (one-of males )]
      [set geneD [geneD] of (one-of males )]
    ]
;;express the gene CD -- better teeth are recessive
     if (geneC + geneD = 2)   [set teeth 2.0]   ;; cc condition
     if (geneC + geneD = 1)   [set teeth 1.0]   ;; cC condition
     if (geneC + geneD = 0)   [set teeth 1.0]   ;; CC condition
     ifelse (geneC + geneD = 2)
      [set color cyan]
      [set color white]

   
;      
;  ;; T is dominant for better teeth
;      if (geneA + geneB = 2)   [set teeth 1.0]   ;; TT condition
;      if (geneA + geneB = 1)   [set teeth 1.0]   ;; tT and Tt condition
;      if (geneA + geneB = 0)   [set teeth 1.0]   ;; tt condition
     ] 
  ] 
end

to add-mutants
  crt  number-added [
    ifelse (random 2 = 0) 
      [set breed females]
      [set breed males]
    set color cyan
    set size 2.5
    set age 2
    set energy random (2 * gain-from-food)
    setxy random-float world-width
          random-float world-height
    if pcolor = red [ fd 3 ]
    set geneA random 2
    set geneB random 2
    set geneC 1
    set geneD 1
    ]
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
  set-current-plot "cc--cC--CC"
  set-plot-x-range -.5  2.5
  set-plot-y-range 0 initial-number-sheep
  set-histogram-num-bars 3
end

to do-plot 
  set-current-plot "populations"
  set-current-plot-pen "white sheep" 
    plot (count turtles with [color = white])
 
  ;; divide by four to keep it within similar range as sheep populations                                         
;  set-current-plot-pen "grass"
 ;   plot (count patches with [pcolor = green]) / 4
  set-current-plot-pen "blue mutation"
    plot count turtles with [color = cyan]
   
 set-current-plot "cc--cC--CC"
  histogram [(geneC + geneD)] of  turtles
end

@#$#@#$#@
GRAPHICS-WINDOW
339
10
719
411
18
18
10.0
1
14
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
30.0

SLIDER
165
10
322
43
initial-number-sheep
initial-number-sheep
0
250
100
1
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
22
10
91
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
20
89
107
122
run once
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
8
333
317
593
populations
time
pop.
0.0
20.0
0.0
100.0
true
true
"" ""
PENS
"white sheep" 1.0 0 -16777216 true "" ""
"grass" 1.0 0 -10899396 true "" ""
"blue mutation" 1.0 0 -11221820 true "" ""

MONITOR
64
275
141
320
white sheep
count turtles with [color = white]
1
1
11

MONITOR
5
275
55
320
year
year
0
1
11

BUTTON
18
50
106
83
run/stop
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
189
91
307
124
selection?
selection?
0
1
-1000

MONITOR
152
277
222
322
blue sheep
count turtles with [color = cyan]
2
1
11

TEXTBOX
190
131
340
187
if selection? is ON, blue sheep get much more energy from grass
11
0.0
0

BUTTON
22
153
131
186
add mutants
add-mutants
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
20
191
136
224
number-added
number-added
0
20
9
1
1
NIL
HORIZONTAL

TEXTBOX
33
231
151
252
adds blue sheep
11
0.0
0

PLOT
346
423
506
593
CC--cC--cc
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

TEXTBOX
537
507
627
535
Only cc has better teeth
11
0.0
0

SWITCH
179
189
308
222
fussyfemales?
fussyfemales?
1
1
-1000

TEXTBOX
178
227
317
255
fussy females won't mate with blue males
11
0.0
0

@#$#@#$#@

		Evolution:  Sheep-fussyfemales
 This is a model of a flock of sheep whose survival depends on eating grass. The babies inherit traits from their parents according to Mendelian genetics. One can watch the spread of a mutation and how it depends on selection pressure. There are two such pressures here: the energy sheep get from grass, and the fact that females will not breed with mutated sheep.

Here are are some explorations:  
1. Picture yourself as a farmer with a large field of sheep. You start with an equal number of males (horns) and females (no horns). They live for six years. The sheep move around the field and eat grass, which grows back at a certain rate. The patch is green if there is grass there, and brown if there is no grass. In the model, the sheep move and eat during each year. They use up energy as they move, and they gain energy from eating grass. If their energy goes to zero, they die. 

2. Once a year, from age 3 to age 6, each female mates with a randomly chosen male and gives birth to a baby. The baby inherits its TEETH trait from both its parents. 

3. In this version, all of the sheep have standard teeth. There are two new   
features, one a pressure in favor of the muation, and one opposing it:  
a. An ADD MUTANTS button. When you hit this button, some blue sheep are added to the herd. Sheep pass their color gene on to their offspring.   
b. A FUSSYFEMALES button. When you hit this button, females refuse to mate with blue (mutated) males.

4. If SELECTION? = ON, a blue sheep gets twice as much energy from grass as a regular sheep. If SELECTION? = OFF, the blue color has no effect on its eating or how likely it is to survive and have offspring.

5. Try the model with SELECTION? on or off, and FUSSYFEMALES? on or off. Run the model, add at least 15 mutants, and fill in the following table. 

Condition			What happens

## SELECTION? = OFF

FUSSYFEMALES? = ON
	  
## SELECTION? = ON

FUSSYFEMALES? = OFF
	  
## SELECTION? = ON

FUSSYFEMALES? = ON
	
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
