# Agentic Enterprise Dashboard 🛡️🤖

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B.svg)
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E.svg)
![Gemini](https://img.shields.io/badge/AI-Gemini%202.0-4285F4.svg)

A cyberpunk-themed **AI Agent Command Center** that lets you deploy, monitor, and control autonomous AI agents in real-time. Think of it as the "Manager" for your digital workforce — agents that work 24/7 while you approve their big decisions.

---

## 🚀 What Does This App Do?

| Feature | Description |
|---------|-------------|
| **Smart Summary** | Gemini 2.0 AI generates an executive overview of your system's health, risks, and recommended actions |
| **Anomaly Detection** | AI scans all agents for cost spikes, performance drops, stuck statuses, and security risks |
| **Human-in-the-Loop (HITL)** | Agents propose actions; you approve or reject before execution |
| **Real-Time Logs** | Live terminal showing exactly what every agent is "thinking" and doing |
| **Agent Inventory** | See all active agents with status indicators (Operational, Anomaly Flagged, Offline) |
| **Kill Switch** | Immediately terminate rogue agents |
| **Secure Vault** | Encrypted storage for API keys and credentials |
| **System Config** | Manage Auto-Approve policies, Threat Detection levels, API Rate Limits |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│               Flutter Frontend                   │
│  (Web, iOS, Android, Mac, Windows, Linux)        │
│                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │Smart Summary│  │ HITL Cards  │  │ Agent    │ │
│  │  Widget     │  │ (Approve/   │  │ Terminal │ │
│  │ (AI Health) │  │  Reject)    │  │ (Logs)   │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┘ │
│         │                │                       │
│         └───────┬────────┘                       │
│                 │ AIService (Singleton)           │
└─────────────────┼────────────────────────────────┘
                  │ HTTPS (Supabase Edge Function)
┌─────────────────┼────────────────────────────────┐
│                 ▼                                 │
│   ┌──────────────────────┐                       │
│   │  agent-brain         │  Supabase Edge        │
│   │  (Deno Runtime)      │  Function             │
│   │                      │                       │
│   │  ┌────────────────┐  │                       │
│   │  │ Gemini 2.0 API │  │                       │
│   │  │ (AI Brain)     │  │                       │
│   │  └────────────────┘  │                       │
│   │                      │                       │
│   │  ┌────────────────┐  │                       │
│   │  │ MCP Access     │  │                       │
│   │  │ Layer          │  │                       │
│   │  └────────────────┘  │                       │
│   └──────────┬───────────┘                       │
│              │                                   │
│   ┌──────────▼───────────┐                       │
│   │  PostgreSQL Database │  Supabase             │
│   │  ├─ mission_control  │  (Real-time)          │
│   │  ├─ agent_actions    │                       │
│   │  └─ agent_logs       │                       │
│   └──────────────────────┘                       │
└──────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform UI — runs on Web, iOS, Android, Mac, Windows, Linux from one codebase |
| **Backend** | Supabase | Open-source Firebase alternative — Database, Auth, Real-time subscriptions, Edge Functions |
| **AI Brain** | Gemini 2.0 Flash | Google's AI — anomaly detection, smart summaries, action proposals |
| **Edge Function** | Deno (TypeScript) | Serverless function on Supabase that connects the AI to the database |
| **Database** | PostgreSQL | Stores mission data, agent actions, and activity logs |
| **Real-time** | Supabase Realtime | WebSocket-based live data streaming to the dashboard |

---

## 🎨 Design System

- **Theme**: Cyberpunk / Sci-Fi Dark Mode
- **Primary**: Neon Green (`#0DF233`) — operational status
- **Danger**: Alert Red (`#FF3B30`) — anomalies & critical warnings
- **AI Accent**: Purple (`#7C3AED`) — AI-powered features
- **Background**: Deep Black (`#0A0C0A`)
- **Typography**: Space Grotesk (headers), JetBrains Mono (terminal/code)

---

## 📦 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or later)
- [Supabase Account](https://supabase.com) (free tier works)
- [Gemini API Key](https://aistudio.google.com/apikey) (free tier available)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/umess-ss/agentic-enterprice-dashboard.git
   cd agentic-enterprice-dashboard
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app** (choose your platform)
   ```bash
   # Web
   flutter run -d chrome

   # Android
   flutter run -d android

   # Linux Desktop
   flutter run -d linux

   # iOS (macOS only)
   flutter run -d ios
   ```

### Backend Setup (Supabase)

4. **Install Supabase CLI**
   ```bash
   npx supabase login
   ```

5. **Deploy the AI Edge Function**
   ```bash
   npx supabase functions deploy agent-brain --project-ref <YOUR_PROJECT_REF>
   ```

6. **Set your Gemini API Key**
   ```bash
   npx supabase secrets set GEMINI_API_KEY=<YOUR_GEMINI_API_KEY> --project-ref <YOUR_PROJECT_REF>
   ```

---

## 🔌 API Endpoint

**POST** `https://<project>.supabase.co/functions/v1/agent-brain`

| Mode | Body | Description |
|------|------|-------------|
| `analyze` | `{"mode": "analyze"}` | Scans all agents for anomalies using Gemini AI |
| `summary` | `{"mode": "summary"}` | Generates an executive health summary |
| `confirm` | `{"mode": "confirm", "action_id": "<uuid>"}` | Human approves an agent's proposed action |

---

## 💰 Monetization Potential

| Strategy | How it works | Revenue |
|----------|-------------|---------|
| **B2B SaaS** | Sell this dashboard to businesses managing AI agents | $99 - $499/mo per customer |
| **Service Arbitrage** | Use agents to do freelance work (writing, data entry, lead gen); manage them via this dashboard | $500+ per project, $5 API cost |
| **Consulting** | Set up AI agent systems for companies | $2,000 - $10,000 per engagement |

---

## 📁 Project Structure

```
enterprise_dashboard/
├── lib/
│   ├── main.dart                     # App entry point
│   ├── models/
│   │   └── agent_model.dart          # Data models (Agent, Action, Log)
│   ├── screens/
│   │   ├── dashboard_screen.dart     # Main command center
│   │   ├── agent_screen.dart         # Agent inventory
│   │   ├── logs_screen.dart          # Real-time terminal
│   │   ├── vault_screen.dart         # Secure vault
│   │   └── config_screen.dart        # System config
│   ├── services/
│   │   ├── supabase_agent_service.dart  # Real-time Supabase streams
│   │   └── ai_service.dart              # Gemini AI integration
│   ├── theme/
│   │   └── app_theme.dart            # Cyberpunk design system
│   └── widgets/
│       ├── smart_summary_widget.dart  # AI health summary
│       └── hitl_approval_card.dart    # Human approval cards
├── supabase/
│   └── functions/
│       └── agent-brain/
│           └── index.ts              # Edge Function (Gemini 2.0)
├── pubspec.yaml
└── README.md
```

---

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
