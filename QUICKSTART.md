# Quick Start Guide

## Building and Running

### In Xcode

1. Open `SolarThermalSystem.xcodeproj` in Xcode
2. Select an iPad Simulator (e.g., iPad Pro 12.9")
3. Press ⌘R to build and run
4. The app will launch showing the simulation interface

### First Run

When you first launch the app, you'll see:

- **Time Display**: Shows 06:00 (sunrise)
- **System Status**: All temperatures at 20°C
- **Pump**: OFF (automatic control enabled)
- **Graph**: Empty, waiting for simulation to start

## Quick Tutorial

### Basic Operation

1. **Press START** (green button)
   - Simulation begins at 6:00 AM
   - Sun rises, solar irradiance increases
   - Collector temperature starts rising

2. **Watch the Pump** (automatic control)
   - When collector reaches ~30°C (10° above tank), pump turns ON
   - Heat begins flowing to tank bottom
   - Tank temperature gradually increases

3. **Observe Stratification**
   - Tank bottom heats first (receives hot fluid from collector)
   - Heat gradually rises through layers
   - Top layer becomes hottest by afternoon
   - Bottom stays cooler (return flow to collector)

4. **Monitor Progress**
   - Time advances through the day
   - Graph shows temperature curves building
   - Energy counter accumulates kWh collected

5. **Evening and Night**
   - Sun sets at 18:00 (6 PM)
   - Collector cools down
   - Pump turns OFF when temp difference drops
   - Tank slowly loses heat to ambient overnight

### Speed Control

- **Default**: 60x speed (1 real second = 1 simulated minute)
- **Full day**: Takes 24 real minutes at 60x speed
- **Speed up**: Drag slider right (up to 300x)
- **Slow down**: Drag slider left (minimum 1x)

**Tip**: Start at 60x to see a full day quickly, then try 1x to see detailed behavior

### Manual Control Mode

To experiment with manual pump control:

1. Toggle **"Automatic Control"** OFF
2. **Turn Pump ON** button appears
3. Tap to manually control pump
4. Observe effects:
   - Pump ON at night: Tank cools (heat flows backward!)
   - Pump OFF during day: Collector overheats, no heat collected
   
This demonstrates why automatic control is essential!

## Understanding the Display

### Temperature Colors

- **Blue** (< 20°C): Cold
- **Cyan** (20-30°C): Cool
- **Green** (30-40°C): Warm
- **Yellow** (40-50°C): Hot
- **Orange** (50-60°C): Very Hot
- **Red** (> 60°C): Extremely Hot

### System Status Panel

```
☀️ Solar Irradiance: 0-1000 W/m²
  (Peaks at ~1000 W/m² at noon)

🌡️ Ambient Temp: 15-25°C
  (Varies through day/night)

▬ Collector Temp: 
  (Rises with sun, cools at night)

💧 Tank Top: 
  (Hottest part, good for use)

💧 Tank Bottom: 
  (Cooler, good for collector efficiency)

📊 Tank Average: 
  (Overall storage temperature)
```

### Graph Legend

- **Orange**: Collector temperature (most dynamic)
- **Red**: Tank top (slowly rises, stays hot)
- **Blue**: Tank bottom (heats when pump runs)
- **Gray dashed**: Ambient air temperature
- **Yellow dashed**: Solar irradiance (÷10 for scale)

## Typical Day Simulation Results

### Morning (6:00 - 9:00)
- Collector: 20°C → 40°C
- Pump: OFF → ON (around 7:00)
- Tank: Begins heating from bottom

### Midday (9:00 - 15:00)
- Collector: 40°C → 60°C (varies with pump cycling)
- Pump: ON most of the time
- Tank: 20°C → 45°C (bottom to top gradient forms)
- Energy: Most collection happens now

### Afternoon (15:00 - 18:00)
- Collector: 60°C → 40°C (sun declining)
- Pump: Still ON, transferring last heat
- Tank: Continues heating, stratification clear

### Evening/Night (18:00 - 6:00)
- Collector: 40°C → 20°C (cools to ambient)
- Pump: OFF (no useful heat to collect)
- Tank: Slowly loses heat, ~35-40°C by morning
- Energy: ~3-5 kWh collected (typical sunny day)

## Troubleshooting

### Graph not updating?
- Make sure simulation is running (Pause button visible)
- Check that time is advancing in top display

### Temperatures not changing?
- Verify pump is operating when collector is hot
- Check that solar irradiance is > 0 (daytime)

### Pump cycling rapidly?
- This is normal around dawn/dusk
- Hysteresis should prevent excessive cycling
- If problematic, it's part of the learning experience!

### Want to see a specific time?
- Reset simulation
- Adjust speed slider to desired rate
- Watch until you reach the time of interest
- Pause to examine in detail

## Experimentation Ideas

### Try These Scenarios

1. **No Pump Operation**
   - Turn off automatic control
   - Leave pump OFF all day
   - See collector overheat (stagnation)
   - See tank remain cold (no heat collected)

2. **Pump Always On**
   - Turn off automatic control
   - Turn pump ON
   - Leave it on through night
   - See tank cool down (reverse flow)
   - Demonstrates why control is needed!

3. **Different Speeds**
   - Run at 1x to see detailed minute-by-minute behavior
   - Run at 300x to see multiple days quickly
   - Compare energy collection over time

4. **Compare Time Periods**
   - Reset and run to noon (peak sun)
   - Note collector temp and pump behavior
   - Reset and run to midnight
   - See nighttime cooling

## Advanced Tips

### Reading Stratification

Good stratification shows:
- Tank top temperature > Tank bottom by 5-15°C
- Smooth temperature gradient (not shown explicitly, but inferred)
- Hot water stays at top throughout day
- Cool water at bottom improves collector efficiency

### Energy Collection

Typical single day results:
- **Sunny**: 3-5 kWh
- **Morning only** (6-12h): 1.5-2.5 kWh
- **Afternoon** (12-18h): 1.5-2.5 kWh

This could heat ~100-150 liters of water by 30°C!

### Performance Indicators

A well-performing system shows:
- ✅ Pump turns on around 7-8 AM
- ✅ Collector stays 5-15°C above tank during operation
- ✅ Tank heats steadily, reaching 40-50°C by afternoon  
- ✅ Pump turns off shortly after sunset
- ✅ Tank retains most heat overnight (good insulation)

## Next Steps

Once you're comfortable with basic operation:

1. Read the full `README.md` for technical details
2. Examine the code structure (MVVM architecture)
3. Review the physics model equations
4. Consider extending with new features
5. Use as educational tool to teach solar thermal concepts

## Questions?

Review the main README.md for:
- Detailed physics equations
- Architecture explanation
- Technical parameters
- Future enhancement ideas

---

**Enjoy exploring solar thermal systems!** ☀️💧🔥


