# 类与存储布局

规定类（字段）的数据放在哪里、叫什么。`<module>` 是 Minecraft 命名空间。

## 速查

storage ID 写用途（角色），路径以类名开头。类 `item` 的数据：

| 路径 | 用途 |
| --- | --- |
| `storage demo:io item` | 接口的输入输出，以及回调运行期间可读的数据（S4、S16） |
| `storage demo:temp item` | 临时交换 |
| `storage demo:data item` | 跨 tick 的动态数据 |
| `storage demo:ins item` | 变量栈，`list<compound>`；每项可以放 `temp`、`data` 等子键，但不能再带 `ins` 或 `stat` |
| `storage demo:stat item` | 静态数据：模板、常量 |

同一份数据（`demo` 模块 `player` 类的 `level`）可以放在任何位置，规则只有一条：数据的“全名”是 `demo.player.level`，放到哪里都保留这个全名。

| 放在哪 | 写法 | 全名在哪 |
| --- | --- | --- |
| 本包的 storage | `storage demo:io player.level`、`storage demo:data player.level` | `demo` 在 storage ID 里，路径从类名开始 |
| 假玩家分数 | `score player.level demo` | `demo` 是记分项，`player.level` 是假名 |
| 执行者分数 | `score @s demo.player.level` | 全名就是记分项名 |
| 其他任意 NBT 位置 | `<位置> <已有路径>.demo.player.level` | 全名接在已有路径后面 |

最后一行的“已有路径”可以是任何东西，例如：

```text
storage demo:data session.players[0].demo.player.level                  # 本包其他类的数据里
storage other:io data.list[0].demo.player.level                          # 别的包的 storage
entity @s data.demo.player.level                                         # marker 实体的 data
entity @s SelectedItem.components."minecraft:custom_data".demo.player.level   # 手持物品
block ~ ~ ~ Items[0].components."minecraft:custom_data".demo.player.level     # 箱子里的物品
```

没有已有路径时，直接从 `demo` 开始，如物品 `custom_data` 的根就是 `{demo:{player:{level:5}}}`。

工具判断一个 NBT 路径属于哪个类时，看路径末尾是否为 `<module>.<class>.<项>`，前面的部分不管。

## 名称与归属

**S1 · 必须** storage ID 为 `<module>:<角色>`，路径以完整类名开头，含继承部分：`storage demo:data item.tool.uses`。角色见 S7。〔检测 1〕

**S2 · 应该** 同一数据换存储形式时，保留全名 `<module>.<class>.<项>`。放进本包角色 storage 以外的任何 NBT 位置时，在已有路径后接全名；没有已有路径时从 `<module>` 开始（见速查）。

**S3 · 应该** 类的接口数据由该类自己的方法读写；其他类通过接口方法使用。

**S4 · 必须** 接口的输入输出放在 `storage <module>:io <class>` 下，以类名为键；记分板形式为 `score <class>.<项> <module>`。〔检测 1〕

`io` 是内置角色之一。类名不要和角色同名，避免 `storage demo:data data.x` 这种难读的写法。

统一放在 `io` 下，模块之间协作时，调用方只需要知道“往 `fn:io <类名>` 写输入、从那里读输出”，再用 `with storage` 把对应部分传给宏：

```mcfunction
function fn:id/assign                                     # 输出写到 storage fn:io id
function fn:id/this_to_store
data modify storage fn:io store.op set value "data.a set value 1"
function fn:store/modify with storage fn:io store         # 只把 store 这一部分作为宏参数
```

其他包读写 `fn:io <类名>` 时，按 C7 只能用接口说明里写明的键，`io` 路径属于接口的一部分。

输入和输出放在同一个 `fn:io <类名>` 下，接口说明要写明哪些键是输入、哪些是输出；同名的输入会被输出覆盖。（待确认，见追问 Q26）

## 属性与继承

子名称有两种含义：

| 关系 | 含义 | 例 |
| --- | --- | --- |
| 属性 | 对象有什么数据 | `pos.x`：位置的 x 分量 |
| 继承 | 对象是哪种具体类型 | `character.knight`：一种角色 |

**S5 · 必须** 同一类中，一个名称只能是属性或继承类型之一。`character.knight` 已表示骑士时，“骑士数量”要另取名，如 `character.knight_count`。

**S6 · 应该** 表示数据的一部分用属性，表示更具体的类型用继承。

继承类的数据位置：

| 位置 | 类 `test` 的属性 `a` | 继承类 `test.b` 的属性 `a` |
| --- | --- | --- |
| 执行者分数 | `score @s <module>.test.a` | `score @s <module>.test.b.a` |
| 假玩家分数 | `score test.a <module>` | `score test.b.a <module>` |
| storage | `storage <module>:io test.a` | `storage <module>:io test.b.a` |
| 实体 tag | `tag <module>.test.a` | `tag <module>.test.b.a` |
| 方法 | `function <module>:test/method` | `function <module>:test.b/method` |

## storage 内部

**S7 · 应该** 按用途使用内置角色 `io`、`temp`、`data`、`ins`、`stat`（见速查），不用在 frank.txt 中声明。需要其他角色时，在 [frank.txt](../README.md#franktxt-中的项目声明) 中用 `special` 声明，如 `special class` 之后可以写 `storage demo:class item`。〔检测 2〕

**S8 · 应该** 跨 tick 的动态数据放在 `data`。

**S9 · 不应** 随意修改 `stat` 中的模板和常量。

`ins` 每项是一份调用的数据，可以按需放 `temp`、`data` 等子键，但不能再带 `ins` 或 `stat`：

```text
storage demo:ins item[0].temp.target
storage demo:ins item[0].abc
```

**S16 · 应该** 带回调的接口，回调运行期间可读的数据和其他接口数据一样，放在 `storage <module>:io <class>`；记分板形式为 `score <class>.<项> <module>`。接口说明里写明哪些键只在回调运行期间有效，回调返回后视为失效。〔检测 2〕

```mcfunction
# fn:ray/cast 运行回调前写入
data modify storage fn:io ray.hit_block set from storage fn:temp ray.block
scoreboard players operation ray.distance fn = #distance fn
```

列表项的增删、索引和保存恢复由开发者决定。用法见[变量与调用边界](variables.md#调用前后) V10。

## 跨位置的一致性

**S10 · 应该** 同一数据放在不同位置时含义一致；类型、单位或缩放不同时，在文档里写明换算。

例：速度在 NBT 中存 `double` `1.25`，在记分板中按 1000 倍存为 `1250`，即 `实际值 = 分数 / 1000`，取整方式按接口约定。

长期数据通常只用一种存储形式；临时输入可以由函数选定一种。

## NBT 路径冲突

NBT 每个节点只能有一种类型。类自身的值和子名称（或父类型与继承类型）要求同一节点类型不同时，就会冲突。

**S11 · 应该** 冲突时把两份数据分到不同子路径。类自身的值可用 `value`，父类型的数据可用 `default` 或其他名称，自定名称要在文档里写明。

```text
# 冲突：entity 既要是 list，又要是 compound
storage demo:data entity           # 所有实体的 UUID 列表
storage demo:data entity.player    # 所有玩家的 UUID 列表

# 解决
storage demo:data entity.default   # 所有实体
storage demo:data entity.player    # 所有玩家
```

**S12 · 应该** 没有实际冲突时保持短路径，不预先加 `value`、`default`。

**S13 · 应该** 物品 `custom_data`、实体 `data` 等任意 NBT 位置中的数据按层级嵌套，不用带点号的平铺键：写 `{demo:{item:{id:"sword"}}}`，不写 `{"demo.item":{id:"sword"}}`。〔检测 2〕

名称含 `.` 等特殊字符时用引号括起，如模块 `my.demo` 写作 `"my.demo".item.tool.uses`。

## 实体组

**S14 · 应该** 由多个实体组成的对象，乘客的 tag 是根实体 tag 的继承类：根实体 `ns.aaa`，乘客 `ns.aaa.bbb`。

乘客是一种更具体的类型，不是根实体的“组成部分”。按 S5，`aaa` 下面的同一个名称不能既当乘客类型，又当属性。

删除整组时调用根实体类的 `__del__`；`ns:aaa.bbb/__del__` 只删 `ns.aaa.bbb` 的实体。

## 世界内的改动

**S15 · 应该** 前置类工具包只在后端保存状态：storage、记分板、世界实体、寄存器方块、常加载区块。前端，即玩家看得到、碰得到的方块、普通实体和物品，除了接口本身要做的改动，不留下任何改动。

这条只约束前置类工具包。生存、玩法类数据包难免改动世界，不受此限；通用协作规范也不做要求。
