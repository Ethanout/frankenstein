# 快速入门 frank 

frank 用于编写简洁、统一的 mcfunction 文档，说明函数读取、修改哪些数据，以及如何调用。文档首先供人阅读，需要时再用工具检查表达式中的类型和条件。

## 如何开始

在任意 mcfunction 文件的开头，输入：

```mcfunction
#> 
#   这是一段描述
#
```

这就是 frank 头文档最基本的形态。

`#> ` 表示文档的开始，后面可以填写当前函数的名字，也可以留空。之后每行都以 `#` 开头，单独的 `#` 表示文档内的空行；遇到真正的空行或 mcfunction 命令时，这段文档结束。

`#   这是一段描述` 是自然语言说明，可以用来描述当前函数的功能、输入、输出和注意事项。

头文档可以按需添加；作为接口提供给其他函数或开发者调用时，需要添加头文档。

## 头文档完全体示例

`demo:item/method` 的头文档可以写成下面这样。这个示例展示各部分的写法，实际使用时按需删减：

```mcfunction
#> demo:item/method
#   这是一段描述
#   描述可以换行
#   描述需要保持缩进一致
#   为了 tab 补空格方便，# 后的首次缩进建议 3 个空格，更深一级建议增加 4 个空格
#
# @input
#   storage(demo:io item.field)
#   entity(@s data.demo.item.field)
#   block(
#       ~ ~ ~ 
#       Items[0]
#           .components                 # `#`开头为注释
#           ."minecraft:custom_data"    # 多个空格和换行符当作单个空格来解析
#           .demo.item.field
#   )
#
# @output
#   score(@s demo.item.field)          # 可以在表达式后补充注释
#   score(item.field demo)
#   也可以直接写自然语言说明。
#   自动识别时，无法完整解析为 frank 表达式的行保留为说明，不参与检查。
#
# @limitation
#   需要预先准备上述 storage、实体数据和方块数据
# @side_effect
#   会移除执行者的 demo.pending tag
#
# @usage
#   execute as @p at @s run function demo:item/method
#
# @whatever
#   这是一段自定义说明

tag @s remove demo.pending
```

`@input`、`@output` 等标签将不同内容分开：

| 标签 | 用来说明什么 |
| --- | --- |
| `@input` | 函数会读取哪些数据 |
| `@output` | 函数会产生或修改哪些结果 |
| `@usage` | 怎样调用这个函数 |
| `@limitation` | 合法输入范围或其他使用限制 |
| `@side_effect` | 除输出以外，还会改变什么 |

以上五个标签的名称和含义由 frank 规定，也可以添加 `@whatever` 这样的自定义标签。

标签的前后顺序可以调整。需要在标签或 frank 语句之间留空行时，写一行单独的 `#`。

## 必须遵守的规则

### 标签下面要有内容

标签下方必须写实际内容。没有内容时，连同标签一起省略。只有空格或单独的 `#` 行不算内容。

错误示例：

```mcfunction
#> demo:item/method
#   这是一个函数
# @input
#   
```

正确示例：

```mcfunction
#> demo:item/method
#   这是一个函数
```

这里没有需要补充的输入说明，所以将 `@input` 一起省略。如果需要这个标签，就在下面写出实际内容。

### 头文档中的每行都以 `#` 开头

头文档中的每一行都要以 `#` 开头，包括用于分隔内容的空行。否则，后面的内容就不再属于这段头文档。

下面的真正空行会打断头文档，导致后面的 `@input` 脱离这段文档：

```mcfunction
#> demo:item/method
#   这是一个函数

# @input
#   storage(demo:io item.field)
```

需要留空行时，应该这样写：

```mcfunction
#> demo:item/method
#   这是一个函数
#
# @input
#   storage(demo:io item.field)
```

函数的实际命令写在头文档之后，正常使用 mcfunction 语法。例如：

```mcfunction
#> demo:item/method
#   移除执行者的 demo.pending tag
#
tag @s remove demo.pending
```

## 如何表示函数的输入输出

参数较多，或者仅靠说明不容易看出数据位置时，可以补充 `@input` 和 `@output`。

最简单的写法是直接列出数据位置：

```frank
storage(demo:io character.damage)
score(@s demo.health)
```

第一行指向 storage `demo:character` 中的 `damage`；第二行指向执行者 `@s` 在 `demo.health` 记分板上的分数。括号内不同项用空格分开。

假设 `demo:character/hurt` 从执行者的生命值中扣除伤害，可以这样说明：

```mcfunction
#> demo:character/hurt
#   从执行者的生命值中扣除伤害，并写回原分数。
# @input
#   storage(demo:io character.damage)
#   要扣除的伤害
#   score(@s demo.health)
#   扣除前的生命值，函数会修改该分数
# @output
#   score(@s demo.health)
#   扣除后的生命值
#
```

`@input` 描述调用前的数据，`@output` 描述调用返回后的结果。`demo.health` 既参与计算又被修改，所以可以同时出现在两处。

在位置旁边补一句自然语言，通常就能说明含义，不必继续添加类型和计算关系。需要明确标记注释时，见[注释与换行](lexical.md)。

## 如何写调用示例

如果调用示例更容易说明用法，可以直接写 `@usage`。下面假设 `demo.health` 记分板已经创建，且游戏中至少有一名玩家：

```mcfunction
#> demo:character/hurt
# @usage
#   data modify storage demo:io character.damage set value 3
#   scoreboard players set @p demo.health 20
#   execute as @p run function demo:character/hurt
#
```

这个示例先准备伤害值，再设置玩家的生命值，最后以该玩家为执行者调用函数。调用方式已经清楚时，可以省略 `@input` 和 `@output`。

`@usage` 中填写可以运行的 mcfunction 命令。其他标签中的 frank 表达式用于说明数据和要求。

## 按需补充名称和类型

后文需要引用某项数据时，可以给它起名。例如，给伤害值起名为 `damage`：

```frank
damage = storage(demo:io character.damage)
```

`=` 读取当前位置的值并给它起名。后面写 `damage` 就引用这个值；即使 storage 中的值后来改变，`damage` 仍保留起名时的值。

需要说明类型时，把类型写在名字前面：

```frank
minecraft_int damage = storage(demo:io character.damage)
```

这里的 `minecraft_int` 表示游戏中的 32 位有符号整数。其他 NBT 类型、精确数学类型及 Python、NumPy 类型的写法见[类型补充与自定义检查](types.md)，均按需填写。

## 按需补充条件和关系

需要明确输入范围时，可以直接写条件。例如，下面这一行表示伤害值不小于 `0`：

```frank
damage >= 0
```

需要说明输入和输出之间的关系时，可以使用 `==`。假设这个函数只接受不超过当前生命值的非负伤害，可以写成：

```mcfunction
#> demo:character/hurt
#   从生命值中扣除伤害，并写回原分数；伤害不能超过当前生命值。
# @input
#   minecraft_int damage = storage(demo:io character.damage)
#   minecraft_int health = score(@s demo.health)
# @output
#   score(@s demo.health) == health - damage
# @limitation
#   0 <= damage <= health
#
```

`damage` 和 `health` 保留调用前的值，`@output` 中的 `score(@s demo.health)` 表示调用后的生命值。因此，输出关系读作“调用后的生命值，等于调用前的生命值减去伤害”。

需要说明输入范围或计算关系时，可以使用这种写法；需要时再交给工具检查。

自然语言或调用示例已经说清楚时，无需再添加复杂表达式。文档写到够用即可。

## 查阅具体写法

- [术语表](../glossary.md)：查阅头文档、数据位置等术语。
- [常用写法](expressions.md)：数据位置、名称、可选类型和条件。
- [注释与换行](lexical.md)：补充自然语言说明、拆分较长的表达式。
- [类型补充与自定义检查](types.md)：类型含义、自定义类型及 Python 扩展。
- [形式化检查](checking.md)：需要工具检查时的上下文、结果与诊断。
- [待补充事项](questions.md#待补充)：尚未确定的数值运算细节。

函数头文档的填写规则见[函数头文档](../style/function-docs.md)。

当前写法仍为草案，尚未实现解析器或检查器。
