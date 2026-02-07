#!/bin/bash

# ============================================
# IXV-agents ASCII Art Banner
# Color: #3F61A7 -> RGB(63, 97, 167)
# ============================================

COLOR="\033[38;2;63;97;167m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${BOLD}${COLOR}"
cat << 'EOF'
    _____  ___    __      ___                    __
   /  _/ |/ / |  / /     /   |_____ ____  ____  / /______
   / / |   /| | / /____ / /| |/ __ `/ _ \/ __ \/ __/ ___/
 _/ / /   | | |/ /_____/ ___ | /_/ /  __/ / / / /_(__  )
/___//_/|_| |___/      /_/  |_\__, /\___/_/ /_/\__/____/
                              /____/
EOF
echo -e "${RESET}"

DIM="\033[2m"

echo -e "  ${BOLD}Specification-Driven AI Development System / 仕様駆動AI開発システム${RESET}"
echo ""
echo -e "  ${DIM}-- 4 Principles / 4つの原則 ---------------------------${RESET}"
echo "  1. Specs are living documents / 仕様は「生きたドキュメント」である"
echo "  2. Specs are the Single Source of Truth / 仕様は「信頼できる唯一の情報源（SSoT）」とする"
echo "  3. Change and iteration are assumed / 仕様は「変更と反復が前提」とする"
echo "  4. AI reduces cost, humans decide / AIでコストを抑えて実現する（人間が最終判断）"
echo ""
echo -e "  ${DIM}-- 7 Processes / 7つの工程 -----------------------------------------------${RESET}"
echo "  #  Process          工程            Output                        Approval"
echo -e "  ${DIM}  --------------------------------------------------------------------------${RESET}"
echo "  1  Constitution     原則決定        CONSTITUTION.md               Human"
echo "  2  Specify          企画・要件定義  README.md (SSoT)              Human"
echo "  3  Plan             設計計画        docs/*                        Human(*)"
echo "  4  Tasks            タスク分割      queue/tasks/, dashboard.md    -"
echo "  5  Implement        実装            Code + Tests, reports/*.yaml  -"
echo "  6  Verify/Accept    検証・受入      dashboard.md, Backlog更新     Human"
echo "  7  Migration/Op     移行・運用      -> 工程2 or 工程4             -"
echo ""
echo -e "                                          ${DIM}(*) = 必要時のみ${RESET}"
echo -e "${RESET}"
