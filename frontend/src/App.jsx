import React, { useEffect, useState, useCallback } from "react";
import Events from "./Events.jsx";
import TerminalStream from "./TerminalStream.jsx";

const API_BASE = import.meta.env.VITE_API_BASE || "";
const BUILD_DEMO = import.meta.env.VITE_DEMO === "1" || import.meta.env.VITE_DEMO === "true";

/* Demo data used when demo mode is enabled */
const demoDashboard = `# IXV-Agents（デモ）
これはデモ用のダッシュボードです。

- デモモードでは疑似データが表示されます。`;

const demoQueue = {
  po_to_sm: {
    file: "po_to_sm.yaml",
    mtime: new Date().toISOString(),
    data: { summary: "デモ: PO → SM 要約" }
  },
  tasks: [
    {
      file: "dev1.yaml",
      mtime: new Date().toISOString(),
      data: {
        task_id: "TASK-DEMO-001",
        assignee: "開発1",
        summary: "デモタスク（一覧表示）",
        type: "dev",
        definition_of_done: ["実装する", "テストを追加する"]
      }
    }
  ],
  reports: []
};

export default function App() {
  const [dashboard, setDashboard] = useState("Loading...");
  const [queue, setQueue] = useState(null);
  const [selectedTaskId, setSelectedTaskId] = useState("");
  const [lastUpdated, setLastUpdated] = useState(null);
  const [demoMode, setDemoMode] = useState(BUILD_DEMO);

  const loadData = useCallback(() => {
    if (demoMode) {
      setDashboard(demoDashboard);
      setQueue(demoQueue);
      setLastUpdated(new Date());
      return;
    }

    fetch(`${API_BASE}/api/dashboard`)
      .then((r) => r.text())
      .then(setDashboard)
      .catch(() => setDashboard("Failed to load dashboard.md"));

    fetch(`${API_BASE}/api/queue`)
      .then((r) => r.json())
      .then(setQueue)
      .catch(() => setQueue({ error: "Failed to load queue" }));

    setLastUpdated(new Date());
  }, [demoMode, API_BASE]);

  useEffect(() => {
    loadData();
    const id = setInterval(loadData, 15000);
    return () => clearInterval(id);
  }, [loadData]);

  useEffect(() => {
    if (!queue?.tasks?.length) return;
    if (!selectedTaskId) {
      setSelectedTaskId(queue.tasks[0]?.data?.task_id || "");
    }
  }, [queue, selectedTaskId]);

  const tasks = queue?.tasks || [];
  const reports = queue?.reports || [];
  const selectedTask = tasks.find((t) => t.data?.task_id === selectedTaskId);
  const matchedReport = reports.find(
    (r) => r.data?.task_id === selectedTaskId
  );

  return (
    <div className="min-h-screen bg-bg-base">
      <header className="px-6 py-5 border-b border-border-default bg-bg-surface">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold">IXV-Agents Dashboard</h1>
            <p className="text-text-muted text-sm">Read-only status view</p>
          </div>
          <div className="flex items-center gap-3">
            <button
              className="text-xs px-2 py-1 rounded border border-primary bg-primary text-white hover:bg-primary-dark"
              onClick={() => setDemoMode((d) => !d)}
              title="デモモード切替"
            >
              {demoMode ? "デモモード" : "ライブモード"}
            </button>
            {demoMode && (
              <div className="text-xs text-text-muted">デモデータ表示中</div>
            )}
          </div>
        </div>
      </header> 
      <main className="grid gap-6 p-6 lg:grid-cols-3 xl:grid-cols-4">
        <section className="rounded-lg border border-border-default bg-bg-surface p-4">
          <h2 className="text-lg font-semibold mb-3">Dashboard</h2>
          <pre className="whitespace-pre-wrap text-sm text-text-base">
            {dashboard}
          </pre>
        </section>
        <section className="rounded-lg border border-border-default bg-bg-surface p-4">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold">Queue Overview</h2>
            <button
              className="text-xs px-2 py-1 rounded border border-border-default hover:bg-bg-hover"
              onClick={loadData}
            >
              Refresh
            </button>
          </div>
          <div className="text-xs text-text-muted mb-4">
            Last updated: {lastUpdated ? lastUpdated.toLocaleTimeString() : "-"}
          </div>
          <div className="space-y-4 text-sm">
            <div>
              <div className="font-semibold">PO → SM</div>
              <div className="text-text-secondary">
                {queue?.po_to_sm?.data?.summary || "No summary"}
              </div>
              <div className="text-xs text-text-muted">
                {queue?.po_to_sm?.file} · {queue?.po_to_sm?.mtime || "-"}
              </div>
            </div>
            <div>
              <div className="font-semibold">Tasks</div>
              <div className="grid gap-2">
                {tasks.length === 0 && (
                  <div className="text-text-muted">No tasks</div>
                )}
                {tasks.map((t) => (
                  <button
                    key={t.file}
                    onClick={() => setSelectedTaskId(t.data?.task_id || "")}
                    className={`text-left rounded border px-2 py-2 ${
                      t.data?.task_id === selectedTaskId
                        ? "border-primary bg-primary-light"
                        : "border-border-default hover:bg-bg-hover"
                    }`}
                  >
                    <div className="font-medium">
                      {t.data?.task_id || t.file}
                    </div>
                    <div className="text-xs text-text-muted">
                      {t.data?.assignee || "-"} · {t.mtime}
                    </div>
                    <div className="text-text-secondary text-xs">
                      {t.data?.summary || "-"}
                    </div>
                  </button>
                ))}
              </div>
            </div>
            <div>
              <div className="font-semibold">Reports</div>
              <div className="text-xs text-text-muted">
                {reports.length} files
              </div>
            </div>
          </div>
        </section>
        <section className="rounded-lg border border-border-default bg-bg-surface p-4">
          <h2 className="text-lg font-semibold mb-3">Task Detail</h2>
          {!selectedTask && (
            <div className="text-sm text-text-muted">No task selected</div>
          )}
          {selectedTask && (
            <div className="space-y-3 text-sm">
              <div>
                <div className="text-text-muted text-xs">Task ID</div>
                <div>{selectedTask.data?.task_id || "-"}</div>
              </div>
              <div>
                <div className="text-text-muted text-xs">Assignee</div>
                <div>{selectedTask.data?.assignee || "-"}</div>
              </div>
              <div>
                <div className="text-text-muted text-xs">Type</div>
                <div>{selectedTask.data?.type || "-"}</div>
              </div>
              <div>
                <div className="text-text-muted text-xs">Summary</div>
                <div>{selectedTask.data?.summary || "-"}</div>
              </div>
              <div>
                <div className="text-text-muted text-xs">Definition of Done</div>
                <ul className="list-disc list-inside text-text-secondary">
                  {(selectedTask.data?.definition_of_done || []).map(
                    (item, idx) => (
                      <li key={idx}>{item}</li>
                    )
                  )}
                </ul>
              </div>
              <div>
                <div className="text-text-muted text-xs">Report Status</div>
                <div>{matchedReport?.data?.status || "-"}</div>
              </div>
              <div>
                <div className="text-text-muted text-xs">Artifacts</div>
                <ul className="list-disc list-inside text-text-secondary">
                  {(matchedReport?.data?.artifacts || []).map((item, idx) => (
                    <li key={idx}>{item}</li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </section>
        <section className="rounded-lg border border-border-default bg-bg-surface p-4">
          <Events apiBase={API_BASE} demoMode={demoMode} />
        </section>
        <section className="rounded-lg border border-border-default bg-bg-surface p-4">
          <TerminalStream apiBase={API_BASE} demoMode={demoMode} />
        </section>
      </main>
    </div>
  );
}
