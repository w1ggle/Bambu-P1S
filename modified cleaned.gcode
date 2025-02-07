;===== machine: P1S =======================
;===== date: 20250202 =====================
;===== modified by w1ggle =================

;===== turn on mainboard fan =================
M710 A1 S255 ;turn on MC fan to prevent overheating

; ===turn on filament runout detection===
M412 S1  ;moved filament runout here, no point in doing the bottom stuff if theres no filament

;===== preheat ==================== ;heating takes the longest. Bed takes 2.5 mins to heat up
M1002 gcode_claim_action : 2 ;display Heatbed preheating
M140 S[bed_temperature_initial_layer_single] ;set bed temp
M104 S140 ;set extruder temp to 140 (so you can touch the bed)

;===== reset machine status/counters =================
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
M221 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem
G29.1 Z{+0.0} ; clear z-trim value first
M204 S10000 ; init ACC set to 10m/s^2

;===== home x and y axis ==========
G91 ; use relative coordinates
M17 Z0.4 ; lower the z-motor current ; turn on slow mode. think this is if the bed is all the way dowm, it wont slam into the bottom
G380 S2 Z5 F300 ; lower heatbed so nozzle wont scrape it when homing ;changed height from 30 to 5
G90 ; Set all axes to absolute
M17 X1.2 Y1.2 Z0.75 ; reset motor current to default/fast mode
G28 X ;homing x axis (is in the front right)
M975 S1 ; turn on vibration suppression

;============= make sure nozzle has filament =========
G1 X60 F12000 ;moves to the poop chute, in case oozing happens in the next parts
G1 Y245
G1 Y265 F3000

;TODO add purge here if using AMS
; ========== switch material if AMS exists ==========
M620 M
M620 S[initial_extruder]A   ; switch material if AMS exist
    M109 S[nozzle_temperature_initial_layer]
    G1 X120 F12000

    G1 X20 Y50 F12000
    G1 Y-3
    T[initial_extruder]
    G1 X54 F12000
    G1 Y265
    M400
M621 S[initial_extruder]A
M620.1 E F{filament_max_volumetric_speed[initial_extruder]/2.4053*60} T{nozzle_temperature_range_high[initial_extruder]}

M109 S140 ; wait for nozzle to get to 140 
M190 S[bed_temperature_initial_layer_single] ;wait for bed temp ;can wait for this at a later point
M400
;after waiting this long, i expect oozing

;======= wipe any oozing after changing ams filament or just waiting ============
M1002 gcode_claim_action : 14 ;Cleaning nozzle tip
M975 S1 ; turn on vibration suppression
G1 X70 F9000
G1 X76 F15000
G1 X65 F15000
G1 X76 F15000
G1 X65 F15000; shake to put down garbage
G1 X80 F6000
G1 X95 F15000
G1 X80 F15000
G1 X165 F15000; wipe and shake

;G1 X65 Y230 F18000 ;move to poop chute?
;G1 Y264 F6000

;G1 X100 F18000 ; first wipe mouth

G0 X135 Y253 F20000  ; move to exposed steel surface edge in middle back
G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL
G0 Z5 F20000 ;move bed down 5 mm

;G1 X60 Y265
;G92 E0
;G1 E-0.5 F300 ; retrack more
;G1 X100 F5000; second wipe mouth
;G1 X70 F15000
;G1 X100 F5000
;G1 X70 F15000
;G1 X100 F5000
;G1 X70 F15000
;G1 X100 F5000
;G1 X70 F15000
;G1 X90 F5000

;G0 X128 Y261 Z-1.5 F20000  ; move to exposed steel surface and stop the nozzle
;M104 S140 ; set temp down to heatbed acceptable
;M106 S255 ; turn on fan (G28 has turn off fan)

;M221 S; push soft endstop status
;M221 Z0 ;turn off Z axis endstop
;G0 Z0.5 F20000
;G0 X125 Y259.5 Z-1.01
;G0 X131 F211
;G0 X124
;G0 Z0.5 F20000
;G0 X125 Y262.5
;G0 Z-1.01
;G0 X131 F211
;G0 X124
;G0 Z0.5 F20000
;G0 X125 Y260.0
;G0 Z-1.01
;G0 X131 F211
;G0 X124
;G0 Z0.5 F20000
;G0 X125 Y262.0
;G0 Z-1.01
;G0 X131 F211
;G0 X124
;G0 Z0.5 F20000
;G0 X125 Y260.5
;G0 Z-1.01
;G0 X131 F211
;G0 X124
;G0 Z0.5 F20000
;G0 X125 Y261.5
;G0 Z-1.01
;G0 X131 F211
;G0 X124
;G0 Z0.5 F20000
;G0 X125 Y261.0
;G0 Z-1.01
;G0 X131 F211
;G0 X124
;G0 X128
;G2 I0.5 J0 F300 ;spin in cirlces
;G2 I0.5 J0 F300
;G2 I0.5 J0 F300
;G2 I0.5 J0 F300

;M109 S140 ; wait nozzle temp down to heatbed acceptable
;G2 I0.5 J0 F3000 ;spin in cirlces
;G2 I0.5 J0 F3000
;G2 I0.5 J0 F3000
;G2 I0.5 J0 F3000

M221 R; pop softend status
;G1 Z10 F1200
M400
; move to the front right??? but why
;G1 Z10
;G1 F30000
;G1 X230 Y15
G29.2 S1 ; turn on ABL
;G28 ; home again after hard wipe mouth
M106 S0 ; turn off fan , too noisy
;===== wipe nozzle end ================================


;===== bed leveling ==================================
M1002 judge_flag g29_before_print_flag
M622 J1

    M1002 gcode_claim_action : 1
;    M109 S140 ; set temp down to heatbed acceptable
;    M190 S[bed_temperature_initial_layer_single] ;wait for bed temp ;can wait for this at a later point
    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]} ;dynamic bed level area instead of whole bed, found by Leckiestein on tiktok (doesnt work with firmware 01.07)
    M400
    M500 ; save cali data

M623
;===== bed leveling end ================================
M104 S{nozzle_temperature_initial_layer[initial_extruder]} ; set extrude temp earlier, to reduce wait time
;===== home after wipe mouth============================
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28

M623
;===== home after wipe mouth end =======================

M975 S1 ; turn on vibration supression


;=============turn on fans to prevent PLA jamming================= ;turned off second pla jamming
;{if filament_type[initial_extruder]=="PLA"}
;    {if (bed_temperature[initial_extruder] >45)||(bed_temperature_initial_layer[initial_extruder] >45)}
;    M106 P3 S180
;    {endif};Prevent PLA from jamming
;{endif}
;M106 P2 S100 ; turn on big fan ,to cool down toolhead




;think this is vibration comp (?)
;===== mech mode fast check============================
;G1 X128 Y128 Z10 F20000
;M400 P200
;M970.3 Q1 A7 B30 C80  H15 K0
;M974 Q1 S2 P0

;G1 X128 Y128 Z10 F20000
;M400 P200
;M970.3 Q0 A7 B30 C90 Q0 H15 K0
;M974 Q0 S2 P0

;M975 S1
;G1 F30000
;G1 X230 Y15
;G28 X ; re-home XY
;===== fmech mode fast check============================


;===== nozzle load line =============================== ; adaptive purge line by u/Jusanden on Reddit
;M104 S{nozzle_temperature_initial_layer[initial_extruder]} ; set extrude temp earlier, to reduce wait time
M975 S1
G90
M83
T1000
;check if okay to default to KAMP

{if ((first_layer_print_min[0] - 5 < 18) && (first_layer_print_min[1]-5 < 28)) || (first_layer_print_min[0] < 6) || (first_layer_print_min[1] < 6) || (first_layer_print_min[0] > 200)}


G1 X255.5 Y0.5 Z1.5 F18000;Move to start position
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G1 Z0.2
G0 E2 F300

M400
G1 X230.5 E25 F300
G0 X210 E1.36 F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
G0 X186 E-0.5 F18000 ;Move quickly away

G1 Z1.5 E0.5 F4000;

{else} ;Fallback

G1 X{first_layer_print_min[0]-5} Y{first_layer_print_min[1]-5} Z1.5 F18000;Move to start position
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G1 Z0.8
G0 E2 F300
M400
G1 X{first_layer_print_min[0]+15} E20 F150
G0 X{first_layer_print_min[0]+45} F18000 ;Move quickly away
{endif}

M400

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
;curr_bed_type={curr_bed_type}
{if curr_bed_type=="Textured PEI Plate"}
G29.1 Z{-0.03} ; for Textured PEI Plate
{endif}

{if (curr_bed_type=="Textured Cool Plate")} ; Textured Cool Plate support by u/Jusanden on Reddit
G29.1 Z{-0.03} ; for Textured PEI Plate
{endif}

;========turn off everything and start print =============
M1002 gcode_claim_action : 0 ;(Clear screen of messages?)
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan
M975 S1 ; turn on mech mode supression