import React, { useEffect, useRef, useState } from "react";

const BUILD_DEMO =
  import.meta.env.VITE_DEMO === "1" || import.meta.env.VITE_DEMO === "true";

const demoRequests = [
  "新規ユーザー向けオンボーディングを短くして離脱を減らしたい。",
  "検索結果に保存済みフィルタを表示して再利用できるようにしたい。",
  "請求書のダウンロードにフィルタと並び替え機能を追加してほしい。"
];

const demoPoReplies = [
  "承知いたしました。要件を整理のうえ、対応方針を改めてご報告いたします。",
  "ご依頼を受領しました。影響範囲と優先度を確認し、進め方をご提案いたします。",
  "内容を確認いたします。実現案とスケジュールを取りまとめ次第ご連絡いたします。"
];

const demoPlanSteps = [
  "要望を整理し、目的指標と優先度を確認",
  "体験フローを分解してSMがタスク化",
  "Devが実装し、QAで品質と回帰を確認"
];

const demoDirectories = [
  "po-inbox",
  "sm-inbox",
  "dev-inbox",
  "qa-inbox",
  "reports"
];

const demoAgents = [
  { id: "po", name: "PO Agent", role: "要件整理", status: "idle", recent: "-" },
  { id: "sm", name: "SM Agent", role: "タスク分解", status: "idle", recent: "-" },
  { id: "qa1", name: "QA Agent 1", role: "品質検証", status: "idle", recent: "-" },
  { id: "qa2", name: "QA Agent 2", role: "回帰検証", status: "idle", recent: "-" },
  { id: "dev1", name: "Dev Agent 1", role: "実装", status: "idle", recent: "-" },
  { id: "dev2", name: "Dev Agent 2", role: "実装", status: "idle", recent: "-" },
  { id: "dev3", name: "Dev Agent 3", role: "実装", status: "idle", recent: "-" },
  { id: "dev4", name: "Dev Agent 4", role: "実装", status: "idle", recent: "-" },
  { id: "dev5", name: "Dev Agent 5", role: "実装", status: "idle", recent: "-" },
  { id: "dev6", name: "Dev Agent 6", role: "実装", status: "idle", recent: "-" },
  { id: "dev7", name: "Dev Agent 7", role: "実装", status: "idle", recent: "-" },
  { id: "dev8", name: "Dev Agent 8", role: "実装", status: "idle", recent: "-" }
];

const demoFlowTemplates = [
  { from: "PO", to: "SM", summary: "要件を要約し、狙いを明確化" },
  { from: "SM", to: "Dev", summary: "タスクを分割して優先度を付与" },
  { from: "Dev", to: "SM", summary: "実装方針と見積りを返信" },
  { from: "SM", to: "PO", summary: "スコープとリリース案を共有" }
];

const demoYamlTemplates = [
  {
    schema_version: "1.0",
    request_id: "REQ-20260128-001",
    priority: "P0",
    summary: "オンボーディング改善",
    acceptance_criteria: ["初回体験の短縮", "離脱率の低減"],
    constraints: ["ローカルのみ"],
    notes: "Phase 5 verification"
  },
  {
    schema_version: "1.0",
    request_id: "REQ-20260128-002",
    priority: "P1",
    summary: "検索フィルタ保存",
    acceptance_criteria: ["保存済みフィルタ表示", "再利用機能"],
    constraints: ["既存API利用"],
    notes: "UX改善"
  },
  {
    schema_version: "1.0",
    request_id: "REQ-20260128-003",
    priority: "P1",
    summary: "請求書ダウンロード機能",
    acceptance_criteria: ["フィルタ機能", "並び替え機能"],
    constraints: ["PDF形式対応"],
    notes: "経理部門要望"
  }
];

const demoTaskTemplates = [
  ["UI調整", "API連携", "追跡計測"],
  ["フィルタUI実装", "保存API", "復元処理"],
  ["一覧画面", "フィルタ実装", "ソート実装", "ダウンロードAPI"]
];

const demoPoToHumanTemplates = [
  {
    title: "PO報告: 方針と目標",
    detail:
      "オンボーディングの初回体験を短縮し、登録完了率を +8% 改善することを目標とします。"
  },
  {
    title: "PO報告: スコープ提案",
    detail:
      "主要3画面に範囲を限定したうえでA/B検証を実施し、効果検証の精度を高めます。"
  },
  {
    title: "PO報告: リスクと対応",
    detail:
      "既存トラッキングの改修が必要となるため、計測設計を前倒しで進めます。"
  }
];

const demoWorkStatusTemplates = [
  { label: "作業中", tone: "active" },
  { label: "完了", tone: "done" }
];

const demoCompletionNotes = [
  "本件の実装およびQAが完了いたしました。リリース判断をご確認ください。",
  "受け入れ基準の確認まで完了しております。運用チームへの引き継ぎを進めます。",
  "全タスクが完了し、回帰テストも問題ございませんでした。"
];

const demoQaTemplates = [
  { label: "QA 待機中", detail: "準備完了。テストケース 12 件" },
  { label: "QA 実行中", detail: "回帰テスト 4 件、手動確認中" },
  { label: "QA 完了", detail: "重大バグなし、軽微 1 件" }
];

const createFlowEvent = (template) => ({
  id: `flow-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
  from: template.from,
  to: template.to,
  summary: template.summary,
  time: new Date().toLocaleTimeString()
});

const createChatMessage = (role, text) => ({
  id: `chat-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
  role,
  text,
  time: new Date().toLocaleTimeString()
});

const createPoInboxItemWithSteps = (request, yamlIndex = 0) => ({
  id: `po-inbox-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
  title: request.length > 20 ? request.substring(0, 20) + "..." : request,
  time: new Date().toLocaleTimeString(),
  yamlIndex,
  steps: [
    {
      type: "received",
      label: "指示受領",
      content: request,
      time: new Date().toLocaleTimeString()
    }
  ],
  outputFiles: []
});

const createSmInboxItemWithSteps = (yamlData) => ({
  id: `sm-inbox-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
  title: `タスク分解: ${yamlData.request_id}`,
  time: new Date().toLocaleTimeString(),
  steps: [
    {
      type: "received",
      label: "指示受領",
      content: "POからYAML読取指示を受信",
      time: new Date().toLocaleTimeString()
    }
  ],
  outputFiles: []
});

const generateYamlString = (template) => {
  return `schema_version: "${template.schema_version}"
request_id: "${template.request_id}"
priority: "${template.priority}"
summary: "${template.summary}"
acceptance_criteria:
${template.acceptance_criteria.map((c) => `  - "${c}"`).join("\n")}
constraints:
${template.constraints.map((c) => `  - "${c}"`).join("\n")}
notes: "${template.notes}"`;
};

export default function App() {
  const [demoMode, setDemoMode] = useState(BUILD_DEMO);
  const [humanRequest, setHumanRequest] = useState("");
  const [chatMessages, setChatMessages] = useState([]);
  const [poReport, setPoReport] = useState({ title: "-", detail: "-" });
  const [workStatus, setWorkStatus] = useState({
    label: "作業中",
    tone: "active"
  });
  const [completionNote, setCompletionNote] = useState("");
  const [planSteps, setPlanSteps] = useState([]);
  const [agentInventory, setAgentInventory] = useState([]);
  const [flowEvents, setFlowEvents] = useState([]);
  const [poSmMessages, setPoSmMessages] = useState([]);
  const [poInbox, setPoInbox] = useState([]);
  const [smInbox, setSmInbox] = useState([]);
  const [qaStatus, setQaStatus] = useState({ label: "-", detail: "-" });
  const [lastUpdated, setLastUpdated] = useState(null);
  const [selectedPoInboxId, setSelectedPoInboxId] = useState(null);
  const [selectedSmInboxId, setSelectedSmInboxId] = useState(null);
  const [flashIds, setFlashIds] = useState({
    flow: null,
    po: null,
    sm: null,
    agent: null,
    poInbox: false,
    smInbox: false,
    poSmChat: false
  });

  const flowIndex = useRef(0);
  const poIndex = useRef(0);
  const poReportIndex = useRef(0);
  const statusIndex = useRef(0);
  const smIndex = useRef(0);
  const requestIndex = useRef(0);
  const qaIndex = useRef(0);
  const devAgentIndex = useRef(0);
  const qaAgentIndex = useRef(0);
  const chatScrollRef = useRef(null);

  const poSmEvents = poSmMessages;

  useEffect(() => {
    if (demoMode) {
      flowIndex.current = 0;
      poIndex.current = 0;
      poReportIndex.current = 0;
      statusIndex.current = 0;
      smIndex.current = 0;
      requestIndex.current = 0;
      qaIndex.current = 0;
      devAgentIndex.current = 0;
      qaAgentIndex.current = 0;

      setHumanRequest(demoRequests[0]);
      setChatMessages([
        createChatMessage("human", demoRequests[0]),
        createChatMessage("po", demoPoReplies[0])
      ]);
      setPoReport(demoPoToHumanTemplates[0]);
      setWorkStatus(demoWorkStatusTemplates[0]);
      setCompletionNote("");
      setPlanSteps(demoPlanSteps);
      setAgentInventory(demoAgents);
      setFlowEvents([createFlowEvent(demoFlowTemplates[0])]);
      setPoSmMessages([
        createFlowEvent({ from: "PO", to: "SM", summary: "要件を受領し、タスク化を依頼" })
      ]);

      // 新しいステップ付きInbox構造で初期化
      const initialPoItem = createPoInboxItemWithSteps(demoRequests[0], 0);
      initialPoItem.steps = [
        { type: "received", label: "指示受領", content: demoRequests[0], time: new Date().toLocaleTimeString() },
        { type: "generating", label: "YAML生成", content: "po_to_sm.yaml を生成完了", time: new Date().toLocaleTimeString() },
        { type: "saved", label: "ファイル保存", content: "queue/po_to_sm.yaml に保存完了", time: new Date().toLocaleTimeString() },
        { type: "notify", label: "SM通知", content: "SMにYAML読取指示を送信", time: new Date().toLocaleTimeString() }
      ];
      initialPoItem.outputFiles = [
        { name: "po_to_sm.yaml", content: generateYamlString(demoYamlTemplates[0]) }
      ];
      setPoInbox([initialPoItem]);
      setSelectedPoInboxId(initialPoItem.id);

      const initialSmItem = createSmInboxItemWithSteps(demoYamlTemplates[0]);
      initialSmItem.steps = [
        { type: "received", label: "指示受領", content: "POからYAML読取指示を受信", time: new Date().toLocaleTimeString() },
        { type: "parsing", label: "YAML解析", content: `queue/po_to_sm.yaml を読取完了\n${demoYamlTemplates[0].summary}`, time: new Date().toLocaleTimeString() },
        { type: "tasks", label: "タスク分解", content: demoTaskTemplates[0], time: new Date().toLocaleTimeString() }
      ];
      initialSmItem.outputFiles = [
        {
          name: "tasks.yaml",
          content: `request_id: "${demoYamlTemplates[0].request_id}"
tasks:
${demoTaskTemplates[0].map((t, i) => `  - id: TASK-${i + 1}
    title: "${t}"
    status: pending`).join("\n")}`
        }
      ];
      setSmInbox([initialSmItem]);
      setSelectedSmInboxId(initialSmItem.id);

      setQaStatus(demoQaTemplates[0]);
      setLastUpdated(new Date());
      setFlashIds({ flow: null, po: null, sm: null, agent: null, poInbox: false, smInbox: false, poSmChat: false });
    } else {
      setHumanRequest("");
      setChatMessages([]);
      setPoReport({ title: "PO報告待ち", detail: "ライブデータ待機中" });
      setWorkStatus({ label: "作業中", tone: "active" });
      setCompletionNote("");
      setPlanSteps(["要件整理を待機", "タスク化を待機", "実装を待機"]);
      setAgentInventory(
        demoAgents.map((agent) => ({
          ...agent,
          status: "idle",
          recent: "ライブデータ待機中"
        }))
      );
      setFlowEvents([]);
      setPoSmMessages([]);
      setPoInbox([]);
      setSmInbox([]);
      setSelectedPoInboxId(null);
      setSelectedSmInboxId(null);
      setQaStatus({ label: "QA 未開始", detail: "入力待機中" });
      setLastUpdated(null);
      setFlashIds({ flow: null, po: null, sm: null, agent: null, poInbox: false, smInbox: false, poSmChat: false });
    }
  }, [demoMode]);

  useEffect(() => {
    if (!demoMode) return;

    const id = setInterval(() => {
      // Flow更新
      const flowTemplate =
        demoFlowTemplates[flowIndex.current % demoFlowTemplates.length];
      const nextFlow = createFlowEvent(flowTemplate);
      flowIndex.current += 1;
      setFlowEvents((prev) => [nextFlow, ...prev].slice(0, 6));

      // PO Report更新
      const nextPoReport =
        demoPoToHumanTemplates[
          poReportIndex.current % demoPoToHumanTemplates.length
        ];
      const nextStatus =
        demoWorkStatusTemplates[
          statusIndex.current % demoWorkStatusTemplates.length
        ];
      poReportIndex.current += 1;
      statusIndex.current += 1;
      setPoReport(nextPoReport);
      setWorkStatus(nextStatus);
      setCompletionNote(
        nextStatus.tone === "done"
          ? demoCompletionNotes[
              statusIndex.current % demoCompletionNotes.length
            ]
          : ""
      );

      // QA更新
      const nextQa = demoQaTemplates[qaIndex.current % demoQaTemplates.length];
      qaIndex.current += 1;
      setQaStatus(nextQa);

      // Agent状態更新
      const pickDevAgentId = () => {
        const agentId = `dev${(devAgentIndex.current % 8) + 1}`;
        devAgentIndex.current += 1;
        return agentId;
      };
      const pickQaAgentId = () => {
        const agentId = `qa${(qaAgentIndex.current % 2) + 1}`;
        qaAgentIndex.current += 1;
        return agentId;
      };
      const activeAgentId =
        nextFlow.to === "SM"
          ? "sm"
          : nextFlow.to === "PO"
            ? "po"
            : nextFlow.to === "Dev"
              ? pickDevAgentId()
              : "po";
      setAgentInventory((prev) =>
        prev.map((agent) => ({
          ...agent,
          status: agent.id === activeAgentId ? "active" : "idle",
          recent:
            agent.id === activeAgentId ? nextFlow.summary : agent.recent
        }))
      );

      setFlashIds({
        flow: nextFlow.id,
        po: null,
        sm: null,
        agent: activeAgentId
      });
      setLastUpdated(new Date());

      if (nextQa.label !== "QA 待機中") {
        const qaId = pickQaAgentId();
        setAgentInventory((prev) =>
          prev.map((agent) => ({
            ...agent,
            status: agent.id === qaId ? "active" : agent.status,
            recent: agent.id === qaId ? nextQa.detail : agent.recent
          }))
        );
        setFlashIds((prev) => ({ ...prev, agent: qaId }));
      }
    }, 4000);

    return () => clearInterval(id);
  }, [demoMode]);

  useEffect(() => {
    if (!chatScrollRef.current) return;
    chatScrollRef.current.scrollTop = chatScrollRef.current.scrollHeight;
  }, [chatMessages]);

  const triggerFlash = (key) => {
    setFlashIds((prev) => ({ ...prev, [key]: true }));
    setTimeout(() => {
      setFlashIds((prev) => ({ ...prev, [key]: false }));
    }, 1200);
  };

  const addPoInboxStep = (itemId, step) => {
    setPoInbox((prev) =>
      prev.map((item) =>
        item.id === itemId ? { ...item, steps: [...item.steps, step] } : item
      )
    );
    triggerFlash("poInbox");
  };

  const addPoInboxOutputFile = (itemId, file) => {
    setPoInbox((prev) =>
      prev.map((item) =>
        item.id === itemId
          ? { ...item, outputFiles: [...item.outputFiles, file] }
          : item
      )
    );
  };

  const addSmInboxStep = (itemId, step) => {
    setSmInbox((prev) =>
      prev.map((item) =>
        item.id === itemId ? { ...item, steps: [...item.steps, step] } : item
      )
    );
    triggerFlash("smInbox");
  };

  const addSmInboxOutputFile = (itemId, file) => {
    setSmInbox((prev) =>
      prev.map((item) =>
        item.id === itemId
          ? { ...item, outputFiles: [...item.outputFiles, file] }
          : item
      )
    );
  };

  const handleHumanSend = () => {
    const value = humanRequest.trim();
    if (!value) return;

    // チャットメッセージ追加
    setChatMessages((prev) =>
      [...prev, createChatMessage("human", value)].slice(-10)
    );
    setHumanRequest("");
    setLastUpdated(new Date());
    setWorkStatus({ label: "作業中", tone: "active" });
    setFlashIds((prev) => ({ ...prev, agent: "po" }));
    setAgentInventory((prev) =>
      prev.map((agent) => ({
        ...agent,
        status: agent.id === "po" ? "active" : "idle",
        recent: agent.id === "po" ? value : agent.recent
      }))
    );

    // PO Inboxに新アイテム追加（receivedステップのみ）
    const yamlIdx = requestIndex.current % demoYamlTemplates.length;
    const newPoItem = createPoInboxItemWithSteps(value, yamlIdx);
    setPoInbox((prev) => [newPoItem, ...prev].slice(0, 10));
    setSelectedPoInboxId(newPoItem.id);

    // POの返信
    const reply = demoPoReplies[requestIndex.current % demoPoReplies.length];
    setTimeout(() => {
      setChatMessages((prev) =>
        [...prev, createChatMessage("po", reply)].slice(-10)
      );
    }, 800);

    // 1.5秒後: YAML生成中ステップ
    const yamlTemplate = demoYamlTemplates[yamlIdx];
    setTimeout(() => {
      addPoInboxStep(newPoItem.id, {
        type: "generating",
        label: "YAML生成中",
        content: "po_to_sm.yaml を生成中...",
        time: new Date().toLocaleTimeString()
      });
    }, 1500);

    // 3秒後: ファイル保存ステップ → outputFilesに追加
    setTimeout(() => {
      addPoInboxStep(newPoItem.id, {
        type: "saved",
        label: "ファイル保存",
        content: "queue/po_to_sm.yaml に保存完了",
        time: new Date().toLocaleTimeString()
      });
      addPoInboxOutputFile(newPoItem.id, {
        name: "po_to_sm.yaml",
        content: generateYamlString(yamlTemplate)
      });
    }, 3000);

    // 4.5秒後: SM通知ステップ + SM Inbox追加
    setTimeout(() => {
      addPoInboxStep(newPoItem.id, {
        type: "notify",
        label: "SM通知",
        content: "SMにYAML読取指示を送信",
        time: new Date().toLocaleTimeString()
      });

      // PO-SMチャットに追加
      setPoSmMessages((prev) =>
        [
          ...prev,
          createFlowEvent({
            from: "PO",
            to: "SM",
            summary: `${yamlTemplate.request_id} のYAMLを読んでください`
          })
        ].slice(-8)
      );
      triggerFlash("poSmChat");

      // SM Inbox追加
      const newSmItem = createSmInboxItemWithSteps(yamlTemplate);
      setSmInbox((prev) => [newSmItem, ...prev].slice(0, 10));
      setSelectedSmInboxId(newSmItem.id);

      // 6秒後: SM YAML解析ステップ
      setTimeout(() => {
        addSmInboxStep(newSmItem.id, {
          type: "parsing",
          label: "YAML解析",
          content: `queue/po_to_sm.yaml を読取中...\n${yamlTemplate.summary}`,
          time: new Date().toLocaleTimeString()
        });
      }, 1500);

      // 7.5秒後: SM タスク分解ステップ
      setTimeout(() => {
        const tasks = demoTaskTemplates[yamlIdx % demoTaskTemplates.length];
        addSmInboxStep(newSmItem.id, {
          type: "tasks",
          label: "タスク分解",
          content: tasks,
          time: new Date().toLocaleTimeString()
        });
        addSmInboxOutputFile(newSmItem.id, {
          name: "tasks.yaml",
          content: `request_id: "${yamlTemplate.request_id}"
tasks:
${tasks.map((t, i) => `  - id: TASK-${i + 1}
    title: "${t}"
    status: pending`).join("\n")}`
        });

        // SM→POへの返信
        setPoSmMessages((prev) =>
          [
            ...prev,
            createFlowEvent({
              from: "SM",
              to: "PO",
              summary: `${tasks.length}件のタスクに分解完了`
            })
          ].slice(-8)
        );
        triggerFlash("poSmChat");
      }, 3000);
    }, 4500);

    requestIndex.current += 1;
  };

  return (
    <div className="min-h-screen bg-bg-base">
      <header className="px-6 py-5 border-b border-border-default bg-bg-surface">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-semibold text-primary">IXV-Agents</h1>
            <p className="text-text-muted text-sm">
              エージェント連携の流れを可視化するステータス画面
            </p>
          </div>
          <div className="flex items-center gap-3">
            <button
              className="text-xs px-2 py-1 rounded border border-primary bg-primary text-white hover:bg-primary-dark"
              onClick={() => setDemoMode((prev) => !prev)}
              title="デモモード切替"
            >
              {demoMode ? "デモモード" : "ライブモード"}
            </button>
            <div className="text-xs text-text-muted">
              最終更新: {lastUpdated ? lastUpdated.toLocaleTimeString() : "-"}
            </div>
          </div>
        </div>
      </header>
      <main className="flex flex-col gap-6 p-6">
        {/* Row 1: Human→POチャット | PO Inbox */}
        <div className="grid gap-6 lg:grid-cols-10">
          {/* Human→POチャット */}
          <div className="lg:col-span-2 rounded-lg border border-border-default bg-bg-surface p-4">
            <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
              Human → PO チャット
            </h2>
            <div className="mt-3 flex flex-col gap-3">
              <div
                ref={chatScrollRef}
                className="flex max-h-48 flex-col gap-3 overflow-y-auto rounded-lg border border-border-muted bg-bg-muted p-3"
              >
                {chatMessages.length === 0 && (
                  <div className="text-xs text-text-muted">
                    まだ指示は送信されていません。
                  </div>
                )}
                {chatMessages.map((message) => {
                  const isHuman = message.role === "human";
                  return (
                    <div
                      key={message.id}
                      className={`flex ${isHuman ? "justify-end" : "justify-start"}`}
                    >
                      <div
                        className={`max-w-[85%] rounded-2xl px-3 py-2 text-sm ${
                          isHuman
                            ? "bg-primary text-white"
                            : "bg-white text-text-base border border-border-default"
                        }`}
                      >
                        <div
                          className={`text-[11px] ${
                            isHuman ? "text-primary-light" : "text-text-muted"
                          }`}
                        >
                          {isHuman ? "Human → PO" : "PO → Human"} · {message.time}
                        </div>
                        <div className="mt-1 whitespace-pre-wrap">
                          {message.text}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
              <div className="flex items-end gap-2 rounded-2xl border border-border-default bg-white px-3 py-2">
                <textarea
                  className="min-h-[36px] flex-1 resize-none bg-transparent text-sm text-text-base focus:outline-none"
                  value={humanRequest}
                  onChange={(event) => setHumanRequest(event.target.value)}
                  onKeyDown={(event) => {
                    if (event.key === "Enter") {
                      if (event.shiftKey) return;
                      event.preventDefault();
                      handleHumanSend();
                    }
                  }}
                  placeholder="メッセージを入力"
                  rows={2}
                />
                <button
                  className="flex h-8 w-8 items-center justify-center rounded-full border border-primary bg-primary text-white hover:bg-primary-dark disabled:cursor-not-allowed disabled:opacity-40"
                  onClick={handleHumanSend}
                  title="送信"
                  aria-label="送信"
                  disabled={!humanRequest.trim()}
                >
                  ↑
                </button>
              </div>
              <div className="text-[11px] text-text-muted">
                Enterで送信 / Shift+Enterで改行
              </div>
            </div>
          </div>

          {/* PO Inbox メーラー形式 (3カラム) */}
          <div className={`lg:col-span-8 rounded-lg border border-border-default bg-bg-surface p-4 ${flashIds.poInbox ? "ixv-flash" : ""}`}>
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
                PO Inbox
              </h2>
              <span className="text-xs text-text-muted">
                {poInbox.length} items
              </span>
            </div>
            <div className="mt-4 flex gap-4 min-h-[200px]">
              {/* 左: 一覧 (20%) */}
              <div className="w-[20%] border-r border-border-muted pr-3 space-y-2 overflow-y-auto max-h-[240px]">
                {poInbox.length === 0 && (
                  <div className="text-sm text-text-muted">メッセージはありません。</div>
                )}
                {poInbox.map((item) => (
                  <div
                    key={item.id}
                    onClick={() => setSelectedPoInboxId(item.id)}
                    className={`cursor-pointer rounded px-2 py-2 transition-colors ${
                      selectedPoInboxId === item.id
                        ? "bg-primary-light border border-primary"
                        : "hover:bg-bg-hover border border-transparent"
                    }`}
                  >
                    <div className="text-sm font-semibold truncate text-text-base">
                      {item.title}
                    </div>
                    <div className="text-xs text-text-muted">{item.time}</div>
                  </div>
                ))}
              </div>
              {/* 中央: 実行詳細 (40%) */}
              <div className="w-[40%] border-r border-border-muted pr-3 space-y-3 overflow-y-auto max-h-[240px]">
                {(() => {
                  const selectedItem = poInbox.find((i) => i.id === selectedPoInboxId);
                  if (!selectedItem) {
                    return (
                      <div className="text-sm text-text-muted">
                        アイテムを選択してください
                      </div>
                    );
                  }
                  return selectedItem.steps.map((step, idx) => (
                    <div
                      key={idx}
                      className="rounded-lg border border-border-muted bg-bg-muted px-3 py-2"
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-semibold text-primary">
                          [{step.label}]
                        </span>
                        <span className="text-xs text-text-muted">{step.time}</span>
                      </div>
                      <div className="mt-2 text-sm">
                        <div className="text-text-secondary">{step.content}</div>
                      </div>
                    </div>
                  ));
                })()}
              </div>
              {/* 右: 出力プレビュー (40%) */}
              <div className="w-[40%] space-y-2 overflow-y-auto max-h-[240px]">
                {(() => {
                  const selectedItem = poInbox.find((i) => i.id === selectedPoInboxId);
                  if (!selectedItem) {
                    return (
                      <div className="text-sm text-text-muted">
                        ファイルを表示するにはアイテムを選択してください
                      </div>
                    );
                  }
                  if (!selectedItem.outputFiles || selectedItem.outputFiles.length === 0) {
                    return (
                      <div className="text-sm text-text-muted">
                        出力ファイルはまだありません
                      </div>
                    );
                  }
                  return (
                    <>
                      {/* タブ */}
                      <div className="flex gap-1 border-b border-border-muted">
                        {selectedItem.outputFiles.map((file, idx) => (
                          <button
                            key={idx}
                            className={`px-3 py-1 text-xs font-semibold border-b-2 ${
                              idx === 0
                                ? "text-primary border-primary"
                                : "text-text-muted border-transparent hover:text-text-base"
                            }`}
                          >
                            {file.name}
                          </button>
                        ))}
                      </div>
                      {/* ファイル内容 */}
                      <pre className="bg-bg-base p-3 rounded text-xs overflow-x-auto whitespace-pre-wrap border border-border-muted">
                        {selectedItem.outputFiles[0]?.content}
                      </pre>
                    </>
                  );
                })()}
              </div>
            </div>
          </div>
        </div>

        {/* Row 2: PO↔SMチャット | SM Inbox */}
        <div className="grid gap-6 lg:grid-cols-10">
          {/* PO↔SMチャット */}
          <div className={`lg:col-span-2 rounded-lg border border-border-default bg-bg-surface p-4 ${flashIds.poSmChat ? "ixv-flash" : ""}`}>
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
                PO ↔ SM チャット
              </h2>
              <span className="text-xs text-text-muted">
                {poSmEvents.length} messages
              </span>
            </div>
            <div className="mt-4 max-h-48 space-y-3 overflow-y-auto pr-1 text-sm">
              {poSmEvents.length === 0 && (
                <div className="text-sm text-text-muted">
                  まだやり取りはありません。
                </div>
              )}
              {poSmEvents.map((event) => {
                const isPo = event.from === "PO";
                return (
                  <div
                    key={`posm-${event.id}`}
                    className={`flex ${isPo ? "justify-start" : "justify-end"}`}
                  >
                    <div
                      className={`max-w-[80%] rounded-2xl px-3 py-2 text-sm ${
                        isPo
                          ? "bg-white text-text-base border border-border-default"
                          : "bg-primary text-white"
                      }`}
                    >
                      <div
                        className={`text-[11px] ${
                          isPo ? "text-text-muted" : "text-primary-light"
                        }`}
                      >
                        {event.from} → {event.to} · {event.time}
                      </div>
                      <div className="mt-1 whitespace-pre-wrap">
                        {event.summary}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* SM Inbox メーラー形式 (3カラム) */}
          <div className={`lg:col-span-8 rounded-lg border border-border-default bg-bg-surface p-4 ${flashIds.smInbox ? "ixv-flash" : ""}`}>
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
                SM Inbox
              </h2>
              <span className="text-xs text-text-muted">
                {smInbox.length} items
              </span>
            </div>
            <div className="mt-4 flex gap-4 min-h-[200px]">
              {/* 左: 一覧 (20%) */}
              <div className="w-[20%] border-r border-border-muted pr-3 space-y-2 overflow-y-auto max-h-[240px]">
                {smInbox.length === 0 && (
                  <div className="text-sm text-text-muted">メッセージはありません。</div>
                )}
                {smInbox.map((item) => (
                  <div
                    key={item.id}
                    onClick={() => setSelectedSmInboxId(item.id)}
                    className={`cursor-pointer rounded px-2 py-2 transition-colors ${
                      selectedSmInboxId === item.id
                        ? "bg-primary-light border border-primary"
                        : "hover:bg-bg-hover border border-transparent"
                    }`}
                  >
                    <div className="text-sm font-semibold truncate text-text-base">
                      {item.title}
                    </div>
                    <div className="text-xs text-text-muted">{item.time}</div>
                  </div>
                ))}
              </div>
              {/* 中央: 実行詳細 (40%) */}
              <div className="w-[40%] border-r border-border-muted pr-3 space-y-3 overflow-y-auto max-h-[240px]">
                {(() => {
                  const selectedItem = smInbox.find((i) => i.id === selectedSmInboxId);
                  if (!selectedItem) {
                    return (
                      <div className="text-sm text-text-muted">
                        アイテムを選択してください
                      </div>
                    );
                  }
                  return selectedItem.steps.map((step, idx) => (
                    <div
                      key={idx}
                      className="rounded-lg border border-border-muted bg-bg-muted px-3 py-2"
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-semibold text-primary">
                          [{step.label}]
                        </span>
                        <span className="text-xs text-text-muted">{step.time}</span>
                      </div>
                      <div className="mt-2 text-sm">
                        {step.type === "tasks" ? (
                          <ul className="list-disc list-inside text-text-secondary">
                            {step.content.map((task, i) => (
                              <li key={i}>{task}</li>
                            ))}
                          </ul>
                        ) : (
                          <div className="text-text-secondary whitespace-pre-wrap">
                            {step.content}
                          </div>
                        )}
                      </div>
                    </div>
                  ));
                })()}
              </div>
              {/* 右: 出力プレビュー (40%) */}
              <div className="w-[40%] space-y-2 overflow-y-auto max-h-[240px]">
                {(() => {
                  const selectedItem = smInbox.find((i) => i.id === selectedSmInboxId);
                  if (!selectedItem) {
                    return (
                      <div className="text-sm text-text-muted">
                        ファイルを表示するにはアイテムを選択してください
                      </div>
                    );
                  }
                  if (!selectedItem.outputFiles || selectedItem.outputFiles.length === 0) {
                    return (
                      <div className="text-sm text-text-muted">
                        出力ファイルはまだありません
                      </div>
                    );
                  }
                  return (
                    <>
                      {/* タブ */}
                      <div className="flex gap-1 border-b border-border-muted">
                        {selectedItem.outputFiles.map((file, idx) => (
                          <button
                            key={idx}
                            className={`px-3 py-1 text-xs font-semibold border-b-2 ${
                              idx === 0
                                ? "text-primary border-primary"
                                : "text-text-muted border-transparent hover:text-text-base"
                            }`}
                          >
                            {file.name}
                          </button>
                        ))}
                      </div>
                      {/* ファイル内容 */}
                      <pre className="bg-bg-base p-3 rounded text-xs overflow-x-auto whitespace-pre-wrap border border-border-muted">
                        {selectedItem.outputFiles[0]?.content}
                      </pre>
                    </>
                  );
                })()}
              </div>
            </div>
          </div>
        </div>

        {/* Row 3: PO→Human Report | Flow */}
        <div className="grid gap-6 lg:grid-cols-10">
          {/* PO→Human Report */}
          <div className="lg:col-span-2 rounded-lg border border-border-default bg-bg-surface p-4">
            <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
              PO → Human Report
            </h2>
            <div className="mt-3 rounded-lg border-2 border-primary bg-primary-light px-4 py-3 text-sm shadow-sm">
              <div className="flex items-center gap-2 text-primary">
                <span className="text-base">●</span>
                <span className="font-semibold">重要報告</span>
              </div>
              <div className="mt-3 flex flex-wrap items-center justify-between gap-2">
                <div className="text-base font-semibold text-text-base">
                  {poReport.title}
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[11px] text-text-muted">作業ステータス</span>
                  <span
                    className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                      workStatus.tone === "done"
                        ? "bg-success-light text-success"
                        : "bg-warning-light text-warning"
                    }`}
                  >
                    {workStatus.label}
                  </span>
                </div>
              </div>
              <div className="mt-2 text-sm text-text-default leading-relaxed">
                {poReport.detail}
              </div>
              {completionNote && (
                <div className="mt-3 rounded-lg border border-success-light bg-success-light/60 px-3 py-2 text-xs text-success">
                  完了報告: {completionNote}
                </div>
              )}
              <div className="mt-4 text-xs text-text-muted">
                最終更新: {lastUpdated ? lastUpdated.toLocaleTimeString() : "-"}
              </div>
            </div>
          </div>

          {/* Flow */}
          <div className="lg:col-span-8 rounded-lg border border-border-default bg-bg-surface p-4">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
                Flow
              </h2>
              <span className="text-xs text-text-muted">PO → SM → Dev</span>
            </div>
            <div className="mt-4 grid gap-4 lg:grid-cols-3">
              <div className="space-y-4 lg:col-span-2">
                <div className="flex items-center gap-3 text-xs text-text-secondary">
                  <span className="rounded-full bg-primary-light px-3 py-1 text-primary">
                    PO
                  </span>
                  <span className="text-text-muted">→</span>
                  <span className="rounded-full bg-primary-light px-3 py-1 text-primary">
                    SM
                  </span>
                  <span className="text-text-muted">→</span>
                  <span className="rounded-full bg-primary-light px-3 py-1 text-primary">
                    Dev
                  </span>
                </div>
                <div className="space-y-3 max-h-32 overflow-y-auto">
                  {flowEvents.length === 0 && (
                    <div className="text-sm text-text-muted">
                      まだイベントはありません。
                    </div>
                  )}
                  {flowEvents.map((event) => (
                    <div
                      key={event.id}
                      className={`rounded-lg border border-border-default bg-bg-muted px-3 py-2 text-sm ${
                        flashIds.flow === event.id ? "ixv-flash" : ""
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <div className="font-semibold text-text-base">
                          {event.from} → {event.to}
                        </div>
                        <div className="text-xs text-text-muted">{event.time}</div>
                      </div>
                      <div className="text-xs text-text-secondary">
                        {event.summary}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              <div className="rounded-lg border border-border-muted bg-bg-muted p-3">
                <div className="text-xs font-semibold text-text-muted uppercase tracking-wide">
                  QA
                </div>
                <div className="mt-3 text-sm font-semibold text-text-base">
                  {qaStatus.label}
                </div>
                <div className="mt-2 text-xs text-text-secondary">
                  {qaStatus.detail}
                </div>
                <div className="mt-4 text-xs text-text-muted">
                  最終更新: {lastUpdated ? lastUpdated.toLocaleTimeString() : "-"}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Row 4: High-level Plan | Agent Inventory | Agent Directories */}
        <div className="grid gap-6 lg:grid-cols-3">
          {/* High-level Plan */}
          <div className="rounded-lg border border-border-default bg-bg-surface p-4">
            <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
              High-level Plan
            </h2>
            <ol className="mt-3 space-y-2 text-sm text-text-base">
              {planSteps.map((step, index) => (
                <li key={`${step}-${index}`} className="flex gap-2">
                  <span className="font-semibold text-primary">{index + 1}.</span>
                  <span>{step}</span>
                </li>
              ))}
            </ol>
          </div>

          {/* Agent Inventory */}
          <div className="rounded-lg border border-border-default bg-bg-surface p-4">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
                Agent Inventory
              </h2>
              <span className="text-xs text-text-muted">
                active {agentInventory.filter((a) => a.status === "active").length}
              </span>
            </div>
            <div className="mt-4 max-h-[180px] space-y-2 overflow-y-auto pr-1 text-sm">
              {agentInventory.map((agent) => (
                <div
                  key={agent.id}
                  className={`rounded-lg border border-border-muted bg-bg-muted px-3 py-2 ${
                    flashIds.agent === agent.id ? "ixv-flash" : ""
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div className="font-semibold text-text-base text-sm">
                      {agent.name}
                    </div>
                    <span
                      className={`text-xs ${
                        agent.status === "active" ? "text-success" : "text-text-muted"
                      }`}
                    >
                      {agent.status === "active" ? "active" : "idle"}
                    </span>
                  </div>
                  <div className="text-xs text-text-muted truncate">
                    {agent.recent}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Agent Directories */}
          <div className="rounded-lg border border-border-default bg-bg-surface p-4">
            <h2 className="text-sm font-semibold text-text-muted uppercase tracking-wide">
              Agent Directories
            </h2>
            <div className="mt-3 flex flex-wrap gap-2">
              {demoDirectories.map((dir) => (
                <span
                  key={dir}
                  className="rounded-full border border-border-default bg-bg-muted px-3 py-1 text-xs text-text-secondary"
                >
                  {dir}/
                </span>
              ))}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
