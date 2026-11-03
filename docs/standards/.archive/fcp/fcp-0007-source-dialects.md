# FCP 7 — 源码方言与版本

```text
FCP: 7
Title: 源码方言与版本
Author: 待署名
Status: Draft
Type: Informational
Created: 18-Oct-2026
Minecraft-Version: 1.15+
Requires: 1
```

## 摘要

本文说明规范中的示例记法、原版命令与 Beet/Bolt 源码的区别，并列出常用功能的版本条件。

## 动机

参考项目同时使用原版形式的命令和构建期扩展语法。区分源码方言与运行版本，可以让示例和构建步骤更容易使用。

## 游戏版本

本系列中 Minecraft 数据包相关提案的游戏版本基线为 **Minecraft Java 1.15+**。涉及特定功能时，按该功能的引入版本使用。

| 功能 | 版本 |
| --- | --- |
| 命令 storage | 1.15 起 |
| 函数宏、`return` 命令 | 1.20.2 起 |
| 数据包函数目录 `functions/` 改为 `function/` | 1.21 起 |
| 函数标签目录 `tags/functions/` 改为 `tags/function/` | 1.21 起 |

FCP 2 中的函数资源位置不包含磁盘目录前缀。项目根据目标版本选择目录名和 `pack_format`。

## 文档约定

**FCP-0007-R01 · 应该：** 示例说明使用的是原版命令、Bolt 源码还是逻辑记法。

本规范使用以下代码块：

| 标记 | 内容 |
| --- | --- |
| `mcfunction` | 原版命令片段，前提写在示例附近 |
| `text` | 数据位置、路径、接口模板或调用关系 |
| `frank` | 按 FCP 9 解释的表达式与检查条件 |
| `python` 等语言标记 | 对应语言的构建脚本或源码 |

`score @s test` 表示记分板位置；`storage demo:test ins[0]` 表示 NBT 位置。`<namespace>` 等尖括号内容是占位符。

frank 表达式使用 `score(@s test)` 等写法，语法及检查范围见 [FCP 9](fcp-0009-frank-expressions.md)。

相关概念：[逻辑记法](../core-concepts.md#逻辑记法)、[frank 表达式](../core-concepts.md#frank-表达式)。

## 源码与构建

**FCP-0007-R02 · 应该：** 项目记录目标游戏版本、构建入口、工具依赖和可复现的构建步骤。

**FCP-0007-R03 · 不应：** 将含扩展语法的 `.mcfunction` 源码直接标为原版命令示例。

**FCP-0007-R04 · 应该：** 分别说明手写源码与生成结果的命名约束。生成结果由构建工具管理。

## 项目实例

| 参考项目 | 源码写法 |
| --- | --- |
| GameCore `data/modify.mcfunction` | 原版形式的 storage、function 调用和接口标签 |
| GameCore `__load__.mcfunction` | `uuid(...)`、跨行书写等构建期写法 |
| MinerGame `item/--main.mcfunction` | 导入、行内函数定义和相对路径 |
| MinerGame `item/set_callbacks.mcfunction` | 构建期对象、资源生成声明和运行期宏 |
| MinerGame `modules/generic.bolt` | Bolt 函数、导入和命令拼接 |

读取时，两个项目的顶层 Spyglass 配置分别使用 1.21.5 和 1.21.11。文件位置见[来源记录](sources.md)。

## 设计理由

扩展名可以帮助识别文件用途，具体语法由工具链决定。手写源码按维护需要组织，生成路径按构建规则组织；两者可以采用不同的目录深度。
