import React, { useEffect, useRef, useState } from "react";

export default function Events({ apiBase = "", demoMode = false }) {
  const [events, setEvents] = useState([]);
  const [agentStatus, setAgentStatus] = useState({});
  const runningRef = useRef(true);
  const esRef = useRef(null);

  const handleEvent = (payload) => {
    const enriched = { ...payload, receivedAt: Date.now() };
    setEvents((prev) => [enriched, ...prev].slice(0, 200));
    if (payload?.agent) {
      setAgentStatus((prev) => ({
        ...prev,
        [payload.agent]: {
          message: payload.message || "",
          ts: payload.ts || new Date().toISOString(),
          updatedAt: Date.now()
        }
      }));
    }
  };

  useEffect(() => {
    runningRef.current = true;

    if (demoMode) {
      const agents = ["PO", "SM", "開発1", "開発2", "QA1", "QA2"];
      const msgs = [
        "計画を更新",
        "タスク開始",
        "PR作成",
        "ユニットテスト失敗",
        "修正中",
        "レビュー依頼",
        "マージ済み",
        "ステージングへデプロイ",
        "問題を調査中",
      ];
      const interval = setInterval(() => {
        if (!runningRef.current) return;
        const ev = {
          id: Date.now(),
          agent: agents[Math.floor(Math.random() * agents.length)],
          message: msgs[Math.floor(Math.random() * msgs.length)],
          ts: new Date().toISOString(),
        };
        handleEvent(ev);
      }, 1200);
      return () => clearInterval(interval);
    }

    // Live mode: connect to backend SSE
    const url = `${apiBase || ""}/api/events`;
    const es = new EventSource(url);
    es.onmessage = (e) => {
      try {
        const payload = JSON.parse(e.data);
        handleEvent(payload);
      } catch (err) {
        // ignore
      }
    };
    es.onerror = (_) => {
      // close on error to allow reconnect by creating new EventSource if needed
      try {
        es.close();
      } catch (err) {}
    };
    esRef.current = es;

    return () => {
      try {
        es.close();
      } catch (err) {}
    };
  }, [apiBase, demoMode]);

  return (
    <div>
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-lg font-semibold">Agent Events (real-time)</h2>
        <div className="flex items-center gap-2">
          <button
            className="text-xs px-2 py-1 rounded border border-slate-700 hover:bg-slate-800"
            onClick={() => (runningRef.current = true)}
            title="Resume events"
          >
            Resume
          </button>
          <button
            className="text-xs px-2 py-1 rounded border border-slate-700 hover:bg-slate-800"
            onClick={() => (runningRef.current = false)}
            title="Pause events"
          >
            Pause
          </button>
          <button
            className="text-xs px-2 py-1 rounded border border-slate-700 hover:bg-slate-800"
            onClick={() => setEvents([])}
            title="Clear events"
          >
            Clear
          </button>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-2 mb-3">
        {Object.keys(agentStatus).length === 0 && (
          <div className="col-span-2 text-slate-500 text-sm">
            No agent activity yet
          </div>
        )}
        {Object.entries(agentStatus).map(([agent, data]) => {
          const isHot = Date.now() - data.updatedAt < 2000;
          return (
            <div
              key={agent}
              className={`rounded border border-slate-800 bg-slate-900/60 p-2 ${
                isHot ? "ixv-flash" : ""
              }`}
            >
              <div className="flex items-center justify-between">
                <div className="font-medium">{agent}</div>
                <div className={`h-2 w-2 rounded-full bg-emerald-400 ${isHot ? "ixv-ping" : ""}`} />
              </div>
              <div className="text-xs text-slate-400 mt-1">
                {new Date(data.ts).toLocaleTimeString()}
              </div>
              <div className="text-slate-300 text-xs mt-1">
                {data.message || "-"}
              </div>
            </div>
          );
        })}
      </div>

      <div className="h-64 overflow-y-auto bg-slate-900/50 p-2 rounded">
        {events.length === 0 && (
          <div className="text-slate-500 text-sm">No events yet</div>
        )}
        <ul className="space-y-2 text-sm">
          {events.map((ev) => {
            const isFresh = Date.now() - (ev.receivedAt || 0) < 1500;
            return (
              <li
                key={ev.id}
                className={`rounded border border-slate-800 p-2 ${
                  isFresh ? "ixv-flash" : ""
                }`}
              >
              <div className="flex items-baseline justify-between">
                <div className="font-medium">{ev.agent}</div>
                <div className="text-xs text-slate-400">{new Date(ev.ts).toLocaleTimeString()}</div>
              </div>
              <div className="text-slate-300 text-sm">{ev.message}</div>
              </li>
            );
          })}
        </ul>
      </div>
    </div>
  );
}
