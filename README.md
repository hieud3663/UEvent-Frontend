# UEvent Mobile - Next-Gen Event Experience App

[](https://flutter.dev/)
[](https://dart.dev/)
[](https://www.google.com/search?q=https://clean-architecture.com/)
[](https://opensource.org/licenses/MIT)

**UEvent Mobile** is a high-performance, cross-platform application designed to revolutionize how users discover, join, and interact with events. Built with **Flutter**, it delivers a native-grade experience with a focus on real-time engagement and seamless entry validation.

> **Backend (Django):** [Link to Repository](https://github.com/TriNguyenThanh/UEvent-backend-Django)

-----

## Core Mobile Experiences

  * **Seamless Onboarding:** Modern Authentication flow including JWT handling and secure session persistence.
  * **Interactive Event Discovery:** Browse, filter, and register for events with a fluid, gesture-driven UI.
  * **Smart Ticket & QR Check-in:** Digital ticket generation with dynamic QR codes for instant, paperless event entry.
  * **Live Engagement Hub:** Real-time Q\&A sessions and instant feedback loops during active events.
  * **Offline-First Readiness:** Local caching of event details to ensure access even with spotty connectivity.

-----

## Technical Architecture

The application is engineered using **Clean Architecture** principles with a **Feature-first** structure to ensure the codebase remains testable and scalable.

### Frontend Stack

  * **State Management:** BLoC (Business Logic Component) / Riverpod — *ensuring a predictable state and separation of concerns.*
  * **Networking:** **Dio** with custom Interceptors for JWT handling and global error logging.
  * **Local Storage:** **Isar / Hive** for high-performance NoSQL local caching.
  * **Dependency Injection:** **Get\_it** & **Injectable**.
  * **UI/UX:** Custom theme engine with Dark Mode support and responsive layouts.

### System Design

  * **Data Layer:** Handles API communication and Data Mapping (Models).
  * **Domain Layer:** Pure Business Logic (Entities & Use Cases) — *Independent of any framework.*
  * **Presentation Layer:** UI Widgets and State Management logic.

-----

## 🛠 Engineering Standards

  * **CI/CD:** Automated builds and Unit Testing via **GitHub Actions**.
  * **Code Quality:** Strict Linting rules (flutter\_lints) and formatted code for maximum readability.
  * **Unit Testing:** Extensive testing of Use Cases and BLoCs to ensure zero-regression logic.
  * **Environment Configuration:** Support for multiple environments (Dev, Staging, Prod) via `.env` files.

-----

## Getting Started

### Prerequisites

  * Flutter SDK (3.19.x or higher)
  * Android Studio / Xcode
  * A running instance of [UEvent Backend](https://www.google.com/search?q=https://github.com/TriNguyenThanh/UEvent-backend-Django)

### Installation

1.  **Clone the project**

    ```bash
    git clone https://github.com/TriNguyenThanh/UEvent-Frontend-Flutter.git
    cd UEvent-Frontend-Flutter
    ```

2.  **Install Dependencies**

    ```bash
    flutter pub get
    ```

3.  **Setup Environment Variables**
    Create a `.env` file in the root directory:

    ```env
    API_BASE_URL=http://your-api-ip:8000/api/v1
    DEBUG_MODE=true
    ```

4.  **Run Code Generation** (if using Injectable/Mappable)

    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the App**

    ```bash
    flutter run
    ```

-----

## Quality Control

To run the comprehensive test suite:

```bash
flutter test
```