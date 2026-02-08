# ============================================
# IXV-agents ASCII Art Banner (PowerShell)
# Color: #3F61A7 -> RGB(63, 97, 167)
# ============================================

$ESC = [char]27
$COLOR = "${ESC}[38;2;63;97;167m"
$BOLD = "${ESC}[1m"
$DIM = "${ESC}[2m"
$RESET = "${ESC}[0m"

Write-Host "${BOLD}${COLOR}"
Write-Host "    _____  ___    __      ___                    __"
Write-Host "   /  _/ |/ / |  / /     /   |_____ ____  ____  / /______"
Write-Host "   / / |   /| | / /____ / /| |/ __ ``/ _ \/ __ \/ __/ ___/"
Write-Host " _/ / /   | | |/ /_____/ ___ | /_/ /  __/ / / / /_(__  )"
Write-Host "/___//_/|_| |___/     /_/  |_\__, /\___/_/ /_/\__/____/"
Write-Host "                            /____/"
Write-Host "${RESET}"

Write-Host "  ${BOLD}Specification-Driven AI Development System / 仕様駆動AI開発システム${RESET}"
Write-Host ""
Write-Host "  ${DIM}-- 4 Principles / 4つの原則 ---------------------------${RESET}"
Write-Host "  1. Specs are living documents / 仕様は「生きたドキュメント」である"
Write-Host "  2. Specs are the Single Source of Truth / 仕様は「信頼できる唯一の情報源（SSoT）」とする"
Write-Host "  3. Change and iteration are assumed / 仕様は「変更と反復が前提」とする"
Write-Host "  4. AI reduces cost, humans decide / AIでコストを抑えて実現する（人間が最終判断）"
Write-Host ""
Write-Host "  ${DIM}-- 7 Processes / 7つの工程 -----------------------------------------------${RESET}"
Write-Host "  #  Process          工程            Output                        Approval"
Write-Host "  ${DIM}  --------------------------------------------------------------------------${RESET}"
Write-Host "  1  Constitution     原則決定        CONSTITUTION.md               Human"
Write-Host "  2  Specify          企画・要件定義  README.md (SSoT)              Human"
Write-Host "  3  Plan             設計計画        docs/*                        Human(*)"
Write-Host "  4  Tasks            タスク分割      queue/tasks/, dashboard.md    -"
Write-Host "  5  Implement        実装            Code + Tests, reports/*.yaml  -"
Write-Host "  6  Verify/Accept    検証・受入      dashboard.md, Backlog更新     Human"
Write-Host "  7  Migration/Op     移行・運用      -> 工程2 or 工程4             -"
Write-Host ""
Write-Host "                                          ${DIM}(*) = 必要時のみ${RESET}"
Write-Host "${RESET}"
