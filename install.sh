#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
  printf '请以 root 运行安装器，例如：curl -fsSL https://raw.githubusercontent.com/kosje/VPS-Tools/main/install.sh | sudo bash\n' >&2
  exit 1
fi

command -v curl >/dev/null 2>&1 || { printf '错误：请先安装 curl。\n' >&2; exit 1; }

url='https://raw.githubusercontent.com/kosje/VPS-Tools/main/box.sh'
dest='/usr/local/bin/box'
tmp="$(mktemp "${TMPDIR:-/tmp}/box-install.XXXXXX")"
trap 'rm -f -- "$tmp"' EXIT

printf '正在获取 VPS 工具菜单……\n'
curl --fail --location --silent --show-error --connect-timeout 15 --max-time 120 "$url" -o "$tmp"
[[ -s "$tmp" ]] || { printf '错误：下载内容为空。\n' >&2; exit 1; }
bash -n "$tmp"
install -D -m 0755 "$tmp" "$dest"
printf '安装完成：%s\n现在输入 box 即可打开菜单；重新运行此安装命令可更新。\n' "$dest"
