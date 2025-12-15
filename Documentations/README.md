# PHR Project Documentation
Note: These documentations were written using AI and then modified and verified by us.

## Quick Navigation

| Document | Description |
|----------|-------------|
| [Architecture](Architecture.md) | App architecture and design patterns |
| [Models](Models.md) | Data models and structures |
| [Services](Services.md) | Data services and persistence |
| [Controllers](Controllers.md) | View controllers by feature |
| [Views](Views.md) | Custom UI components |
| [Storyboards](Storyboards.md) | UI layout and navigation |
| [Extensions](Extensions.md) | Swift extensions and utilities |
| [References](References.md) | External resources and citations |

## Project Structure

```
PHR_Project/
├── AppDelegate.swift          # App lifecycle
├── SceneDelegate.swift        # Scene lifecycle
├── Constants.swift            # App-wide constants
├── Base.lproj/               # Main storyboards
├── Controller/               # View controllers (by feature)
├── Model/                    # Data models
├── View/                     # Custom UI components
├── DataService/              # Persistence services
├── Extensions/               # UIKit extensions
└── CoreData/                 # Core Data model (if used)
```

## Features

- **Home** - Dashboard with health summaries
- **Meals** - Meal logging and nutrition tracking
- **Symptoms** - Symptom tracking and history
- **Documents** - Health document management
- **Profile** - User profile and allergies
- **Family** - Family member management
