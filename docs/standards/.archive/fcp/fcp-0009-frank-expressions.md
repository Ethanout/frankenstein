# FCP 9 — frank 在函数文档中的使用

```text
FCP: 9
Title: frank 在函数文档中的使用
Author: 待署名
Status: Draft
Type: Standards Track
Created: 18-Oct-2026
Requires: 1, 4
```

## 摘要

本文约定 frank 在 MCFunction 头文档中的使用方式。frank 用统一、简洁的伪代码辅助文档编写，首先供人阅读，需要时再交给工具检查。具体写法独立维护于 [frank 文档表达式](../frank/quickstart.md)。

## 动机

表达式写法与头文档格式分开维护。本文说明如何把表达式用于头文档，以及调用前后的数据如何解释；具体写法按文档编写需要独立说明。

## 规范

### 采用范围

按 [FCP 4](fcp-0004-function-contracts.md) R02、R12 最小化文档：通常只写说明或 `@usage`，参数较多时可补充 `@input`、`@output`。需要编写伪代码时，建议优先使用 frank。

frank 以人的阅读和编写体验为先。使用它不要求启用形式化检查；仅在内容难以说清或确有必要检查时，才建议补充可检查的条件并启用检查。

相关概念：[frank 表达式](../core-concepts.md#frank-表达式)、[形式化检查](../core-concepts.md#形式化检查)。

### 检查片段

**FCP-0009-R01 · 必须：** 启用检查时，检查器明确哪些头文档内容需要检查，不得把同一字段中的自然语言或其他伪代码自动判为 frank 表达式错误。

字段中可以直接混写自然语言。自动识别失败时，内容保留为说明，不参与检查；疑似表达式笔误应给出提示。明确要求检查的表达式解析失败时仍报告错误，具体见[自动识别与明确检查](../frank/checking.md#自动识别与明确检查)。

从头文档提取表达式时，先去掉每行开头表示 mcfunction 注释的 `#`，再去掉各行共有的内容缩进；其余内容保持原样。书写规则见[注释与换行](../frank/lexical.md)，检查范围和结果说明见[形式化检查](../frank/checking.md)。

需要保留说明并检查其中的条件时，可以按 FCP 4 R14 混写。以下假设 `x` 已在输入中定义：

```mcfunction
# @limitation
#   # 只处理非负输入。
#   x >= 0
```

取得字段内容后，`# 只处理非负输入。` 是 frank 注释，`x >= 0` 是待检查的条件。

相关概念：[头文档](../core-concepts.md#头文档)、[文档字段](../core-concepts.md#文档字段)、[自动识别](../core-concepts.md#自动识别)。

### 名称与取值时机

在一个头文档中定义的名称，可在后续文档字段中使用。同一名称不得重复定义，使用前先定义。

**FCP-0009-R05 · 必须：** 头文档中的数据位置在 `@input`、`@limitation` 中读取调用前的值，在 `@output`、`@side_effect` 中读取调用返回后的值。已定义的名称始终表示定义时的值。

输入条件不得引用调用结束后才取得的值。自定义字段读取调用前还是调用后的数据，由调用方明确。缺少相应游戏数据时，仍可检查语法，但无法据此判断条件是否成立。

在 `@input` 中单独列出一个位置，表示函数会读取它；在 `@output` 中单独列出一个位置，表示它保存输出结果。只列位置不限定具体数值，也不表示该值一定改变。输入是否允许修改，仍按 FCP 4 的接口约定说明。

相关概念：[名称与取值时机](../core-concepts.md#名称与取值时机)。

## 示例

以下展示选用形式化检查时的写法，不作为所有函数的文档模板。假设 `demo` 记分板及 `demo:math/square` 接口已经创建。

```mcfunction
#> demo:math/square
#   将非负整数 x 的平方写回原记分项。
# @input
#   minecraft_int x = score(math.x demo)
# @output
#   score(math.x demo) == x * x
# @usage
#   scoreboard players set math.x demo 12
#   function demo:math/square
# @limitation
#   0 <= x <= 46340
```

`@usage` 使用原版命令，其他字段使用 frank。输入名称 `x` 保留调用前的值，输出位置读取返回后的值。调用前为 `12`、调用后为 `144` 时，范围和输出关系均成立；该范围也避免平方结果超出记分板整数范围。

## 设计理由

frank 的统一、简洁和清晰服务于人的阅读，形式化检查是可选用途。本提案只约定表达式在头文档中的使用，不为简单接口增加必填表达式。

## 参考资料

- [frank 文档表达式](../frank/quickstart.md)
- [FCP 4 — 函数接口与头文档](fcp-0004-function-contracts.md)
