# 手部模型

第一人称手部模型资源包及 Minecraft 26.2 移植实验。

- [26.2 移植实验](resourcepack/first_person_hand_models_26.2/README.md)：当前项目清单选择的资源包来源。
- [客户端验证步骤](resourcepack/first_person_hand_models_26.2/migration-notes.md)。
- 原始参考包位于 `resourcepack/first_person_hand_models/`，与移植版相邻，供比较使用。

两个资源包目录都包含各自的 `pack.mcmeta` 和 `assets/`。使用移植版时，以
`resourcepack/first_person_hand_models_26.2/` 为资源包根目录；
`resourcepack/` 本身只是变体分组目录。

`project.json` 的 `resourcepack` 目标只声明 26.2 移植版，未包含原始参考包。
统一构建器尚未实现；根 `beet build` 不会打包或验证本项目。
兼容性限制以移植实验说明为准，仍需在目标客户端验证。
