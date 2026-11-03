# FCP 3 — 字段与存储布局

```text
FCP: 3
Title: 字段与存储布局
Author: 待署名
Status: Draft
Type: Standards Track
Created: 18-Oct-2026
Minecraft-Version: 1.15+
Requires: 1
```

## 摘要

<a id="字段"></a>

字段（也称“类”）是一组命名和数据格式的约定。本文规定字段在 storage、记分板、实体和方块中的表示方式，以及属性、继承和存储布局。

## 动机

同一字段的数据可能存放在不同位置。统一命名和数据格式，可以明确数据归属，并减少跨方法和跨模块使用时的歧义。

## 规范

### 字段及其存放位置

**FCP-0003-R01 · 应该：** 同一字段的数据采用不同存储形式时，保留一致的模块名、字段名和数据项名称。

例如，玩家等级 `level` 可以按需使用下列存储形式：

```text
entity @s data.demo.player.level                                            # marker 实体，带demo命名空间
storage demo:player level                                                   # 字段自己的 storage
storage demo:player temp.level                                              # 字段自己的 storage，临时位置
storage demo:session demo.player.level                                      # 其他字段的 storage，带demo命名空间
score player.level demo                                                     # 记分板
score @s demo.player.level                                                  # 记分板，带demo命名空间
block ~ ~ ~ Items[0].components."minecraft:custom_data".demo.player.level   # 箱子中的物品，以 Minecraft Java 1.21.5 版本为例，带demo命名空间
```

自己的 storage 通过 `demo:player` 表明字段归属；保存到其他 storage、实体或方块中时，在已有 NBT 路径后接 `demo.player.level`。没有已有路径时，直接从 `demo` 开始。

NBT 路径中的点号分隔数据层级；记分板中，`player.level` 是记分项名，`demo` 是记分板名。

各存储形式的语义和类型约定见 [R13](#跨位置的数据约定)。

相关概念：[模块](../core-concepts.md#模块)、[字段](../core-concepts.md#字段)。

### 属性与继承

字段之间的关系分为属性和继承：

| 关系 | 表达的含义 | 示例 |
| --- | --- | --- |
| 属性 | 对象有什么数据 | `pos.x` 是位置的 x 分量，只是位置的一部分 |
| 继承 | 对象属于什么具体类型 | `character.knight` 是骑士，属于 `character` 的一种具体类型 |

**FCP-0003-R02 · 必须：** 同一字段内，同一个名称只能表示一种关系，不得同时作为属性名和继承类型名。

例如，`character.knight` 已表示骑士类型时，就不能再用它表示角色的“骑士数量”属性；后者可以另命名为 `character.knight_count`。

**FCP-0003-R03 · 应该：** 描述对象的一部分数据时，使用属性；描述一种更具体的对象类型时，使用继承。

相关概念：[属性](../core-concepts.md#属性)、[继承](../core-concepts.md#继承)。

### 存储归属

**FCP-0003-R09 · 必须：** 字段的独立 storage ID 使用 `<module>:<class>`。`module` 是所属模块的 Minecraft 命名空间；`class` 是完整字段名，包含已声明的子字段名，例如 `item.tool`。

把字段数据放进其他字段的 storage 时，使用那个 storage 的名称，并按 R01 在数据路径中保留原来的模块名和字段名。

例如，模块 `demo` 中的 `item` 字段使用 `demo:item`，其方法位于 `demo:item/...`。

```text
storage demo:item temp
storage demo:item data
storage demo:item ins
storage demo:item stat
```

**FCP-0003-R11 · 应该：** 在字段内部，按数据用途优先使用以下 NBT 路径名。

| 位置 | 用途 |
| --- | --- |
| `<module>:<class> temp` | 临时交换数据 |
| `<module>:<class> data` | 跨 tick 保存的动态数据 |
| `<module>:<class> ins` | compound 列表，每项内部与根目录使用相同规则 |
| `<module>:<class> stat` | 全静态数据，例如模板和常量 |

`ins` 为 `list<compound>`，形如 `[{...}, {...}]`。每个 compound 内部与 storage 根目录完全相同，可按需包含 `temp`、`data`、`ins`、`stat` 及自定义数据。列表项的增删、索引以及调用状态的保存与恢复由开发者决定。

```text
storage demo:item ins[0].abc
storage demo:item ins[0].temp.target
storage demo:item ins[0].ins[0].abc
```

**FCP-0003-R12 · 可以：** 开发者根据字段需要，在 `<module>:<class>` 下添加自定义 NBT 路径及内容，例如 `<module>:<class> abc`。

```text
storage demo:item abc
storage demo:item abc.count
```

**FCP-0003-R06 · 不应：** 随意修改静态模板和常量。

**FCP-0003-R07 · 应该：** 将字段内需要跨 tick 保存的动态数据放入 `data`。

**FCP-0003-R10 · 应该：** 协作时，由所属字段的方法管理其接口数据。例如，`demo:item damage` 通常由 `demo:item/...` 读写；其他字段通过该字段的接口方法使用它。

相关概念：[字段](../core-concepts.md#字段)、[存储角色](../core-concepts.md#存储角色)、[变量栈](../core-concepts.md#变量栈)。

### 跨位置的数据约定

**FCP-0003-R13 · 应该：** 同一字段或属性采用不同存储形式时，保持其语义一致；数据类型、单位或缩放比例不同时，在文档或函数头文档中说明换算规则。

存储位置按需选择。函数可以为临时变量选定一种输入形式；长期数据通常只采用一种存储形式。以下示例列出可选的位置写法，实际使用时按需选用。

例如，同一速度值可以在 NBT 中用 `double` 保存为 `1.25`，也可以在记分板中按 `1000` 倍缩放保存为 `1250`。后一种形式按 `实际值 = 分数 / 1000` 解释，缩放时的取整方式按接口约定。

#### 示例：玩家手持物品

`uses` 均表示工具的剩余使用次数，NBT 中使用 `int`。手持物品采用 Minecraft Java 1.20.5+ 的组件结构：

```text
storage demo:item.tool uses
score item.tool.uses demo
entity @s SelectedItem.components."minecraft:custom_data".demo.item.tool.uses
```

#### 示例：实体的 data

`ticks` 均表示任务的剩余 tick 数，NBT 中使用 `int`。实体形式中的 `@s` 为 Minecraft Java 1.17+ 的 `marker`：

```text
storage demo:timer.task ticks
score timer.task.ticks demo
entity @s data.demo.timer.task.ticks
```

相关概念：[字段](../core-concepts.md#字段)、[属性](../core-concepts.md#属性)。

### 属性与继承的位置示例

下表使用逻辑位置记法，各项用空格分隔，具体说明见 [FCP 7](fcp-0007-source-dialects.md)。

| 位置 | 字段 `test` 的属性 `a` | 继承字段 `test.b` 的属性 `a` |
| --- | --- | --- |
| 执行者记分板 | `score @s <module>.test.a` | `score @s <module>.test.b.a` |
| 假玩家记分板 | `score test.a <module>` | `score test.b.a <module>` |
| 方法接口 | `storage <module>:test a` | `storage <module>:test.b a` |
| 临时交换 | `storage <module>:test temp.a` | `storage <module>:test.b temp.a` |
| ins 列表项 | `storage <module>:test ins[0].a` | `storage <module>:test.b ins[0].a` |
| 静态模板 | `storage <module>:test stat.template_name.a` | `storage <module>:test.b stat.template_name.a` |
| 实体 tag | `tag <module>.test.a` | `tag <module>.test.b.a` |
| 方法 | `function <module>:test/method` | `function <module>:test.b/method` |

假玩家的记分项名为 `<class>.<数据项>`，记分板名为 `<module>`；执行者的记分项名为 `@s`，记分板名为 `<module>.<class>.<数据项>`。两种形式均先写完整字段名，再写数据项名。

实体或方块上的数据也可以属于字段。对象类型由字段约定决定。

相关概念：[属性](../core-concepts.md#属性)、[继承](../core-concepts.md#继承)、[逻辑记法](../core-concepts.md#逻辑记法)。

### NBT 路径冲突

NBT 中，每个节点只有一种类型。字段自身的数据与子字段对同一节点要求不同类型时，就会发生冲突；父类型与继承类型之间也可能发生这种冲突。

**FCP-0003-R04 · 应该：** 两份数据要求同一个 NBT 节点使用不同类型时，将它们分别放到不同的子路径。

保存字段自身值的子路径可以命名为 `value`；保存父类型数据的子路径可以命名为 `default`、`dummy` 或其他合适的名称。自定命名需要在布局文档中注明。

例如，`entity` 表示实体，`entity.player` 表示玩家。需要同时保存以下两份列表：

```text
storage demo:entity data         # 全部已登记实体的 UUID 列表
storage demo:entity data.player  # 全部已登记玩家的 UUID 列表
```

第一行要求 `data` 为 list；第二行要求 `data` 为 compound。同一节点 `data` 的类型要求不同，因此冲突。

将实体列表改存于 `data.default`，两份列表就位于同一层级：

```text
storage demo:entity data.default  # 全部已登记实体的 UUID 列表
storage demo:entity data.player   # 全部已登记玩家的 UUID 列表
```

此时，`data` 为 compound，`data.default` 和 `data.player` 均为 list。

也可以不使用 `default`，使用其他命名，如 `entity`：

```text
storage demo:entity data.entity   # 全部已登记实体的 UUID 列表
storage demo:entity data.player   # 全部已登记玩家的 UUID 列表
```

**FCP-0003-R08 · 应该：** 没有实际结构冲突时，保持简短名称。

相关概念：[子字段与字段值](../core-concepts.md#子字段与字段值)、[继承](../core-concepts.md#继承)、[继承冲突](../core-concepts.md#继承冲突)。

### NBT 名称中的特殊字符

名称本身含点号等 NBT 路径特殊字符时，使用引号将其作为一个完整的键。例如，模块名为 `my.demo` 时，写作 `"my.demo".item.tool.uses`，表示名为 `my.demo` 的数据下面的 `item.tool.uses`。引号内的点号属于名称本身。

## 设计理由

storage ID 表达字段归属，内部路径表达数据用途。协作双方可以通过字段接口交互，字段内部布局则保留调整空间。发生 NBT 路径冲突时，用独立子路径分开存放。
