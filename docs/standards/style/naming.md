# 命名与函数路径

规定包、函数路径、实体 tag 和特殊名称的写法。`<module>` 是 Minecraft 命名空间。

## 速查

| 对象 | 写法 | 例 |
| --- | --- | --- |
| 主包 | `<项目>` | `fn` |
| 附属包 | `<项目>.<包>` | `fn.unbake` |
| 方法 | `<module>:<class>/<method>` | `fn:ray/cast` |
| 方法（空名入口） | `<module>:<class>/<method>/` | `fn:ray/cast/` |
| 中间过程 | `<module>:<class>/<method>/<name>` | `fn:ray/cast/step` |
| 继承类 | `<class>.<sub>` | `demo:character.knight/update` |
| 私有方法 | `__<name>` | `demo:character/__validate` |
| 自动方法 | `__<name>__` | `demo:character/__tick__` |
| 实体 tag | `<module>` 或 `<module>.…` | `demo.character.knight` |

## 名称

**N1 · 应该** 含义明确时用简短名称，有歧义时改用更完整的名称。

**N2 · 必须** 类名和方法名全部小写，只用小写字母、数字和下划线；继承类用点号连接。〔检测 1〕

**N3 · 必须** 实体 tag 等于所属命名空间，或以 `<module>.` 开头。〔检测 1〕

由资源位置构造 tag 时，把 `:`、`/` 换成 `.`：`demo:character/knight` → `demo.character.knight`。

**N4 · 不得** 两个不同的资源位置在 `:`、`/` 换成 `.` 后同名。〔检测 1〕

```text
demo:player/update   → demo.player.update
demo.player:update   → demo.player.update   # 与上一行冲突
```

## 包

**N5 · 应该** 主包的命名空间用项目名，附属包用 `<项目>.<包名>`。附属功能拆成附属包，供玩家选装；包内的类也可以做成选装。

```text
function fn:ray/cast              # 主包 fn
function fn.unbake:block/get      # 附属包 fn.unbake
```

附属包依赖其他包时，按[通用协作规范](../core.md) C11 写明。按 N4，主包里不要再建与附属包同名的类：`fn:unbake/block/get` 会和 `fn.unbake:block/get` 冲突。

## 函数路径

**N6 · 应该** 函数按“类／方法／中间过程”三层组织，继承类用点号表示。

**N7 · 必须** 方法入口从下面两种写法中选一种，同一个包内统一。〔检测 1〕

```text
# 写法一：入口是同名文件
fn:ray/cast                 # ray/cast.mcfunction
fn:ray/cast/step            # ray/cast/step.mcfunction

# 写法二：入口是方法目录里的空名函数
fn:ray/cast/                # ray/cast/.mcfunction
fn:ray/cast/step            # ray/cast/step.mcfunction
```

写法二调用时末尾要带 `/`：`function fn:ray/cast/`。

**N8 · 应该** 中间过程按功能命名，如 `read_input`、`write_data`。

**N9 · 应该** 手写函数一般不超过三层。宏穷举也放在第三层，条目多到影响浏览时可加第四层；生成器和大型模块按规模自定。层数只数斜杠，命名空间和点号不计。

```text
demo:character/update/case_0        # 第三层直接列出
demo:character/update/case/0        # 条目很多时收进第四层
```

可选写法：

- 过程再拆分时，用原过程名加下划线作前缀，文件放在同一层：`search` → `search_check_target` → `search_check_target_read_position`。
- 有循环的过程名中加 `loop`：`search_loop`、`search_loop_step`。

## 方法名

**N10 · 应该** 方法名尽量写明它修改的数据；太长时可省略部分，但不能产生歧义。

可以用 `modify_<target>` 和 `<source>_to_<target>`，所属类和 storage 由路径确定：

| 方法 | 含义 |
| --- | --- |
| `demo:item/modify_abc` | 修改 `storage demo:io item.abc` |
| `demo:item/score_to_abc` | `score item.abc demo` → `storage demo:io item.abc` |
| `demo:item/this_score_to_abc` | `score @s demo.item.abc` → `storage demo:io item.abc` |

| 数据位置 | 名称中的写法 |
| --- | --- |
| `@s` 的分数 | `this_score` |
| 假玩家分数 | `score` |
| storage | `store` |
| `@s` 的 NBT | `this_<名称>` 或 `this` |
| 方块的 NBT | `block_<名称>` 或 `this` |

用 `this` 时，要在类或函数文档里说明它指哪个实体或方块。

## 特殊名称

**N11 · 必须** 同一类中，去掉 `__` 标记后同名的方法不得表示不同功能，例如 `tick` 与 `__tick__`。〔检测 1〕

两者可以互为别名：一个只转发调用另一个，返回值、执行结果和副作用保持等价。

```text
demo:character/__tick__ → demo:character/tick
```

**N12 · 应该** 由游戏机制、函数标签或手动入口调用的方法，用 `__<name>__` 标记。

```text
__load__     # load 标签
__tick__     # tick 标签
__etick__    # 实体 tick
__rtick__    # 随机 tick
__5tick0__   # 每 5 tick，余数为 0 时
```

周期和随机调度由调用方负责。名称可加前缀表达用途，如 `__oh_no_42tick11__`。

**N22 · 应该** 由资源触发的函数也是自动方法，按 N12 加双下划线，路径与触发它的资源对应：同名，或放进同名目录按情况分开。适用于进度奖励、附魔效果、物品组件中的 `run_function`。〔检测 2〕

```text
进度 ns:player/inventory_changed       → function ns:player/__inventory_changed__
进度 ns:player/__inventory_changed__   → function ns:player/__inventory_changed__
附魔 ns:player/lightning               → function ns:player/__lightning__/0、/1、/2
```

**N23 · 必须** `__new__`、`__del__` 是保留方法名：`__new__` 创建本类实例，`__del__` 删除本类实例，不得用作其他用途。实体组的删除范围见[类与存储布局](storage.md#实体组) S14。实例本身怎样引用（分数 ID、UUID 等）由各子项目决定。

卸载入口用 `<ns>:__unload__`，见[通用协作规范](../core.md) C14。

## 封装接口

封装接口是给调用者用的干净入口：负责校验输入、补默认值，内部再调用普通接口。普通接口只管算法本身，性能更好，但调用步骤更多。两者不必同名。

**N17 · 必须** 本项目的封装接口用函数标签 `#<module>:<class>/<method>`，即在 frank.txt 中声明 `api_form tag`（见通用协作规范 C18）。〔检测 1〕

```mcfunction
# 普通接口：多步调用
function fn:id/assign
function fn:id/this_to_store
data modify storage fn:io store.op set value "data.a set value 1"
function fn:store/modify with storage fn:io store

# 封装接口：一步完成
function #fn:store/modify {op:"data.a set value 1"}
```

**N18 · 不得** 往其他包的封装接口标签里添加函数。只有 `#<module>:<class>/__<name>__` 形式的标签允许其他包添加，作为事件或钩子使用。〔检测 1〕

**N20 · 应该** 封装接口校验输入，缺省参数用 `stat` 中的默认值补齐。默认值的格式不做规定。

**N21 · 应该** 多个封装接口共用的输入处理，提取为私有方法，如 `fn:item/__handle_input`。

```mcfunction
# fn:item/__handle_input
data modify storage fn:temp item set from storage fn:stat item.default_input
$data merge storage fn:temp item {with:$(with)}
```

## 其他资源

**N19 · 应该** 进度、谓词、物品修饰器、战利品表、方块／物品／实体类型标签、配方等资源，和函数一样按 `<module>:<class>/<name>` 组织。〔检测 2〕

| 资源 | 例 |
| --- | --- |
| 进度（作触发器） | `demo:player/hurt` 或 `demo:player/__hurt__` |
| 谓词 | `demo:player/is_sneaking` |
| 物品修饰器 | `demo:item/set_damage` |
| 战利品表 | `demo:item/sword` |
| 类型标签 | `#demo:block/breakable` |

作触发器的进度，在它触发的函数里撤销；触发的函数按 N22 命名，如 `demo:player/__hurt__`。

## 可见性

**N13 · 必须** 中间过程只由所属方法调用。〔检测 1〕

**N14 · 必须** 私有方法以 `__` 开头。单个 `_` 开头不表示任何可见性，由各包自定。

**N15 · 应该** 多个方法要用同一中间过程时，提取为私有方法 `__<name>`。

**N16 · 不应** 在类外调用该类的私有方法；继承类可以调用。〔检测 2〕

```text
demo:character/create/validate     # 只给 create 用
demo:character/__validate          # character 内共享
demo:character.knight/update       # 可以调用 character/__validate
```

自动方法也可以兼作私有入口，由类文档说明。私有方法的变量规则见[变量与调用边界](variables.md#私有方法)。
