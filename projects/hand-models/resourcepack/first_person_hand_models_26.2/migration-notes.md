# 26.2 migration notes

26.2 client.jar 中存在 `assets/minecraft/shaders/core/entity.vsh` 和
`entity.fsh`，不存在 `entity_translucent.*` 或旧版 pipeline JSON。移植版
因此复制 26.2 的输入/输出接口，并在 `texCoord0` 生成后插入手臂 UV remap。

验证顺序：

1. 仅加载原版 entity shader，确认客户端资源重载无 GLSL 编译错误。
2. 在第一人称、第三人称、GUI、旁观者分别截图，检查判据触发范围。
3. 用 Steve/Alex 皮肤和左右手模型检查 UV 面方向。
4. 再测试透明实体、发光实体和带 overlay 的实体，确认几何保护没有误触发。

如果 26.2 后续快照改变 `FogStart` 或 `ProjMat`，应优先更新检测宏，而不是
修改模型 JSON。
