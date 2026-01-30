import React, { useEffect, useRef, useState } from "react";

export default function TerminalStream({ apiBase = "", demoMode = false }) {
  const [panes, setPanes] = useState({});
  const esRef = useRef(null);

  const localizeLine = (line) => {
    if (!line) return line;
    let out = line;
    out = out.replace(/^PM\s+/, "PM（プロダクト） ");
    out = out.replace(/Updating dashboard/gi, "ダッシュボード更新中");
    out = out.replace(/Planning update/gi, "計画更新");
    out = out.replace(/Started task/gi, "タスク開始");
    out = out.replace(/Working on fix/gi, "修正中");
    out = out.replace(/Review requested/gi, "レビュー依頼");
    out = out.replace(/Merged/gi, "マージ済み");
    out = out.replace(/Deployed to staging/gi, "ステージングへデプロイ");
    out = out.replace(/Investigating issue/gi, "問題調査中");
    out = out.replace(/Unit tests failing/gi, "ユニットテスト失敗");
    out = out.replace(/Pushed PR/gi, "PR作成");
    out = out.replace(/Reviewing report/gi, "レポート確認中");
    out = out.replace(/Queueing next task/gi, "次のタスクをキュー中");
    out = out.replace(/Thinking\.\.\./gi, "考え中...");
    return out;
  };

  useEffect(() => {
    if (demoMode) {
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
        setPanes((prev) => ({
          ...prev,
          [pane]: {
            pane,
            lines: [`${new Date().toLocaleTimeString()} ${line}`],
            ts: new Date().toISOString(),
            updatedAt: Date.now(),
            demo: true
          }
        }));
      }, 1200);
      return () => clearInterval(interval);
    }

    const url = `${apiBase || ""}/api/terminals`;
    const es = new EventSource(url);
    es.onmessage = (e) => {
      try {
        const payload = JSON.parse(e.data);
        const key = payload.pane || payload.paneId || "system";
        setPanes((prev) => ({
          ...prev,
          [key]: {
            ...payload,
            updatedAt: Date.now()
          }
        }));
      } catch (err) {
        // ignore
      }
    };
    es.onerror = () => {
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

  const items = Object.values(panes);

  return (
    <div>
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-lg font-semibold">ターミナル活動</h2>
        <div className="text-xs text-text-muted">
          {demoMode ? "デモストリーム" : "tmux ライブストリーム"}
        </div>
      </div>

      {items.length === 0 && (
        <div className="text-text-muted text-sm">ターミナル出力を待機中…</div>
      )}

      <div className="space-y-3">
        {items.map((pane) => {
          const isHot = Date.now() - (pane.updatedAt || 0) < 1500;
          return (
            <div
              key={pane.pane || pane.paneId || "system"}
              className={`rounded border border-border-default bg-bg-muted p-2 ${
                isHot ? "ixv-flash" : ""
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <div className="font-medium">{pane.pane || "system"}</div>
                <div className="text-xs text-text-muted">
                  {pane.ts ? new Date(pane.ts).toLocaleTimeString() : "-"}
                </div>
              </div>
              <pre className="text-xs text-text-secondary whitespace-pre-wrap overflow-x-auto">
                {(pane.lines || []).map(localizeLine).join("\n")}
              </pre>
            </div>
          );
        })}
      </div>
    </div>
  );
}
