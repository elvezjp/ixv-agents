# IXV Frontend

React + Tailwind UI for read-only dashboards.

## Dev

- Install deps: `npm install`
- Start dev server: `npm run dev`
- Configure API base: `VITE_API_BASE=http://localhost:8787`

## Demo mode (no backend required) ✅

You can run the frontend without starting the backend by enabling demo mode.

- Start dev server in demo mode: `VITE_DEMO=1 npm run dev`
- When demo mode is active, the UI uses built-in demo data and a header button lets you toggle between "Demo Mode" and "Live Mode" at runtime.

This is useful for quick demos or development when the API server isn't available.

## Real-time agent events

The dashboard includes an **Agent Events (real-time)** panel. It shows a live stream of agent messages:

- In **demo mode** the browser simulates and renders events locally.
- In **live mode**, the UI connects to the backend SSE endpoint at `/api/events` and displays incoming events in real time.

To see live events, start the backend and the frontend (no `VITE_DEMO`) and open the dashboard.
