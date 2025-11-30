;; Extensions
extensions [qlearningextension table]
__includes ["pacmans.nls" "ghosts.nls" "utils.nls" "patches_reward.nls"]


globals [
  pellets-gone?

  ticks-check
  episode-check

  is-random?
  is-all?

  almost-done-check
]


;;;;;;;;;;;;;;;;;; SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all

  ;; Import predefined world
  let maps ["pacman_world.csv"]
  import-world item 0 maps

  ;; Makes all the patches white
  ask patches [
    set visited-x-times? 0
    if pellet-grid? = true [
    set pcolor white
    ]
  ]

  ;; Set pellets flag
  set pellets-gone? false

  ;; Own commands for the turtles
  pacman-setup
  ghost-setup


  ;tick-checke
  set ticks-check 0

  ;; almost-done checker
  ;; set almost-done-check 0

  ;; episode-checker
  set episode-check 0

  set is-all? false




  reset-ticks

end

;;;;;;;;;;;;;;;;;;;;;;;;;; GO PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;; PACMAN ONLY ;;;;;;;;;;;;;;

;; Go Procedure for Pacman
to go-pacman

  ; For reset of ghosts agents
  set is-random? true

  ; Episode limit for go-forever
    if episode-check > max-episode [
    stop
  ]

  ; Patches calculate pacman reward
  calc-reward-pacman

  ; Pacman current state
  pacman-get-current-state

  ; Pacman action
  ask pacmans [
    qlearningextension:learning
  ]

  ; Episode return calculation
  pacman-update-env

;    if almost-done-check = 0 and episode-return-patches-left [
;    episode-return-almost-done patch-cutoff
;  ]

  ; Then ghosts move randomly
   move-ghosts-random

  tick
end


;;;;;;; GHOSTS ONLY ;;;;;;;;;;;;;;;;


;; Go Procedure for Red Ghost
to go-ghosts-red

 ; For reset of pacman agent
  set is-random? true


   if episode-check > max-episode [
    stop
  ]

  ;; Pacman moves first
  move-pacman-random

  ; Patches calculate ghosts reward
  calc-reward-ghosts

  ;; Get current state
  ghosts-get-current-state

  ; Ghost red action
  ask ghosts with [who = 1] [
    qlearningextension:learning

  ]

  ; Episode return calculation
  ghost-update-env

  tick
end


;; Go Procedure for Green Ghost
to go-ghosts-green

  set is-random? true

  if episode-check > max-episode [
    stop
  ]

  ;; Pacman moves first
  move-pacman-random

  calc-reward-ghosts

  ghosts-get-current-state

  ask ghosts with [who = 2] [
    qlearningextension:learning

  ]

  ghost-update-env


  tick
end

; Both ghosts
to go-ghosts-total

  set is-random? true

  if episode-check > max-episode [
    stop
  ]

  ;; Pacman moves first
  move-pacman-random


  calc-reward-ghosts

  ghosts-get-current-state

  ask ghosts [
    qlearningextension:learning

  ]

  ghost-update-env

  tick

end


;;;;;;;;;;;;;; PACMAN AND GHOSTS ;;;;;;;;;;;;;;;;;;;;;;

to go-all

  set is-random? false
  set is-all? true

  if episode-check > max-episode [
    stop
  ]

  ;; First pacman agent calculations

  calc-reward-pacman

  pacman-get-current-state

  ask pacmans [
    qlearningextension:learning
  ]

  pacman-update-env

  ;; Then ghosts agent calculations

  calc-reward-ghosts

  ;; Get current state
  ghosts-get-current-state

  ask ghosts [
    qlearningextension:learning

  ]

  ghost-update-env

  tick

end
@#$#@#$#@
GRAPHICS-WINDOW
843
74
1195
427
-1
-1
26.524
1
10
1
1
1
0
1
0
1
-6
6
-6
6
1
1
1
ticks
30.0

BUTTON
20
42
228
106
Setup
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
687
98
830
131
Go Pacman
go-pacman
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
689
139
829
172
Go Pacman Forever
go-pacman
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
30
226
234
259
reward-pellet
reward-pellet
0
5000
3130.0
10
1
NIL
HORIZONTAL

SLIDER
1658
92
1847
125
reward-caught
reward-caught
0
1000
500.0
100
1
NIL
HORIZONTAL

MONITOR
579
277
793
322
Current Episode Return Pacman
[episode-return] of one-of pacmans
17
1
11

PLOT
65
812
819
1011
Pacman Return per Episode
Episodes
Return
0.0
100.0
-10000.0
10000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if is-end-state?[set-current-plot \"Pacman Return per Episode\"\nplot ([episode-return] of one-of pacmans)]"

MONITOR
579
228
794
273
Step Reward Pacman
[rewardFunc] of one-of pacmans
17
1
11

BUTTON
1208
95
1363
128
Go Ghost Red
go-ghosts-red
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
1208
138
1363
171
Go Ghost Red Forever
go-ghosts-red
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
1658
133
1848
166
reward-radius
reward-radius
0
1000
250.0
1
1
NIL
HORIZONTAL

MONITOR
1443
383
1647
428
Current Episode Return Ghost Red
[episode-return-ghost] of one-of ghosts with [who = 1]
17
1
11

TEXTBOX
693
71
843
90
Pacman Run Buttons
15
44.0
1

TEXTBOX
1211
68
1361
87
Ghost Run Buttons
15
94.0
1

MONITOR
582
340
795
385
Closest Pellet Xcor Away of Pacman 
[target-dx] of one-of pacmans
17
1
11

MONITOR
583
392
795
437
Closest Pellet Ycor Away of Pacman
[target-dy] of one-of pacmans
17
1
11

PLOT
1364
929
2114
1151
Ghost Return per Episode
Episodes
Return
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"ghost-red" 1.0 0 -2674135 true "" ""
"ghost-green" 1.0 0 -10899396 true "" ""
"ghosts-total" 1.0 0 -5825686 true "" ""

SLIDER
1658
172
1847
205
reward-next-to-pacman
reward-next-to-pacman
0
1000
500.0
1
1
NIL
HORIZONTAL

BUTTON
1202
202
1370
235
Go Ghost Green
go-ghosts-green
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
1202
246
1368
279
Go Ghost Green Forever
go-ghosts-green
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1786
373
2005
418
Current Episode Return Ghost Green 
[episode-return-ghost] of one-of ghosts with [who = 2]
17
1
11

TEXTBOX
1810
63
1960
82
Ghosts Parameters
15
94.0
1

MONITOR
1787
325
2003
370
Step Reward Ghost Green
[rewardFunc-ghost-green] of one-of ghosts with [who = 2]
17
1
11

BUTTON
1202
301
1369
334
Go Ghosts
go-ghosts-total
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
1203
344
1367
377
Go Ghosts Forever
go-ghosts-total
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1449
297
1640
335
Ghost Red State Monitors
15
13.0
1

TEXTBOX
1761
283
1944
321
Ghost Green State Monitors
15
53.0
1

SLIDER
250
224
443
257
punishment-ghost-ahead
punishment-ghost-ahead
-500
0
-400.0
10
1
NIL
HORIZONTAL

SLIDER
249
265
444
298
punishment-no-pellet
punishment-no-pellet
-500
0
-100.0
10
1
NIL
HORIZONTAL

SLIDER
249
305
444
338
punishment-caught
punishment-caught
-1000
0
-500.0
10
1
NIL
HORIZONTAL

SLIDER
29
267
233
300
reward-finished-episode
reward-finished-episode
0
500
500.0
10
1
NIL
HORIZONTAL

SLIDER
246
363
445
396
punishment-distance-nearest-pellet-multiplier
punishment-distance-nearest-pellet-multiplier
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
937
621
1145
654
max-ticks-episode
max-ticks-episode
0
100000
72000.0
1000
1
NIL
HORIZONTAL

SLIDER
28
328
232
361
learning-rate-pacman
learning-rate-pacman
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
27
372
233
405
discount-factor-pacman
discount-factor-pacman
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
246
467
443
500
visited-limit
visited-limit
0
50
30.0
1
1
NIL
HORIZONTAL

SLIDER
1875
93
2102
126
punishment-pacman-not-nearby
punishment-pacman-not-nearby
-500
0
-200.0
10
1
NIL
HORIZONTAL

TEXTBOX
172
186
322
205
Pacman Parameters
15
44.0
1

SLIDER
1878
190
2104
223
learning-rate-ghosts
learning-rate-ghosts
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
1878
232
2103
265
discount-factor-ghosts
discount-factor-ghosts
0
1
0.9
0.01
1
NIL
HORIZONTAL

CHOOSER
409
115
582
160
pacmans-method
pacmans-method
"ghost-location-method" "visited-patch-method" "nearest-pellet-method" "combination-method"
3

SLIDER
246
431
444
464
punishment-visited-too-often
punishment-visited-too-often
-1000
0
-300.0
1
1
NIL
HORIZONTAL

SWITCH
847
951
1056
984
episode-return-patches-left
episode-return-patches-left
1
1
-1000

SLIDER
848
991
1020
1024
patch-cutoff
patch-cutoff
0
12
12.0
1
1
NIL
HORIZONTAL

SWITCH
304
645
546
678
write-episode-return-pacman-flag
write-episode-return-pacman-flag
1
1
-1000

SWITCH
567
645
799
678
write-episode-ticks-pacman-flag
write-episode-ticks-pacman-flag
1
1
-1000

INPUTBOX
303
690
532
750
filename-episode-return-pacman
episode-return-combination.txt
1
0
String

INPUTBOX
565
685
816
745
filename-episode-ticks-pacman
episode-ticks-combination.txt
1
0
String

SLIDER
952
580
1124
613
max-episode
max-episode
0
100000
50000.0
1000
1
NIL
HORIZONTAL

MONITOR
829
762
931
807
Episode Number
episode-check
17
1
11

SWITCH
387
170
592
203
show-label-reward-pacman
show-label-reward-pacman
1
1
-1000

SWITCH
1396
162
1613
195
show-label-reward-ghosts
show-label-reward-ghosts
1
1
-1000

CHOOSER
1395
101
1635
146
ghosts-method
ghosts-method
"approximate-location-method" "exact-location-method" "joint-approximate-location-method" "joint-exact-location-method"
2

MONITOR
1400
436
1518
481
Pacman DX Ghost Red
[pacman-dx] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1400
483
1518
528
Pacman DY Ghost Red
[pacman-dy] of one-of ghosts with [who = 1]
17
1
11

TEXTBOX
438
72
588
91
Pacman Method
15
44.0
1

TEXTBOX
20
14
236
52
Always Press \"SETUP\" First
15
0.0
1

TEXTBOX
616
192
782
229
Pacman State Monitors
15
44.0
1

TEXTBOX
320
601
535
639
Pacman Filename Writers
15
44.0
1

MONITOR
1444
335
1646
380
Step Reward Ghost Red
[rewardFunc-ghost-red] of one-of ghosts with [who = 1]
17
1
11

MONITOR
582
446
686
491
Ghost Top Left
[ghosts-top-left] of one-of pacmans
17
1
11

MONITOR
694
446
812
491
Ghost Top Right
[ghosts-top-right] of one-of pacmans
17
1
11

MONITOR
581
498
686
543
Ghosts Bottom Left
[ghosts-bottom-left] of one-of pacmans
17
1
11

MONITOR
693
499
813
544
Ghost Bottom Right
[ghosts-bottom-right] of one-of pacmans
17
1
11

TEXTBOX
1435
68
1585
87
Ghosts Method
15
94.0
1

MONITOR
1576
434
1677
479
Ghost Green DX
[ghost-dx] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1577
482
1678
527
Ghost Green DY
[ghost-dy] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1760
429
1888
474
Pacman DX Ghost Green
[pacman-dx] of one-of ghosts with [who = 2]
17
1
11

MONITOR
1760
477
1888
522
Pacman DY Ghost Green
[pacman-dy] of one-of ghosts with [who = 2]
17
1
11

MONITOR
1949
428
2038
473
Ghost Red DX
[ghost-dx] of one-of ghosts with [who = 2]
17
1
11

MONITOR
1949
477
2038
522
Ghost Red DY
[ghost-dy] of one-of ghosts with [who = 2]
17
1
11

INPUTBOX
1800
781
2093
841
filename-episode-ticks-ghost-red
episode-ticks-joint-approx.txt
1
0
String

INPUTBOX
1800
846
2093
906
filename-episode-ticks-ghost-green
ignore2.txt
1
0
String

INPUTBOX
1382
778
1673
838
filename-episode-return-ghost-red
episode-return-joint-approx.txt
1
0
String

INPUTBOX
1381
841
1672
901
filename-episode-return-ghost-green
ignore.txt
1
0
String

SWITCH
1393
736
1647
769
write-episode-return-ghosts-flag
write-episode-return-ghosts-flag
0
1
-1000

SWITCH
1806
731
2073
764
write-episode-ticks-ghosts-flag
write-episode-ticks-ghosts-flag
0
1
-1000

MONITOR
1386
538
1545
583
Pacman Top Left Ghost Red
[pacman-top-left] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1553
536
1721
581
Pacman Top Right Ghost Red
[pacman-top-right] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1384
585
1545
630
Pacman Bottom Left Ghost Red
[pacman-bottom-left] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1551
584
1720
629
Pacman Bottom Right Ghost Red
[pacman-bottom-right] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1733
530
1906
575
Pacman Top Left Ghost Green
[pacman-top-left] of one-of ghosts with [who = 2]
17
1
11

MONITOR
1921
530
2098
575
Pacman Top Right Ghost Green
[pacman-top-right] of one-of ghosts with [who = 2]
17
1
11

MONITOR
1734
579
1906
624
Pacman Bottom Left Ghost Green
[pacman-bottom-left] of one-of ghosts with [who = 2]
17
1
11

MONITOR
1921
580
2098
625
Pacman Bottom Right Ghost Green
[pacman-bottom-right] of one-of ghosts with [who = 2]
17
1
11

MONITOR
828
812
984
857
Current Episode Captures
[episode-caught] of one-of pacmans
17
1
11

MONITOR
829
864
961
909
Current Episode Ticks
[episode-ticks] of one-of pacmans
17
1
11

PLOT
63
1025
818
1199
Pacman Ticks per Episode
Episodes
Ticks 
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pacman-tick" 1.0 0 -16777216 true "" ""

PLOT
65
1206
820
1356
Pacman Captures per Episode
Episodes
Captures
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pacman-capture" 1.0 0 -16777216 true "" ""

PLOT
1364
1160
2112
1310
Ghost Ticks per Episode
Episodes
Ticks
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"ghost-red" 1.0 0 -2674135 true "" ""
"ghost-green" 1.0 0 -10899396 true "" ""
"ghosts-total" 1.0 0 -5825686 true "" ""

MONITOR
2056
322
2230
367
Current Total Episode Return
[episode-return-ghost] of one-of ghosts with [who = 1]
17
1
11

MONITOR
2056
379
2227
424
Step Reward Total
[rewardFunc-ghosts] of one-of ghosts with [who = 1 ]
17
1
11

BUTTON
952
485
1111
518
Go All
go-all
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
955
530
1111
563
Go All Forever
go-all
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
19
645
275
678
write-episode-captures-pacman-flag
write-episode-captures-pacman-flag
1
1
-1000

INPUTBOX
20
686
277
746
filename-episode-captures-pacman
episode-captures-combination.txt
1
0
String

TEXTBOX
942
459
1133
497
Ghost and Pacman Buttons
15
24.0
1

TEXTBOX
2054
283
2247
321
Ghost Total State Monitors
15
94.0
1

SLIDER
1873
130
2105
163
punishment-distance-pacman-multiplier
punishment-distance-pacman-multiplier
0
10
5.0
1
1
NIL
HORIZONTAL

MONITOR
1174
830
1367
875
Current Episode Ticks Ghost Red
[episode-ticks-ghost] of one-of ghosts with [who = 1]
17
1
11

MONITOR
1161
885
1365
930
Current Episode Ticks Ghost Green
[episode-ticks-ghost] of one-of ghosts with [who = 2]
17
1
11

@#$#@#$#@
## The Model

This is a simplified version of the game "Pacman" to experiment Q-Learning in a multi-agent setup. This can be tested for one of the ghosts, which are green and red and are represented by sad faces, and Pacman itself, which is a yellow star in this case. 

Whatever Agent is trained, the other agents will perform random movements.

## Requirements

In order for the model to work, the "pacman_world.csv" file is required, which contains the labyrinth grid and the parameters of the patches. In addition, the nls files of "pacmans.nls", "ghosts.nls" and "utils.nls" are required which specify the agents. These have to be in the same folder as the Netlogo file. 


## How to use the Model 

Important: Always start with the "Setup" button, otherwise the model will not work. 
Go Forever will make the respective agent learn.

## Tips 
writing save-qtable [path] [agents] will write the q-table of the agent. 
0 is Pacman 
1 is the red ghost 
2 is the green ghost 
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
NetLogo 6.4.0
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
