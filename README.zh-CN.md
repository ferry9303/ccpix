# ccpix

[English](README.md) | **中文**

在终端里查看 **Claude Code** 会话记录里的图片。

`cc`（Claude Code）+ `pix`（pictures）。Claude Code 会把你粘贴/上传的每一张图（以及它读取或生成的图）以 base64 形式存进**会话 transcript**：

```
<claude-config>/projects/<project>/<session-id>.jsonl
```

磁盘上的图片缓存（`~/.claude/image-cache/<id>/`）是**临时的**——Claude 会清理它，旧图随时消失。而 transcript 把所有图都留着。`ccpix` 直接从 transcript 里把图片提取出来并内联显示，于是你可以翻看任意历史会话里的图。

## 安装

```sh
brew tap ferry9303/ccpix https://github.com/ferry9303/ccpix
brew install ccpix
```

不等正式 release，直接装 `main` 最新版：

```sh
brew install --HEAD ferry9303/ccpix/ccpix
```

`chafa`（推荐依赖）是让 iTerm2 之外的终端也能内联显示图片的关键。

### 不用 Homebrew

它就是一个零依赖的单文件 Python 3 脚本：

```sh
curl -fsSL https://raw.githubusercontent.com/ferry9303/ccpix/main/ccpix \
  -o ~/.local/bin/ccpix && chmod +x ~/.local/bin/ccpix
```

（或者 clone 下来跑 `./install.sh`。）

## 用法

```sh
ccpix                  # 列出包含图片的会话（id · 张数 · 第一句话）
ccpix 9f3a             # 查看 id 以 9f3a 开头的会话里的全部图
ccpix 9f3a -o          # 用系统图片查看器打开（macOS 上是「预览」）
ccpix 9f3a -w 60%      # 设置宽度（仅 imgcat 后端；如 60% / 600px / auto）
ccpix 9f3a -b chafa    # 强制指定显示后端
```

会话 id 是**前缀**——几个字符就够。不带参数运行 `ccpix` 就能看到所有 id：

```text
$ ccpix
9f3a1c20-...   12 imgs  redesign the onboarding flow
2b7e44a1-...    3 imgs  why does the build fail on CI
0c9d8f55-...    1 img   crop this logo to a square
```

提取出的图片写到 `$TMPDIR/ccpix-<id>/`（按出现顺序编号、已去重），想留着就从那里 `cp` 出来。

### 用假数据试一下（不碰任何真实数据）

仓库自带一份合成的 demo 配置（由 `examples/make-demo.py` 生成——图片是现场画的，没有任何真实内容）：

```sh
CLAUDE_CONFIG_DIR=examples/demo-claude ccpix              # 列出一个假会话，3 张图
CLAUDE_CONFIG_DIR=examples/demo-claude ccpix 0a1b         # 显示生成的 3 张图
```

## 显示后端

`ccpix` 会自动探测在你的终端里用哪种方式画图：

| 后端     | 何时使用                          | 协议                          |
| -------- | --------------------------------- | ----------------------------- |
| `imgcat` | 在 iTerm2 里（且 `imgcat` 存在）  | iTerm2 内联图协议             |
| `chafa`  | 其它装了 `chafa` 的终端           | 自动：Kitty / Sixel / iTerm2  |
| `kitten` | 装了 `kitten`（kitty）            | Kitty graphics                |
| `open`   | 以上都没有                        | 系统图片查看器                |

`chafa` 最通用——它自己探测终端并选对图形协议（Ghostty/kitty 用 Kitty graphics、其它用 Sixel，再不行降级为彩色字符块）。用 `-b` 或 `CCPIX_BACKEND=chafa` 覆盖自动探测。

## 原理

- 读取 `$CLAUDE_CONFIG_DIR/projects/*/*.jsonl`（默认 `~/.claude`）。
- 递归扫描每行 transcript 里的 `{"type":"image","source":{"type":"base64",…}}`——既包含你粘贴/上传的图，**也包含** tool result 里的图（比如 Claude `Read` 过的文件）。
- 按内容哈希去重（同一张图常在会话上下文里出现很多次），解码成真实文件。

## 环境要求

- **Python 3.9+**（仅标准库——无需 pip 包）
- **macOS 或 Linux**（`open` 在 Linux 回退到 `xdg-open`；Windows 用 `start`）
- 内联显示需要支持图形的终端（iTerm2、Kitty、Ghostty、WezTerm，或任意支持 Sixel 的终端）。否则用 `-o` 在查看器里打开。

## 发布（维护者）

1. 打 tag 并 push：
   ```sh
   git tag v0.1.0 && git push origin v0.1.0
   ```
2. 算 tarball 的 sha256，填进 `Formula/ccpix.rb`：
   ```sh
   curl -fsSL https://github.com/ferry9303/ccpix/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
   ```
3. 提交 formula。此后 `brew install ferry9303/ccpix/ccpix` 即装稳定版。

## 许可证

MIT
