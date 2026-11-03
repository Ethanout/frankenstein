# FCP 5 — 临时变量与调用边界

```text
FCP: 5
Title: 临时变量与调用边界
Author: 待署名
Status: Draft
Type: Standards Track
Created: 18-Oct-2026
Minecraft-Version: 1.15+
Requires: 1, 4
```

## 摘要

本文区分接口变量、类内变量和临时变量，约定命名、调用后的有效范围及跨 tick 保存方式。本文中的“类”与“字段”含义相同。

## 动机

同一记分项、storage 路径或 tag 可以被多个函数使用。调用其他函数后，这些位置中的值可能已被改写。明确调用前后哪些值还能使用，可以减少意外覆盖。

## 规范

### 变量用途

| 示例 | 用途 | 有效范围 |
| --- | --- | --- |
| `pos`、`pos.x` | 全局变量，作为对外接口 | 各方法按接口约定读写，当前 tick 内有效 |
| `pos.__a` | 类内变量，作为内部接口 | 仅 `pos` 类内部读写，当前 tick 内有效 |
| `#a` | 临时变量 | 所属方法及其中间过程内使用，调用其他方法后失效 |
| `##a` | 强制临时变量 | 当前函数内使用，调用任意函数后失效，一般不用 |
| `pos.__g__` | 跨 tick 全局变量 | 各方法按接口约定读写，跨 tick 有效 |

表中名称是变量的逻辑名称，变量名仅为示例。例如，`pos.x` 可以写为 `score pos.x demo`；跨 tick 全局变量也可以命名为 `pos.__count__`、`pos.__last_tick__`。

“失效”或“视为销毁”表示不能继续依赖旧值，再次读取前必须重新赋值或按接口取得有效值。Minecraft 中的数据不会因此自动清除。接口变量在调用后仍有效，也不表示它的值没有改变。

**FCP-0005-R12 · 应该：** 类 `xx` 的接口变量 `yy` 使用 `xx.yy` 命名。类自身的接口值可以直接使用类名，例如 `pos`。

**FCP-0005-R13 · 必须：** 类内变量使用 `<class>.__<name>` 命名，只供该类的方法及其中间过程读写。例如，`pos.__a` 只允许 `demo:pos/...` 内的函数使用；`demo:pos.knight/...` 不因继承关系自动获得访问权限。

相关概念：[接口值](../core-concepts.md#接口值)、[类内变量](../core-concepts.md#类内变量)、[临时变量](../core-concepts.md#临时变量)、[长期状态](../core-concepts.md#长期状态)。

### 普通调用

**FCP-0005-R01 · 必须：** 调用其他方法后，将调用前的 `#a` 类临时变量视为失效。同类方法、其他类的方法和私有方法均适用。调用所属方法的中间过程不使这类临时变量失效；`##a` 类强制临时变量则在调用任意函数后失效。

中间过程内部再调用其他方法时，同样适用上述规则，外层方法不能继续依赖调用前的临时值。

**FCP-0005-R02 · 必须：** 方法通过接口变量读取调用者提供的值。类内部传值可以使用类内变量；不得用调用者的 `#a` 或 `##a` 作为跨方法输入。

例如，`demo:pos/update/read` 是 `update` 的中间过程，`demo:pos/__validate` 是另一个方法。假设 `demo` 记分板已创建：

```mcfunction
# demo:pos/update
scoreboard players set #a demo 1
scoreboard players set ##a demo 1
function demo:pos/update/read
# #a 仍可读取；##a 已失效。
scoreboard players get #a demo

function demo:pos/__validate
# #a 也已失效，读取前必须重新赋值。
```

**FCP-0005-R04 · 应该：** 普通方法之间传值时，优先使用名称和用途已在接口中说明的数据；多个方法共享同一中间过程时，将该过程提取为私有方法。

```mcfunction
# 调用者准备显式输入
scoreboard players set character.damage demo 10
function demo:character/hurt
```

这里的 `character.damage` 是接口值，由 `hurt` 的文档说明用途，默认只读。

相关概念：[普通调用](../core-concepts.md#普通调用)、[中间过程](../core-concepts.md#中间过程)、[临时变量](../core-concepts.md#临时变量)、[接口值](../core-concepts.md#接口值)。

### 私有调用

**FCP-0005-R03 · 不应：** 私有方法意外覆盖接口变量或长期数据。约定内的修改在说明或 `@side_effect` 中交代。

同类的私有方法可以按内部约定读取类内变量，省略单独的输入声明。私有方法同样遵守 R01，不保留调用者的临时变量。

```mcfunction
# demo:pos/update
scoreboard players set pos.__a demo 1
function demo:pos/__validate
# pos.__a 仍可读取；值按 __validate 的内部约定确定。
scoreboard players get pos.__a demo
```

**FCP-0005-R10 · 不应：** 私有方法调用普通方法或其他上层逻辑。通常通过嵌套私有方法组织共享过程。

**FCP-0005-R11 · 必须：** 私有方法内部调用其他方法时，将内部调用对接口变量或长期数据的修改计入自身的副作用。

相关概念：[私有方法](../core-concepts.md#私有方法)、[类内变量](../core-concepts.md#类内变量)、[副作用](../core-concepts.md#副作用)。

### 递归与嵌套调用

**FCP-0005-R05 · 应该：** 递归或嵌套调用会重复使用同一输入输出位置时，用变量栈分别保存每次调用的数据。

可使用 `ins` 列表保存调用状态，每项内部与 storage 根目录使用相同规则，见 [FCP 3](fcp-0003-fields-storage.md#存储归属)。保存、恢复及列表操作由开发者决定。

类名前缀只区分数据归属，不会为每次调用分配独立数据。同类方法递归或嵌套调用时，类内变量和全局变量也可能互相覆盖。

相关概念：[嵌套调用](../core-concepts.md#嵌套调用)、[变量栈](../core-concepts.md#变量栈)。

### tick 边界

**FCP-0005-R14 · 必须：** 当前 tick 结束后，将普通全局变量、类内变量、临时变量和强制临时变量视为失效；不得在下一 tick 直接沿用旧值。需要跨 tick 保留的变量，使用 `<class>.__<name>__` 命名，例如 `pos.__g__`。

数字常量按 R06 处理。storage 中的 `data`、`stat` 等长期数据仍按 [FCP 3](fcp-0003-fields-storage.md#存储归属) 的约定保存。

相关概念：[长期状态](../core-concepts.md#长期状态)、[存储角色](../core-concepts.md#存储角色)。

### 名称前缀

**FCP-0005-R06 · 可以：** 数字常量名使用或省略 `#`，例如 `16` 与 `#16`。

**FCP-0005-R07 · 可以：** 对外接口额外使用 `$` 标记。使用该标记时，仍保留类名和变量名，不改变变量的有效范围。

**FCP-0005-R08 · 可以：** 使用 `##` 标记强制临时变量，例如 `##a`。一般使用 `#a` 即可，无需额外缩小范围。

**FCP-0005-R09 · 必须：** 以单个 `#` 开头且不是数字常量的假玩家变量，作为所属方法及其中间过程的临时变量使用，不作为类内跨方法共享值。

相关概念：[临时变量](../core-concepts.md#临时变量)、[类内变量](../core-concepts.md#类内变量)、[接口值](../core-concepts.md#接口值)。

## 设计理由

类名前缀标明接口数据的归属，`#` 保留方法内计算所需的短名称。跨方法共享使用明确的接口变量；需要隔离递归或嵌套调用的数据时，再使用变量栈。

