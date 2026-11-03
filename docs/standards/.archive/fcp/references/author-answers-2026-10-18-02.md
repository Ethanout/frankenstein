# 问题与答复

更新日期：2026-10-18。

本页优先列出需要继续讨论的问题，可以直接填写“答复”。已收到的决定列在后半部分；你上次填写的完整原文保存在[答复快照](references/author-answers-2026-10-18.md)。

## 待讨论

### Q03

**接口里既要保存 item 的值，又要保存 item.damage，怎样组织？**

例如，两处代码分别想保存：

```mcfunction
data modify storage demo:io item set value 1
data modify storage demo:io item.damage set value 2
```

第一条让 `item` 成为数字。第二条需要它是一个包含 `damage` 的 compound，因此这两个位置不能同时保存这两份数据。

这时，是否建议接口也使用 `value`？

```mcfunction
data modify storage demo:io item set value {value:1,damage:2}
```

- A：是，接口发生这种冲突时也用 `item.value` 和 `item.damage`。
- B：接口不统一增加 `value`，由接口作者选择两个不冲突的位置，并写在接口说明中。

关联：[MCF 3](mcf-0003-fields-storage.md)。

**答复：**A。但是在协作的时候，demo:io item.damage一般是不会被内部的function demo:item/xxx以外的其他函数调用的

### Q04

**私有方法内部调用普通方法后，外层的临时值还能不能继续用？**

假设 `demo` objective 已创建。下面有三个函数，调用顺序是 `a → __b → c`：

```mcfunction
# demo:field/a
scoreboard players set #a demo 1
function demo:field/__b
scoreboard players get #a demo

# demo:field/__b
function demo:field/c

# demo:field/c
scoreboard players set #a demo 2
```

最后读取到的实际值是 2。需要决定的是：这段代码违反了哪一条约定，应该怎样改？

- A：`__b` 应保留外层仍需要的 `#a`。它要在调用 `c` 前保存、之后恢复，让 `a` 继续读到 1。
- B：调用链中出现了普通方法 `c`，外层的 `#a` 也视为未知。`a` 应改用接口或栈保存需要保留的值。

关联：[MCF 5](mcf-0005-variable-lifetimes.md)。

**答复：**私有方法内部一般不允许调用普通方法，只能私有套私有。`__b`的含义就是告诉你这个方法是公共调用，确保安全的，因此一般不在`__b`里调用其他上层逻辑。如果一定要套，#a demo还是视为未被销毁，`__b`产生的修改视为副作用。

### Q05

**私有方法读取调用者的临时值，需要写在输入说明里吗？**

假设 `demo` objective 已创建：

```mcfunction
# demo:field/a
scoreboard players set #damage demo 10
function demo:field/__calculate

# demo:field/__calculate
scoreboard players operation #result demo = #damage demo
```

`__calculate` 能在命令层面读到 10。这里要决定的是：规范是否允许它直接依赖这个值？

- A：同字段的私有方法可以按内部约定直接读取，不要求单独声明。
- B：需要在 `__calculate` 的接口说明中写明 `#damage demo` 是输入。

关联：[MCF 4](mcf-0004-function-contracts.md)、[MCF 5](mcf-0005-variable-lifetimes.md)。

**答复：**A

### Q01

**普通变量要不要统一用 # 与 ## 区分范围？**

已确认：数字常量的 `#` 可加可不加，`$` 对外接口前缀也是可选的，已写入 [MCF 5](mcf-0005-variable-lifetimes.md)。

还有一部分需要决定：GameCore 原约定中，`##temp` 表示不跨函数，`#shared` 表示可跨方法、限字段内使用。这组区分是否保留为统一建议？

- A：保留；普通变量按这组前缀表达范围。
- B：不统一前缀；范围由变量用途和接口约定说明。

**已收到的答复：** 数字是例外，加#是为了更好的性能，对于数字，#可加可不加。“$xx 为对外接口”不是强制规则

**补充答复：**  `##temp` 表示不跨函数为可选建议，`#shared` 表示可跨方法、限字段内使用为规范要求。

### Q14

**是否增加模块存储？module 是固定名称，还是模块名占位？**

按你的设想，[MCF 8](mcf-0008-module-storage.md) 展开了两种布局。假设模块名为 `combat`：

- A：模块名作为 ID，例如 `storage demo:combat io.damage`、`temp.target`、`data.cooldown`。
- B：使用固定的 `demo:module`，例如 `storage demo:module combat.io.damage`。
- C：暂时保持 MCF 3 的公共存储布局，后续再增加模块存储。

**答复：** 我在想2套规范哪种更好
一套是强制性命名io data等，后面强制使用class名
storage demo:io damage
storage demo:io temp.damage
storage demo:data damage

一套是强制性规定module:class，后面写什么仅为建议，可能更适合推广协作
storage demo:damage io
storage demo:damage data
storage demo:damage stack


## 已记录的决定

### Q00

**规范维护位置**

在当前项目的 `docs/standards/` 维护，MCF 系列位于 `mcf/`。

### Q02

**公共 storage 布局**

采用 Wiki 的多个 storage ID 作为规范建议：`<namespace>:io`、`:stack`、`:stat`、`:data`。

已写入 [MCF 3](mcf-0003-fields-storage.md)。你提出的模块存储想法另见 MCF 8 和 Q14。

### Q06

**变量栈职责**

变量栈只负责存放，具体操作由开发者决定。

已写入 [MCF 3](mcf-0003-fields-storage.md) 和 [MCF 5](mcf-0005-variable-lifetimes.md)。

### Q07

**继承访问、入口角色与别名**

- `character.knight` 可以调用 `character` 的私有方法。
- 自动方法可以同时承担私有入口。
- 纯转发别名的返回值、执行结果和其他副作用需要完全等价。

已写入 [MCF 6](mcf-0006-special-names.md)。

### Q08

**父类型分支名称**

`default` 或 `dummy` 由字段或项目选择，在布局文档中注明，作为建议。

已写入 [MCF 3](mcf-0003-fields-storage.md)。

### Q09

**目录深度**

深度建议面向手写文件。宏穷举原则上放第三层，第四层用于让第三层更易浏览。大型分支模块和生成器可以例外。

已写入 [MCF 2](mcf-0002-naming.md) 和 [MCF 7](mcf-0007-source-dialects.md)。

### Q10

**attr.txt 登记**

规范对 `attr.txt` 不作要求。

已写入 [MCF 4](mcf-0004-function-contracts.md)。

### Q11

**游戏版本基线**

以 Minecraft Java 1.15+ 为基线。特定功能的版本条件见 [MCF 7](mcf-0007-source-dialects.md)。

### Q12

**提案形式与可读性**

采用 Python PEP 风格：文档头、独立编号、类型和状态，以及摘要、动机、规范、设计理由等正文部分。

本次重写精简了正文，将来源与讨论集中到独立文档。

### Q13

**ins 的含义**

`ins` 是 `stack` 的遗留同义词。新文统一使用 `stack`，见 [MCF 3](mcf-0003-fields-storage.md)。
