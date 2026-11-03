# Frankenstein

多项目工作区，可容纳 Minecraft 数据包、资源包、地图，以及网页、服务和工具。
同一项目共同维护的内容放在 `projects/<项目名>/` 中，可按不同目标独立构建和发布。
工作区保留 Beet/Bolt 构建模板，各项目可以选择自己的技术栈。

## 当前内容

- [手部模型项目](projects/hand-models/README.md)：原始参考资源包与 26.2 移植实验。
- [历史 pow 实现](archive/pow-implementation-2026-08-27/README.md)：历史实现及研究资料。
- [项目模板](templates/README.md)：数据包、资源包、着色器、组合项目和网页。

目录职责见 [PROJECT_LAYOUT.md](PROJECT_LAYOUT.md)，
项目清单约定见 [project-manifest.md](docs/conventions/project-manifest.md)。
项目开发约定见 [FCP 提案索引](docs/standards/fcp/fcp-0000-index.md)，按 PEP 形式维护；
待讨论的规则和已确认的决定见 [问题与答复](docs/standards/fcp/questions.md)。

用于辅助文档编写的 frank 写法见 [frank 文档表达式](docs/standards/frank/quickstart.md)。

## 构建入口

安装 `beet`、`bolt` 和 `bolt-expressions` 后，在根目录运行：

```powershell
beet build
```

该命令只处理根 `beet.json` 指定的 `src/`，输出到 `build/`。
根 `src/` 当前仅有占位用的 `pack.mcmeta`。根构建和现有 CI 均不会自动构建
子项目，也不会读取新增的 `project.json`；统一构建器尚未实现。

子项目按各自说明使用。26.2 着色器实验的客户端验证步骤见
[migration-notes.md](projects/hand-models/resourcepack/first_person_hand_models_26.2/migration-notes.md)。

## 新增项目

从 `templates/` 选择模板，复制到 `projects/<项目名>/`，修改 `project.json`
中的项目 ID、组件路径和目标组合，并填写技术栈、运行环境和使用步骤。
Minecraft 组件还需记录支持的游戏版本与命名空间。
项目可以只包含网页，也可以同时包含数据包、资源包、源地图和配套网页。

网页可从 [web 模板](templates/web/README.md) 起步。模板不依赖前端框架；
采用框架后，在所属组件内保存依赖清单、锁文件和配置，不要求其他项目使用相同工具链。

项目专用源码、工具、测试和文档随项目保存。多个项目确实需要复用的模块放入
`packages/`，工作区构建工具放入 `build_tools/`。
