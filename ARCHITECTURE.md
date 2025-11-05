# Architecture

This document describes the layered architecture of the Solar Thermal System application.

## Directory Structure

The codebase is organized by **layers** and within the UI layer by **features**:

```
SolarThermalSystem/
├── App/                                    # Application Layer
│   └── SolarThermalSystemApp.swift        # App entry point
│
├── Core/                                   # Core/Reusable Layer
│   ├── Styling/                           # Styling & Theming
│   │   └── AppStyling.swift              # Centralized design system
│   └── UI/                                # Reusable UI Components
│       └── FloatingPanel.swift           # Floating panel modifier
│
├── Features/                               # Features Layer
│   └── Simulation/                        # Simulation Feature
│       ├── Models/                        # Domain/Business Models
│       │   ├── Environment.swift         # Environmental conditions model
│       │   ├── SolarCollector.swift      # Solar collector physics model
│       │   ├── ThermalStorageTank.swift  # Thermal storage tank model
│       │   ├── Pump.swift                # Circulation pump model
│       │   └── TemperatureDataPoint.swift # Data point for graphing
│       ├── ViewModels/                    # Presentation Logic
│       │   └── SimulationViewModel.swift # Main simulation coordinator
│       └── Views/                         # UI Views
│           ├── ContentView.swift         # Main view with controls
│           └── SchematicView.swift       # Schematic visualization
│
└── Resources/                              # Resources Layer
    └── Assets.xcassets/                   # Images, colors, icons
```

## Architecture Layers

### 1. App Layer
- **Purpose**: Application entry point and configuration
- **Contents**: `@main` struct and global app settings
- **Dependencies**: Can depend on all other layers

### 2. Core Layer
- **Purpose**: Reusable components shared across features
- **Subfolders**:
  - `Styling/`: Design system (colors, typography, spacing)
  - `UI/`: Reusable UI components and modifiers
- **Dependencies**: Should not depend on Features layer

### 3. Features Layer
- **Purpose**: Feature-specific code organized by domain
- **Organization**: Each feature is subdivided into:
  - `Models/`: Domain models and business logic
  - `ViewModels/`: Presentation logic (MVVM pattern)
  - `Views/`: SwiftUI views
- **Dependencies**: Features can use Core layer but should be independent of each other

### 4. Resources Layer
- **Purpose**: Non-code assets (images, asset catalogs)
- **Contents**: Assets.xcassets and other resources
- **Dependencies**: None

## Design Patterns

### MVVM (Model-View-ViewModel)
The application follows the MVVM pattern:

- **Models** (`Models/`): Pure business logic with no UI dependencies
  - `Environment`: Solar irradiance and ambient temperature calculations
  - `SolarCollector`: Heat absorption and transfer physics
  - `ThermalStorageTank`: Thermal storage with stratification
  - `Pump`: Circulation pump control logic

- **ViewModels** (`ViewModels/`): Bridge between Models and Views
  - `SimulationViewModel`: Orchestrates the simulation, updates UI state

- **Views** (`Views/`): SwiftUI views for presentation
  - `ContentView`: Main interface with control panel
  - `SchematicView`: Visual schematic of the system

## Benefits of This Structure

1. **Separation of Concerns**: Clear boundaries between layers
2. **Scalability**: Easy to add new features without affecting existing code
3. **Reusability**: Core components can be used across features
4. **Testability**: Models are independent and easy to test
5. **Maintainability**: Related files are grouped together
6. **Team Collaboration**: Different developers can work on different features

## Adding New Features

To add a new feature:

1. Create a new folder under `Features/`
2. Add subfolders: `Models/`, `ViewModels/`, `Views/`
3. Keep feature-specific code within that feature folder
4. Extract reusable components to the `Core/` layer

## File Sync

This project uses Xcode's modern `PBXFileSystemSynchronizedRootGroup` format, which automatically discovers source files. No manual project file updates are needed when adding or moving files.

