# First Person Hand Models 26.2

这是 `JNNGL/vanilla-shaders` 的独立移植实验目录。26.2 已将旧的
`entity_translucent` 管线合并为 `core/entity.vsh/fsh`，所以本目录覆盖的是
统一 entity 管线，可能影响所有实体渲染。

## 第一人称检测 trick

原包没有读取一个明确的“第一人称”标志，而是利用 vanilla 在第一人称手持
物品渲染时留下的 uniform 状态：

```glsl
FogStart > 3e38 && ProjMat[2][3] != 0
```

满足时才把模型 UV 重映射到玩家皮肤的手臂区域。`FogStart` 的超大值来自
第一人称物品的无雾设置，投影矩阵条件用于排除 GUI/正交渲染。这是经验性
判据，不是 Mojang API；第三方渲染器或未来快照可能改变它。

`isSlim()` 通过采样皮肤 `(54,20)`、`(55,20)` 判断 Alex 手臂，随后按六个面
选择 Steve/Alex 的 UV。模型尺寸保护仍由物品模型的 first-person scale
(`0.471, 0.515, 1.515`) 提供；移植时不要删掉该保护，否则会污染普通实体。

## 26.2 风险

- 26.2 的 shader 文件接口和宏集合与 1.21.x 不同，必须在 26.2 客户端实际
  加载验证；本目录是可审查的移植基线，不宣称跨版本兼容。
- 覆盖 `core/entity.*` 会影响透明、发光、溶解等 entity 变体。生产版本应
  根据 26.2 的渲染定义拆分专用变体，或改用 Fabric/Iris 提供的相机宏。
- 资源包只能检测“像第一人称”的 uniform 组合，无法可靠区分旁观者、镜像
  手和自定义相机。

## 来源

上游：<https://github.com/JNNGL/vanilla-shaders/tree/main/first_person_hand_models>
原始文件保留在同级 `first_person_hand_models` 目录，便于逐行比较。
