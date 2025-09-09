# Two-Container Stack: Python App + PostgreSQL

> **Purpose:** A copy‑paste‑ready README that acts as a “user guide” for your stack.  
> It includes: what the stack does, exact run/stop commands, example output, where outputs are written, and troubleshooting.

---

## What this stack does (2–3 sentences)
This project runs a lightweight Python application and a PostgreSQL database using Docker Compose. On startup, the app waits for the database, seeds/queries a `trips` table, computes simple stats, **prints a JSON summary to stdout**, and **writes the same JSON to `out/summary.json`** on the host. Everything is reproducible and can be launched with a single command.

> **Tip:** If your rubric expects a specific output folder, keep `out/` as the default so graders can find the file easily.

---

## Prerequisites
- Docker Desktop (Windows/macOS) or Docker Engine (Linux)
- Docker Compose (`docker compose` in recent versions)
- Optional: `make` (macOS/Linux). On Windows, use the Docker commands directly.

---

## Project structure
```
.
├─ db/
│  ├─ Dockerfile           # FROM postgres:16, copies init.sql
│  └─ init.sql             # creates & seeds trips(city, minutes, fare)
├─ app/
│  ├─ Dockerfile           # FROM python:3.11-slim, installs deps
│  └─ main.py              # connects, queries, prints & writes summary JSON
├─ compose.yml             # services: db + app; healthcheck; ./out mapped to /out
├─ out/                    # host-mounted output folder (summary.json appears here)
└─ README.md
```

---

## Configuration
The app uses environment variables defined directly in `compose.yml` (or via an `.env` file if you prefer):
- `DB_HOST=db`
- `DB_PORT=5432`
- `DB_USER=appuser`
- `DB_PASS=secretpw`
- `DB_NAME=appdb`
- `APP_TOP_N=10`  *(how many longest trips to show; clamps to available rows)*

> **Change output folder name:** You can use a different folder than `out/`. If you do:
> 1) Create it locally first (e.g., `results/`).  
> 2) Update the volume mapping in `compose.yml` (e.g., `./results:/out`).  
> 3) Make sure your app writes to `/out/...` inside the container so it reaches the host.

---

## Exact commands to run / stop

### 1) Create the output folder (must exist before running)
- **Windows PowerShell**
```powershell
New-Item -ItemType Directory -Force out
```
- **macOS/Linux**
```bash
mkdir -p out
```

### 2) Build & run (foreground logs)
```bash
docker compose up --build
```

### 3) Run detached (in background)
```bash
docker compose up --build -d
```

### 4) View logs
```bash
docker compose logs -f
```

### 5) Stop containers (keep volumes/data)
```bash
docker compose down
```

### 6) Stop and remove volumes (fresh start)
```bash
docker compose down -v
```

> If you’re on an older setup, replace `docker compose` with `docker-compose`.

### Optional: Makefile shortcuts (if you have `make`)
```bash
make up        # builds & starts (docker compose up --build)
make down      # docker compose down -v
make clean     # removes out/ then recreates it
make all       # clean + up
```

---

## Example output (copy/paste)

**Sample console (stdout) when the stack starts**
```
app-1      | Waiting for database...
db-1       | LOG:  database system is ready to accept connections
app-1      | Connected to Postgres at db:5432
app-1      | === Summary ===
app-1      | {
app-1      |   "total_trips": 6,
app-1      |   "avg_fare_by_city": [
app-1      |     {"city": "Charlotte", "avg_fare": 16.25},
app-1      |     {"city": "New York", "avg_fare": 19.0},
app-1      |     {"city": "San Francisco", "avg_fare": 20.25}
app-1      |   ],
app-1      |   "top_by_minutes": [
app-1      |     {"id": 6, "city": "San Francisco", "minutes": 28, "fare": 29.3},
app-1      |     {"id": 4, "city": "New York", "minutes": 26, "fare": 27.1},
app-1      |     {"id": 2, "city": "Charlotte", "minutes": 21, "fare": 20.0}
app-1      |   ]
app-1      | }
```

**Sample file written**
```
out/
└─ summary.json
```

**Sample `out/summary.json` content**
```json
{
  "total_trips": 6,
  "avg_fare_by_city": [
    {"city": "Charlotte", "avg_fare": 16.25},
    {"city": "New York", "avg_fare": 19.0},
    {"city": "San Francisco", "avg_fare": 20.25}
  ],
  "top_by_minutes": [
    {"id": 6, "city": "San Francisco", "minutes": 28, "fare": 29.3},
    {"id": 4, "city": "New York", "minutes": 26, "fare": 27.1},
    {"id": 2, "city": "Charlotte", "minutes": 21, "fare": 20.0}
  ]
}
```

> Replace the snippet above with your actual run output when you test.

---

## Where outputs are written
- The app writes its JSON summary to **`out/summary.json`** (host-mounted).
- Because it’s a bind mount, files persist after containers stop and are easy to include in your submission.

---

## How it works (quick overview)
1. **DB container (`db/`)** starts from `postgres:16`, runs `init.sql` on first boot to create and seed `trips`.
2. **App container (`app/`)** waits for the DB healthcheck, connects using env vars, runs queries, prints the summary to stdout, and writes the same JSON to `/out/summary.json` (mapped to `./out` on the host).
3. **Compose** maps `./out` to `/out`, so outputs are visible on your machine.

---

## Troubleshooting

### A) “DB not ready” / connection refused
- First run can take a few seconds while Postgres initializes. The app includes a simple wait/retry loop.
- If it still fails, rebuild from scratch:
```bash
docker compose down -v
docker compose up --build
```
- Make sure no other service is using port **5432**. If needed, change the host port in `compose.yml` (e.g., `5433:5432`).

### B) Permission errors on `out/` (or your custom output folder)
- Ensure the folder exists **before** starting containers.
- **macOS/Linux**:
```bash
chmod -R 777 out   # quick fix for class projects; tighten in prod
```
- **Windows**:
  - Ensure Docker Desktop has file-sharing access to your project path.
  - Ensure the folder is not read-only.
  - If you started once without the folder, try:
```powershell
docker compose down -v
New-Item -ItemType Directory -Force out
docker compose up --build
```

### C) `make: command not found` (Windows or minimal setups)
- Use the Docker commands shown above instead of `make`.

### D) “`rm` is not recognized” on Windows
- Use PowerShell equivalents:
```powershell
Remove-Item -Recurse -Force out
New-Item -ItemType Directory -Force out
```

### E) Compose cannot find your file / wrong directory
- Run commands from the repository **root** containing `compose.yml`.
- Or specify the file explicitly:
```bash
docker compose -f compose.yml up --build
```

### F) Old DB data/schema sticking around
- Remove volumes to start fresh:
```bash
docker compose down -v
docker compose up --build
```

---
