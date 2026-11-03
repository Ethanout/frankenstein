# FCP 4 — 函数接口与头文档

```text
FCP: 4
Title: 函数接口与头文档
Author: 待署名
Status: Draft
Type: Standards Track
Created: 18-Oct-2026
Minecraft-Version: 1.15+
Requires: 1
```

## 摘要

本文规定函数头文档的格式、保留字段和填写要求。接口函数必须提供头文档，其他函数可以省略；方法输入默认只读。建议最小化文档，通常只写说明或 `@usage`，其余内容按需补充。

## 动机

记分板和 storage 由多个函数共享。清楚的输入、输出和副作用说明，可以减少调用者对函数内部实现的依赖。

## 规范

### 头文档

**FCP-0004-R01 · 可以：** 为非接口函数添加头文档。

**FCP-0004-R07 · 必须：** 作为接口提供的函数（例如 `/function ns:class/method`）添加头文档。

头文档的完整形式如下，用于展示可用字段，无需全部填写。`#> ` 后可以填写当前函数的完整资源位置，也可以留空；其余部分按下述规则取舍：

```text
#> <namespace>:<class>/<method>
#   自然语言说明。
# @input
#   frank 表达式、伪代码或自然语言。
# @output
#   frank 表达式、伪代码或自然语言。
# @usage
#   可运行且无语法错误的 mcfunction 命令。
# @limitation
#   frank 表达式、伪代码或自然语言。
# @side_effect
#   frank 表达式、伪代码或自然语言。
# @xxxx
#   frank 表达式、伪代码或自然语言。
```

**FCP-0004-R08 · 必须：** 存在头文档时，保留以 `#> ` 开头的函数标识行，后面的函数名可以省略。说明和字段按需填写。

**FCP-0004-R09 · 必须：** 字段标签与下方内容成对出现。每个 `@字段名` 后都要有非空内容；省略字段时，同时省略标签和内容。

**FCP-0004-R02 · 应该：** 最小化文档。通常只写自然语言说明或 `@usage`，需要时同时提供；参数较多或输入输出不易说明时，再补充 `@input`、`@output`。已有内容足以说明用法时，不增加字段或重复说明。

相关概念：[接口](../core-concepts.md#接口)、[头文档](../core-concepts.md#头文档)。

### 保留字段与扩展

`input`、`output`、`usage`、`limitation`、`side_effect` 是保留字段名，其含义如下：

| 字段 | 内容 |
| --- | --- |
| `@input` | 输入数据、位置及要求 |
| `@output` | 输出数据、返回结果 |
| `@usage` | 可运行的调用示例 |
| `@limitation` | 合法输入范围或其他使用限制 |
| `@side_effect` | 除输出以外的状态变化 |

**FCP-0004-R10 · 必须：** `@usage` 使用可运行且无语法错误的 mcfunction 命令。

`@limitation` 主要用于数学库函数，明确合法输入范围。其他使用限制可以写入自然语言说明。副作用也可以写入说明，省略 `@side_effect`。

**FCP-0004-R11 · 可以：** 使用保留字段名以外的名称添加自定义字段，如 `@perf`。自定义字段同样遵守 R09。

相关概念：[文档字段](../core-concepts.md#文档字段)、[副作用](../core-concepts.md#副作用)。

### frank 表达式

**FCP-0004-R12 · 应该：** 在 `@input`、`@output`、`@limitation` 中需要写伪代码时，优先使用 frank 表达式。以简洁、清晰为目标，兼顾阅读和编写成本；自然语言已能说明的内容，无需改写为表达式。

使用 frank 表达式不要求进行形式化检查。仅在内容难以说清，或确有必要检查时，才建议补充可检查的条件并启用检查。

**FCP-0004-R14 · 可以：** 希望部分内容进入形式化检查时，在同一字段中同时使用自然语言和 frank 表达式。用自然语言说明含义，用表达式写出需要检查的内容。

**FCP-0004-R13 · 可以：** 直接列出数据位置表达式，例如 `score(@s xx)`，不必写成 `x = score(@s xx)`。具体写法见 [frank](../frank/quickstart.md) 的[数据位置](../frank/expressions.md#数据位置)。

表达式的常用写法、注释、类型及可选检查规则独立维护于 [frank 文档表达式](../frank/quickstart.md)；头文档中的名称范围和取值时机见 [FCP 9 — frank 在函数文档中的使用](fcp-0009-frank-expressions.md)。

相关概念：[frank 表达式](../core-concepts.md#frank-表达式)、[形式化检查](../core-concepts.md#形式化检查)。

### 输入与输出

**FCP-0004-R03 · 必须：** 方法输入默认只读。需要修改输入时，在接口文档中说明修改行为。

**FCP-0004-R04 · 应该：** 对外接口按调用需要说明数据结构、执行条件（如执行者和位置）、返回结果及其含义，以及重要副作用。这些内容可以写入说明或示例，不必逐项设置文档字段。

以下分别展示输入输出字段、`@usage` 和自然语言说明的写法。假设 `demo` 和 `demo.health` 记分板已创建：

```mcfunction
#> demo:character/hurt
#   扣除 @s 的 demo.health 分数
# @input
#   storage(demo:character damage)
#   要扣除的伤害
# @output
#   score(@s demo.health)
#   被扣除后的玩家血量
```

也可以这么写：

```mcfunction
#> demo:character/hurt
#   扣除 @s 的 demo.health 分数
# @usage
#   data modify storage demo:character damage set value 3
#   scoreboard players set @p demo.health 20
#   execute as @p run function demo:character/hurt

execute store result score #damage demo run data get storage demo:character damage 1
scoreboard players operation @s demo.health -= #damage demo
```

或者更简单：

```mcfunction
#> demo:character/hurt
#   扣除 @s 的 demo.health 分数
#   输入为 demo:character damage
#   输出为 @s demo.health

execute store result score #damage demo run data get storage demo:character damage 1
scoreboard players operation @s demo.health -= #damage demo
```


需要修改输入时，可以直接在说明中写明，例如“处理 items 列表，并删除已处理的条目”。

相关概念：[接口](../core-concepts.md#接口)、[接口值](../core-concepts.md#接口值)、[副作用](../core-concepts.md#副作用)。

## 设计理由

接口函数通过说明或可运行的示例交代用法，其余内容按复杂度补充，若无必要，勿增实体。frank 用于统一需要编写的伪代码，不要求为简单接口额外编写表达式或开展形式化检查。修改输入会影响调用者后续使用，因此需要明确说明。

项目自行选择接口登记方式；本规范对 `attr.txt` 不作要求。

## 字段内部共享

**FCP-0004-R06 · 可以：** 同一字段的私有方法读取调用者按内部约定准备的类内变量，无需将这些值单独列为输入。需要修改输入时，仍按 R03 说明修改行为。

例如，`demo:field/__calculate` 可以读取同字段调用者准备的 `score field.__damage demo`。变量范围和嵌套调用规则见 [FCP 5](fcp-0005-variable-lifetimes.md)。

相关概念：[字段](../core-concepts.md#字段)、[私有方法](../core-concepts.md#私有方法)、[类内变量](../core-concepts.md#类内变量)。

