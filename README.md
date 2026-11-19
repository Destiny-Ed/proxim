# Proxim

**On-demand artisans marketplace for Nigeria** — Bolt-style experience for finding and booking trusted local service providers.

Connect customers with verified artisans (plumbers, electricians, stylists, car washers, cleaners, etc.) in real time. Providers go online, accept jobs, deliver, and get paid. Customers request, track, and rate.

## Features

### For Customers
- Browse & search providers by category, location, rating
- View rich provider profiles (services, portfolio, past work, reviews)
- Request a job with description, preferred time, and budget
- Real-time request status timeline (Pending → Accepted → In Progress → Completed)
- Request history & re-book
- In-app wallet (top-up, pay for jobs)
- Rate & review after completion

### For Providers (Artisans)
- Complete profile setup (bio, services, portfolio photos, rates)
- Go Online / Offline toggle
- Incoming job requests with accept/reject
- Job status updates & timeline
- Earnings wallet + commission tracking
- Service portfolio & past work showcase

### Shared
- Role-based auth (Customer / Provider)
- Clean, Notion-inspired UI (soft cards, whitespace, clear hierarchy)
- Push-ready architecture (notifications stubs)
- Wallet with transaction history

## Architecture

```
proxim/
├── backend/                 # Dart Shelf API (swappable DataSource)
│   ├── bin/server.dart
│   └── lib/
│       ├── core/            # DI, errors, helpers
│       ├── data/sources/    # Memory (default) + Firebase stub
│       └── features/        # auth, providers, jobs, wallet
│           ├── models/
│           ├── datasource/  # abstract + memory + firebase
│           ├── repository/
│           ├── repository_impl/
│           └── handler/
├── apps/
│   ├── mobile/              # Flutter app (Provider state, Notion UI)
│   ├── admin/               # Simple analytics dashboard
│   └── landing/             # Marketing page
└── README.md
```

### Backend DataSource Pattern
Handlers and repositories never know the storage technology.  
Switch with env var:

```bash
DATA_SOURCE=memory   # default (in-memory, great for local/dev)
DATA_SOURCE=firebase # stub ready — implement Firebase methods
# future: postgres, supabase, etc.
```

Only the factory and concrete datasource classes change. No handler/repo rewrites.

## Quick Start

### 1. Backend
```bash
cd backend
dart pub get
dart run bin/server.dart
# → http://localhost:8080
```

### 2. Mobile
```bash
cd apps/mobile
flutter pub get
flutter run
# API base: http://10.0.2.2:8080 (Android emulator) or http://localhost:8080 (iOS/web)
```

### 3. Admin / Landing
Open `apps/admin` or `apps/landing/index.html`.

## Tech Stack
- **Mobile**: Flutter + Provider + clean feature folders
- **Backend**: Dart Shelf + Router
- **Storage**: In-memory (MVP) → Firebase / Postgres ready
- **Payments**: Wallet (Paystack/Flutterwave integration points ready)

## License
Private — Destiny Ed / Proxim
