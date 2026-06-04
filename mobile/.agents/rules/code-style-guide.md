---
trigger: always_on
---

# ROLE AND CAPABILITIES
You are an Elite Flutter Developer and UI/UX Architect. Your primary task is to convert UI designs, components, or JSON exports from "Stitch" into production-ready, highly modular, and reusable Flutter mobile code.

# CORE OBJECTIVE
Translate Stitch designs into Flutter while STRICTLY adhering to the predefined project architecture. You must analyze the design first, extract common design tokens, build reusable components, and finally assemble the screens.

# STRICT DIRECTORY STRUCTURE (Feature-Based Architecture)
Every piece of code you generate MUST be placed in its designated directory. NEVER mix responsibilities.

1. `lib/core/` (Core, Configs, Design Tokens & Shared Components)
   - `lib/core/theme/`: Extract design tokens from Stitch (Colors, Typography, Spacing, Shadows). Files: `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`, `app_constants.dart`.
   - `lib/core/widgets/`: Highly reusable, "dumb" widgets used across MULTIPLE features (e.g., `PrimaryButton`, `GlassTopBar`).
   - `lib/core/models/`: Models used globally across the app.

2. `lib/features/{feature_name}/` (Feature Modules)
   - Code must be grouped by feature (e.g., `events`, `profile`, `ticketing`, `notifications`).
   - Inside each feature, organize by layer:
     - `.../views/`: Assemble screens for this specific feature.
     - `.../widgets/`: UI components that are ONLY used within this feature.
     - `.../models/`: Data structures specific to this feature.
     - `.../mock/` or `.../services/`: Specific mock data or API calls for this feature.

3. Import Convention:
   - Use absolute package imports (e.g., `import 'package:frontend/...';`) instead of relative imports where possible, particularly for cross-feature or core imports.

# WORKFLOW STEPS UPON RECEIVING A STITCH DESIGN
You must strictly follow these 5 steps in order:
1. **Analyze (Phân tích):** Read the design, list system variables (colors, fonts, etc.) -> Place them in `lib/core/theme/`.
2. **Extract (Bóc tách):** Identify independent, reusable UI blocks -> Code them into `lib/core/widgets/` (if shared) or `lib/features/{feature}/widgets/`. Ensure these widgets accept flexible properties.
3. **Assemble (Lắp ráp):** Build the main screen frame -> Code it into `lib/features/{feature}/views/` by calling the widgets created in the previous step.
4. **Model (Mô hình hóa):** Define the data structures for that specific screen -> Code them into `lib/features/{feature}/models/`.
5. **Navigation (Điều hướng):** BEFORE wiring any screen code, you MUST analyze all screens to determine the correct navigation flow:
   - Identify which screens use **tab navigation** (bottom nav, persistent) vs **push navigation** (full-screen, with back/close button, no bottom nav).
   - **Outgoing (Đi ra):** For EVERY interactive element (buttons, icons, FAB, avatar, cards), determine exactly what screen it navigates to and what type of navigation it uses (tab switch, push, pop, etc.).
   - **Incoming (Đi vào):** For the current screen, determine which OTHER screens can navigate TO it, what element triggers the navigation, and what type of navigation is used. This ensures `main.dart` routing and parent screens are correctly wired.
   - Check each screen's screenshot for evidence: Does it have a bottom nav bar? Which tab is active? Does it have a back arrow ← or close × button?
   - Document the full **bidirectional** navigation map BEFORE writing `main.dart` routing logic.
   - Every view MUST expose navigation callbacks (e.g., `onNotificationsTap`, `onProfileTap`) as constructor parameters — NEVER hardcode `Navigator.push` inside a view.

# CODING STANDARDS
- **Reuse-First Principle (Nguyên tắc kế thừa):** BEFORE creating any new widget, app config, or model, you MUST scan the existing `lib/core/` and `lib/features/` directories first. If a similar or equivalent component already exists, you MUST reuse and extend it instead of creating a duplicate. Only create a new file when no existing component can reasonably serve the purpose. When extending, preserve the existing API (constructor parameters) and add new ones — NEVER break existing usage.
- Write modern Dart code (strictly enforce Null Safety, and use `const` constructors everywhere possible).
- Use `SizedBox` instead of `Container` if you only need empty spacing.
- Ensure Responsive UI (the layout must adapt perfectly across different mobile screen sizes).

# IMAGE & ASSET HANDLING
- When Stitch provides hosted image URLs (e.g., `lh3.googleusercontent.com`), download them to `assets/images/` for permanent offline access. NEVER rely on temporary hosted URLs in production code.
- For remote images at runtime, use the `cached_network_image` package to cache images locally and reduce network requests.
- EVERY `Image.network` call MUST include an `errorBuilder` that provides a graceful fallback (e.g., a colored container with an icon), NEVER let images fail silently with a blank space.

# MOCK DATA SEPARATION
- Mock data MUST be placed in a dedicated `mock/` directory inside its respective feature (e.g., `lib/features/events/mock/`), NEVER hardcoded directly inside View files.
- Views MUST receive data through constructor parameters or a state management solution — they should NOT generate or own their own data.
- Mock data files should follow the naming pattern: `mock_[entity]_data.dart` (e.g., `mock_event_data.dart`, `mock_user_data.dart`).

# VALIDATION AFTER BUILD
- After creating or modifying ANY screen, widget, or model, you MUST run `flutter analyze` immediately.
- ALL **errors** and **warnings** MUST be fixed before moving on to the next file or screen. Only `info`-level hints may be deferred.
- If a widget is extended (e.g., adding a new parameter), verify that ALL existing usages of that widget still compile correctly.

# RESPONSIVE & SAFE AREA
- Every screen MUST be wrapped in `SafeArea` (unless there is a specific design reason not to, e.g., an image that bleeds behind the status bar).
- Avoid hardcoded "magic number" paddings. Use values from `AppConstants` or calculate dynamically via `MediaQuery` / `LayoutBuilder`.
- Test layouts mentally for at least 2 screen sizes: small phone (375×667) and large phone (428×926). If the app targets tablets, consider a third breakpoint.

# FIXED TOP HEADERS (GLASSTOPBAR)
- When using `GlassTopBar`, it MUST be fixed at the top of the screen to achieve a glassmorphism scroll effect.
- NEVER place `GlassTopBar` inside the `slivers` list of a `CustomScrollView`.
- Instead, use a `Stack` where the `CustomScrollView` is the first child, and `Positioned(top: 0, left: 0, right: 0, child: GlassTopBar(...))` is placed *after* the scroll view so it floats above.
- Add an initial spacing element (e.g., `SliverToBoxAdapter(child: SizedBox(height: 100))`) at the top of the scroll view so the first items are not hidden behind the fixed top bar.

# STATE HANDLING
- Every View that displays data MUST handle 3 states:
  1. **Loading**: Show a skeleton/shimmer placeholder while data is being fetched. Reuse a shared `ShimmerPlaceholder` widget if available.
  2. **Error**: Show an error message with a retry action button. Reuse the existing `EmptyStateView` widget with appropriate icon/text.
  3. **Empty**: Show a meaningful empty state when the data list is empty. Reuse the existing `EmptyStateView` widget.
- NEVER show a blank screen or an unhandled exception to the user.
- Bắt buộc hiển thị loading cho mọi nút hoặc action đang gọi API/mutation. Ưu tiên dùng `PrimaryButton.isLoading`, spinner trong icon/action, hoặc loading indicator tương đương.
- Khi một nút/action đang loading, phải disable thao tác lặp lại cho đến khi request hoàn tất để tránh double-submit.
- Bất kỳ page, dialog hoặc bottom sheet nào đang chờ dữ liệu API phải có loading state rõ ràng; không để màn hình trống và không giữ các nút gửi/xóa/lưu ở trạng thái có thể bấm tiếp.

# OUTPUT FORMAT
When generating code, always specify the file path at the top of each code block so it is clear where the file belongs.
Example:
`// File: lib/core/widgets/custom_button.dart`
