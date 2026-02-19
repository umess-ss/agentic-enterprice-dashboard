# Agentic Enterprise Dashboard 🛡️

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B.svg)

A high-fidelity, cyberpunk-themed mobile command center developed for monitoring and managing autonomous AI agents in real-time. This application provides a "Dark Mode" first interface with neon accents, designed for clarity and rapid response in high-stakes environments.

## 🚀 Features

- **Real-Time Terminal**: Live streaming logs of agent activities, system warnings, and threat detections with a retro-terminal aesthetic.
- **Agent Inventory**: Comprehensive list of active agents including `Agent_Alpha-9`, `Financial_Audit_Bot`, and more.
  - **Status Indicators**: Operational, Anomaly Flagged, Offline.
  - **Control Actions**: "Kill Switch" for immediate termination of rogue agents, "Approve" for task validation.
- **Metrics Dashboard**: 
  - Active Agent Counter.
  - Real-time Cost Tracking.
  - Safety Alert Monitoring.
- **Secure Vault**: Encrypted storage visualization for API keys, DB passwords, and OAuth credentials.
- **System Config**: Manage global settings like Auto-Approve policies, Threat Detection levels, and API Rate Limits.

## 🎨 Design System

The app follows a strict **Cyberpunk / Sci-Fi** aesthetic:
- **Primary Color**: Neon Green (`#0DF233`) for operational status and system health.
- **Danger Color**: Alert Red (`#FF3B30`) for anomalies using critical warnings.
- **Background**: Deep Dark/Black (`#0A0C0A`) to reduce eye strain and enhance contrast.
- **Typography**: 
  - *Heads*: Space Grotesk (Tech/Futuristic).
  - *Mono*: JetBrains Mono (Code/Terminal data).

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **Platforms**: iOS, Android, Web, Linux, macOS, Windows
- **Fonts**: Google Fonts (`google_fonts` package)
- **Icons**: Material Symbols

## 📸 Screenshots

| Dashboard | Agent Control | Terminal Logs |
|-----------|---------------|---------------|
| ![Dashboard](https://via.placeholder.com/300x600/0A0C0A/0DF233?text=Dashboard) | ![Agents](https://via.placeholder.com/300x600/0A0C0A/0DF233?text=Agents) | ![Logs](https://via.placeholder.com/300x600/0A0C0A/0DF233?text=Logs) |

## 📦 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
- Valid Dart environment.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/umess-ss/agentic-enterprice-dashboard.git
   cd agentic-enterprice-dashboard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
