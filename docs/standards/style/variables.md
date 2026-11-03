# 变量与调用边界

规定记分板假玩家、storage 路径等“变量”的命名、可用范围和跨 tick 保存方式。“类”见[术语表](../glossary.md)。

## 速查

| 写法 | 种类 | 谁能读写 | 何时失效 |
| --- | --- | --- | --- |
| `pos`、`pos.x` | 接口变量 | 任何方法，按接口约定 | 当前 tick 结束 |
| `pos.__a` | 类内变量 | 仅 `pos` 类的方法及其中间过程 | 当前 tick 结束 |
| `pos.__count__` | 跨 tick 变量 | 任何方法，按接口约定 | 不失效 |
| `#a`、`#temp_a` | 临时变量 | 当前方法及其中间过程 | 调用其他方法后 |
| `##a` | 强制临时变量 | 当前函数 | 调用任意函数后 |
| `16`、`#16` | 常量 | 任何方法，只读 | 不失效 |

“失效”指不能再依赖旧值，读取前要重新赋值。

表中是逻辑名称，实际可写成 `score pos.x demo`、`storage demo:io pos.x` 等，见[类与存储布局](storage.md)。

## 命名

**V1 · 应该** 类 `xx` 的接口变量命名为 `xx.yy`；类自身的值可直接用类名，如 `pos`。

**V2 · 必须** 类内变量命名为 `<class>.__<name>`，只供该类的方法及其中间过程使用。继承类不会自动获得访问权限：`pos.__a` 不能在 `demo:pos.knight/...` 中使用。〔检测 1〕

**V3 · 必须** 跨 tick 保存的变量命名为 `<class>.__<name>__`，如 `pos.__count__`。前后双下划线只表示跨 tick，它仍是公开的接口变量，不是类内私有。

**V4 · 必须** `#` 开头且不是数字的假名都是临时变量，如 `#a`、`#temp_a`，不得用作跨方法共享值。〔检测 1〕

`temp_a`、`stemp` 这类不带 `#` 的名称不算临时变量：小豆的规范中它们会在函数之间传值。

可选写法，不影响有效范围：

- 对外接口可额外加 `$` 标记，类名和变量名照常保留。
- 需要更小范围时可用 `##a`，一般 `#a` 就够了。

## 记分板与常量

**V5 · 必须** 全局的假玩家变量和常量都放在与命名空间同名的记分项上，如 `score pos.x demo`、`score 16 demo`。一个包只用这一个记分项存假玩家。〔检测 1〕

执行者自己的分数（`score @s demo.pos.x`）不受此限，按 [S2](storage.md#名称与归属) 命名。

在 frank.txt 中声明过的记分项也不受此限：

- `const`：额外的常量记分项（见 V6）
- `trigger`：给玩家用的 `/trigger` 记分项
- `extern`：由其他库定义、本包只往里登记的记分项，如 Lantern Load 的 `load.status`

回调期间可读的数据不另建记分项，和接口数据一样放在 `<module>:io <class>` 或 `<class>.<项>`，如 `ray.distance`，见[类与存储布局](storage.md#storage-内部) S16。

**V6 · 必须** 在 `<module>` 记分项上，常量的假名就是它的数值，可加 `#`：`16` 和 `#16` 的值都是 16。〔检测 1〕

```mcfunction
scoreboard objectives add demo dummy
scoreboard players set 16 demo 16
scoreboard players set -1 demo -1
```

需要单独的常量记分项时，在 [frank.txt](../README.md#franktxt-中的项目声明) 中用 `const` 声明。声明过的记分项上，假名不受 V6 限制，如 `#PI_x1000`。

## 调用前后

**V7 · 必须** 调用其他方法后，之前的临时变量视为失效，同类的私有方法除外。调用本方法的中间过程不受影响，但中间过程里再调用其他方法，同样会让外层的临时变量失效。`##a` 在调用任意函数后都失效。〔检测 1〕

**V8 · 必须** 方法的输入通过接口变量传入，类内部可用类内变量；不得把调用者的临时变量当作输入。

```mcfunction
#> demo:pos/update
scoreboard players set #a demo 1
scoreboard players set ##a demo 1

function demo:pos/update/read       # 本方法的中间过程
# #a 仍有效；##a 已失效

function demo:pos/__validate        # 同属于 pos 类的私有方法
# #a 仍有效

function demo:pos/reverse           # reverse 和 update 不是同一个方法
# #a 失效了，读取前需重新赋值
```

有方法可以防止值失效。只要在函数前后加上出入栈的命令即可：

```mcfunction
#> demo:pos/update
scoreboard players set #a demo 1

# 将a暂存到列表（栈）中
data modify storage demo:ins pos append value {}
execute store result storage demo:ins pos[-1].temp.a int 1 run scoreboard players get #a demo

# 运行函数方法
function demo:pos/reverse

# 还原列表（栈）中的变量到记分板
execute store result score #a demo run data get storage demo:ins pos[-1].temp.a
data remove storage demo:ins pos[-1]
```

**V9 · 应该** 方法之间优先用接口文档里写明的数据传值。多个方法要共用同一个中间过程时，把它提取为私有方法。

```mcfunction
scoreboard players set character.damage demo 10
function demo:character/hurt      # 读取 character.damage，默认只读
```

**V10 · 应该** 递归或嵌套调用会重复使用同一组变量时，用 `storage <module>:ins <class>` 列表做变量栈，每次调用各占一项。类名前缀只区分归属，不会自动隔离每次调用的数据。

## 私有方法

**V11 · 不应** 私有方法意外改写接口变量或跨 tick 数据。约定内的修改要写进说明或 `@side_effect`。

**V12 · 必须** 私有方法内部再调用其他方法时，这些调用造成的修改算作它自己的副作用，需要一并说明。

**V13 · 不应** 私有方法调用普通方法；共享逻辑用嵌套的私有方法组织。

同类私有方法可以按内部约定直接读取类内变量，不必单独声明输入，但同样遵守 V7。

```mcfunction
#> demo:pos/update
scoreboard players set pos.__a demo 1
scoreboard players set pos.b demo 1
function demo:pos/__validate
# pos.__a 仍可读取，值由 __validate 的内部约定决定
```

## tick 边界

**V14 · 必须** 当前 tick 结束后，除 `<class>.__<name>__` 和常量外的变量全部视为失效，下一 tick 不得沿用旧值。`<module>:data`、`<module>:stat` 中的长期数据按存储布局保存，不受此条影响。
