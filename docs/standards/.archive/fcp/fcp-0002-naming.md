# FCP 2 — 名称、命名空间与函数路径

```text
FCP: 2
Title: 名称、命名空间与函数路径
Author: 待署名
Status: Draft
Type: Standards Track
Created: 18-Oct-2026
Minecraft-Version: 1.15+
Requires: 1
```

## 摘要

本文约定名称和函数路径的组织方式：名称简短明确，路径按[字段](fcp-0003-fields-storage.md#字段)、方法和中间过程分层。

## 动机

函数较多时，目录应能反映职责，名称应能显示调用链。这样既方便定位入口，也方便理解局部逻辑。

## 规范

### 名称

**FCP-0002-R01 · 应该：** 在含义明确的前提下使用简短名称。存在歧义时，选择更完整的名称。

**FCP-0002-R02 · 必须：** 实体 tag 必须显式包含所属命名空间。tag 名称必须等于该命名空间，或以 `<namespace>.` 开头。

根据资源位置构造 tag 名称时，将分隔命名空间与路径的冒号、斜杠等替换为点号。例如，`demo:character/example` 所属命名空间为 `demo`，其相关 tag 可以是 `demo`、`demo.character` 或 `demo.character.knight`。

```mcfunction
tag @s add demo
tag @s add demo.character
tag @s add demo.character.knight
tag @s remove demo.character
tag @s remove demo.character.knight
```

**FCP-0002-R10 · 不得：** 让含义或归属不同的名称，在将 `:` 和 `/` 全部替换为 `.` 后变成同名。此要求适用于所有路径和命名空间的组合。

例如，以下两种组合不能同时用于表示不同对象：

| 资源位置 | 替换后的名称 |
| --- | --- |
| `demo:player/update` | `demo.player.update` |
| `demo.player:update` | `demo.player.update` |

两者的命名空间和路径划分不同，替换后却无法区分。

### 函数路径

**FCP-0002-R03 · 应该：** 按“字段／方法／中间过程”组织函数路径。继承字段可以用点号表示，例如 `character.knight`。

```text
demo:character/update
demo:character/update/read_input
demo:character/update/check_state
demo:character.knight/update
```

**FCP-0002-R04 · 应该：** 中间过程按功能或特征命名，例如 `read_input`、`write_data`。

**FCP-0002-R05 · 可以：** 同一方法内，拆分过程时，在新过程名前加上原过程的完整名称，用下划线连接。

例如，`search` 拆出“检查目标”和“写入结果”两个过程；“检查目标”再拆出“读取位置”的过程：

```text
demo:character/update/search
demo:character/update/search_check_target
demo:character/update/search_check_target_read_position
demo:character/update/search_write_result
```

这些函数放在同一层目录，文件名中的前缀显示逻辑上的从属关系：`search_check_target_read_position` 属于 `search_check_target`，二者都属于 `search`。

同级且职责独立的过程按各自功能命名，例如 `read_input` 和 `check_state`。

**FCP-0002-R06 · 可以：** 逻辑链出现循环时，在相关名称中加入 `loop`。

```text
demo:character/update/search
demo:character/update/search_loop
demo:character/update/search_loop_step
```

相关概念：[字段](../core-concepts.md#字段)、[方法](../core-concepts.md#方法)、[中间过程](../core-concepts.md#中间过程)、[继承](../core-concepts.md#继承)。

### 方法名中的数据位置

**FCP-0002-R08 · 应该：** 方法名尽可能写明要修改的变量；名称过长或影响可读性时，可以省略部分信息，但不能造成歧义。

**FCP-0002-R09 · 可以：** 使用 `modify_<target>` 表示修改目标，使用 `<source>_to_<target>` 表示将来源数据写入目标。所属字段和 storage ID 可由函数路径确定，例如：

| 方法 | 含义 |
| --- | --- |
| `function demo:class/modify_abc` | 修改 `storage demo:class abc` |
| `function demo:class/score_to_abc` | 将 `score class.abc demo` 复制到 `storage demo:class abc` |
| `function demo:class/this_score_to_abc` | 将 `score @s demo.class.abc` 复制到 `storage demo:class abc` |

方法名中可以用以下名称表示数据来源或目标位置：

| 数据位置 | 方法名中的写法 |
| --- | --- |
| `@s` 的分数 | `this_score` |
| 全局分数（假玩家） | `score` |
| storage | `store` |
| `@s` 的 NBT | `this_<名称>` 或 `this` |
| 方块的 NBT | `block_<名称>` 或 `this` |

名称中的单词用下划线连接，例如“this score”写为 `this_score`。使用 `this` 时，方法所在字段及文档要说明它指向哪个实体或方块。

相关概念：[字段](../core-concepts.md#字段)、[方法](../core-concepts.md#方法)、[数据位置](../core-concepts.md#数据位置)。

### 目录深度

**FCP-0002-R07 · 应该：** 手写函数通常按“字段／方法／中间过程”三层组织。宏穷举也优先放在第三层；第三层条目过多、影响浏览时，可以增加第四层分组。大型分支模块和生成器可以根据规模调整层级。

层级仅按函数路径中的斜杠分段计算，命名空间和点号不计入层数。

```text
# 第三层直接列出穷举过程
demo:character/update/case_0
demo:character/update/case_1

# 穷举条目较多干扰开发时，可以用第四层收纳
demo:character/update/case/0
demo:character/update/case/1
#...
demo:character/update/case/100
```

生成函数的目录由构建工具组织，见 [FCP 7](fcp-0007-source-dialects.md)。

相关概念：[方法](../core-concepts.md#方法)、[中间过程](../core-concepts.md#中间过程)。

## 设计理由

第三层把一个方法的实现放在可直接浏览的位置。共同前缀显示子过程关系，`loop` 标记显示循环。只有在分组能改善阅读时才增加层级。

## 相关提案

字段含义见 [FCP 3](fcp-0003-fields-storage.md)，特殊名称见 [FCP 6](fcp-0006-special-names.md)，变量前缀见 [FCP 5](fcp-0005-variable-lifetimes.md)。
