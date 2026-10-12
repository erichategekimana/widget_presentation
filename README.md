# KeyboardListener Widget Presentation

## Summary
This project is an interactive Flutter demo called **Corner Collector**. In this app, you control a character inside a square arena using keyboard inputs:
* **Move:** Use the **Arrow Keys** or **WASD** to navigate around the board.
* **Collect:** Move close to any of the four corner gems and press the **Spacebar** to collect it.
* **Restart:** After collecting all four gems, press the **R** key to reset the board and play again.

The app provides a practical, visual example of how to capture and respond to real-time physical keystrokes in Flutter using the `KeyboardListener` widget.

---

## Widget Description
`KeyboardListener` is a Flutter widget that listens for hardware keyboard events (like pressing, holding, or releasing a key) whenever it has keyboard focus.

---

## How to Run the App

Make sure you have [Flutter](https://flutter.dev) installed on your system.

1. Open your terminal and navigate to the project directory:
   ```bash
   cd keyboard_listener
   ```

2. Download all necessary packages:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```
   *(Tip: You can also target a specific platform, such as `flutter run -d chrome` or `flutter run -d linux`)*

---

## The Three Key Attributes

In this project, `KeyboardListener` uses three essential attributes to handle keyboard input accurately:

### 1. `focusNode` (`FocusNode`, Required)
* **What it does:** It controls and tracks the keyboard focus state of the widget in Flutter's focus tree.
* **Why it matters:** Flutter only sends hardware keyboard events to widgets that are currently focused. Without an active `FocusNode`, the system cannot determine where to deliver key presses.
* **Best practice:** Always create the `FocusNode` in `initState()` (or in a stateful class) and dispose of it in `dispose()` to avoid memory leaks.

### 2. `autofocus` (`bool`, Default: `false`)
* **What it does:** It tells Flutter to automatically give focus to this widget as soon as it is rendered on the screen.
* **Why it matters:** If `autofocus` is `false`, the user must first click or tap on the widget to focus it. Setting `autofocus: true` ensures keyboard events work immediately without requiring any extra user interaction.

### 3. `onKeyEvent` (`ValueChanged<KeyEvent>?`)
* **What it does:** It is the callback function triggered every time the user interacts with a physical key while the widget is focused.
* **Why it matters:** It provides a modern `KeyEvent` object containing:
  * **Event type:** Checks whether the key was pressed (`KeyDownEvent`), held down (`KeyRepeatEvent`), or released (`KeyUpEvent`).
  * **Key identity:** Uses `event.logicalKey` (e.g., `LogicalKeyboardKey.arrowUp` or `LogicalKeyboardKey.space`) to identify keys regardless of keyboard layout, or `event.physicalKey` for the hardware position.
* **Note:** `onKeyEvent` is the modern Flutter standard, replacing the older and deprecated `onKey` (`RawKeyEvent`).