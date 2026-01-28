import React, { useEffect, useState } from "react";

const API_BASE = import.meta.env.VITE_API_BASE || "";

export default function App() {
  const [dashboard, setDashboard] = useState("Loading...");
  const [queue, setQueue] = useState(null);
  const [selectedTaskId, setSelectedTaskId] = useState("");
  const [lastUpdated, setLastUpdated] = useState(null);

  const loadData = () => {
    fetch(`${API_BASE}/api/dashboard`)
      .then((r) => r.text())
      .then(setDashboard)
      .catch(() => setDashboard("Failed to load dashboard.md"));

    fetch(`${API_BASE}/api/queue`)
      .then((r) => r.json())
      .then(setQueue)
      .catch(() => setQueue({ error: "Failed to load queue" }));

    setLastUpdated(new Date());
  };

  useEffect(() => {
    loadData();
    const id = setInterval(loadData, 15000);
    return () => clearInterval(id);
  }, []);

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
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <header className="px-6 py-5 border-b border-slate-800">
        <h1 className="text-2xl font-semibold">IXV-Agents Dashboard</h1>
        <p className="text-slate-400 text-sm">Read-only status view</p>
      </header>
      <main className="grid gap-6 p-6 lg:grid-cols-3">
        <section className="rounded-lg border border-slate-800 bg-slate-900/60 p-4">
          <h2 className="text-lg font-semibold mb-3">Dashboard</h2>
          <pre className="whitespace-pre-wrap text-sm text-slate-200">
            {dashboard}
          </pre>
        </section>
        <section className="rounded-lg border border-slate-800 bg-slate-900/60 p-4">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold">Queue Overview</h2>
            <button
              className="text-xs px-2 py-1 rounded border border-slate-700 hover:bg-slate-800"
              onClick={loadData}
            >
              Refresh
            </button>
          </div>
          <div className="text-xs text-slate-400 mb-4">
            Last updated: {lastUpdated ? lastUpdated.toLocaleTimeString() : "-"}
          </div>
          <div className="space-y-4 text-sm">
            <div>
              <div className="font-semibold">PO → SM</div>
              <div className="text-slate-300">
                {queue?.po_to_sm?.data?.summary || "No summary"}
              </div>
              <div className="text-xs text-slate-500">
                {queue?.po_to_sm?.file} · {queue?.po_to_sm?.mtime || "-"}
              </div>
            </div>
            <div>
              <div className="font-semibold">Tasks</div>
              <div className="grid gap-2">
                {tasks.length === 0 && (
                  <div className="text-slate-500">No tasks</div>
                )}
                {tasks.map((t) => (
                  <button
                    key={t.file}
                    onClick={() => setSelectedTaskId(t.data?.task_id || "")}
                    className={`text-left rounded border px-2 py-2 ${
                      t.data?.task_id === selectedTaskId
                        ? "border-emerald-600 bg-emerald-950/40"
                        : "border-slate-800 hover:bg-slate-800/60"
                    }`}
                  >
                    <div className="font-medium">
                      {t.data?.task_id || t.file}
                    </div>
                    <div className="text-xs text-slate-400">
                      {t.data?.assignee || "-"} · {t.mtime}
                    </div>
                    <div className="text-slate-300 text-xs">
                      {t.data?.summary || "-"}
                    </div>
                  </button>
                ))}
              </div>
            </div>
            <div>
              <div className="font-semibold">Reports</div>
              <div className="text-xs text-slate-400">
                {reports.length} files
              </div>
            </div>
          </div>
        </section>
        <section className="rounded-lg border border-slate-800 bg-slate-900/60 p-4">
          <h2 className="text-lg font-semibold mb-3">Task Detail</h2>
          {!selectedTask && (
            <div className="text-sm text-slate-400">No task selected</div>
          )}
          {selectedTask && (
            <div className="space-y-3 text-sm">
              <div>
                <div className="text-slate-400 text-xs">Task ID</div>
                <div>{selectedTask.data?.task_id || "-"}</div>
              </div>
              <div>
                <div className="text-slate-400 text-xs">Assignee</div>
                <div>{selectedTask.data?.assignee || "-"}</div>
              </div>
              <div>
                <div className="text-slate-400 text-xs">Type</div>
                <div>{selectedTask.data?.type || "-"}</div>
              </div>
              <div>
                <div className="text-slate-400 text-xs">Summary</div>
                <div>{selectedTask.data?.summary || "-"}</div>
              </div>
              <div>
                <div className="text-slate-400 text-xs">Definition of Done</div>
                <ul className="list-disc list-inside text-slate-300">
                  {(selectedTask.data?.definition_of_done || []).map(
                    (item, idx) => (
                      <li key={idx}>{item}</li>
                    )
                  )}
                </ul>
              </div>
              <div>
                <div className="text-slate-400 text-xs">Report Status</div>
                <div>{matchedReport?.data?.status || "-"}</div>
              </div>
              <div>
                <div className="text-slate-400 text-xs">Artifacts</div>
                <ul className="list-disc list-inside text-slate-300">
                  {(matchedReport?.data?.artifacts || []).map((item, idx) => (
                    <li key={idx}>{item}</li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
