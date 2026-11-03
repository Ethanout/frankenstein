# FCP 0 — 提案索引

```text
FCP: 0
Title: 提案索引
Author: 待署名
Status: Active
Type: Informational
Created: 18-Oct-2026
```

## 摘要

FCP（Frankenstein Convention Proposals，Frankenstein 约定提案）是一组供 Frankenstein 项目及自愿采用的项目使用的开发约定提案，采用类似 Python PEP 的编号、文档头和修订流程。

当前提案主要面向 MCFunction 与 Beet/Bolt 项目，游戏版本基线为 Minecraft Java 1.16+。后续可按主题加入构建器、网页等开发约定。

每篇提案讨论一个主题。文档状态表示讨论进度，条文中的“必须、应该、可以”表示要求强度，定义见 [FCP 1](fcp-0001-process.md)。

## 提案目录

| 编号 | 标题 | 类型 | 状态 |
| --- | --- | --- | --- |
| 0 | 提案索引 | Informational | Active |
| [1](fcp-0001-process.md) | 提案流程与规范用语 | Process | Draft |
| [2](fcp-0002-naming.md) | 名称、命名空间与函数路径 | Standards Track | Draft |
| [3](fcp-0003-fields-storage.md) | 字段与存储布局 | Standards Track | Draft |
| [4](fcp-0004-function-contracts.md) | 函数接口与头文档 | Standards Track | Draft |
| [5](fcp-0005-variable-lifetimes.md) | 临时变量与调用边界 | Standards Track | Draft |
| [6](fcp-0006-special-names.md) | 特殊名称与可见性 | Standards Track | Draft |
| [7](fcp-0007-source-dialects.md) | 源码方言与版本 | Informational | Draft |
| [9](fcp-0009-frank-expressions.md) | frank 在函数文档中的使用 | Standards Track | Draft |

FCP 0 持续维护索引。其余提案目前处于草案阶段。

## 阅读顺序

了解整体约定时，先读 FCP 1，再依次读 FCP 2—6。不熟悉的术语可查阅[核心概念](../core-concepts.md)，各章末尾也提供相关概念链接。查找具体规则时，按主题直接阅读。涉及扩展语法和游戏版本时，查阅 FCP 7。

需要编写伪代码时，建议优先使用 frank。语言本身见 [frank 文档表达式](../frank/quickstart.md)，在函数头文档中的使用见 FCP 9；形式化检查按需选用，不是文档的必备内容。

## 编号与引用

标题使用“FCP 3”，文件名使用四位编号，如 `fcp-0003-fields-storage.md`。条款使用 `FCP-0003-R09` 这样的编号，便于引用。编号不表示优先级，初版草案可随结构调整编号。

新提案从[模板](proposal-template.md)开始。

## 参考资料

- [PEP 0 — Index of Python Enhancement Proposals](https://peps.python.org/pep-0000/)
- [PEP 1 — PEP Purpose and Guidelines](https://peps.python.org/pep-0001/)
