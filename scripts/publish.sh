#!/usr/bin/env bash
# 将私有 vault 的 public/ 目录同步到公开站点的 content/，并提交推送。
# 用法：
#   ./scripts/publish.sh                # 同步并自动提交推送
#   ./scripts/publish.sh "更新说明"     # 自定义提交信息
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VAULT_DIR="$SITE_DIR/../obsidian-vault"
SRC="$VAULT_DIR/public"
DST="$SITE_DIR/content"

if [ ! -d "$SRC" ]; then
  echo "错误：找不到待发布目录 $SRC"
  exit 1
fi

echo "==> 同步 $SRC -> $DST"
rsync -a --delete \
  --exclude='.DS_Store' \
  --exclude='.obsidian' \
  "$SRC/" "$DST/"

cd "$SITE_DIR"

if [ -z "$(git status --porcelain content)" ]; then
  echo "content/ 无变化，无需提交"
  exit 0
fi

MSG="${1:-sync published notes $(date '+%Y-%m-%d %H:%M')}"
git add content
git commit -m "$MSG"
git push
echo "==> 已提交并推送：$MSG"
