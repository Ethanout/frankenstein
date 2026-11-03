# 原版着色器项目模板

复制到 `projects/<项目名>/`，修改项目 ID，并按目标 Minecraft 版本填写
`resourcepack/pack.mcmeta`。着色器作为资源包的一部分开发。

- `resourcepack/assets/minecraft/shaders/core/`：按目标版本接口编写的着色器。
- `resourcepack/assets/minecraft/shaders/include/`：着色器引用文件。
- `resourcepack/assets/minecraft/textures/`：着色器所用纹理。
- `materials/`：可选的材质设计资料，不直接加入资源包。
- `scripts/`、`tests/`、`docs/`：项目专用工具、验证和说明。

`resourcepack/` 是资源包根目录。`project.json` 不会自动生成或验证着色器；
需要在目标客户端执行资源重载并检查渲染效果。
