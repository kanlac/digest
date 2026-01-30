# Digest — 高质量信息摘要简报

从本地信息源中自动提取有启发性的观点，生成每日简报。

## 使用方式

### 手动生成

```bash
./scripts/generate.sh
```

简报输出到 `output/YYYY-MM-DD.md`。

### 自动生成

推送到 GitHub 后，GitHub Actions 每天北京时间 8:00 自动生成简报并 commit。需要在仓库 Settings → Secrets 中配置 `ANTHROPIC_API_KEY`。

## 配置信息源

编辑 `sources.yaml` 添加或修改信息源。

## 自定义提取规则

编辑 `prompts/digest.md` 调整 Agent 的提取标准和输出格式。
