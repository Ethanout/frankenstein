# 函数头文档

规定 mcfunction 文件开头的说明注释怎么写。表达式的完整写法见 [frank](../frank/quickstart.md)。

frank 的接口写法还是草案，后面可能调整。

## 速查

```mcfunction
#> demo:character/hurt
#   从执行者的生命值中扣除伤害。
# @input
#   storage(demo:io character.damage)
# @output
#   score(@s demo.health)
# @usage
#   data modify storage demo:io character.damage set value 3
#   execute as @p run function demo:character/hurt

execute store result score #damage demo run data get storage demo:io character.damage 1
scoreboard players operation @s demo.health -= #damage demo
```

| 标签 | 写什么 | 取值时机 |
| --- | --- | --- |
| `@input` | 读取的数据及要求 | 调用前 |
| `@output` | 产生或修改的结果 | 调用后 |
| `@usage` | 可运行的调用命令 | — |
| `@limitation` | 合法输入范围等限制 | 调用前 |
| `@side_effect` | 输出以外的状态变化 | 调用后 |
| `@deprecated` | 已弃用，写明替代接口和删除版本 | — |

标签都是可选的，顺序随意；也可以自定义，如 `@perf`。`@deprecated` 的用法见[通用协作规范](../core.md) C13。

## 格式

**D1 · 必须** 作为接口供人调用的函数要有头文档；其他函数可选。

**D2 · 必须** 头文档以 `#> ` 开头，后面的函数名可省略。〔检测 1〕

**D3 · 必须** 头文档每行以 `#` 开头，文档内的空行写成单独的 `#`。真正的空行或命令行会结束头文档。〔检测 1〕

```mcfunction
#> demo:item/method
#   这是一个函数
#
# @input
#   storage(demo:io item.field)
```

**D4 · 必须** 每个标签下面要有内容；没内容就连标签一起删掉。只有空格或 `#` 不算内容。〔检测 1〕

缩进建议：`#` 后首级 3 个空格，每深一级加 4 个。

## 内容

**D5 · 应该** 文档写到够用即可。通常只写一句说明或 `@usage`；参数多或数据位置不明显时，再加 `@input`、`@output`。

**D6 · 必须** `@usage` 是能直接运行、无语法错误的 mcfunction 命令。〔检测 1〕

**D7 · 必须** 输入默认只读。函数会修改输入时，要在文档里说明，如“处理 items 列表并删除已处理的条目”。

**D8 · 应该** 对外接口按需说明数据结构、执行条件（执行者、位置）、返回结果和重要副作用。写在说明或示例里即可，不必每项都开标签。

最简形式也可以：

```mcfunction
#> demo:character/hurt
#   扣除 @s 的 demo.health 分数
#   输入为 demo:io character.damage
```

同类私有方法可以直接读取调用者准备的类内变量，不必列为输入，见[变量与调用边界](variables.md#私有方法)。

## 使用 frank 表达式

**D9 · 应该** `@input`、`@output`、`@limitation` 里需要伪代码时，优先用 frank。自然语言能说清的不必改写。

frank 是写给人看的，不要求做形式化检查。常用写法：

```frank
storage(demo:io character.damage)                          # 只列位置
damage = storage(demo:io character.damage)                 # 起名，保留此刻的值
minecraft_int damage = storage(demo:io character.damage)   # 补类型
0 <= damage <= health                                   # 条件
score(@s demo.health) == health - damage                # 输入输出关系
```

自然语言和表达式可以混写在同一个标签里。

**D10 · 必须** 数据位置在 `@input`、`@limitation` 中读调用前的值，在 `@output`、`@side_effect` 中读调用后的值。名称始终表示起名时的值，先定义后使用，不得重复定义。

```mcfunction
#> demo:math/square
#   将非负整数 x 的平方写回原记分项。
# @input
#   minecraft_int x = score(math.x demo)
# @output
#   score(math.x demo) == x * x
# @limitation
#   0 <= x <= 46340
```

`x` 是调用前的值，`score(math.x demo)` 在 `@output` 中是调用后的值。

## 返回值

**D11 · 应该** 函数的返回值用 `return(...)` 写在 `@output` 中。〔检测 2〕

| 写法 | 含义 |
| --- | --- |
| `return(int)` | 用 `return <值>` 返回整数 |
| `return(bool)` | 成立用 `return 1`，不成立用 `return fail` |
| `return(void)` | 明确不返回值，调用方不得用 `execute store result` 读取 |
| `return(any)` | 不保证返回什么；没写 `return(...)` 时按此处理 |

可以用 `|` 连写多种，如 `return(int|bool)`。

`return <值>` 的成败标志是“成功”，`return fail` 的返回值是 0、成败标志是“失败”。所以：

- `return(bool)` 的调用方用 `execute store success` 或 `execute if function` 判断真假。
- `return(int)` 出错时用 `return fail`，调用方用 `execute store success` 区分“出错”和“正常返回 0”。

**D12 · 必须** 写了 `return(int)`、`return(bool)` 的函数，所有正常出口都返回对应类型的值。〔检测 2〕

```mcfunction
#> demo:player/is_alive
# @output
#   return(bool)

execute if entity @s[type=player] run return 1
return fail
```

```mcfunction
# 调用方
execute store success score #alive demo run function demo:player/is_alive
```

## 宏

**D13 · 必须** 宏参数写在 `@input` 中，形如 `macro(item1, item2)`；参数名用小写蛇形。〔检测 2〕

**D16 · 应该** 接口的必填宏参数直接传入，可选参数放进 `with`。Bookshelf 也这样处理。〔检测 2〕

```mcfunction
function #fn:store/modify {op:"data.a set value 1", with:{silent:true}}
function #bs.raycast:run {with:{max_distance:10}}
```

**D14 · 必须** 函数内部用宏拼出命令时，在 `@output` 或 `@side_effect` 中用 frank 表达式写明宏影响的范围，便于处理宏的兼容性。〔检测 2〕

```mcfunction
#> demo:item/__apply
# @input
#   macro(slot, id)
# @side_effect
#   entity(@s Inventory[{Slot:$(slot)b}])
```

普通接口的宏参数从 `io` 传入，只传被调用类自己那一部分（见[类与存储布局](storage.md#名称与归属) S4）：

```mcfunction
data modify storage fn:io store.op set value "data.a set value 1"
function fn:store/modify with storage fn:io store
```

`$(slot)` 是宏参数在 frank 中的临时写法，变量的模糊匹配规则还没定。包内部的宏数据与其他变量一样，只有本类方法读写本类的数据（见[变量与调用边界](variables.md)）。

## 执行上下文

带回调的接口，回调以命令字符串传入，如 `{with:{on_hit:"function demo:x"}}`。运行回调时，与函数用途无关的上下文应尽量不变：`fn:ray/run_at_endpoint` 只改执行位置，执行者不变。改变上下文的部分最好在函数名中体现。

**D15 · 必须** 函数改变了调用方或回调看到的执行上下文时，在 `@side_effect` 中用 `context(...)` 写明。〔检测 3〕

```mcfunction
#> fn:ray/run_at_endpoint
# @input
#   macro(run)
# @side_effect
#   context(at 射线终点)         # 执行者不变，只改位置
```

`context()` 里每项写成“键 值”，多项用逗号分隔，如 `context(at 起点, as 终点)`。键名用 execute 子命令：`as`、`at`、`positioned`、`rotated`、`facing`、`in`、`anchored`。没写的项表示不变。

需要区块已加载、或要求在特定维度运行的接口，也在文档中写明。

## 给工具实现者

- 提取表达式时，先去掉每行开头的 `#`，再去掉各行共有的缩进。
- 只有明确要求检查的内容解析失败才报错；自动识别失败的行保留为说明，不得判为错误。疑似笔误可以提示。
- 缺少游戏数据时只检查语法，不判断条件是否成立。
- 自定义标签读调用前还是调用后的值，由使用方约定。

详见 [frank 形式化检查](../frank/checking.md)。

