#!/usr/bin/env bash
set -u

# Managed by kosje/VPS-Tools
run_remote_script() {
  local title="$1"
  local url="$2"
  local tmp rc

  if ! command -v curl >/dev/null 2>&1; then
    printf '错误：需要先安装 curl。\n' >&2
    return 127
  fi

  tmp="$(mktemp "${TMPDIR:-/tmp}/box-tool.XXXXXX")" || return 1
  printf '\n正在下载：%s\n来源：%s\n' "$title" "$url"
  if ! curl --fail --location --silent --show-error --connect-timeout 15 --max-time 600 "$url" -o "$tmp"; then
    printf '下载失败，未运行该脚本。\n' >&2
    rm -f -- "$tmp"
    return 1
  fi
  if [[ ! -s "$tmp" ]]; then
    printf '错误：下载内容为空，未运行该脚本。\n' >&2
    rm -f -- "$tmp"
    return 1
  fi

  printf '即将以当前用户权限运行远程脚本。若此工具需要管理员权限，请退出后使用 sudo box。\n\n'
  bash "$tmp"
  rc=$?
  rm -f -- "$tmp"
  return "$rc"
}

run_uninstaller() {
  local url='https://raw.githubusercontent.com/kosje/VPS-Tools/main/uninstall.sh'
  local answer tmp rc

  printf '\n此操作会删除 VPS-Tools 菜单命令 /usr/local/bin/box；不会卸载通过菜单运行的第三方软件。\n'
  read -r -p '确认彻底卸载？[y/N]: ' answer || return 1
  case "$answer" in
    [yY]|[yY][eE][sS]) ;;
    *) printf '已取消卸载。\n'; return 1 ;;
  esac

  if ! command -v curl >/dev/null 2>&1; then
    printf '错误：需要先安装 curl。\n' >&2
    return 1
  fi

  tmp="$(mktemp "${TMPDIR:-/tmp}/box-uninstall.XXXXXX")" || return 1
  printf '\n正在获取卸载程序……\n'
  if ! curl --fail --location --silent --show-error --connect-timeout 15 --max-time 120 "$url" -o "$tmp"; then
    printf '卸载程序下载失败，未作更改。\n' >&2
    rm -f -- "$tmp"
    return 1
  fi
  if [[ ! -s "$tmp" ]] || ! bash -n "$tmp"; then
    printf '错误：卸载程序为空或语法检查失败，未作更改。\n' >&2
    rm -f -- "$tmp"
    return 1
  fi

  if (( EUID == 0 )); then
    bash "$tmp"
    rc=$?
  elif command -v sudo >/dev/null 2>&1; then
    sudo bash "$tmp"
    rc=$?
  else
    printf '错误：卸载需要 root 权限；请安装 sudo，或使用 sudo box 后重试。\n' >&2
    rc=1
  fi
  rm -f -- "$tmp"
  return "$rc"
}

show_menu() {
  cat <<'MENU'

╭──────────────────────────────────────────────╮
│                 VPS 工具箱                   │
├──────────────────────────────────────────────┤
│  1) VPS 工具箱（ssh_tool.eooce.com）         │
│  2) SSH/TCP 调优与加固                       │
│  3) NodeQuality 测试                         │
│  4) TcpQuality 测试                          │
│  5) AnyTLS-Go 一键部署                       │
│  6) 彻底卸载 VPS-Tools                       │
│  0) 退出                                     │
╰──────────────────────────────────────────────╯
MENU
}

while true; do
  show_menu
  read -r -p '请选择 [0-6]: ' choice || exit 0
  case "$choice" in
    1) run_remote_script 'VPS 工具箱' 'https://ssh_tool.eooce.com' ;;
    2) run_remote_script 'SSH/TCP 调优与加固' 'https://raw.githubusercontent.com/chnnic/SSH-Hardening/refs/heads/main/SSH-Hardening.sh' ;;
    3) run_remote_script 'NodeQuality 测试' 'https://run.NodeQuality.com' ;;
    4) run_remote_script 'TcpQuality 测试' 'https://raw.githubusercontent.com/ibsgss/TcpQuality/main/runTcpQuality.sh' ;;
    5) run_remote_script 'AnyTLS-Go 一键部署' 'https://raw.githubusercontent.com/kosje/anytls-go/refs/heads/main/installer.sh' ;;
    6) run_uninstaller && exit 0 ;;
    0) printf '已退出 VPS 工具箱。\n'; exit 0 ;;
    *) printf '无效选项，请输入 0 到 6。\n' ;;
  esac
  result=$?
  if [[ "$choice" =~ ^[1-5]$ ]]; then
    printf '\n工具退出状态：%s\n' "$result"
    read -r -p '按回车返回菜单（Ctrl+C 退出）...' _ || exit 0
  fi
done
