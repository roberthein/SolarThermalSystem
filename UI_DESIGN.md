# UI Design Documentation

## Overview

The Solar Thermal System app features a modern, dark-mode-only interface with a beautiful temperature gradient visualization and an interactive schematic diagram.

## Design System

### Color Palette

#### Background Colors (Dark Theme)
- **Primary Background**: `rgb(13, 13, 20)` - Deepest dark for main canvas
- **Secondary Background**: `rgb(20, 20, 31)` - Panel backgrounds
- **Tertiary Background**: `rgb(31, 31, 41)` - Section dividers
- **Card Background**: `rgb(26, 26, 36)` - Elevated cards with shadows

#### Temperature Gradient (Blue → Purple → Hot-Pink)
The temperature visualization uses a scientifically-inspired gradient:

- **Cold (< 15°C)**: `rgb(51, 102, 255)` - Bright blue
- **Cool (15-25°C)**: `rgb(102, 77, 230)` - Blue-purple transition
- **Medium (25-35°C)**: `rgb(153, 51, 204)` - Purple
- **Warm (35-45°C)**: `rgb(204, 51, 179)` - Purple-pink
- **Hot (45-60°C)**: `rgb(255, 51, 153)` - Hot pink
- **Very Hot (> 60°C)**: `rgb(255, 77, 128)` - Lighter hot pink

This gradient provides excellent visual feedback on temperature changes and is scientifically intuitive (blue = cold, pink = hot).

#### Accent Colors
- **Primary Accent**: `rgb(102, 153, 255)` - Light blue for interactive elements
- **Secondary Accent**: `rgb(204, 77, 230)` - Purple for highlights
- **Success**: `rgb(77, 204, 128)` - Green for pump on/success states
- **Warning**: `rgb(255, 153, 51)` - Orange for pause/warning
- **Danger**: `rgb(255, 77, 77)` - Red for stop/danger

#### Solar/Sun Colors
- **Sun**: `rgb(255, 204, 51)` - Warm yellow
- **Sun Glow**: `rgb(255, 179, 0)` - Golden glow effect

#### Text Colors
- **Primary**: White `rgba(255, 255, 255, 1.0)`
- **Secondary**: `rgba(255, 255, 255, 0.7)` - Dimmed text
- **Tertiary**: `rgba(255, 255, 255, 0.5)` - Subtle text

### Typography

All text uses the SF Rounded design for a modern, friendly appearance:

- **Large Title**: 34pt, Bold - App title
- **Title**: 28pt, Semibold - Section headers
- **Title 2**: 22pt, Semibold - Subsection headers
- **Headline**: 17pt, Semibold - Card titles
- **Body**: 17pt, Regular - Main content
- **Caption**: 12pt, Regular - Labels and metadata
- **Monospaced Digit**: 17pt, Monospaced - Time and temperature values

### Spacing System

Consistent spacing using a scale:
- **XS**: 4px - Tight spacing
- **SM**: 8px - Small gaps
- **MD**: 16px - Standard padding
- **LG**: 24px - Section spacing
- **XL**: 32px - Large gaps
- **XXL**: 48px - Major divisions

### Corner Radius
- **SM**: 8px - Small elements
- **MD**: 12px - Cards and panels
- **LG**: 16px - Large containers
- **XL**: 24px - Major sections

## Main Visualization: Schematic View

The **SchematicView** is the centerpiece of the app, showing:

### Components

1. **Sun Indicator** (Top)
   - Animated sun icon (☀️) during day, moon (🌙) at night
   - Radial glow effect proportional to solar irradiance
   - Real-time irradiance display (W/m²)

2. **Solar Collector Panel** (Left)
   - Large rounded rectangle with temperature-based gradient fill
   - Grid pattern overlay simulating photovoltaic cells
   - Live temperature label with dark card overlay
   - Shadow effect using temperature color for "heat glow"

3. **Piping System** (Center)
   - **Hot Pipe** (Top): From collector to tank
   - **Return Pipe** (Bottom): From tank back to collector
   - Color matches fluid temperature using gradient
   - Animated flow indicators when pump is on:
     - White circles flow through pipes
     - Staggered animation for continuous flow effect
   - **Pump Indicator** (Middle):
     - Circular badge between pipes
     - Green glow when running, gray when off
     - Rotating animation when active

4. **Storage Tank** (Right)
   - Tall rounded rectangle showing stratification
   - **10 horizontal layers** with independent temperature colors
   - Smooth gradient from cold (bottom) to hot (top)
   - Temperature labels at top and bottom
   - Volume indicator (300L) at base
   - Demonstrates thermal stratification in real-time

### Temperature Color Feedback

Every component in the schematic updates its color based on actual temperature:
- **Collector**: Glows from blue (cool) to hot pink (very hot)
- **Pipes**: Show fluid temperature as it flows
- **Tank layers**: Each layer independently colored, creating visible stratification
- **Shadows**: Temperature-based glow effects enhance the heat visualization

### Animations

- **Sun Glow**: Pulsing radial gradient during daytime
- **Flow Indicators**: Continuous vertical movement through pipes (1.5s cycle)
- **Pump Rotation**: 360° rotation every 2 seconds when active
- **Color Transitions**: Smooth interpolation as temperatures change

## Control Panel

Located on the left side (landscape) or top (portrait):

### Sections

1. **Time Display**
   - Large digital clock (HH:MM format)
   - Sun/moon icon indicator
   - Card-style background

2. **Simulation Controls**
   - **Start/Pause Button**: Green (start) or orange (pause)
   - **Reset Button**: Blue, returns to initial state
   - **Speed Slider**: 1x to 300x, with live readout

3. **System Status**
   - Solar irradiance (sun color)
   - Ambient temperature (blue)
   - Collector temperature (gradient)
   - Tank top/bottom/average (gradient colors)
   - All use temperature-appropriate colors

4. **Pump Controls**
   - Status indicator (green dot when on)
   - Automatic/Manual toggle
   - Manual control button (when automatic is off)

5. **Energy Statistics**
   - Large kWh display in green
   - Cumulative collection over simulation

### Card Design

All sections use elevated cards with:
- Dark card background
- Medium corner radius (12px)
- Subtle shadow for depth
- Consistent padding (16px)

## Chart View

Alternative visualization accessible via toggle:

### Features

- **Dark background** matching app theme
- **Temperature gradient colors**:
  - Collector: Hot pink
  - Tank Top: Purple
  - Tank Bottom: Blue
  - Ambient: Gray (dashed)
  - Solar: Yellow (dashed)
- **Grid lines**: Subtle tertiary color
- **Axis labels**: Secondary text color
- **Legend**: Bottom-aligned with color-coded lines

## Responsive Layout

### Landscape (iPad)
- **Control Panel**: 30% width on left
- **Schematic/Chart**: 70% width on right
- Side-by-side layout

### Portrait (iPad)
- **Control Panel**: 35% height on top
- **Schematic/Chart**: 65% height on bottom
- Stacked vertical layout

## View Toggle

Users can switch between:
- **Schematic** (default): Interactive system diagram
- **Chart**: Temperature graph over time

Toggle buttons at top of visualization area with:
- Active state: Card background
- Inactive state: Transparent
- Smooth transition between views

## Dark Mode Enforcement

The app is **dark mode only**:
- Set via `.preferredColorScheme(.dark)` on root view
- All colors designed specifically for dark backgrounds
- No light mode variants
- Ensures consistent, premium appearance

## Accessibility

- High contrast between text and backgrounds
- Color is supplemented with labels and icons
- Large tap targets (minimum 44x44 points)
- Clear visual hierarchy
- Readable fonts with appropriate sizes

## Animation Principles

- **Subtle and purposeful**: Animations enhance understanding
- **Performant**: 60 FPS animations using SwiftUI
- **Meaningful**: Flow shows pump operation, glow shows sun intensity
- **Non-distracting**: Smooth, professional motion

## Technical Implementation

### Centralized Styling
All design tokens in `AppStyling.swift`:
- Single source of truth
- Easy to maintain and update
- Consistent across entire app

### Temperature Color Function
```swift
AppStyling.Temperature.color(for: temperature)
```
Automatically returns appropriate color for any temperature value using smooth interpolation.

### Reusable Components
- `CardStyle` modifier for consistent cards
- `statusRow()` for uniform status display
- `legendItem()` for chart legend consistency

## Visual Hierarchy

1. **Primary**: Schematic visualization (largest, center)
2. **Secondary**: Control panel (persistent, left/top)
3. **Tertiary**: Chart view (alternative, toggled)
4. **Utility**: Time, pump status (always visible)

## Future Enhancements

Potential visual improvements:
- [ ] Animated steam/heat waves from collector
- [ ] Particle effects for solar rays
- [ ] 3D perspective transform on schematic
- [ ] Fluid simulation in pipes
- [ ] Temperature heatmap overlay
- [ ] Day/night background gradient
- [ ] Custom tank level animation
- [ ] Energy collection sparkle effects

---

**Design Philosophy**: Beautiful, functional, and thermodynamically accurate. Every visual element serves both aesthetic and educational purposes.


