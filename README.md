# Gait Analysis Web App

A real-time biomechanics monitoring dashboard built with Flutter Web. This application connects to an ESP32 microcontroller or other serial devices using the **Web Serial API** or **WebSockets** to plot gait analysis data in real-time.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Git](https://git-scm.com/downloads)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Ensure `flutter` is added to your system's PATH)
- **Google Chrome** (or any Chromium-based browser like Microsoft Edge, Brave, or Opera). *Note: The Web Serial API is NOT supported in Firefox or Safari.*

## Getting Started

Follow these steps to clone, install, and run the application locally.

### 1. Clone the Repository

Open your terminal and run the following command to clone the project:

```bash
git clone <your-repository-url>
cd Gait-App
```
*(Replace `<your-repository-url>` with the actual URL of this repository).*

### 2. Install Dependencies

Fetch the required Flutter packages:

```bash
flutter pub get
```

### 3. Run the App in Chrome

Since this app relies on the Web Serial API, you must run it in a compatible browser. To launch the app in Google Chrome, run:

```bash
flutter run -d chrome
```

This command will compile the application and automatically open a new Chrome window.

## Usage

1. Once the app launches in Chrome, you will see the connection screen.
2. Select the **Serial** connection option.
3. Click the **CONNECT SERIAL DEVICE** button.
4. Your browser will prompt you to select a serial port. Choose the port connected to your microcontroller (e.g., ESP32) and click **Connect**.
5. The dashboard will now display real-time sensor data, pressure heatmaps, and IMU tracking.

> **Note:** If you are testing via WebSockets instead of a direct serial connection, select the **WebSocket** option, enter the device's WebSocket URL (e.g., `ws://192.168.4.1:81`), and connect.
