# 资源包项目模板

复制到 `projects/<项目名>/`，修改项目 ID，并按目标 Minecraft 版本填写
`resourcepack/pack.mcmeta`。

- `resourcepack/assets/<namespace>/`：纹理、模型、字体和声音等资源。
- `resourcepack/assets/minecraft/`：需要覆盖的原版资源。
- `docs/`、`tests/`：项目说明和加载验证。

`resourcepack/` 是资源包根目录。`project.json` 的目标只声明要使用的组件，
当前没有自动打包命令。
