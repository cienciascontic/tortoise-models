;attributes of the simulation
breed [ worm ]

patches-own [grass]
turtles-own [life energy]
globals [
MAX_POPULATION       ;the maximum population of worms allowable (setting above 10000 is not recommended!)
MAX_GRASS_HEIGHT     ;max height of grass
]

to startup
setup
end


;get things ready
to setup
  set MAX_POPULATION 10000
  set MAX_GRASS_HEIGHT 50
  ct
  clear-plot
  clear-patches
  set-current-plot "population vs. time"

  create-worm Initial_Population   ;initial population of worms
  ask worm 
  	[getready set life Life_Span set energy Energy_Reserve]
  ask patches 
	  [set grass Food_Conversion]   ;start out with enough grass to eat
end

;time-tick events:  1. grow grass (then color it)  2. worms live  3. update plot
to time-tick

  ask patches 
      [set grass (grass + Growth_Rate)
 	     if grass > MAX_GRASS_HEIGHT [set grass MAX_GRASS_HEIGHT]]
  ask patches 
	    [set pcolor scale-color green grass 0 (MAX_GRASS_HEIGHT * 2)]

  ask worm [live]

  plot count turtles

  if count turtles > MAX_POPULATION [stop]
  ;quit when population max reached
end

;worm procedures:

to live

  crawl
  
  eat

  metabolize
    
  reproduce

end


to getready
  set shape "worm"
  setxy random(world-width) random(world-height)
  set heading random(360)
end

;we make several arbitrary assumptions:  life capacity decreases at an even rate, life is somewhat extended by the
; presence of ample food, and living requires 1/2 "calorie" per tick.  of course any of these assumptions may be modified.
to metabolize
   set life (life - 1)
   ; extend lifespan when energy reserve is at the maximum
   if energy = Energy_Reserve [set life (life + .5)]
   set energy (energy - .5)
   if (life < 0 or energy < 0) [die]
end

;reproduction here is asexual budding -- on average, Reproduction_Rate times per 100 ticks
to reproduce
  if Reproduction_Rate > random(100) 
    [ if (energy > Energy_Reserve / 2)
      ;we start new offspring with a limited energy supply (taken from the parent) so that starvation is not imminent
	    [hatch 1 [set life Life_Span set heading random(360) set energy energy / 2] 
       set energy energy / 2]
    ]
end

;the worm motion is quite arbitrary; these values were picked to produce quasi-realistic motion
to crawl
  rt random 20 
  lt random 20
  forward ((random 2) + (random 2))
end

;the Food_Conversion variable specifies what length of "grass" in a square must be eaten to produce 1 calorie for the worm
to eat
  let grasshere [grass] of patch-at 0 0
  if (grasshere > Food_Conversion and energy < Energy_Reserve) 
     [set energy (energy + 1) 
      ask patch-at 0 0 [set grass (grasshere - Food_Conversion)]
      ]
end
@#$#@#$#@
GRAPHICS-WINDOW
402
10
817
446
13
13
15.0
1
10
1
1
1
0
1
1
1
-13
13
-13
13
0
0
1
ticks

BUTTON
21
10
87
43
NIL
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
98
10
180
43
go/stop
time-tick
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
222
12
359
45
Initial_Population
Initial_Population
0
100
3
1
1
NIL
HORIZONTAL

SLIDER
20
56
172
89
Life_Span
Life_Span
0
100
40
1
1
ticks
HORIZONTAL

SLIDER
20
98
173
131
Reproduction_Rate
Reproduction_Rate
0
50
12
1
1
%
HORIZONTAL

SLIDER
220
97
396
130
Food_Conversion
Food_Conversion
0
25
10
1
1
mm/cal
HORIZONTAL

SLIDER
220
57
392
90
Energy_Reserve
Energy_Reserve
2
10
5
1
1
cal
HORIZONTAL

SLIDER
219
137
391
170
Growth_Rate
Growth_Rate
0
10
5
1
1
mm/tick
HORIZONTAL

PLOT
13
229
388
443
population vs. time
ticks
population
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

TEXTBOX
12
182
389
249
Reproduction rate = fraction of population reproducing per tick (given enough food).  Food Conversion = length of grass needed to generate one \"calorie\".  Growth rate = length of grass growth per tick.
11
0.0
1

@#$#@#$#@
WHAT IS IT?
-----------

The Worm simulation is a model of a population of virtual "worms".  The model explores the relationship between individual behavior and population dynamics.  It can easily stand alone, but it was developed as an enrichment activity following several weeks of a standard mealworm biology lab.  It is suitable both for an introduction to population dynamics, and as an introduction to agent-based modeling in biology.  Although quite simple, the simulation can produce complex dynamics that could be suitable for discussion up through a high school level.


HOW IT WORKS
------------

The simulation consists of essentially just two elements, a field of "grass" which is the food source of the worms, and the worms themselves.  We measure the grass in terms of its "length", which is recorded in the _grass_ variable owned by patches.  The grass also grows at a rate defined by the Growth_Rate slider, with length going from zero (black patch color) up to a maximum defined by the MAX_GRASS_HEIGHT constant (bright green patch color).  The worms own _life_ and _energy_ attributes.  Energy derives from food consumed, while life (lifespan) acts as a counter limiting the amount of time the worm has left to live.  In each tick, worms 1. crawl, 2. eat, 3. metabolize and 4. reproduce.

1.  crawl - this is essentially random motion forward and within 20 degrees to the left or right
2.  eat - worms eat any grass available in their square in each tick, cropping a length defined by the Food_Conversion slider (if that much is available - otherwise the worm does not eat); this then increases the worm's _energy_ variable by 1 unit (a "calorie"), up to the maximum defined by the Energy_Reserve slider.
3.  metabolize - the worms' _life_ counter is decremented, as well as the _energy_ counter (by 1/2 a calorie); when there is abundant food, a worm's lifespan is doubled.  Either old age or starvation may kill a worm.
4.  reproduce - every worm that has at least half of its maximum energy (defined by Energy_Reserve) has a chance of asexually reproducing a single offspring given by Reproduction_Rate.  When food is abundant, the reproduction rate essentially gives the per-tick growth rate of the worm population (not accounting for death of old worms).

The interaction of resource-dependent population growth with resource limitations gives rise to surprisingly complex population dynamics.  At the beginning, unbounded exponential growth is observed.  As the worm population approaches the environment's carrying capacity, growth saturates and, depending on the rate of grass regrowth and the maximum energy reserve per worm, the population may experience a mass die-off due to starvation.  In this case, eventually the population rebounds and after several oscillations will stabilize at some intermediate value.  Otherwise, the population simply levels off.


HOW TO USE IT
-------------

As mentioned above, this simulation was originally developed as a follow-on to a mealworm biology lab, but can easily stand alone.  The virtual "worms" in this simulation are far simpler than real mealworms (which are actually beetle larvae, not real worms).  It is helpful to introduce the simulation starting with just a single worm and introducing the four behaviors one by one.  The simulation can be run with each of the four behaviors (described above) commented out and then incrementally uncommented.  In particular, commenting out the "metabolize" function in the "to live" procedure essentially turns off the worms' life counter, meaning that no worms die.  This is a good way to show the consequences of unbounded population growth, given the (unrealistic) assumption that there are no limitations on resources.  

As usual, "setup" should be executed before "go".

The various sliders, some of which discussed are above, control the following variables:
- Initial Population.  This should be self-explanatory.  Note that the initial population is generated by the "setup" procedure, so changes to this (and other) sliders are generally not registered after setup is executed.
- Life Span.  The number of ticks that each worm lives (this number may be doubled if abundant food is available at each span of time).
- Reproduction Rate.  The fraction of well-fed worms (i.e. having at least half the maximum energy reserve) that reproduce per tick.  Reproduction corresponds to asexual budding.  Individuals reproduce probabilistically.
- Energy Reserve.  This specifies how many excess "calories" a worm can accumulate for consumption when food is not available.  Any worm that runs out of food will starve (die).  A worm can produce up to 1 calorie of energy from eating per tick, while 1/2 a colorie is consumed by living.  Hence, excess energy is accumulated at a rate of 1/2 calorie per tick (while food is abundant).
- Food Conversion.  This specifies what length of grass is cropped by a feeding worm to produce 1 calorie of energy.  This is inversely equivalent to the worm's gain from food.
- Growth Rate.  This specifies how fast the grass grows, i.e. by what amount (per tick) it is increased, up to the maximum.


THINGS TO NOTICE
----------------

The Food_Conversion slider has a direct impact on the steady-state carrying capacity of the environment.  It also has indirect effects on the dynamics of the population.  For instance, a very large value of Food_Conversion has the effect of reducing the reproduction rate, since it is relatively more difficult for a worm to obtain enough food to eat.  Coupling large Food_Conversion with small Life_Span values may easily make the worms go extinct.

The combination of a large reproductive rate with a high Energy_Reserve value might seem to be quite advantagous to a worm population.  However, this combination tends to have the unexpected effect of sustaining a population boom that exhausts the carrying capacity of the environment (particularly when grass regrowth is slow), resulting in mass die-offs and cycles of population boom and bust that may or may not stabilize.  When the Energy_Reserve value is low, and lifespan short, the population of worms tends to respond directly to the amount of food available, rather than with a time lag, and hence rather than oscillating the population merely plateaus at the carrying capacity.


THINGS TO TRY
-------------

A number of basic questions can be answered with this model.  What is the effect of initial population on final population?  (It effectively jumps the clock forward, but otherwise has no effect).  What is the effect of reproductive rate and life span on final population size?  And so on.

For more advanced classes, it is interesting - and challenging - to characterize what combinations of parameters produce:
- oscillating vs. stable populations
- the highest (or lowest) carrying capacity

It is also interesting and challenging to describe the population dynamics analytically.  This is discussed more below.


EXTENDING THE MODEL
-------------------

This model can be extended in a number of ways.  A trivial extension that would be appropriate to relate the model to some other real-life lab (such as bacterial growth) would be to change the turtle appearance from a worm to some other creature (especially for students who may feel squeamish about worms!)  Similarly, characteristics of grass growth, worm metabolism, etc. may all be tailored.

One basic extension that was used with an earlier version of this model was to add a population of birds that preyed on the worms.  This gives rise to familar predator-prey dynamics.  It is also straightforward to add some characteristic (such as length) to worms which affects their food gain, to see how random variations in that characteristic may over time lead to natural selection for longer or shorter worms.  A characteristic such as length may also, when predators are present, be used to illustrate competing influences on survival.  For instance, large worms may live longer (and hence produce more offspring), but may be easier prey for birds.

It would also not be difficult to add state variables that could be used to plot ideal population dynamics according to standard exponential growth and decay models, so that comparative analysis could be accomplished.


RELATED MODELS
--------------

The Wolves and Sheep model is similar in some respects.  There is also a more mathematically oriented population dynamics model in the library which can be related to this one.


CREDITS AND REFERENCES
----------------------

This model was written by Mathew Davies through the NSF-sponsored GK-12 program at the School of Engineering and Applied Sciences at Columbia University, for use in 8th-grade science classrooms at I.S. 143 (Eleanor Roosevelt intermediate school, Washington Heights) in Manhattan, New York in the fall of 2004.  The author may be contacted at the email address:
mpd2002@columbia.edu

This simulation, along with other technology-based classroom resources, may be found at the website
http://tip.columbia.edu
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
Circle -7500403 true true 30 30 240

circle 2
false
0
Circle -7500403 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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
Polygon -7500403 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7500403 true true 75 120 105 210 195 210 225 120 150 75

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

worm
true
0
Polygon -6459832 true false 135 75 120 120 120 165 135 195 165 225 180 255 180 285 165 300 195 285 210 225 195 195 180 165 180 120 165 75 135 75
Circle -7500403 true true 120 30 58
Rectangle -1 true false 120 30 135 45
Rectangle -1 true false 165 30 180 45
Polygon -16777216 false false 148 90 148 167 194 242 152 168

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
