# 用 Hugo 把《强化学习之旅》发布成 GitHub Pages 站点

> 目标：`git push` 之后，浏览器打开 `https://<你的用户名>.github.io/<仓库名>/` 就能读这本教材。
>
> **前提：全程不修改你的 md 文件。** 原始 `README.md`、`docs/*.md`、`_EXPERIMENTS.md`、`_STYLE-GUIDE.md` 保持原样，站点内容由脚本从它们**拷贝生成**。

---

## 0. 结构：md 与站点如何共存

```
reinforcement-learning-journey/
├── README.md                     ← 你的源文件（不动）
├── _STYLE-GUIDE.md               ← 你的源文件（不动）
├── _EXPERIMENTS.md               ← 你的源文件（不动）
├── docs/                         ← 你的源文件（34 章，不动）
│   ├── 00-overview.md … 33-capstone.md
├── check-docs-v2.ps1             ← 你原有的结构体检脚本
│
├── scripts/prepare-content.mjs   ← 新增：拷贝 + 注入 front matter（唯一"加工"环节）
├── site/                         ← 新增：Hugo 站点
│   ├── hugo.toml                 ← 站点配置（数学公式、主题、中文）
│   ├── layouts/                  ← 4 个模板（首页/单页/分区/侧边栏）
│   ├── static/css/site.css       ← 样式
│   ├── content/                  ← 【构建产物，不入库】由脚本生成
│   └── public/                   ← 【构建产物，不入库】hugo 输出
├── .github/workflows/pages.yml   ← 新增：GitHub Actions 部署流水线
└── .gitignore                    ← 新增：忽略构建产物
```

**为什么这样设计**：Hugo 需要 front matter（标题、排序）才能生成页面与侧边栏，但你的 md 里没有。直接在源文件里加 front matter 会污染正文、也会和你现有的 MD 阅读习惯冲突。所以让脚本**拷贝一份**到 `site/content/` 再注入——源文件永远干净，`git diff` 里也永远看不到"为了建站而改内容"的噪声。

生成规则（`prepare-content.mjs`）：

| 源 | 站点位置 | 标题取自 | 排序 |
|---|---|---|---|
| `README.md` | `content/_index.md`（**首页**） | 第一个 `# ` 标题 | — |
| `docs/NN-*.md` | `content/docs/NN-*.md` | 首个 `## ` 标题（并从正文里摘掉，避免与页面标题重复） | `weight = NN+1` |
| `_EXPERIMENTS.md` | `content/experiments.md` | 第一个 `# ` 标题 | 100 |
| `_STYLE-GUIDE.md` | `content/style-guide.md` | 第一个 `# ` 标题 | 200 |

顺带做了两处**只作用于副本**的小改写：README 里的 `](_EXPERIMENTS.md)` → `](experiments/)`；模块表里的章号列 `| 12 |` 变成指向该章的链接（判断依据是"第二列不以 `**` 开头"，因此不会误改"变更说明"表里的序号）。

---

## 1. 前置检查

```powershell
cd H:\AI_Study\deepseek_harness\reinforcement-learning-journey
hugo version        # 需要 ≥ 0.146（本例实测 v0.170.0 通过）
node -v             # 需要 ≥ 18（本例 v24.19.0）
git --version
```

若无 Hugo：`choco install hugo`（你机器上已装）或 `winget install Hugo.Hugo`。

---

## 2. 本地生成内容并预览（两条命令）

```powershell
# ① 从源 md 生成 site/content（可反复执行，会先清空重建）
node scripts/prepare-content.mjs

# ② 启动本地预览
hugo server --source site
```

打开 <http://localhost:1313/reinforcement-learning-journey/> 。

> **端口/路径说明**：`site/hugo.toml` 里的 `baseURL` 是 `https://example.github.io/reinforcement-learning-journey/`，所以本地也跟着这个子路径。如果想让本地直接跑在根路径，加一个参数即可：
> `hugo server --source site --baseURL http://localhost:1313/`

**改了 md 之后**：脚本生成的是副本，所以每次改完源 md 都要重跑 `node scripts/prepare-content.mjs`（`hugo server` 会自动热重载新内容）。

---

## 3. 本地构建一次，确认产物无警告

```powershell
hugo --source site --destination public --cleanDestinationDir
```

预期输出（实测）：

```
Pages            │ 39
Static files     │  1        ← css/site.css
Total in 268 ms
```

并逐项检查：

```powershell
# 页数应约 38 个 html
(Get-ChildItem site\public -Recurse -Filter *.html).Count

# 块级公式不应被 <p> 切断（应输出 0）
(Select-String -Path site\public\docs\12-grpo\index.html -Pattern '<p>\$\$' -AllMatches).Matches.Count
```

> 如果第二项不是 0，说明源 md 的 `$$ … $$` 块内部有空行——Hugo 会把公式拆成两段，KaTeX 就渲染不出来。修法：删掉公式块内的空行。

---

## 4. 初始化 git 并提交（当前目录还不是 git 仓库）

```powershell
git init -b main
git add .
git commit -m "docs: 强化学习之旅 34 章 + Hugo 站点与 Pages 部署"
```

**提交前自查**（确认构建产物没被加进去）：

```powershell
git status --short | Select-String 'site/content|site/public'   # 应无输出
```

`.gitignore` 已排除 `site/content/`、`site/public/`、`site/resources/`。

---

## 5. 创建 GitHub 仓库

**方式 A（网页，最省事）**

1. 打开 <https://github.com/new>
2. Repository name 填 `reinforcement-learning-journey`（**必须和你想访问的路径一致**）
3. 选 Public（Pages 对私有库需要付费计划）
4. **不要**勾选 "Add a README file"（保持空仓库，否则首次推送要处理冲突）

**方式 B（命令行）**

```powershell
winget install GitHub.cli      # 你机器上还没装 gh
gh auth login
gh repo create reinforcement-learning-journey --public --source=. --remote=origin --push
```

---

## 6. 关联远端并推送

```powershell
git remote add origin https://github.com/<你的用户名>/reinforcement-learning-journey.git
git push -u origin main
```

---

## 7. 开启 GitHub Pages（关键一步，选错就 404）

在仓库页面：

**Settings → Pages → Build and deployment → Source 选 `GitHub Actions`**

> ⚠️ 不要选 "Deploy from a branch"。本仓库用的是 Actions 流水线（`.github/workflows/pages.yml`），选错源会导致站点一直空白，而 Actions 里显示"成功"。

首次推送后到 **Actions** 标签页看 `构建并部署 Hugo 站点到 GitHub Pages` 这次运行：

- `build` 作业：安装 Node → 生成 `site/content` → 安装 Hugo → 构建 → 上传产物
- `deploy` 作业：发布到 Pages

成功后，`deploy` 作业会打印站点地址：`https://<用户名>.github.io/reinforcement-learning-journey/`

如果推送时 Pages 还没开，去开一下，然后 **Actions → 该 workflow → Run workflow** 手动重跑一次即可。

---

## 8. 访问与验收

打开站点，逐项确认：

| 检查 | 期望 |
|---|---|
| 首页 | 显示 README 的内容，标题为「强化学习之旅 · Reinforcement Learning Journey」 |
| 左侧目录 | 「正文 · 34 章」列出 0–33，**按章号顺序**（不是字典序） |
| 点任一章 | 顶部是章标题（如「1. 多臂老虎机与探索」），正文从"本章回答的问题"开始 |
| 数学 | 行内 $A_{i,t}$ 与块级公式都渲染成排版数学，**不是 `$…$` 原样文本** |
| 表格 | 有边框、能横向滚动，不撑破页面 |
| 章末 | 有「← 上一章 / 下一章 →」 |
| 移动端 | 缩窄浏览器窗口，左上角出现「☰ 目录」按钮 |

---

## 9. 日常更新流程（以后只跑这四步）

```powershell
# 1. 正常编辑你的 md（README.md / docs/*.md）
# 2. 重新生成站点内容（本地预览需要；CI 会自动做）
node scripts/prepare-content.mjs
# 3. 本地看一眼
hugo server --source site
# 4. 提交推送，Actions 自动部署
git add .
git commit -m "docs: 修订第 12 章"
git push
```

页面通常在 1 分钟内更新（首次部署后 CDN 可能有几分钟缓存）。

---

## 10. 需要你改的两处个性化配置

| 位置 | 现状（占位值） | 改成 |
|---|---|---|
| `site/hugo.toml` → `baseURL` | `https://example.github.io/reinforcement-learning-journey/` | 你的实际地址。**CI 构建时会用 `configure-pages` 自动覆盖**，所以只有"本地构建产物要直接上传"时才必须改 |
| `site/hugo.toml` → `params.repoURL` | `https://github.com/CuriMind/reinforcement-learning-journey` | 你的仓库地址（侧边栏底部「GitHub 仓库 ↗」） |

另外两个可选调整：

- **站点名**：`title = "强化学习之旅"`
- **样式**：改 `site/static/css/site.css`（纯 CSS，无预处理器，不需要 Hugo extended）

---

## 11. 故障排查

| 症状 | 原因 | 处理 |
|---|---|---|
| 页面 404，Actions 全绿 | Pages 的 Source 选成了 "Deploy from a branch" | 改选 `GitHub Actions` 后重跑 workflow |
| 站点能开但没样式 | `site/static/css/site.css` 没被提交 | `git ls-files site/static` 确认；若缺失则 `git add -f site/static` |
| 公式显示成 `$…$` 原文 | KaTeX CDN 被墙，或 `passthrough` 没生效 | 打开 DevTools 看 `katex` 的 JS 是否 404；本地可换 CDN 或改成本地 KaTeX |
| 公式一半渲染一半原文 | `$$ … $$` 块内有空行被 Hugo 拆段 | 删掉块内空行后重跑脚本 |
| 侧边栏空白 | `site/content/docs/` 没生成 | 忘了跑 `node scripts/prepare-content.mjs` |
| 章节顺序是乱的（0,1,10,11…） | `weight` 没注入 | 确认 `site/content/docs/*.md` 头部有 `weight:` |
| 本地正常、线上链接全 404 | 本地用占位 `baseURL` 构建后直接上传了 `public/` | 线上必须让 CI 构建（它会注入真实 baseURL） |
| Actions 报 `prepare-content.mjs` 找不到 | 工作流在仓库根运行，脚本路径对；若你挪了目录需同步改 `pages.yml` | — |

---

## 12. 这套方案的两个代价（如实说明）

1. **`site/content/` 是生成物，不能手改**。想在站点里调整标题或加 front matter，要改 `prepare-content.mjs` 的规则，而不是改生成出来的文件——否则下次生成就被覆盖。
2. **KaTeX 走 CDN**（jsDelivr）。离线预览时公式不会渲染，页面会显示 `$…$` 原文；要彻底离线，需要把 KaTeX 的 CSS/JS/字体下载到 `site/static/` 并改 `baseof.html` 的引用。GitHub Pages 在线访问不受影响。

---

## 附：核心命令速查

```powershell
node scripts/prepare-content.mjs                                  # 生成内容
hugo server --source site                                         # 本地预览 :1313
hugo --source site --destination public --cleanDestinationDir     # 本地构建
git push                                                          # 触发线上部署
```
