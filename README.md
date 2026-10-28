# ADF (AllenDevelopFlow)

ADF 是 Allen 的開發流程，做成一個 Claude Code plugin。它管理從 issue 進件到結案的流程（A 到 J），提供品質關卡（單元測試、CRAP、變異測試），並設定每個回答的格式。

## 安裝

在 Claude Code 中執行：

```
/plugin marketplace add KaiJuY/ADF
/plugin install adf@adf
```

開發 ADF 本身時，可以改用本機 clone 的路徑：`/plugin marketplace add <clone 的路徑>`。

安裝品質關卡工具（每台機器一次）。`<ADF>` 是 plugin 所在的資料夾：從 GitHub 安裝時是 `%USERPROFILE%\.claude\plugins\marketplaces\adf`；用本機 clone 時就是 clone 的路徑。

```powershell
& "<ADF>\scripts\install-tools.ps1"
```

工具裝在 `<ADF>\.tools`，不裝全域。需要 .NET SDK 8 或更新的版本。

## 指令

| 類別 | 指令 | 用途 |
|---|---|---|
| 進件 | `#issue`、`#bug`、`#feature`、`/adf:grill` | 分輪釐清，然後建立或更新 GitHub issue |
| 理解 | `/adf:how`、`/adf:why`、`/adf:plain`、`/adf:recall` | 程式怎麼運作、為什麼這樣設計、白話重述、回到上次進度 |
| 流程 | `/adf:flow #n`、`/adf:status` | 跑完整流程、看目前在哪一關 |
| 各階段 | `/adf:plan`、`/adf:propose`、`/adf:challenge`、`/adf:build`、`/adf:clean`、`/adf:gate`、`/adf:integrate`、`/adf:close` | B 到 J |
| 技術債 | `/adf:scan`、`/adf:debt` | 建立基線、修一項技術債 |
| 其他 | `/adf:log`、`/adf:learn`、`/adf:write` | 決策紀錄、把糾正變成規則、文件標準 |

## 流程

| 階段 | 指令 | 通過條件 |
|---|---|---|
| A 進件 | `/adf:grill` | issue 有編號的驗收條件 |
| B 拆解 | `/adf:plan` | 每個單元有檔案範圍和相依關係 |
| C 提案 | `/adf:propose` | 每個對既有程式碼的斷言都有證據 |
| D+E 對抗審查 | `/adf:challenge` | blocker 和 major 都是 0 |
| F 實作 | `/adf:build` | 單元測試通過，測試基本盤達成 |
| G 清理 | `/adf:clean` | 刪除項目經 owner 確認，merge 無衝突 |
| H 關卡 | `/adf:gate` | 單元測試、CRAP、變異測試都通過 |
| I 整合 | `/adf:integrate` | 行為和預期一致 |
| J 結案 | `/adf:close` | issue 已關閉並附上 merge commit |

詳細規則在 [references/](references/README.md)。

## 在專案中啟用

1. 在專案中執行 `/adf:scan`。它會建立 `.adf/profile.json` 和 `.adf/profile.md`，並記錄技術債基線。
2. 測試專案需要 `coverlet.collector` 套件。scan 會列出缺少的專案。

專案內的 ADF 檔案：

| 路徑 | 內容 | 是否 commit |
|---|---|---|
| `.adf/profile.json`、`.adf/profile.md` | 專案設定與專案特有的規則 | 是 |
| `.adf/baseline/` | CRAP、變異測試、測試清單的基線 | 是 |
| `.adf/proposals/`、`.adf/scenarios/`、`.adf/log/` | 提案、整合測試情境、決策紀錄 | 是 |
| `.adf/out/` | 每次關卡的輸出 | 否 |

## 工具

| 工具 | 版本 | 來源 |
|---|---|---|
| coverlet.collector | 依測試專案 | github.com/coverlet-coverage/coverlet |
| ReportGenerator | 5.5.12 | github.com/danielpalme/ReportGenerator |
| Stryker.NET | 4.16.0 | github.com/stryker-mutator/stryker-net |
| FlaUI.UIA3 | 5.0.0 | github.com/FlaUI/FlaUI |

Stryker.NET 5.0.0 只提供 net10.0 版本。安裝 .NET 10 SDK 後，再改 `scripts/install-tools.ps1` 的版本。

## 回答格式

SessionStart hook 會在每個 session 開始時載入 `references/response-style.md`。說「stop ADF style」可以關閉。
