# Solar Thermal System Simulation

A comprehensive iPad app simulating a solar thermal heating system with real-time physics-based heat transfer calculations and interactive visualization.

![Platform](https://img.shields.io/badge/platform-iOS%2017.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)

## Overview

This educational simulation demonstrates how solar thermal systems work by modeling heat transfer from a solar collector panel to a stratified storage tank. The app provides real-time visualization of temperatures, pump control, and energy collection over a simulated 24-hour day/night cycle.

## Features

### ✨ Core Functionality

- **Real-time Simulation**: Physics-based heat transfer calculations updated continuously
- **24-Hour Solar Cycle**: Realistic day/night irradiance patterns with dawn, noon peak, and dusk
- **Thermal Stratification**: Multi-layer tank model preserving hot water at top, cold at bottom
- **Automatic Pump Control**: Differential temperature controller with hysteresis to prevent cycling
- **Interactive Charts**: Live temperature graphs using SwiftUI Charts framework
- **Variable Speed**: Adjust simulation speed from 1x to 300x real-time

### 📊 Visualization

- **Temperature Tracking**: 
  - Solar collector temperature
  - Tank top and bottom temperatures  
  - Ambient air temperature
  - Solar irradiance (scaled)
  
- **System Status**:
  - Real-time clock display (00:00 - 23:59)
  - Pump on/off indicator
  - Cumulative energy collected (kWh)
  - Color-coded temperature indicators

- **Responsive Layout**: 
  - Landscape: Side-by-side control panel and chart
  - Portrait: Stacked layout optimized for iPad

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with clean separation of concerns:

```
SolarThermalSystem/
├── Models/
│   ├── Environment.swift              # Sun cycle & ambient conditions
│   ├── SolarCollector.swift           # Panel heat physics
│   ├── ThermalStorageTank.swift       # Stratified storage with 10 layers
│   ├── Pump.swift                     # Circulation pump & controller
│   └── TemperatureDataPoint.swift     # Data structure for graphing
│
├── ViewModels/
│   └── SimulationViewModel.swift      # Orchestrates simulation & publishes state
│
└── Views/
    └── ContentView.swift               # Main UI with controls & charts
```

### Key Design Principles

1. **Separation of Concerns**: Each physical component is a separate class/struct
2. **Pure Logic Models**: Models contain no SwiftUI dependencies
3. **Observable State**: ViewModel publishes changes via `@Published` properties
4. **Responsive UI**: SwiftUI automatically updates views when state changes

## Physics Model

### Solar Collector

The collector absorbs sunlight and converts it to heat with realistic losses:

```
Q_solar = G(t) × A × η
Q_loss = U_loss × A × (T_panel - T_ambient)
```

Where:
- `G(t)` = Solar irradiance (0-1000 W/m²)
- `A` = Collector area (3.0 m²)
- `η` = Efficiency (75%)
- `U_loss` = Heat loss coefficient (8.0 W/m²·K)

### Thermal Storage Tank

The tank uses **10 stratification layers** to model natural convection:

- **Heat Input**: Bottom layer receives heat from collector when pump is on
- **Stratification**: Hot water naturally rises, maintaining temperature gradient
- **Heat Losses**: Each layer loses heat to ambient, top layer loses more
- **Mixing**: Limited thermal diffusion between layers preserves stratification

Benefits of stratification:
- Hottest water stays at top for immediate use
- Cooler bottom water more efficiently absorbs collector heat
- More realistic than single-temperature tank models

### Pump Control

Automatic differential controller with hysteresis:

- **Turn ON**: When `T_collector - T_tank_bottom > 10°C`
- **Turn OFF**: When `T_collector - T_tank_bottom < 3°C`

This prevents rapid on/off cycling and ensures efficient heat transfer only when beneficial.

### Environment

24-hour cycle with realistic patterns:

- **Solar Irradiance**: Sine curve from sunrise (6 AM) to sunset (6 PM), peaking at noon (~1000 W/m²)
- **Ambient Temperature**: Cosine wave with minimum at 3 AM (15°C) and maximum at 3 PM (25°C)

## Usage

### Getting Started

1. **Start Simulation**: Tap the green "Start" button to begin the 24-hour simulation
2. **Watch Temperature Rise**: As sun comes up, collector heats and pump automatically turns on
3. **Observe Stratification**: Tank bottom heats first, then heat rises to top layers
4. **Adjust Speed**: Use slider to speed up simulation (60x = 1 real second = 1 simulated minute)
5. **Monitor Energy**: Track cumulative kWh collected throughout the day

### Controls

- **Start/Pause Button**: Toggle simulation running state
- **Reset Button**: Return to initial conditions (6:00 AM, all temps at 20°C)
- **Speed Slider**: Adjust simulation speed (1x - 300x)
- **Automatic Control Toggle**: Switch between automatic and manual pump control
- **Manual Pump Toggle**: Turn pump on/off manually (only when automatic control is disabled)

### Understanding the Graph

The interactive chart shows five data series:

1. **Orange Line** (Collector Temp): Rises quickly in sun, cools at night
2. **Red Line** (Tank Top): Hottest part of tank, heats gradually
3. **Blue Line** (Tank Bottom): Cooler inlet, heats when pump runs
4. **Gray Dashed** (Ambient): Background air temperature
5. **Yellow Dashed** (Solar ÷10): Irradiance scaled down for visibility

## Technical Details

### Simulation Parameters

```swift
// Time stepping
simulationTimeStep = 60.0 seconds     // 1-minute increments
updateInterval = 0.1 seconds          // 10 Hz UI refresh

// Collector
area = 3.0 m²
efficiency = 0.75 (75%)
heatLossCoefficient = 8.0 W/m²·K
thermalCapacity = 5000 J/K

// Tank
volume = 300 liters
numberOfLayers = 10
waterSpecificHeat = 4184 J/kg·K
heatLossCoefficient = 2.0 W/K

// Pump
turnOnDelta = 10°C
turnOffDelta = 3°C
heatTransferCoefficient = 500 W/K
```

### Thermodynamic Correctness

The simulation follows fundamental thermodynamic principles:

1. **Energy Conservation**: All heat flows are accounted for (solar input = stored energy + losses)
2. **Second Law**: Heat flows from hot to cold (collector to tank only when T_collector > T_tank)
3. **Natural Convection**: Hot water rises in tank, maintaining stratification
4. **Realistic Limits**: Temperatures bounded by physics (no negative temps, stagnation at equilibrium)

### Performance

- **Real-time Updates**: 10 Hz UI refresh for smooth visualization
- **Efficient Calculations**: Simple explicit Euler integration for heat equations
- **Memory Management**: Data points limited to 500 to prevent memory growth
- **Smooth Charts**: SwiftUI Charts automatically animates data updates

## Requirements

- iOS 17.0 or later
- iPadOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Educational Value

This simulation helps students and engineers understand:

- How solar thermal collectors work
- Why thermal stratification improves efficiency
- How differential controllers optimize pump operation
- Energy balance in renewable heating systems
- Real-world system behavior over daily cycles

## Future Enhancements

Potential additions for future versions:

- [ ] User-adjustable system parameters (collector area, tank volume, etc.)
- [ ] Different climate profiles (sunny, cloudy, seasonal variations)
- [ ] Heat exchanger modeling (indirect systems)
- [ ] Auxiliary heating element
- [ ] Hot water draw-off simulation
- [ ] Multi-day simulation with weather data
- [ ] Export data to CSV for analysis
- [ ] Schematic diagram of system with animated flow
- [ ] Comparison with reference data or other configurations

## License

This project is intended for educational purposes.

## References

The simulation is inspired by professional solar thermal design software like:
- **T*SOL** (Valentin Software): Dynamic simulation with 1-6 minute time steps
- **TRNSYS**: Transient system simulation program
- Research on stratified thermal storage systems

## Author

Created as a demonstration of SwiftUI, MVVM architecture, and physics-based simulation on iOS.

---

**Note**: This is a simplified educational model. Real solar thermal systems require professional design considering local climate, building loads, plumbing, safety systems, and building codes.


