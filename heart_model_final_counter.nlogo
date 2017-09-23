globals [

  cell-color                     ; color of heart cell (represents its membrane potential)
  atria                          ; a patch set that contains the patches of the atria
  left-ventricle                 ; a patch set that contains the patches of the left ventricle
  right-ventricle                ; a patch set that contains the patches of the right ventricle
  AV-node-bundle                 ; a patch set that contains the patches of the AV node and conduction bundle (bundle of His)
  SA-node                        ; a patch set that contains the patches of the SA node
  SA-node-size                   ; a dimension that defines the height and width of the SA node
  AV-node-size                   ; a dimension that defines the height and width of the AV node
  bundle-width                   ; a dimension that defines the width of the conduction bundle
  countdown                      ; the amount of time between depolarization events in the SA-node

]

breed [ depolarized-cells depolarized-cell ]    ;; bright, depolarized/activated cells
breed [ repolarizing-cells repolarizing-cell ]  ;; cells gradually fading to near black as they repolarize (return to resting state)

to setup
  ca

  set-default-shape turtles "square"

  set countdown 0


  ;; Set constant global variables
  set SA-node-size 1
  set AV-node-size 1
  set bundle-width 1

  draw-heart ;; procedure which draws the heart structures

  reset-ticks
end

to go
 ;; check to see if any depolarized cells in the heart, if not then generate a new action potential
 if countdown = 0 [
   ask SA-node [ fire-action-potential ]
   set countdown TIME-BETWEEN-IMPULSES ]

 ;; During fibrilation, electrical activity is random, chaotic, and irregular. During fibrilation, cells fire at random
 if fibrilation? [
 ask one-of atria [ fire-action-potential ]
 ask one-of left-ventricle [ fire-action-potential ]
 ask one-of right-ventricle [ fire-action-potential ]
 ]

 ask depolarized-cells
   [ ask neighbors with [pcolor = 121]
     [ fire-action-potential ]
     set breed repolarizing-cells ]
 repolarize-cell

 set countdown (countdown - 1)
 tick
end


;; creates depolarized cell agents
to fire-action-potential  ;; patch procedure
  sprout-depolarized-cells 1
    [ set color 125 ]
  set pcolor 125
end

;; achieve fading color effect as action potential moves away and cells repolarize
to repolarize-cell
  ask repolarizing-cells
    [ ifelse color >= 125 - 4.0
      [ set color color - repolarization-rate ]
      [ set pcolor 121
        die ]
    ]
end

;; procedure to draw the structures of the heart
to draw-heart

  set SA-node ( patch-set
  ;; create SA node
  ( patches with [(pxcor <= min-pxcor + SA-node-size) and (pycor >= max-pycor - SA-node-size)]))

  set atria ( patch-set
  ;; create atria
  (patches with [ (random-float 100) < cell-density and pxcor < 0 and pycor > 0 ]))
  ask atria [ set pcolor 121 ]

  ;; create right ventricle
  set right-ventricle patches with [
    ((random-float 100) < cell-density and pxcor < -15 and pycor < -10 )
  ]
  ask right-ventricle [ set pcolor 121 ]

  ;; create left ventricle
  set left-ventricle patches with [
    ((random-float 100) < cell-density and pxcor > 10 and pycor < -10 )
  ]
  ask left-ventricle [ set pcolor 121 ]

  ;; create AV node and conduction bundle
  set AV-node-bundle ( patch-set
    ; the AV node
    (patches with [ pxcor <= 0 and pxcor >= (-(AV-node-size)) and pycor >= 0 and pycor <= AV-node-size])
    ; the verticle part of the bundle
    (patches with [ pxcor >= (-(bundle-width)) and pxcor <= 0 and pycor <= 10 and pycor >= (-(max-pycor))])
    ; the horizontal part of the bundle
    (patches with [ pxcor >= (-(max-pxcor / 2)) and pxcor <= (max-pxcor / 2) and pycor < (-(max-pycor - bundle-width)) ]))
  ask AV-node-bundle [ set pcolor 121 ]

end
@#$#@#$#@
GRAPHICS-WINDOW
357
13
967
624
-1
-1
2.0
1
10
1
1
1
0
0
0
1
-150
150
-150
150
0
0
1
ticks
30.0

SLIDER
21
21
193
54
CELL-DENSITY
CELL-DENSITY
0
100
70.0
1
1
%
HORIZONTAL

BUTTON
23
190
90
223
SETUP
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
94
190
157
223
GO
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
23
146
158
179
FIBRILATION?
FIBRILATION?
0
1
-1000

PLOT
21
234
334
384
Number of Depolarized Cells per Region
Time
Count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Atria" 1.0 0 -12186836 true "" "plot count atria with [ pcolor = 125 ]"
"Left Ventricle" 1.0 0 -5825686 true "" "plot count left-ventricle with [ pcolor = 125 ]"

SLIDER
22
63
212
96
REPOLARIZATION-RATE
REPOLARIZATION-RATE
0
.25
0.1
.05
1
NIL
HORIZONTAL

SLIDER
22
103
218
136
TIME-BETWEEN-IMPULSES
TIME-BETWEEN-IMPULSES
200
1000
700.0
20
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?


#  SCOPE  

This project simulates the spread of an action potential (electrical depolarization) through the heart. **Depolarization** refers to a rapid reversal in the electrical potential that exists accross the plasma membrane of a cell. The heart is comprised of electrically-coupled excitable muscle cells. With each heart-beat, electrical depolarization spreads throughout the heart, causing the cells of the heart (also called myocytes or fibers) to contract; electrically-coupled contraction generates the force to pump blood. This model, however, does not simulate contraction nor pumping of blood, only the spatial and temporal dyanamics of electrical activation (depolarization).

This model allows the user to adjust the density cells, the rate at which they repolarize (return to their resting state) following activation/depolarization, and the duration of time between depolarization events using sliders.

The model also allows the user to simulate the phenomenon of **fibrilation** (a.k.a. arrhythmia). Fibrillation is the rapid, irregular, and unsynchronized activation of heart cells. 

## HOW IT WORKS

# AGENTS

Although conceptually, the agents in this model are individual heart cells, there are actually two breeds of agents, which represent two different phases of activity in the cells:

1) **depolarized-cells** - *magenta* (color 125) agents that represent activated/depolarized cells
2) **repolarizing-cells** - agents that represent cells in the repolarization phase. These agents gradually fade from magenta to very dark red (color 121). 

#  ENVIRONMENT  

The heart cell agents are arraged spatially into three areas that represent the four chambers of the heart. The two top chambers of the heart are modelled as a single **atria** (patch-set) because they are not electrically isolated from one another; the atria patch set appears on the upper half of the world. The bottom two patch areas in world represent the two **ventricles** of the heart. The ventricles are electrically isolated from one another, as well as from the atria, and therefore are modeled as two separate patch areas appearing on the lower half of the world. The atria area is connected to the two ventricles via the conduction bundle; a depolarization wave is generated in the atria and spreads to the ventricle via the **AV-node-conduction bundle**.

There is a special patch set within the atria patch set called the **SA-node** (sinoatrial node). The SA node is responsible for generating each new wave of depolarization (also called an action potential), which spreads through the heart.  

A wave of depolarization is generated in the sinoatrial node (SA node) - a patch set located in the upper-left corner of the atria patch set - and spreads to neighboring heart cells. The cardiac myocytes that comprise the SA node have the property of firing rhythmically/periodically. Depolarized cells are indicated by their magenta color. Once depolarization has spread through the atria to the AV node located at the base of the atria, a dense bundle of fibers rapidly conducts the electrical depolarization to the apex of the ventricles; depolarization then spreads through the two ventricles. 

Electrical depolarization spreads from the base of the atria to the apex of the two ventricles through a conduction bundle pathway. Thus, the heart model has altogether 4 areas (one for the two atria, one for the purkinje fiber pathway, and two more for each of the ventricles).


# ORDER OF EVENTS

When the **GO button** is clicked, the SA-node patch-set activates (turns magenta or color 125) and sprouts **depolarized-cell** agents. Depolarized-cells check the surrounding patches in the Moore neighborhood, and if one those patches is the color representing the resting cell potential (color 121), then a new depolarized-cell agent is generated on that patch using a procedure that employs NetLogo's **sprout** command. The depolarized-cell then changes its breed to **repolarizing-cell**. With each time step, repolarizing-cells gradually fade their color, decrementing by 1, until the color returns to 121 (the color representing a resting cell); the agent then dies.

Thus, depolarization spreads to neighboring cell agents in the Moore neighborhood. So, the generated action potential must have cells in the surrounding Moore neighborhood in order to advance. That is, the depolarization wave cannot skip over an area with no cells, so such a dead space would block propagation of depolarization in that direction. In this way depolarization spreads through the heart similarly to the way fire spreads through the forest in the Fire model (Wilensky, 1997). Importantly, there is a refractory period, during which cells must repolarize before they can “fire”, or depolarize again; this property is realistic of actual cardiac cell physiology. In other words, repolarizing-cells cannot depolarize again until they have fully repolarized (inicated by fading of their color).

**The SA node generates new waves of depolarization according to a user-controlled variable TIME-BETWEEN-IMPULSES. If the countdown variable has reached zero, then the SA-node will generate a new wave of depolarization and the cycle repeats.**

# INPUTS AND OUTPUTS

The user controls several **input variables** through the user interface:

1) **CELL-DENSITY** - a variable that ranges between 0 and 1 that represents density of cells in the heart. If the density of cells drops below 50%, an action potential will not propagate throughout the heart. This would represent a degenerative heart disease condition (i.e. heart failure).

2) **REPOLARIZATION-RATE** - a variable that controls the rate at which the cells repolarize after depolarization. With a faster repolarization rate

3) **TIME-BETWEEN-IMPULSES** - a variable that controls the duration of time between subsequent depolarization events (If the user moves this below a certain threshold it slows the model substantially)

4) **FIBRILATION?** - a user-controlled boolean variable that controls whether normal heart function is being modeled or fibrilation.

The **outputs** incude a graph which represents the number of activated cells in the atria patch set or in the left-ventricle. The graph illustrates the regular rhythmic pattern of activity if FIBRILATION? is set to false; if if FIBRILATION? is set to true the graph shows a pattern of activity which qualitatively resembles real world fibrilation activity.




## HOW TO USE IT

Click the **SETUP** button to set up the structure of the heart and draw the heart in the world.

Click the **GO** button to start the simulation.

The **CELL-DENSITY** slider controls the density of cells in the heart regions. (Note: Changes in the **CELL-DENSITY** slider do not take effect until the next **SETUP.**)

The **REPOLARIZATION-RATE** slider controls the rate at which cell repolarize after depolarization (i.e. controls the refractory period). 

The **TIME-BETWEEN-IMPULSES** slider controls the number of ticks between the generation of depolarization waves by the SA-node.

The **FIBRILATION?** switch controls whether or not fibrilation is simulated.

**IMPORTANT: The model runs optimally with the default values for the slider variables. If the TIME-BETWEEN-IMPULSES varible is too low, the model will run more slowly.**

## THINGS TO NOTICE

Electrical activity (also called membrane potential) is modeled according to patch color. Depolarization of the ventricles is temporally delayed/offset relative to depolarization of the atria; furthermore, depolarization spreads with an opposite directionality in the atria than it does through the ventricles. These properties are realistic of actual heart physiology; the atria first contract to fill the ventricles with blood, then the ventricles contract to pump blood to the lungs and the rest of the body. If contraction of the atria and ventricles is not temporally offset as occurs during fibrilation, blood is not pumped in effectively. 

The pattern of activity generated by the model during fibrilation, closely resembles the electrocardiogram (EKG) during actual fibrilation, which validates the model to an extent.


## THINGS TO TRY

Turn the **FIBRILATION?** switch on to simulate fibrilation of the heart and compare the graph generated under fibrilation to that when the fibrilation switch is off.

Vary the density of cells. If you lower the **CELL-DENSITY** slider variable below a certain threshold, there is virtually no chance that the action potential will reach the AV node and conduction bundle, thus preventing acitvation of the ventricles -- this models cardiac disease, where the cells have degenerated to the point where the heart no longer conducts action potentials efficiently.

Try varying the **TIME-BETWEEN-IMPULSES** slider. The lower the value of this slower the model runs because more cells will be depolarizaed at the same time.

Try changing the size of the lattice (max-pxcor and max-pycor in the Model Settings). Does it change the time for one contraction cycle?

## EXTENDING THE MODEL

One could attempt to plot the color value of the patches (perhaps as an average) or plot the color of individual agents as a surrogate measure of membrane-potential. 


## RELATED MODELS

This model was inspired by and is similar to the Fire model (Uri Wilensky, 1997). 
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
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
