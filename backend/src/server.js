import express from "express";
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

app.listen(PORT, () => {
  console.log(`[ixv-backend] listening on http://localhost:${PORT}`);
});
