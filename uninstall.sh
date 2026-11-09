#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
  printf '请以 root 运行卸载器，例如：curl -fsSL https://raw.githubusercontent.com/kosje/VPS-Tools/main/uninstall.sh | sudo bash\n' >&2
  exit 1
fi

dest='/usr/local/bin/box'

if [[ ! -e "$dest" && ! -L "$dest" ]]; then
  printf '未发现 VPS-Tools 菜单；无需清理。\n'
  exit 0
fi

if [[ -L "$dest" || ! -f "$dest" ]]; then
  printf '错误：%s 不是 VPS-Tools 安装器创建的普通文件；为避免误删，未作更改。\n' "$dest" >&2
  exit 1
fi

# 新版本写入明确标记；同时兼容此前安装的 VPS-Tools 菜单。
if ! grep -Fq '# Managed by kosje/VPS-Tools' "$dest"; then
  if ! grep -Fq 'run_remote_script()' "$dest" \
    || ! grep -Fq 'raw.githubusercontent.com/kosje/anytls-go/refs/heads/main/installer.sh' "$dest"; then
    printf '错误：%s 不像 VPS-Tools 菜单；为避免误删，未作更改。\n' "$dest" >&2
    exit 1
  fi
fi

rm -- "$dest"
if [[ -e "$dest" || -L "$dest" ]]; then
  printf '错误：无法删除 %s。\n' "$dest" >&2
  exit 1
fi

printf '已卸载 VPS-Tools：%s 已删除。项目自身没有其他持久化文件、配置或服务。\n' "$dest"
printf '注意：通过菜单运行的第三方安装脚本可能另外安装软件或修改系统；这些内容不会由本卸载器删除。\n'
