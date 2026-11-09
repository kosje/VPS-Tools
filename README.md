# VPS-Tools

一个轻量的交互式 VPS 菜单。安装后，在 VPS 终端输入 `box` 即可选择运行常用工具；命令安装在 `/usr/local/bin/box`，重启和重新登录后仍可用。

## 一键安装

在 VPS 上以有 sudo 权限的账号运行：

```bash
curl -fsSL https://raw.githubusercontent.com/kosje/VPS-Tools/main/install.sh | sudo bash
```

然后运行：

```bash
box
```

如果当前已经是 root，安装时可去掉管道中的 `sudo`。重新运行一键安装命令会更新菜单。

## 菜单项目

1. **VPS 工具箱**：`https://ssh_tool.eooce.com`
2. **SSH/TCP 调优与加固**：`chnnic/SSH-Hardening`
3. **NodeQuality 测试**：`https://run.NodeQuality.com`
4. **TcpQuality 测试**：`ibsgss/TcpQuality`
5. **AnyTLS-Go 部署**：`kosje/anytls-go`

菜单只在你选择对应项目后才下载并运行其脚本。下载文件使用临时文件，执行后会删除。

## 安全提示

这些入口会运行第三方或远程维护的 Bash 脚本；远端内容可能随时变化，脚本也可能安装软件、修改系统配置或需要 root 权限。请只运行你信任的项目，并在重要 VPS 上先备份、确认有云厂商控制台或其他恢复方式。SSH 加固/调优可能影响 SSH 或网络连接，勿在没有备用访问方式时贸然执行。菜单不会自动提权；若工具明确要求管理员权限，可在 VPS 上用 `sudo box` 打开菜单后再选择。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/kosje/VPS-Tools/main/uninstall.sh | sudo bash
```

卸载器只删除 VPS-Tools 安装的 `/usr/local/bin/box`。本项目没有其他持久化文件、配置或服务；菜单启动的第三方脚本可能安装软件或修改系统，这些内容需使用对应项目的卸载方式清理。

菜单脚本位于本仓库的 `box.sh`，安装器位于 `install.sh`。
