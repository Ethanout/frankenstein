# 数据包项目模板

复制到 `projects/<项目名>/`，修改 `project.json` 的 ID 和 `datapack/beet.json`
中的包名称，填写命名空间与支持的 Minecraft 版本。

- `datapack/src/data/<namespace>/`：数据包和 Bolt 源码。
- `datapack/beet.json`：该组件的 Beet 构建配置。
- `docs/`、`tests/`：项目说明和测试。

安装 Beet/Bolt 依赖后，从复制后的项目根目录进入 `datapack/`，运行 `beet build`。
输出位于 `datapack/build/`。`project.json` 不会自动调用 Beet。

需要资源包或源地图时，在同一项目内增加对应组件和目标，不必另建项目。
