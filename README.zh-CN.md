# read-repo

[English](./README.md) · [简体中文](./README.zh-CN.md)

> 一个 Copilot CLI 技能，深度分析本地代码仓库并生成结构化文档 —— 帮助你快速读懂陌生项目。

## 功能

安装此技能后，你的 Copilot CLI 智能体可以：

- 🔍 **分析**任意本地代码库 —— 技术栈、语言、架构、目录职责、核心模式
- 📝 **生成**可直接提交的 Markdown 文档：`READREPO.md`、`ARCHITECTURE.md`、`TECH-STACK.md`、`FOLDER-GUIDE.md`、`ONBOARDING.md`
- 🗺️ **映射**每个目录的职责
- 💡 **挖掘**不易察觉的架构决策与核心洞察

## 安装

```bash
npx skills add T3QC0LU/read-repo
```

安装完成后，下次启动 Copilot CLI 时技能会自动加载。

## 使用方式

直接用自然语言与智能体对话即可：

```
analyze this repo
read this codebase and generate docs
what does this project do?
generate READREPO.md for this project
explain the architecture of ~/work/my-app
```

## 输出

技能始终生成以下内容：

| 输出 | 说明 |
|---|---|
| **摘要卡片** | 内联 ≤15 行概览：技术栈、架构模式、项目目的 |
| **READREPO.md** | 始终生成 —— 完整的项目 README 风格分析文档 |
| **ARCHITECTURE.md** | 针对非平凡结构生成 |
| **TECH-STACK.md** | 针对多语言或复杂依赖树生成 |
| **FOLDER-GUIDE.md** | 针对大型源码树（8+ 顶层目录）生成 |
| **ONBOARDING.md** | 检测到环境配置步骤或环境变量时生成 |

## 分析模式

技能根据你的意图选择不同的分析视角：

| 模式 | 触发词 | 侧重点 |
|---|---|---|
| `learn` | "理解"、"学习"、"这是什么"（默认） | 数据流、阅读路径、核心概念 |
| `takeover` | "接手"、"我是新成员"、"继承" | 模块职责、隐性决策、常见坑 |
| `hack` | "贡献"、"扩展"、"fork"、"修改" | 扩展点、硬编码位置、测试覆盖 |

## 目录结构

```
read-repo/
├── CONTEXT.md      # 术语表与设计决策
├── SKILL.md        # 智能体指令
├── REFERENCE.md    # 文档模板
├── docs/
│   └── adr/        # 架构决策记录 (ADR)
└── scripts/
    └── scan.sh     # 机械式仓库扫描脚本 (bash)
```

## 环境要求

- GitHub Copilot CLI
- `bash`、`find`（macOS/Linux 标准工具）
- `tree`（可选，改善目录输出 —— `brew install tree`）

## License

MIT
