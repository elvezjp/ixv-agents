# IXV Backend

Read-only local service for dashboard and queue files.

## Dev

- Install deps: `npm install`
- Start server: `npm run dev`
- Endpoints:
  - `GET /api/dashboard`
  - `GET /api/queue`
  - `GET /api/events` (Server-Sent Events stream for agent events; useful for demoing real-time interactions)

Notes: `/api/events` emits demo events for connected clients. It streams JSON via SSE (text/event-stream).
