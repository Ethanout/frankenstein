# 项目模板

选择一个模板，复制到 `projects/<项目名>/`，再修改项目 ID 和内容。
模板类型只用于选择起点，不构成实际项目的目录分类。

| 模板 | 起始内容 |
| --- | --- |
| [datapack](datapack/README.md) | Beet/Bolt 数据包 |
| [resourcepack](resourcepack/README.md) | 普通资源包 |
| [shaderpack](shaderpack/README.md) | 原版着色器资源包 |
| [combined](combined/README.md) | 同时开发的数据包、资源包和源地图 |
| [web](web/README.md) | 无框架依赖的静态网页，可替换为前端应用 |

复制后填写项目说明、技术栈、运行环境和使用方式。Minecraft 组件还需填写命名空间
和兼容版本；资源包 `pack.mcmeta` 中的格式号是示例值，必须按目标版本检查并修改。

这些模板只提供起点，不限制组件类型。网页可以独立成项目，也可以加入现有项目；
后一种情况只需增加 `web/`、组件声明和对应目标。前端框架与包管理器按项目需要选择。

`project.json` 记录组件路径和目标组合，统一构建器尚未实现。
模板不是可直接发布的成品；源地图、素材、构建处理和测试需要按项目补充。

清单约定见 [project-manifest.md](../docs/conventions/project-manifest.md)。
