import express from "express";
import { execSync } from "child_process";
import fs from "fs";
import path from "path";
import yaml from "js-yaml";

const app = express();
const PORT = process.env.PORT || 8787;
const ROOT = path.resolve(process.cwd(), "..");

// CORS for local development
app.use((_req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET");
  res.header("Access-Control-Allow-Headers", "Content-Type");
  next();
});

const readText = (rel) => fs.readFileSync(path.join(ROOT, rel), "utf8");
const readYaml = (rel) => yaml.load(readText(rel));
const getMtime = (rel) => fs.statSync(path.join(ROOT, rel)).mtime.toISOString();

app.get("/api/dashboard", (_req, res) => {
  try {
    res.type("text/plain").send(readText("dashboard.md"));
  } catch (err) {
    res.status(500).send("Failed to read dashboard.md");
  }
});

app.get("/api/queue", (_req, res) => {
  try {
    const poFile = "queue/po_to_sm.yaml";
    const po = {
      file: path.basename(poFile),
      mtime: getMtime(poFile),
      data: readYaml(poFile)
    };
    const tasksDir = path.join(ROOT, "queue/tasks");
    const reportsDir = path.join(ROOT, "queue/reports");

    const tasks = fs
      .readdirSync(tasksDir)
      .filter((f) => f.endsWith(".yaml"))
      .sort()
      .map((f) => {
        const rel = `queue/tasks/${f}`;
        return { file: f, mtime: getMtime(rel), data: readYaml(rel) };
      });

    const reports = fs.existsSync(reportsDir)
      ? fs
          .readdirSync(reportsDir)
          .filter((f) => f.endsWith(".yaml"))
          .sort()
          .map((f) => {
            const rel = `queue/reports/${f}`;
            return { file: f, mtime: getMtime(rel), data: readYaml(rel) };
          })
      : [];

    res.json({ po_to_sm: po, tasks, reports });
  } catch (err) {
    res.status(500).json({ error: "Failed to read queue" });
  }
});

// Server-Sent Events (SSE) for agent events (demo/live stream)
app.get('/api/events', (req, res) => {
  res.set({
    'Cache-Control': 'no-cache',
    'Content-Type': 'text/event-stream',
    Connection: 'keep-alive'
  });
  res.flushHeaders();

  let id = 0;
  const agents = ['PO', 'SM', 'Dev1', 'Dev2', 'Dev3', 'QA1', 'QA2'];
  const messages = [
    'Planning update',
    'Started task',
    'Pushed PR',
    'Unit tests failing',
    'Working on fix',
    'Review requested',
    'Merged',
    'Deployed to staging',
    'Investigating issue'
  ];

  const send = (payload) => {
    res.write(`data: ${JSON.stringify(payload)}\n\n`);
  };

  // emit demo events; clients can pass ?demo=1 to request demo stream
  const interval = setInterval(() => {
    const ev = {
      id: ++id,
      agent: agents[Math.floor(Math.random() * agents.length)],
      message: messages[Math.floor(Math.random() * messages.length)],
      ts: new Date().toISOString()
    };
    send(ev);
  }, 1500);

  req.on('close', () => clearInterval(interval));
});

const safeExec = (cmd) => {
  try {
    return execSync(cmd, { stdio: ["ignore", "pipe", "pipe"] })
      .toString()
      .trim();
  } catch (err) {
    return "";
  }
};

const getTmuxPanes = () => {
  const output = safeExec("tmux list-panes -a -F '#{pane_id}:::#{pane_title}'");
  if (!output) return [];
  return output
    .split("\n")
    .map((line) => line.split(":::"))
    .filter((parts) => parts.length >= 2)
    .map(([paneId, title]) => ({ paneId, title: title || paneId }));
};

const capturePane = (paneId) => {
  const output = safeExec(`tmux capture-pane -p -t ${paneId} -S -30`);
  return output || "";
};

// Server-Sent Events (SSE) for terminal output stream
app.get("/api/terminals", (req, res) => {
  const demo = req.query.demo === "1" || req.query.demo === "true";

  res.set({
    "Cache-Control": "no-cache",
    "Content-Type": "text/event-stream",
    Connection: "keep-alive"
  });
  res.flushHeaders();

  const send = (payload) => {
    res.write(`data: ${JSON.stringify(payload)}\n\n`);
  };

  let id = 0;
  let lastByPane = {};

  if (demo) {
    const demoPanes = ["PO", "SM", "開発1", "開発2", "QA1"];
    const demoLines = [
      "考え中...",
      "spec_ref を解析中...",
      "タスクYAMLを書き込み中",
      "テスト実行中",
      "ダッシュボード更新中",
      "レポート確認中",
      "次のタスクをキュー中"
    ];
    const interval = setInterval(() => {
      const pane = demoPanes[Math.floor(Math.random() * demoPanes.length)];
      const line = demoLines[Math.floor(Math.random() * demoLines.length)];
      send({
        id: ++id,
        pane,
        lines: [`${new Date().toLocaleTimeString()} ${line}`],
        ts: new Date().toISOString(),
        demo: true
      });
    }, 1200);

    req.on("close", () => clearInterval(interval));
    return;
  }

  const interval = setInterval(() => {
    const panes = getTmuxPanes();
    if (panes.length === 0) {
      send({
        id: ++id,
        pane: "system",
        lines: ["tmux panes not found. Start ixv_boot.sh first."],
        ts: new Date().toISOString(),
        warning: true
      });
      return;
    }

    panes.forEach(({ paneId, title }) => {
      const text = capturePane(paneId);
      if (!text) return;
      if (lastByPane[paneId] === text) return;
      lastByPane[paneId] = text;
      const lines = text.split("\n").slice(-10);
      send({
        id: ++id,
        paneId,
        pane: title || paneId,
        lines,
        ts: new Date().toISOString()
      });
    });
  }, 1000);

  req.on("close", () => clearInterval(interval));
});

app.listen(PORT, () => {
  console.log(`[ixv-backend] listening on http://localhost:${PORT}`);
});
