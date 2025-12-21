Product Requirements Document (PRD)
Bookist - A Modern Book Reading & Discovery App

1. Executive Summary
Product Name: Bookist
Platform: iOS (iPhone & iPad)
Technology Stack: SwiftUI, SwiftData, Gutendex API
Version: 1.0
Target iOS: iOS 17.0+
Bookist is a premium book reading and discovery application that delivers a highly animated, intuitive experience for book lovers. The app leverages the free Gutendex API for book data and implements a sophisticated design system with pixel-perfect layouts, advanced animations, and seamless data persistence.

2. Technical Architecture
2.1 Architecture Pattern

MVVM + Clean Architecture
Repository Pattern for data layer abstraction
SOLID Principles enforcement throughout codebase
Protocol-Oriented Programming for testability and modularity
Reactive State Management using Combine framework
Dependency Injection for loose coupling

2.2 Core Layers
┌─────────────────────────────────────┐
│     Presentation Layer (Views)       │
│  - SwiftUI Views                     │
│  - View Components                   │
│  - Animation Controllers             │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     ViewModel Layer                  │
│  - ViewModels                        │
│  - State Management                  │
│  - Business Logic                    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Domain Layer                     │
│  - Use Cases                         │
│  - Domain Models                     │
│  - Repository Protocols              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Data Layer                       │
│  - Repositories (Implementation)     │
│  - Network Service                   │
│  - SwiftData Models                  │
│  - Cache Manager                     │
└─────────────────────────────────────┘

3. Project Structure & File Hierarchy
BookScape/
├── App/
│   ├── BookScapeApp.swift
│   └── AppConfiguration.swift
│
├── Core/
│   ├── DesignSystem/
│   │   ├── Colors/
│   │   │   ├── AppColors.swift
│   │   │   └── ColorScheme+Extension.swift
│   │   ├── Typography/
│   │   │   ├── AppFonts.swift
│   │   │   └── TextStyles.swift
│   │   ├── Spacing/
│   │   │   └── AppSpacing.swift
│   │   ├── Components/
│   │   │   ├── Buttons/
│   │   │   │   ├── PrimaryButton.swift
│   │   │   │   ├── NavigationButton.swift
│   │   │   │   └── IconButton.swift
│   │   │   ├── Cards/
│   │   │   │   ├── BookCard.swift
│   │   │   │   ├── StatsCard.swift
│   │   │   │   └── ReviewCard.swift
│   │   │   ├── Inputs/
│   │   │   │   ├── AnimatedSearchBar.swift
│   │   │   │   └── RatingView.swift
│   │   │   └── Indicators/
│   │   │       ├── ProgressRing.swift
│   │   │       └── LoadingView.swift
│   │   └── Animations/
│   │       ├── AnimationConstants.swift
│   │       ├── SpringAnimations.swift
│   │       └── TransitionAnimations.swift
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── View+Extension.swift
│   │   │   ├── String+Extension.swift
│   │   │   ├── Date+Extension.swift
│   │   │   └── Color+Extension.swift
│   │   ├── Helpers/
│   │   │   ├── HapticManager.swift
│   │   │   ├── NumberFormatter+Custom.swift
│   │   │   └── DateFormatter+Custom.swift
│   │   └── Constants/
│   │       └── AppConstants.swift
│   │
│   └── Network/
│       ├── NetworkService.swift
│       ├── APIEndpoint.swift
│       ├── NetworkError.swift
│       └── RequestBuilder.swift
│
├── Domain/
│   ├── Models/
│   │   ├── Book.swift
│   │   ├── Author.swift
│   │   ├── SearchResult.swift
│   │   └── ReadingStreak.swift
│   │
│   ├── UseCases/
│   │   ├── Books/
│   │   │   ├── FetchBooksUseCase.swift
│   │   │   ├── SearchBooksUseCase.swift
│   │   │   └── FetchBookDetailUseCase.swift
│   │   ├── ReadingHistory/
│   │   │   ├── SaveReadingHistoryUseCase.swift
│   │   │   ├── FetchRecentlyReadUseCase.swift
│   │   │   └── UpdateReadingStreakUseCase.swift
│   │   ├── SavedBooks/
│   │   │   ├── SaveBookForLaterUseCase.swift
│   │   │   ├── RemoveSavedBookUseCase.swift
│   │   │   └── FetchSavedBooksUseCase.swift
│   │   └── Reviews/
│   │       ├── SaveReviewUseCase.swift
│   │       ├── UpdateReviewUseCase.swift
│   │       └── FetchReviewsUseCase.swift
│   │
│   └── RepositoryProtocols/
│       ├── BookRepositoryProtocol.swift
│       ├── ReadingHistoryRepositoryProtocol.swift
│       ├── SavedBooksRepositoryProtocol.swift
│       ├── ReviewRepositoryProtocol.swift
│       └── UserProfileRepositoryProtocol.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── BookRepository.swift
│   │   ├── ReadingHistoryRepository.swift
│   │   ├── SavedBooksRepository.swift
│   │   ├── ReviewRepository.swift
│   │   └── UserProfileRepository.swift
│   │
│   ├── Persistence/
│   │   ├── SwiftData/
│   │   │   ├── Models/
│   │   │   │   ├── BookEntity.swift
│   │   │   │   ├── ReadingHistoryEntity.swift
│   │   │   │   ├── SavedBookEntity.swift
│   │   │   │   ├── ReviewEntity.swift
│   │   │   │   ├── UserProfileEntity.swift
│   │   │   │   └── ReadingStreakEntity.swift
│   │   │   ├── ModelContainer+Configuration.swift
│   │   │   └── SwiftDataManager.swift
│   │   │
│   │   └── Cache/
│   │       ├── ImageCache.swift
│   │       ├── CacheManager.swift
│   │       └── CachePolicy.swift
│   │
│   ├── Remote/
│   │   ├── DTOs/
│   │   │   ├── BookDTO.swift
│   │   │   ├── AuthorDTO.swift
│   │   │   └── SearchResponseDTO.swift
│   │   └── APIService.swift
│   │
│   └── DataSources/
│       ├── RemoteDataSource.swift
│       └── LocalDataSource.swift
│
├── Presentation/
│   ├── Screens/
│   │   ├── Home/
│   │   │   ├── Views/
│   │   │   │   ├── HomeView.swift
│   │   │   │   ├── Components/
│   │   │   │   │   ├── HeaderView.swift
│   │   │   │   │   ├── MenuButton.swift
│   │   │   │   │   ├── ReadingStreakCard.swift
│   │   │   │   │   ├── BookSectionView.swift
│   │   │   │   │   └── AnimatedSearchHeader.swift
│   │   │   │   └── SearchView.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── HomeViewModel.swift
│   │   │   │   └── SearchViewModel.swift
│   │   │   └── Models/
│   │   │       └── HomeViewState.swift
│   │   │
│   │   ├── BookDetail/
│   │   │   ├── Views/
│   │   │   │   ├── BookDetailView.swift
│   │   │   │   ├── Components/
│   │   │   │   │   ├── StretchyHeader.swift
│   │   │   │   │   ├── BookSummaryView.swift
│   │   │   │   │   ├── TabSelectorView.swift
│   │   │   │   │   ├── AboutSection.swift
│   │   │   │   │   ├── RatingSection.swift
│   │   │   │   │   └── BottomActionButton.swift
│   │   │   │   └── Sheets/
│   │   │   │       └── SummaryBottomSheet.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── BookDetailViewModel.swift
│   │   │   └── Models/
│   │   │       └── BookDetailViewState.swift
│   │   │
│   │   └── Profile/
│   │       ├── Views/
│   │       │   ├── ProfileView.swift
│   │       │   ├── Components/
│   │       │   │   ├── ProfileHeaderView.swift
│   │       │   │   ├── StatsSection.swift
│   │       │   │   ├── GoalsCard.swift
│   │       │   │   ├── FinishedCard.swift
│   │       │   │   ├── InsightsCard.swift
│   │       │   │   ├── ReadingStreakCalendar.swift
│   │       │   │   ├── SavedBooksListView.swift
│   │       │   │   └── ReviewsListView.swift
│   │       │   └── Sheets/
│   │       │       └── SettingsSheet.swift
│   │       ├── ViewModels/
│   │       │   └── ProfileViewModel.swift
│   │       └── Models/
│   │           └── ProfileViewState.swift
│   │
│   ├── Navigation/
│   │   ├── AppCoordinator.swift
│   │   ├── NavigationRouter.swift
│   │   └── NavigationDestination.swift
│   │
│   └── StateManagement/
│       ├── AppState.swift
│       ├── StateObserver.swift
│       └── DataConsistencyManager.swift
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Fonts/
│   └── Localizable.strings
│
├── Supporting Files/
│   ├── Info.plist
│   ├── instructions.md
│   └── README.md
│
└── Tests/
    ├── UnitTests/
    │   ├── ViewModelTests/
    │   ├── UseCaseTests/
    │   └── RepositoryTests/
    └── UITests/

4. Design System Specifications
4.1 Color Palette
swift// Extract from screenshots - Light Mode
struct LightModeColors {
    static let background = Color(hex: "#FFFFFF")
    static let cardBackground = Color(hex: "#F5F5F5")
    static let headerDark = Color(hex: "#1A1A1A")
    static let primaryText = Color(hex: "#000000")
    static let secondaryText = Color(hex: "#666666")
    static let accent = Color(hex: "#6366F1") // Purple
    static let accentOrange = Color(hex: "#FF6B35")
    static let divider = Color(hex: "#E5E5E5")
}

// Dark Mode
struct DarkModeColors {
    static let background = Color(hex: "#000000")
    static let cardBackground = Color(hex: "#1A1A1A")
    static let headerLight = Color(hex: "#FFFFFF")
    static let primaryText = Color(hex: "#FFFFFF")
    static let secondaryText = Color(hex: "#A0A0A0")
    static let accent = Color(hex: "#818CF8") // Lighter Purple
    static let accentOrange = Color(hex: "#FF8C6B")
    static let divider = Color(hex: "#333333")
}
4.2 Typography System
swiftenum AppFontWeight {
    case regular, medium, semibold, bold
}

enum AppFontSize {
    case caption     // 12pt
    case body        // 15pt
    case bodyLarge   // 17pt
    case title       // 20pt
    case titleLarge  // 24pt
    case headline    // 28pt
    case display     // 34pt
}

struct TextStyle {
    let size: AppFontSize
    let weight: AppFontWeight
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
}

// Predefined Styles
extension TextStyle {
    static let largeTitle = TextStyle(size: .display, weight: .bold, lineHeight: 41, letterSpacing: 0)
    static let title1 = TextStyle(size: .headline, weight: .bold, lineHeight: 34, letterSpacing: 0.36)
    static let title2 = TextStyle(size: .titleLarge, weight: .semibold, lineHeight: 29, letterSpacing: 0.35)
    static let headline = TextStyle(size: .title, weight: .semibold, lineHeight: 24, letterSpacing: 0.38)
    static let body = TextStyle(size: .bodyLarge, weight: .regular, lineHeight: 22, letterSpacing: -0.41)
    static let bodyBold = TextStyle(size: .bodyLarge, weight: .semibold, lineHeight: 22, letterSpacing: -0.41)
    static let caption = TextStyle(size: .caption, weight: .regular, lineHeight: 16, letterSpacing: 0)
}
4.3 Spacing System
swiftstruct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
}
4.4 Corner Radius & Shadows
swiftstruct AppRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 20
    static let circle: CGFloat = .infinity
}

struct AppShadow {
    static let button = Shadow(
        color: Color.black.opacity(0.15),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let card = Shadow(
        color: Color.black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 2
    )
    
    static let navigation = Shadow(
        color: Color.black.opacity(0.2),
        radius: 6,
        x: 0,
        y: 3
    )
}

5. Animation Specifications
5.1 Animation Constants
swiftstruct AnimationTiming {
    // Duration
    static let instant: Double = 0.15
    static let quick: Double = 0.25
    static let standard: Double = 0.35
    static let moderate: Double = 0.5
    static let slow: Double = 0.7
    
    // Spring Animations
    static let springResponse: Double = 0.5
    static let springDampingRatio: Double = 0.68
    
    // Curves
    static let easeIn = Animation.easeIn(duration: standard)
    static let easeOut = Animation.easeOut(duration: standard)
    static let easeInOut = Animation.easeInOut(duration: standard)
    static let spring = Animation.spring(
        response: springResponse,
        dampingFraction: springDampingRatio
    )
    static let smoothSpring = Animation.spring(
        response: 0.4,
        dampingFraction: 0.75
    )
}
```

### 5.2 Specific Animation Behaviors

#### Search Bar Animation Sequence
```
Timeline (Total: ~0.6s):

0.0s - 0.25s: Menu Button
  - Fade out from opacity 1.0 to 0.0
  - Translate X: 0 to -30 (leftward)
  - Animation: easeIn

0.0s - 0.35s: Search Icon
  - Scale: 1.0 to 1.2 to 0 (expansion then disappear)
  - Opacity: 1.0 to 0.0
  - Animation: easeInOut

0.1s - 0.4s: Search Field
  - Width: 44pt (icon size) to full width - 100pt
  - Opacity: 0.0 to 1.0
  - Animation: smoothSpring

0.25s - 0.5s: Cancel Button
  - Translate X: 30 to 0
  - Opacity: 0.0 to 1.0
  - Animation: easeOut

0.0s - 0.25s: User Icon
  - Fade out opacity 1.0 to 0.0
  - Translate X: 0 to 30 (rightward)
  - Animation: easeIn

0.15s - 0.45s: Content Below (Home → Search)
  - Opacity: 1.0 to 0.0 to 1.0 (crossfade)
  - Scale: 1.0 to 0.98 to 1.0 (subtle breathe)
  - Animation: easeInOut
```

#### Stretchy Header Pull-to-Refresh
```
Behavior:
- Scroll offset < 0: Header height increases proportionally
- Stretch factor: abs(offset) * 0.6
- Threshold: -120pt for refresh trigger
- Haptic: .medium impact at threshold
- Spring animation on release
- Refresh indicator: Rotating circular progress
```

#### Book Card Interactions
```
On Appear:
- Delay: index * 0.1s (staggered)
- Translate Y: 20 to 0
- Opacity: 0 to 1
- Scale: 0.95 to 1.0
- Animation: smoothSpring

On Tap:
- Haptic: .light impact
- Scale: 1.0 to 0.97 to 1.0 (press effect)
- Duration: 0.15s
- Hero animation to detail screen
```

#### Section Toggle (For You ↔ Trending)
```
Content Transition:
- Outgoing section: 
  - Opacity: 1.0 to 0.0
  - Scale: 1.0 to 0.95
  - Duration: 0.25s
  
- Layout collapse/expand:
  - Height animation with spring
  - Duration: 0.35s
  
- Incoming section:
  - Opacity: 0.0 to 1.0
  - Scale: 0.95 to 1.0
  - Delay: 0.15s
  - Duration: 0.3s
```

#### Tab Selector (About ↔ Rating)
```
Indicator Movement:
- Position X animation with smoothSpring
- Duration: 0.4s
- Haptic: .selection feedback

Content Swap:
- Horizontal sliding effect
- Translation X: ±full width
- Opacity crossfade
- Animation: easeInOut (0.35s)
```

#### Rating Stars
```
On Tap:
- Fill animation: Sequential for all stars up to tapped
- Delay between stars: 0.05s
- Scale: 0.8 to 1.2 to 1.0 (bounce)
- Haptic: .light impact per star
- Color transition: gray to yellow
```

---

## 6. Screen Specifications

### 6.1 Home Screen (HomeView)

#### Layout Structure
```
┌─────────────────────────────────────┐
│  Header (40% vertical)               │
│  ┌───────────────────────────────┐  │
│  │ Menu Button  [Search] [User]  │  │
│  │                                │  │
│  │  Did you read today?           │  │
│  │  [Calendar Streak: 7 days]     │  │
│  │  [Yes, I read today! Button]   │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  Content (60% vertical, scrollable) │
│  ┌───────────────────────────────┐  │
│  │ Recently Read                  │  │
│  │ [Horizontal Scroll: Book Cards]│  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Popular Books                  │  │
│  │ [Horizontal Scroll: Book Cards]│  │
│  │ [Load More on Scroll]          │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

#### Component Specifications

**Header View**
- Height: 40% of screen height
- Background: 
  - Light mode: `#1A1A1A`
  - Dark mode: `#FFFFFF`
- Corner radius: Bottom corners only, 24pt
- Padding: Top safe area + 16pt, horizontal 20pt

**Menu Button (UIMenu)**
- Title: "For You" (default) with chevron down
- Options: ["For You", "Trending"]
- Typography: Title2 style
- Behavior: 
  - "For You": Shows both Recently Read & Popular Books
  - "Trending": Hides Recently Read, shows only Popular Books
  - Haptic: .selection on change
  - Animation: Fade/collapse sections (0.35s spring)

**Search Icon Button**
- Size: 44x44pt
- Icon: SF Symbol "magnifyingglass"
- Shadow: AppShadow.navigation
- Tap behavior: Triggers search animation sequence

**User Icon Button**
- Size: 44x44pt
- Icon: SF Symbol "person.fill"
- Shadow: AppShadow.navigation
- Tap behavior: Navigate to ProfileView

**Reading Streak Card**
- Background: Card background with border radius 16pt
- Padding: 20pt
- Title: "Did you read today?" (Headline style)
- Calendar: 7-day horizontal layout
  - Days: Mon-Sun with dates
  - Current day: Highlighted with accent color circle
  - Read days: Checkmark indicator
  - Unread days: Empty circle
- Button: "Yes, I read today!"
  - Full width, height 50pt
  - Background: Primary black (light) / white (dark)
  - Corner radius: 12pt
  - Tap: Mark current day as read, haptic .medium
  - Update: Save to SwiftData, update UI immediately

**Recently Read Section**
- Title: "Recently Read" (Title2 style)
- Display condition: Only if user has reading history
- Empty state: "Search for any book with title or author name and start reading"
  - Typography: Body style, secondary text color
  - Animation: Fade in with breathing effect (scale 0.98 to 1.0 loop)
- Layout: Horizontal ScrollView
- Book Cards: 120x180pt covers, title below (2 lines max)
- Data source: SwiftData query (limit 10 most recent)
- Animation: Staggered appear (0.1s delay per card)

**Popular Books Section**
- Title: "Popular Books" (Title2 style)
- Layout: Horizontal ScrollView with pagination
- API Endpoint: `https://gutendex.com/books?page=1`
- Initial load: 10 books
- Pagination: Load next page when scrolled to last 2 items
- Loading indicator: Subtle spinner at end
- Book Cards: Same as Recently Read

#### Search Experience

**Search Activation**
```
State Transitions:
1. Normal State → Search Active State
   - Trigger: Tap search icon
   - Animation sequence: See Animation Specifications
   - UI Changes:
     * Hide: Menu button, user icon
     * Transform: Search icon → Search field
     * Show: Cancel button, keyboard
     * Replace: HomeView content → SearchView content
     
2. SearchView Layout:
   - Search field: 
     * Height: 50pt
     * Corner radius: 12pt
     * Placeholder: "Search books or authors..."
     * Clear button when typing
   - Cancel button:
     * Text: "Cancel"
     * Typography: Body style
     * Width: 60pt
   
   - Content Area:
     * Default: Recent searches list
     * Typing: Live search results
     * Results: Book list with cover, title, author, summary (3 lines)
```

**Search Implementation**
- Debounce: 0.3s after last keystroke
- API Call: `GET /books?search={query}`
- Results: Display with fade-in stagger animation
- Tap result: Navigate to BookDetailView with hero animation
- Recent searches: Store in SwiftData (max 10), newest first

---

### 6.2 Book Detail Screen (BookDetailView)

#### Layout Structure
```
┌─────────────────────────────────────┐
│ [Back] ────────────────────── [Share]│
│                                      │
│  ┌────────────────────────────────┐ │
│  │                                 │ │
│  │   Stretchy Header Image (30%)   │ │
│  │                                 │ │
│  └────────────────────────────────┘ │
│              [Save Later Icon]       │
├──────────────────────────────────────┤
│  Scrollable Content:                 │
│  ┌────────────────────────────────┐ │
│  │ Book Title (Title1)             │ │
│  │ Summary (Body, 3 lines)...more  │ │
│  │                                 │ │
│  │ Author: Name    2,263 Readers   │ │
│  │ ──────────────────────────────  │ │
│  │ [About] ──── [Rating]           │ │
│  │ ════════                        │ │
│  │                                 │ │
│  │ ┌─ About Content ──────────┐   │ │
│  │ │ Authors: X, Y, Z          │   │ │
│  │ │ Subjects: A, B, C         │   │ │
│  │ │ Bookshelves: P, Q         │   │ │
│  │ │ Language: [EN Badge]      │   │ │
│  │ └───────────────────────────┘   │ │
│  │                                 │ │
│  │   OR                            │ │
│  │                                 │ │
│  │ ┌─ Rating Content ─────────┐   │ │
│  │ │ How was the book?         │   │ │
│  │ │ ★★★★★                    │   │ │
│  │ │ [Write your review...]    │   │ │
│  │ │ [Save Button]             │   │ │
│  │ └───────────────────────────┘   │ │
│  └────────────────────────────────┘ │
├──────────────────────────────────────┤
│  [Start Reading] (Pinned Bottom)    │
└──────────────────────────────────────┘
Navigation Buttons
Back Button

Position: Top-left, safe area + 16pt
Size: 44x44pt
Background: White (light) / Black (dark) with opacity 0.9
Corner radius: 22pt (circle)
Icon: SF Symbol "chevron.left"
Shadow: AppShadow.navigation
Behavior: Pop to previous screen with animation

Share Button

Position: Top-right, safe area + 16pt
Size: 44x44pt
Background: Same as back button
Icon: SF Symbol "square.and.arrow.up"
Shadow: AppShadow.navigation
Behavior: Present share sheet with book info

Save Later Icon

Position: Below header, centered, -22pt overlap
Size: 44x44pt
Background: Accent color
Icon: SF Symbol "bookmark" / "bookmark.fill"
Corner radius: 22pt
Shadow: AppShadow.button
State:

Unfilled: Not saved
Filled: Saved to list


Behavior: Toggle save state, haptic .medium, update SwiftData

Stretchy Header
Implementation
swiftBehavior:
- Default height: 30% of screen
- Scroll offset tracking via GeometryReader
- Stretch factor: max(0, -offset) for pull down
- New height: defaultHeight + (stretchFactor * 0.6)
- Image: Aspect fill, clipped to bounds
- Threshold: -120pt for refresh
- Haptic: .medium at threshold
- Action: Reload book detail from API
- Animation: Spring on release
Overlay Elements

Gradient overlay: Bottom 40% with fade to content background
Save Later button: Positioned absolutely

Book Information Section
Title & Summary

Title: Title1 style, 2 lines max
Summary: Body style, 3 lines with "...more"
Tap "more": Present bottom sheet with full summary
Summary sheet:

Detent: .medium (iPhone), .large (iPad)
Background: Card background
Corner radius: 20pt (top)
Padding: 24pt
Typography: Same as summary
Dismiss: Swipe down or tap outside



Author & Readers

Layout: Horizontal stack, space between
Author:

Label: "Author" (Caption style)
Name: Body bold style


Readers:

Label: Use download_count from API
Format: "2,263 Readers"
Typography: Caption style



Tab Selector (About / Rating)
Design

Background: Divider color
Height: 44pt
Corner radius: 8pt
Tabs: Equal width
Selected indicator:

Background: Primary text color
Corner radius: 6pt
Position animation: smoothSpring
Shadow: Subtle inner shadow



Interaction

Tap: Switch content with horizontal slide
Haptic: .selection feedback
Animation: Content fade + slide (0.35s)

About Section Content
Layout (Vertical Stack)
Authors:
├─ Heading: "Authors" (Headline style)
└─ Text: Comma-separated names (Body style)

Subjects:
├─ Heading: "Subjects" (Headline style)
└─ Text : Comma-separated (Body style)
Bookshelves:
├─ Heading: "Bookshelves" (Headline style)
└─ Text: Comma-separated (Body style)
Language:
├─ Heading: "Language" (Headline style)
└─ Badge:
├─ Background: Linear gradient (accent colors)
├─ Stroke: 1pt white/black
├─ Shadow: AppShadow.card
├─ Padding: 8pt horizontal, 4pt vertical
├─ Corner radius: 6pt
└─ Text: Language code uppercase (e.g., "EN")

**Spacing**
- Between sections: 24pt
- Heading to content: 8pt

#### Rating Section Content

**Title**
- Text: "How was the book?"
- Typography: Headline style
- Alignment: Leading

**Star Rating View**
```swift
Implementation:
- 5 stars horizontal
- Size: 32x32pt each
- Spacing: 8pt
- States:
  * Unfilled: Gray outline
  * Filled: Yellow fill with subtle glow
- Interaction:
  * Tap star N: Fill stars 1 to N
  * Sequential animation: 0.05s delay between stars
  * Scale effect: 0.8 → 1.2 → 1.0 per star
  * Haptic: .light per star
- Validation: At least 1 star required for save
```

**Review Text Field**
```swift
Design:
- Placeholder: "Write your review..."
- Min height: 100pt
- Max height: 200pt (scrollable)
- Background: Card background
- Border: 1pt divider color
- Corner radius: 12pt
- Padding: 12pt
- Typography: Body style
- Character limit: 500 (optional)
```

**Save Button**
```swift
Design:
- Width: Full width - 32pt horizontal padding
- Height: 50pt
- Corner radius: 12pt
- Background: Accent color
- Typography: Body bold, white text
- Shadow: AppShadow.button
- Disabled state: Opacity 0.5 when no rating

Behavior:
- Validation: Rating required (1-5 stars)
- Review text: Optional
- Action: 
  * Save/Update ReviewEntity in SwiftData
  * Include: bookId, rating, reviewText, date
  * Update: If review exists, update; else create
  * Haptic: .success
  * UI feedback: Checkmark animation briefly
  * Broadcast: Notify DataConsistencyManager
```

**Edit Existing Review**
- If review exists: Populate stars and text
- Button text: "Update Review"
- Animation: Fade in content when loading

#### Bottom Action Button

**Start Reading Button**
```swift
Design:
- Position: Pinned to bottom safe area
- Width: Full width - 32pt
- Height: 56pt
- Corner radius: 16pt
- Background: Primary text color (inverted)
- Typography: Headline style
- Text: "Start Reading"
- Shadow: AppShadow.button

Behavior:
- Tap: Haptic .medium
- Action: Open EPUB reader (placeholder for now)
- Future: Integrate EPub reader package
```

**Context-Aware Bottom Button**
- About section: "Start Reading"
- Rating section with no review: "Start Reading"
- Rating section with review: "Update Review" (if edited)

---

### 6.3 Profile Screen (ProfileView)

#### Layout Structure
┌─────────────────────────────────────┐
│ [Back: Profile] ────────────── [⚙️]│
│                                      │
│  ┌────────────────────────────────┐ │
│  │    Header (25% height)          │ │
│  │                                 │ │
│  │    You [✏️]                     │ │
│  │    2.4K book reads • 24 reviewed│ │
│  └────────────────────────────────┘ │
├──────────────────────────────────────┤
│  [Stats] [Lists] [Reviews]          │
│  ═══════                            │
├──────────────────────────────────────┤
│  Scrollable Content (75%):          │
│  ┌────────────────────────────────┐ │
│  │ ┌─ Goals Card ──────────────┐  │ │
│  │ │ 🏆 2025 Reading Goal       │  │ │
│  │ │ 01 of 30 books             │  │ │
│  │ │ [Progress Ring]            │  │ │
│  │ └────────────────────────────┘  │ │
│  │ ┌─ Finished Card ───────────┐  │ │
│  │ │ 📚 30 books so far         │  │ │
│  │ └────────────────────────────┘  │ │
│  │ ┌─ Insights Card ───────────┐  │ │
│  │ │ 💡 Insights                │  │ │
│  │ │ At your current pace...    │  │ │
│  │ └────────────────────────────┘  │ │
│  │ ┌─ Reading Streak ──────────┐  │ │
│  │ │ Best reading streak        │  │ │
│  │ │ [September ▼]              │  │ │
│  │ │ [Calendar Grid]            │  │ │
│  │ └────────────────────────────┘  │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘

#### Header Section

**Design**
- Height: 25% of screen
- Background: 
  - Light mode: `#1A1A1A` (dark)
  - Dark mode: `#FFFFFF` (light)
- Corner radius: Bottom 24pt
- Padding: Safe area top + 16pt, horizontal 20pt

**Back Button**
- Title: "Profile"
- Style: Title2
- Icon: chevron.left before title
- Custom font applied

**Settings Button**
- Icon: SF Symbol "gearshape.fill"
- Size: 44x44pt
- Behavior: Present settings bottom sheet

**User Name Field**
```swift
Design:
- Text: "You" (default)
- Icon: SF Symbol "pencil" (12pt, secondary color)
- Typography: Display style
- Editable: Tap to focus inline
- Max length: 30 characters
- Save: On editing end, update SwiftData

Implementation:
- State binding to UserProfileEntity
- Auto-save on text change with debounce (0.5s)
- Animation: Subtle scale pulse on edit
```

**Stats Text**
```swift
Format:
- Pattern: "{reads} book reads • {reviews} reviewed"
- Reads formatting:
  * < 1000: Show exact number (e.g., "24")
  * >= 1000: Show abbreviated (e.g., "2.4K")
  * >= 1000000: Show in millions (e.g., "1.2M")
- Reviews: Same formatting

Empty State:
- Text: "Today is a good day to start reading"
- Animation: Fade in with gentle breathing (0.98-1.0 scale)
- Typography: Body style, secondary color
```

#### Tab Selector (Stats / Lists / Reviews)

**Design**
- Same as BookDetail tab selector
- Height: 44pt
- Equal width distribution
- Underline indicator: Animated position
- Haptic: .selection on switch

#### Stats Section Content

**Goals Card**
```swift
Design:
- Background: Accent gradient (purple)
- Corner radius: 20pt
- Padding: 24pt
- Shadow: AppShadow.card

Layout:
├─ Icon: 🏆 Trophy (32pt)
├─ Title: "2025 Reading Goal" (Title2, white)
├─ Progress: "01 of 30 books" (Headline, white)
└─ Progress Ring:
   ├─ Size: 120x120pt
   ├─ Line width: 12pt
   ├─ Background: White opacity 0.3
   ├─ Foreground: White
   ├─ Progress: bookReads / goalReads (30)
   └─ Animation: Trim path with spring (1.0s)

Behavior:
- Goal: 30 books per year (constant)
- Data source: SwiftData count of ReadingHistoryEntity
- Animation: On appear, animate ring fill
```

**Finished Card**
```swift
Design:
- Background: Card background
- Border: 1pt divider color
- Corner radius: 16pt
- Padding: 20pt

Layout:
├─ Icon: 📚 (24pt, accent orange)
├─ Text: "{count} books so far this year"
└─ Typography: Headline style

Data:
- Count: ReadingHistoryEntity filtered by current year
- Update: Reactive to data changes
```

**Insights Card**
```swift
Design:
- Background: Card background (light orange tint)
- Corner radius: 16pt
- Padding: 20pt

Layout:
├─ Icon: 💡 (24pt, accent orange)
├─ Title: "Insights" (Headline, accent orange)
└─ Message: Body style, secondary text

Logic:
- Calculate: Books read in last 30 days
- Pace: booksLastMonth / 30 * 365
- Projection: Will reach goal? On track/Behind/Ahead
- Messages:
  * On track: "Keep it going! At your current pace, you're on track to meet your 2025 reading goal in {month}."
  * Behind: "You're reading at a pace of {X} books/month. To reach your goal, aim for {Y} books/month."
  * Ahead: "Amazing! You're ahead of schedule and on track to finish {X} books this year!"

Future Enhancement:
- Share button: Generate image with stats
- Action: Present UIActivityViewController
```

**Reading Streak Card**
```swift
Design:
- Background: Card background
- Corner radius: 16pt
- Padding: 20pt

Layout:
├─ Title: "Best reading streak" (Headline)
├─ Month Picker: Dropdown with chevron
│  ├─ Shows: Current month by default
│  ├─ Options: All months with data
│  └─ Animation: Smooth transition on change
└─ Calendar Grid:
   ├─ 7 columns (Sun-Sat)
   ├─ Rows: Dynamic based on month
   ├─ Day cells: 40x40pt
   ├─ Date numbers: Caption style
   ├─ Read indicator: Accent color circle behind
   └─ Current day: Bold with accent border

Data Source:
- Query ReadingStreakEntity by selected month
- Mark days with streak.isRead = true
- Animation: Stagger fade-in on month change
```

#### Lists Section Content

**Design**
```swift
Layout: Vertical List
- Item spacing: 0 (divider creates separation)
- Padding: Horizontal 20pt

List Item:
├─ Book Cover: 60x90pt
│  ├─ Corner radius: 8pt
│  ├─ Shadow: AppShadow.card
│  └─ Cached image
├─ Content (Vertical Stack):
│  ├─ Title: Body bold, 1 line truncated
│  ├─ Author: Caption, secondary color
│  └─ Summary: Body, 2 lines truncated
└─ Divider:
   ├─ Height: 1pt
   ├─ Color: Divider color
   └─ Leading padding: 80pt (cover width + spacing)

Empty State:
- Icon: SF Symbol "bookmark" (48pt, gray)
- Text: "No saved books yet"
- Subtitle: "Tap the bookmark icon to save books for later"
- Animation: Fade in with breathing

Interaction:
- Tap: Navigate to BookDetailView
- Swipe to delete: Remove from SavedBooksEntity
- Haptic: .medium on delete
- Animation: Smooth remove with collapse
```

#### Reviews Section Content

**Design**
```swift
Layout: Vertical Stack
- Item spacing: 16pt
- Padding: Horizontal 20pt

Review Card:
├─ Header:
│  ├─ Book Title: Headline style, 1 line
│  ├─ Date: Caption, secondary color
│  └─ Chevron: SF Symbol "chevron.right"
├─ Star Rating:
│  ├─ Size: 16x16pt per star
│  ├─ Filled: Up to user rating
│  └─ Color: Yellow fill, gray outline
├─ Review Text:
│  ├─ Typography: Body style
│  ├─ Lines: 3 max with truncation
│  └─ Color: Secondary text
└─ Background: Card background
   ├─ Corner radius: 12pt
   ├─ Shadow: AppShadow.card
   └─ Padding: 16pt

Empty State:
- Icon: SF Symbol "star" (48pt, gray)
- Text: "No reviews yet"
- Subtitle: "Rate books you've read to see them here"

Interaction:
- Tap card: Navigate to BookDetailView
- Load: Book detail, scroll to Rating section
- Haptic: .light on tap
```

#### Settings Sheet

**Design**
```swift
Presentation:
- Style: .sheet
- Detents: 
  * iPhone: [.medium]
  * iPad: [.large]
- Drag indicator: Visible
- Background: Sheet background

Content:
├─ Title: "Settings" (Title1)
├─ Padding: 24pt
└─ List Items:
   ├─ Terms of Service
   │  ├─ Icon: SF Symbol "doc.text"
   │  ├─ Typography: Body
   │  └─ Action: Navigate/Open URL
   └─ Privacy Policy
      ├─ Icon: SF Symbol "hand.raised"
      ├─ Typography: Body
      └─ Action: Navigate/Open URL

Future:
- Account settings
- Notifications toggle
- Theme selector
- Language preferences
```

---

## 7. API Integration Specifications

### 7.1 Gutendex API Overview

**Base URL:** `https://gutendex.com`

**Response Format:**
```json
{
  "count": 77334,
  "next": "https://gutendex.com/books?page=2",
  "previous": null,
  "results": [
    {
      "id": 1234,
      "title": "Book Title",
      "authors": [
        {
          "name": "Author Name",
          "birth_year": 1850,
          "death_year": 1920
        }
      ],
      "subjects": ["Fiction", "Classic"],
      "bookshelves": ["Best Books", "Popular"],
      "languages": ["en"],
      "copyright": false,
      "media_type": "Text",
      "formats": {
        "text/html": "https://...",
        "application/epub+zip": "https://...",
        "image/jpeg": "https://covers.gutendex.com/..."
      },
      "download_count": 2263
    }
  ]
}
```

### 7.2 Endpoints

#### Get Books (Popular)
GET /books
Query Parameters:

page: Page number (default: 1)
page_size: Results per page (use default 32)

Usage: Popular Books section
Cache: 5 minutes for same page

#### Search Books
GET /books
Query Parameters:

search: Search term (title or author)
page: Page number

Usage: Search functionality
Cache: 2 minutes for same query
Debounce: 300ms before API call

#### Get Book by ID
GET /books/{id}
Usage: Book detail when opening from saved/recent
Cache: 10 minutes for same book

### 7.3 Network Service Implementation
```swift
protocol NetworkServiceProtocol {
    func fetchBooks(page: Int) async throws -> BookListResponse
    func searchBooks(query: String, page: Int) async throws -> BookListResponse
    func fetchBookDetail(id: Int) async throws -> Book
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://gutendex.com"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // Rate limiting: Max 60 requests/minute
    private let rateLimiter: RateLimiter
    
    // Retry logic: 3 attempts with exponential backoff
    private let retryPolicy: RetryPolicy
    
    // Request timeout: 30 seconds
    private let timeout: TimeInterval = 30
}
```

**Error Handling:**
```swift
enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case rateLimitExceeded
    case noInternetConnection
    case timeout
}

// User-facing messages
extension NetworkError {
    var localizedDescription: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        case .timeout:
            return "Request timed out. Please try again."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
```

### 7.4 Response Caching Strategy
```swift
class CacheManager {
    // Memory cache: NSCache for book covers
    private let imageCache: NSCache<NSString, UIImage>
    
    // Disk cache: FileManager for API responses
    private let diskCache: DiskCache
    
    // Cache policies
    struct CachePolicy {
        static let bookList = TimeInterval(300) // 5 minutes
        static let bookDetail = TimeInterval(600) // 10 minutes
        static let searchResults = TimeInterval(120) // 2 minutes
        static let bookCover = TimeInterval(86400) // 24 hours
    }
    
    // Cache keys
    func cacheKey(for endpoint: APIEndpoint) -> String
    
    // Image caching
    func cacheImage(_ image: UIImage, for url: URL)
    func getCachedImage(for url: URL) -> UIImage?
}
```

### 7.5 Pagination Implementation
```swift
class PaginationManager {
    private var currentPage: Int = 1
    private var nextPageURL: String?
    private var isLoading: Bool = false
    private var hasMorePages: Bool = true
    
    func loadNextPage() async throws -> [Book]
    func reset()
    func shouldLoadMore(currentItem: Book, allItems: [Book]) -> Bool
}

// Trigger pagination when:
// - User scrolls to last 2 items in horizontal scroll
// - Not currently loading
// - Has more pages available
```

---

## 8. SwiftData Schema & Relationships

### 8.1 Data Models

#### BookEntity
```swift
@Model
final class BookEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var summary: String?
    var coverImageURL: String?
    var downloadCount: Int
    var languages: [String]
    var mediaType: String
    var copyright: Bool
    
    // Relationships
    @Relationship(deleteRule: .cascade) var authors: [AuthorEntity]
    @Relationship(deleteRule: .nullify) var subjects: [SubjectEntity]
    @Relationship(deleteRule: .nullify) var bookshelves: [BookshelfEntity]
    @Relationship(deleteRule: .cascade, inverse: \ReadingHistoryEntity.book) 
    var readingHistory: ReadingHistoryEntity?
    @Relationship(deleteRule: .cascade, inverse: \SavedBookEntity.book)
    var savedBook: SavedBookEntity?
    @Relationship(deleteRule: .cascade, inverse: \ReviewEntity.book)
    var review: ReviewEntity?
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, title: String, summary: String?, coverImageURL: String?, 
         downloadCount: Int, languages: [String], mediaType: String, copyright: Bool) {
        self.id = id
        self.title = title
        self.summary = summary
        self.coverImageURL = coverImageURL
        self.downloadCount = downloadCount
        self.languages = languages
        self.mediaType = mediaType
        self.copyright = copyright
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

#### AuthorEntity
```swift
@Model
final class AuthorEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthYear: Int?
    var deathYear: Int?
    
    @Relationship(inverse: \BookEntity.authors) var books: [BookEntity]
    
    init(name: String, birthYear: Int? = nil, deathYear: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.birthYear = birthYear
        self.deathYear = deathYear
    }
}
```

#### SubjectEntity
```swift
@Model
final class SubjectEntity {
    @Attribute(.unique) var name: String
    @Relationship(inverse: \BookEntity.subjects) var books: [BookEntity]
    
    init(name: String) {
        self.name = name
    }
}
```

#### BookshelfEntity
```swift
@Model
final class BookshelfEntity {
    @Attribute(.unique) var name: String
    @Relationship(inverse: \BookEntity.bookshelves) var books: [BookEntity]
    
    init(name: String) {
        self.name = name
    }
}
```

#### ReadingHistoryEntity
```swift
@Model
final class ReadingHistoryEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int  // Reference to API ID
    @Relationship var book: BookEntity?
    var lastOpenedAt: Date
    var openCount: Int
    var currentProgress: Double  // 0.0 to 1.0
    
    init(bookId: Int, book: BookEntity? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.book = book
        self.lastOpenedAt = Date()
        self.openCount = 1
        self.currentProgress = 0.0
    }
    
    func incrementOpenCount() {
        openCount += 1
        lastOpenedAt = Date()
    }
}
```

#### SavedBookEntity
```swift
@Model
final class SavedBookEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int
    @Relationship var book: BookEntity?
    var savedAt: Date
    
    init(bookId: Int, book: BookEntity? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.book = book
        self.savedAt = Date()
    }
}
```

#### ReviewEntity
```swift
@Model
final class ReviewEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int
    @Relationship var book: BookEntity?
    var rating: Int  // 1-5
    var reviewText: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(bookId: Int, book: BookEntity? = nil, rating: Int, reviewText: String? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.book = book
        self.rating = rating
        self.reviewText = reviewText
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func update(rating: Int, reviewText: String?) {
        self.rating = rating
        self.reviewText = reviewText
        self.updatedAt = Date()
    }
}
```

#### ReadingStreakEntity
```swift
@Model
final class ReadingStreakEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var isRead: Bool
    var bookIdsRead: [Int]  // Books read on this day
    
    init(date: Date, isRead: Bool = false, bookIdsRead: [Int] = []) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.isRead = isRead
        self.bookIdsRead = bookIdsRead
    }
}
```

#### UserProfileEntity
```swift
@Model
final class UserProfileEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var yearlyReadingGoal: Int  // Default 30
    
    init(name: String = "You", yearlyReadingGoal: Int = 30) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.yearlyReadingGoal = yearlyReadingGoal
    }
}
```

### 8.2 ModelContainer Configuration
```swift
class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([
            BookEntity.self,
            AuthorEntity.self,
            SubjectEntity.self,
            BookshelfEntity.self,
            ReadingHistoryEntity.self,
            SavedBookEntity.self,
            ReviewEntity.self,
            ReadingStreakEntity.self,
            UserProfileEntity.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    @MainActor
    var context: ModelContext {
        container.mainContext
    }
}
```

### 8.3 Data Consistency Manager
```swift
@Observable
class DataConsistencyManager {
    static let shared = DataConsistencyManager()
    
    private let notificationCenter = NotificationCenter.default
    
    // Notification names
    enum DataChange {
        static let reviewUpdated = Notification.Name("reviewUpdated")
        static let bookSaved = Notification.Name("bookSaved")
        static let bookRemoved = Notification.Name("bookRemoved")
        static let readingHistoryUpdated = Notification.Name("readingHistoryUpdated")
        static let streakUpdated = Notification.Name("streakUpdated")
    }
    
    // Post updates
    func notifyReviewUpdated(bookId: Int) {
        notificationCenter.post(
            name: DataChange.reviewUpdated, 
            object: nil, 
            userInfo: ["bookId": bookId]
        )
    }
    
    func notifyBookSaved(bookId: Int) {
        notificationCenter.post(
            name: DataChange.bookSaved,
            object: nil,
            userInfo: ["bookId": bookId]
        )
    }
    
    func notifyBookRemoved(bookId: Int) {
        notificationCenter.post(
            name: DataChange.bookRemoved,
            object: nil,
            userInfo: ["bookId": bookId]
        )
    }
    
    // Subscribe to updates
    func observeDataChanges(handler: @escaping (Notification) -> Void) -> AnyCancellable {
        notificationCenter
            .publisher(for: DataChange.reviewUpdated)
            .merge(with: notificationCenter.publisher(for: DataChange.bookSaved))
            .merge(with: notificationCenter.publisher(for: DataChange.bookRemoved))
            .sink(receiveValue: handler)
    }
}
```

---

## 9. Navigation Architecture

### 9.1 Navigation Structure
```swift
enum NavigationDestination: Hashable {
    case home
    case bookDetail(bookId: Int)
    case profile
    case search
}

@Observable
class NavigationRouter {
    var path = NavigationPath()
    
    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }
    
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
```

### 9.2 Root View Setup
```swift
@main
struct BookScapeApp: App {
    @State private var router = NavigationRouter()
    
    let dataManager = SwiftDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomeView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .home:
                            HomeView()
                        case .bookDetail(let bookId):
                            BookDetailView(bookId: bookId)
                        case .profile:
                            ProfileView()
                        case .search:
                            SearchView()
                        }
                    }
            }
            .environment(router)
            .modelContainer(dataManager.container)
        }
    }
}
```

### 9.3 Navigation Transitions
```swift
// Custom navigation transitions
extension View {
    func customNavigationTransition() -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// Hero animation for book covers
extension View {
    func heroAnimation(id: String) -> some View {
        self.matchedGeometryEffect(id: id, in: namespace)
    }
}
```

---

## 10. Platform-Specific Adaptations

### 10.1 iPhone vs iPad
```swift
struct AdaptiveLayout {
    static func cardWidth(for horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
        switch horizontalSizeClass {
        case .compact:  // iPhone
            return 120
        case .regular:  // iPad
            return 180
        default:
            return 120
        }
    }
    
    static func headerHeight(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        return screenHeight * (geometry.horizontalSizeClass == .compact ? 0.4 : 0.3)
    }
    
    static func sheetDetent(for horizontalSizeClass: UserInterfaceSizeClass?) -> PresentationDetent {
        switch horizontalSizeClass {
        case .compact:
            return .medium
        case .regular:
            return .large
        default:
            return .medium
        }
    }
}
```

### 10.2 Safe Area Handling
```swift
extension View {
    func adaptivePadding() -> some View {
        self.padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
    }
    
    func adaptiveSafeArea() -> some View {
        self.safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
    }
}
```

---

## 11. Performance Optimization

### 11.1 Image Loading & Caching
```swift
actor ImageLoader {
    private let cache = ImageCache.shared
    private var activeDownloads: [URL: Task<UIImage?, Never>] = [:]
    
    func loadImage(from url: URL) async -> UIImage? {
        // Check cache first
        if let cachedImage = cache.image(for: url) {
            return cachedImage
        }
        
        // Check active downloads
        if let existingTask = activeDownloads[url] {
            return await existingTask.value
        }
        // Create new download task
    let task = Task {
        await downloadImage(from: url)
    }
    activeDownloads[url] = task
    
    let image = await task.value
    activeDownloads[url] = nil
    
    if let image = image {
        cache.store(image, for: url)
    }
    
    return image
}

private func downloadImage(from url: URL) async -> UIImage? {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    } catch {
        print("Image download failed: \(error)")
        return nil
    }
}
}

### 11.2 List Performance
````swift
// Use LazyVStack/LazyHStack for long lists
struct OptimizedBookList: View {
    let books: [Book]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(books) { book in
                    BookCard(book: book)
                        .id(book.id)
                }
            }
        }
    }
}

// Pagination trigger
extension View {
    func onAppearOfLastItem(
        in items: [Book],
        perform action: @escaping () -> Void
    ) -> some View {
        self.onAppear {
            if items.last?.id == item.id {
                action()
            }
        }
    }
}
````

### 11.3 SwiftData Query Optimization
````swift
// Fetch descriptors with predicates
extension ReadingHistoryRepository {
    func fetchRecentlyRead(limit: Int = 10) async throws -> [ReadingHistoryEntity] {
        let descriptor = FetchDescriptor<ReadingHistoryEntity>(
            sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)],
            predicate: nil
        )
        descriptor.fetchLimit = limit
        
        return try await context.fetch(descriptor)
    }
}

// Batch operations
extension SwiftDataManager {
    func batchDelete<T: PersistentModel>(_ type: T.Type, matching predicate: Predicate<T>) async throws {
        try await context.delete(model: type, where: predicate)
        try context.save()
    }
}
````

---

## 12. Accessibility

### 12.1 VoiceOver Support
````swift
extension View {
    func bookCardAccessibility(title: String, author: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title) by \(author)")
            .accessibilityHint("Double tap to view book details")
            .accessibilityAddTraits(.isButton)
    }
    
    func ratingAccessibility(rating: Int) -> some View {
        self
            .accessibilityLabel("\(rating) out of 5 stars")
            .accessibilityValue("Rating")
    }
}
````

### 12.2 Dynamic Type
````swift
// All text should respect Dynamic Type
Text("Book Title")
    .font(.custom("AppFont", size: 20, relativeTo: .title2))
    .lineLimit(2)
    .minimumScaleFactor(0.8)
````

### 12.3 Color Contrast
````swift
// Ensure minimum contrast ratios
struct AccessibleColors {
    static func ensureContrast(_ foreground: Color, on background: Color) -> Color {
        // Calculate contrast ratio
        // Return adjusted color if needed
    }
}
````

---

## 13. Testing Strategy

### 13.1 Unit Tests
````swift
// ViewModel Tests
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockRepository: MockBookRepository!
    
    override func setUp() {
        mockRepository = MockBookRepository()
        sut = HomeViewModel(repository: mockRepository)
    }
    
    func testFetchPopularBooks() async throws {
        // Given
        let expectedBooks = [/* mock books */]
        mockRepository.booksToReturn = expectedBooks
        
        // When
        await sut.fetchPopularBooks()
        
        // Then
        XCTAssertEqual(sut.popularBooks.count, expectedBooks.count)
        XCTAssertFalse(sut.isLoading)
    }
}

// Use Case Tests
final class SaveReviewUseCaseTests: XCTestCase {
    func testSaveReview_Success() async throws {
        // Test review saving logic
    }
    
    func testSaveReview_ValidationFailure() async throws {
        // Test validation
    }
}

// Repository Tests
final class BookRepositoryTests: XCTestCase {
    func testFetchBooks_CacheHit() async throws {
        // Test cache behavior
    }
}
````

### 13.2 UI Tests
````swift
final class BookScapeUITests: XCTestCase {
    func testSearchFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Tap search
        app.buttons["search"].tap()
        
        // Verify animation completed
        XCTAssertTrue(app.textFields["searchField"].exists)
        
        // Type query
        app.textFields["searchField"].tap()
        app.textFields["searchField"].typeText("Swift")
        
        // Verify results appear
        XCTAssertTrue(app.scrollViews["searchResults"].exists)
    }
}
````

---

## 14. Build Configuration

### 14.1 Xcode Project Settings
Product Name: BookScape
Organization Identifier: com.bookscape
Bundle Identifier: com.bookscape.BookScape
Deployment Target: iOS 17.0
Supported Devices: iPhone, iPad
Supported Orientations:

iPhone: Portrait only
iPad: All orientations

Capabilities:

Internet access (for API calls)

Build Configurations:

Debug
Release

Compiler Flags:

Strict Concurrency Checking: Complete
Swift Language Version: Swift 5.9


### 14.2 Info.plist Requirements
````xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>gutendex.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>

<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
</dict>

<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>

<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
````

---

## 15. Development Phases

### Phase 1: Foundation (Week 1-2)
- [x] Project setup & structure
- [x] Design system implementation
- [x] SwiftData models & relationships
- [x] Network layer & API integration
- [x] Image caching system

### Phase 2: Core Features (Week 3-4)
- [x] Home screen with menu & sections
- [x] Search functionality with animations
- [x] Book detail screen
- [x] Reading streak implementation
- [x] Navigation system

### Phase 3: User Features (Week 5)
- [x] Profile screen
- [x] Stats & insights
- [x] Review system
- [x] Saved books management

### Phase 4: Polish (Week 6)
- [x] Animation refinement
- [x] Performance optimization
- [x] Accessibility
- [x] Testing

### Phase 5: Future Enhancements
- [ ] EPUB reader integration
- [ ] Social sharing features
- [ ] Advanced statistics
- [ ] Offline mode
- [ ] Notifications

---

## 16. Key Implementation Notes

### 16.1 Critical Requirements

1. **Animation Quality**: Every interaction must feel premium
   - Use spring animations for natural movement
   - Stagger animations for lists
   - Hero transitions between screens
   - Haptic feedback on all taps

2. **Pixel Perfect Design**: Match screenshots exactly
   - Measure spacing with precision
   - Use exact color values
   - Respect typography specifications
   - Maintain design system consistency

3. **Data Consistency**: Real-time updates across screens
   - Use DataConsistencyManager for broadcasts
   - Observe changes reactively
   - Update UI immediately on data changes
   - Handle edge cases (empty states, loading, errors)

4. **Image Caching**: Optimize performance
   - Memory cache for active images
   - Disk cache for persistence
   - Async loading with placeholders
   - Cache invalidation strategy

5. **Error Handling**: Graceful degradation
   - User-friendly error messages
   - Retry mechanisms
   - Offline support where possible
   - Loading states

### 16.2 Code Quality Standards
````swift
// 1. Protocol-oriented design
protocol BookRepositoryProtocol {
    func fetchBooks(page: Int) async throws -> [Book]
}

// 2. Dependency injection
class HomeViewModel {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
}

// 3. Async/await for concurrency
func loadData() async {
    do {
        let books = try await repository.fetchBooks(page: 1)
        await MainActor.run {
            self.books = books
        }
    } catch {
        await handleError(error)
    }
}

// 4. SwiftUI best practices
struct BookCard: View {
    let book: Book
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            // Content
        }
        .frame(width: 120, height: 200)
    }
}

// 5. Clear naming conventions
// - ViewModels: HomeViewModel, BookDetailViewModel
// - Use Cases: FetchBooksUseCase, SaveReviewUseCase
// - Repositories: BookRepository, ReviewRepository
// - Entities: BookEntity, ReviewEntity
````

### 16.3 File Organization

Each feature should be self-contained:
Home/
├── Views/
│   ├── HomeView.swift
│   └── Components/
│       ├── HeaderView.swift
│       └── BookSectionView.swift
├── ViewModels/
│   └── HomeViewModel.swift
└── Models/
└── HomeViewState.swift

---

## 17. Documentation Requirements

### 17.1 README.md
````markdown
# BookScape

A modern book reading and discovery app for iOS.

## Features
- Browse popular books from Project Gutenberg
- Search by title or author
- Track reading history
- Rate and review books
- Save books for later
- Reading streak tracking
- Personalized statistics

## Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation
1. Clone the repository
2. Open BookScape.xcodeproj
3. Build and run

## Architecture
- SwiftUI for UI
- SwiftData for persistence
- MVVM + Clean Architecture
- Protocol-oriented design

## API
Uses Gutendex API (https://gutendex.com)

## License
MIT License
````

### 17.2 instructions.md
````markdown
# BookScape Implementation Instructions

## Overview
This document provides detailed implementation guidance for building BookScape.

## Prerequisites
- Xcode 15.0 or later
- iOS 17.0 SDK
- Understanding of SwiftUI and SwiftData

## Step-by-Step Implementation

### 1. Project Setup
- Create new iOS App project
- Select SwiftUI interface
- Set deployment target to iOS 17.0
- Add SwiftData capability

### 2. Design System
- Implement Colors.swift with light/dark modes
- Create Typography.swift with custom text styles
- Define Spacing.swift constants
- Build reusable components

### 3. Data Layer
- Define SwiftData models
- Create repository protocols
- Implement repository classes
- Set up model container

### 4. Network Layer
- Create NetworkService
- Define API endpoints
- Implement error handling
- Add caching logic

### 5. Presentation Layer
- Build HomeView with animations
- Implement SearchView
- Create BookDetailView
- Design ProfileView

### 6. State Management
- Set up ViewModels
- Implement DataConsistencyManager
- Configure navigation router

### 7. Testing
- Write unit tests for ViewModels
- Test use cases
- Add UI tests for critical flows

### 8. Polish
- Refine animations
- Optimize performance
- Add accessibility support
- Test on multiple devices

## Best Practices
- Follow SOLID principles
- Use async/await for async operations
- Implement proper error handling
- Write clean, documented code
- Test thoroughly

## Common Patterns

### ViewModel Pattern
```swift
@Observable
class HomeViewModel {
    var books: [Book] = []
    var isLoading = false
    var error: Error?
    
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadBooks() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            books = try await repository.fetchBooks(page: 1)
        } catch {
            self.error = error
        }
    }
}
```

### Repository Pattern
```swift
protocol BookRepositoryProtocol {
    func fetchBooks(page: Int) async throws -> [Book]
}

class BookRepository: BookRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localDataSource: LocalDataSourceProtocol
    
    func fetchBooks(page: Int) async throws -> [Book] {
        // Check cache
        if let cached = try await localDataSource.fetchBooks() {
            return cached
        }
        
        // Fetch from network
        let books = try await networkService.fetchBooks(page: page)
        
        // Save to cache
        try await localDataSource.saveBooks(books)
        
        return books
    }
}
```

## Troubleshooting

### SwiftData Issues
- Ensure model container is properly configured
- Check relationship delete rules
- Verify @Model and @Relationship attributes

### Animation Issues
- Use withAnimation {} wrapper
- Check animation timing curves
- Verify state changes trigger animations

### Network Issues
- Implement proper error handling
- Add retry logic
- Check API endpoint URLs

## Resources
- SwiftUI Documentation
- SwiftData Guide
- Gutendex API Docs
- WWDC Videos on SwiftUI

## Support
For questions or issues, please refer to the main README.md
````

---

## 18. Acceptance Criteria

### Functional Requirements
- ✅ Users can browse popular books
- ✅ Users can search for books by title/author
- ✅ Users can view detailed book information
- ✅ Users can save books for later
- ✅ Users can rate and review books
- ✅ Users can track reading history
- ✅ Users can mark daily reading streaks
- ✅ Users can view personalized statistics

### Non-Functional Requirements
- ✅ App works on iPhone (all sizes) and iPad
- ✅ Supports iOS 17.0+
- ✅ Smooth 60fps animations
- ✅ < 2s initial load time
- ✅ Offline access to saved data
- ✅ Supports light and dark modes
- ✅ Accessible via VoiceOver
- ✅ Memory efficient (<100MB typical usage)

### Quality Requirements
- ✅ Zero crashes in normal use
- ✅ Clean, readable code
- ✅ Comprehensive error handling
- ✅ Unit test coverage >70%
- ✅ UI tests for critical flows
- ✅ Follows iOS HIG
- ✅ Follows SOLID principles

---

## 19. Future Enhancements

### Phase 2 Features
1. **EPUB Reader Integration**
   - In-app reading experience
   - Bookmarking and highlights
   - Reading progress tracking
   - Font customization

2. **Social Features**
   - Share reading progress
   - Follow other readers
   - Reading challenges
   - Book clubs

3. **Advanced Statistics**
   - Reading speed analysis
   - Genre preferences
   - Reading patterns
   - Monthly/yearly reports

4. **Offline Mode**
   - Download books for offline reading
   - Queue management
   - Storage management

5. **Notifications**
   - Reading reminders
   - New releases in favorite genres
   - Streak maintenance reminders
   - Goal achievement celebrations

6. **iCloud Sync**
   - Sync across devices
   - Backup reading data
   - Restore functionality

---

## 20. Conclusion

This PRD provides comprehensive specifications for building BookScape, a premium book reading and discovery app. The focus is on:

1. **Exceptional User Experience**: Rich animations, haptic feedback, and intuitive interactions
2. **Solid Architecture**: MVVM + Clean Architecture with SOLID principles
3. **Performance**: Efficient caching, pagination, and async operations
4. **Quality**: Comprehensive testing and error handling
5. **Accessibility**: Support for all users
6. **Scalability**: Modular structure for easy feature additions

The implementation should prioritize code quality, maintainability, and adherence to iOS best practices while delivering a visually stunning and highly functional app that delights users.
