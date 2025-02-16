I was unhappy with the stock start gcode for bambu p1s (which i found from orcaslicer). Bambulabs took the lazy way and just copied and pasted the x1c start gcode for the p1s.
I couldnt find any good start gcodes so i made my own:

changes:
- In general:
    - removed the pla jamming gcode sections. I didnt have any issues with pla jamming on any printer. All it does here is just turn on the fans and theyre noissssyyyyy
    - sectioned off/commented lines. HOPING OTHER PPL WILL HELP MAKE THIS GCODE BETTER
- Specifics (top to bottom):
    - moved the filament runout detection to top. no point in running gcode if theres no filament
    - moved preheating to earlier and moved the wait for print bed to right before homing the z axis (which is when it matters). This saves A LOT of time
    - separated the resetting of machine status and homing the x (and y axis) for clarity
    - when homing the x axis, i reduced the amount of distance the z axis moves out of the way. before it would move a total of 60 mm to get out of the way of the nozzle. I reduced it to 5 mm to save time.
    - reduced poop amount from 105mm to 25 mm. i believe theres only 20 mm of filament in the nozzle. extra 5 to help with color bleed. then the purge line should hopefully get rid of the rest. NEED TO FIGURE OUT IF THIS IS ENOUGH PURGE
    - changed bed leveling to dynamic. Found by Leckiestein on tiktok (doesnt work with firmware 01.07)
    - changed purge line to smaller dynamic one. Found by u/Jusanden on Reddit
    - added support for Textured cool plate. Found by u/Jusanden on Reddit