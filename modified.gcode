;===== machine: P1S =======================
;===== date: 20250202 =====================
;===== modified by w1ggle =================

;===== turn on the HB fan & MC board fan =================
;M104 S75 ;set extruder temp to turn on the HB fan and prevent filament oozing from nozzle ;think the MC fan turns on regardless of extruder temp
M710 A1 S255 ;turn on MC fan by default(P1S)

M412 S1 ; ===turn on filament runout detection=== ;moved filament runout here, no point in doing the bottom stuff if theres no filament

;===== preheat ==================== ;heating takes the longest. Bed takes 2.5 mins to heat up
M1002 gcode_claim_action : 2 ;display Heatbed preheating
M140 S[bed_temperature_initial_layer_single] ;set bed temp
M104 S140 ;set extruder temp to 140 (so you can touch the bed)

;===== reset machine status ================= ;first half i believe checks if the bed is all the way at the bottom. I dont think its necessary
;M290 X40 Y40 Z2.6666666 ;baby step (what for?)
;G91 ; use relative coordinates
;M17 Z0.4 ; lower the z-motor current ; turn on slow mode. think this is if the bed is all the way dowm, it wont slam into the bottom
;G380 S2 Z10 F300 ; G380 is same as G38; lower the hotbed , to prevent the nozzle is below the hotbed ;changed height from 30 to 10
;G380 S2 Z-5 F300 ;changed height from -25 to -5
;G1 Z5 F300 ;whats the point of moving bed down 5
;G90 ; Set all axes to absolute
;M17 X1.2 Y1.2 Z0.75 ; reset motor current to default
;M960 S5 P1 ; turn on logo lamp can turn off this lamp ;what logo lamp?
;G90
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 5 ;display M400 pause ;whats the point of this
M221 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem
G29.1 Z{+0.0} ; clear z-trim value first
M204 S10000 ; init ACC set to 10m/s^2

;===== heatbed preheat ==================== ;moved this up
;M1002 gcode_claim_action : 2
;M140 S[bed_temperature_initial_layer_single] ;set bed temp
;M190 S[bed_temperature_initial_layer_single] ;wait for bed temp

;think this can all be commented out, i havent had pla jams
;=============turn on fans to prevent PLA jamming=================
;{if filament_type[initial_extruder]=="PLA"}
;    {if (bed_temperature[initial_extruder] >45)||(bed_temperature_initial_layer[initial_extruder] >45)}
;    M106 P3 S180
;    {endif};Prevent PLA from jamming
;{endif}
;M106 P2 S100 ; turn on big fan ,to cool down toolhead

;===== prepare print temperature and material ==========
;M104 S[nozzle_temperature_initial_layer] ;set extruder temp ;extruder temp is set to 140 earlier
G91 ; Set all axes to relative 
G0 Z10 F1200 ;move bed down (think so it can move the gantry to the front right corner and not scrape) ; changed from z10 to z5
G90 ; Set all axes to absolute 
G28 X ;homing x axis (is in the front right)
M975 S1 ; turn on vibration suppression

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



; ========== purge nozzle and remove poop ========== ; i think theres no need to purge nozzle every time unless ams is used, i think this should be in ams block above
;M109 S250 ;set nozzle to common flush temp
;M106 P1 S0 ;turn off fan (helps nozzle heat up faster)
;G92 E0 ;reset extruded to 0
;G1 E10 F200 ;reduced extrusion from 50 to 10
;M400 ;wait till everything is done
;M104 S[nozzle_temperature_initial_layer] ;no need to purge twice
;G92 E0
;G1 E50 F200
;M400
;M106 P1 S100 ;reduced fan speed from 255 to 100
;G92 E0 ;no need to purge again
;G1 E5 F300
;M109 S{nozzle_temperature_initial_layer[initial_extruder]-20} ; drop nozzle temp, make filament shink a bit
;G92 E0 ;reset extruded to 0
;G1 E-0.5 F300 ;retract 1mm of filament to reduce oozing ;changed -0.5 to -1

;just wipe the oozing
G1 X70 F9000
G1 X76 F15000
G1 X65 F15000
G1 X76 F15000
G1 X65 F15000; shake to put down garbage
G1 X80 F6000
G1 X95 F15000
G1 X80 F15000
G1 X165 F15000; wipe and shake
M400
M106 P1 S0 ;turn off fan
;===== prepare print temperature and material end =====


;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14 ;Cleaning nozzle tip
M975 S1 ; turn on vibration suppression
M106 S100 ;reduced fan speed from 255 to 100

G1 X65 Y230 F18000 ;move to poop chute?
G1 Y264 F6000
M109 S{nozzle_temperature_initial_layer[initial_extruder]-20} ;should the nozzle be hot when doing the circles at the bed? kinda think this can be skipped
M190 S[bed_temperature_initial_layer_single] ;wait for bed temp ;can wait for this at a later point
G1 X100 F18000 ; first wipe mouth

G0 X135 Y253 F20000  ; move to exposed steel surface edge in middle back
G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL
G0 Z5 F20000 ;move bed down 5 mm

G1 X60 Y265
G92 E0
G1 E-0.5 F300 ; retrack more
G1 X100 F5000; second wipe mouth
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X90 F5000
G0 X128 Y261 Z-1.5 F20000  ; move to exposed steel surface and stop the nozzle
M104 S140 ; set temp down to heatbed acceptable
M106 S255 ; turn on fan (G28 has turn off fan)

M221 S; push soft endstop status
M221 Z0 ;turn off Z axis endstop
G0 Z0.5 F20000
G0 X125 Y259.5 Z-1.01
G0 X131 F211
G0 X124
G0 Z0.5 F20000
G0 X125 Y262.5
G0 Z-1.01
G0 X131 F211
G0 X124
G0 Z0.5 F20000
G0 X125 Y260.0
G0 Z-1.01
G0 X131 F211
G0 X124
G0 Z0.5 F20000
G0 X125 Y262.0
G0 Z-1.01
G0 X131 F211
G0 X124
G0 Z0.5 F20000
G0 X125 Y260.5
G0 Z-1.01
G0 X131 F211
G0 X124
G0 Z0.5 F20000
G0 X125 Y261.5
G0 Z-1.01
G0 X131 F211
G0 X124
G0 Z0.5 F20000
G0 X125 Y261.0
G0 Z-1.01
G0 X131 F211
G0 X124
G0 X128
G2 I0.5 J0 F300 ;spin in cirlces
G2 I0.5 J0 F300
G2 I0.5 J0 F300
G2 I0.5 J0 F300

M109 S140 ; wait nozzle temp down to heatbed acceptable
G2 I0.5 J0 F3000 ;spin in cirlces
G2 I0.5 J0 F3000
G2 I0.5 J0 F3000
G2 I0.5 J0 F3000

M221 R; pop softend status
G1 Z10 F1200
M400
G1 Z10
G1 F30000
G1 X230 Y15
G29.2 S1 ; turn on ABL
;G28 ; home again after hard wipe mouth
M106 S0 ; turn off fan , too noisy
;===== wipe nozzle end ================================


;===== bed leveling ==================================
M109 S140 ; set temp down to heatbed acceptable
M190 S[bed_temperature_initial_layer_single] ;wait for bed temp ;can wait for this at a later point
M1002 judge_flag g29_before_print_flag
M622 J1

    M1002 gcode_claim_action : 1
    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]} ;dynamic bed level area instead of whole bed, found by Leckiestein on tiktok (doesnt work with firmware 01.07)
    M400
    M500 ; save cali data

M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28

M623
;===== home after wipe mouth end =======================

M975 S1 ; turn on vibration supression


;=============turn on fans to prevent PLA jamming=================
{if filament_type[initial_extruder]=="PLA"}
    {if (bed_temperature[initial_extruder] >45)||(bed_temperature_initial_layer[initial_extruder] >45)}
    M106 P3 S180
    {endif};Prevent PLA from jamming
{endif}
M106 P2 S100 ; turn on big fan ,to cool down toolhead


M104 S{nozzle_temperature_initial_layer[initial_extruder]} ; set extrude temp earlier, to reduce wait time

;===== mech mode fast check============================
G1 X128 Y128 Z10 F20000
M400 P200
M970.3 Q1 A7 B30 C80  H15 K0
M974 Q1 S2 P0

G1 X128 Y128 Z10 F20000
M400 P200
M970.3 Q0 A7 B30 C90 Q0 H15 K0
M974 Q0 S2 P0

M975 S1
G1 F30000
G1 X230 Y15
G28 X ; re-home XY
;===== fmech mode fast check============================


;===== nozzle load line =============================== ; adaptive purge line by u/Jusanden on Reddit
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
G29.1 Z{-0.04} ; for Textured PEI Plate
{endif}

{if (curr_bed_type=="Textured Cool Plate")} ; Textured Cool Plate support by u/Jusanden on Reddit
G29.1 Z{-0.04} ; for Textured PEI Plate
{endif}


;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan


M975 S1 ; turn on mech mode supression
