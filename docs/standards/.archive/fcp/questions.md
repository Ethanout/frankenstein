# 问题与答复

更新日期：2026-10-19。

Q00—Q23 的答复已整理。frank 的具体写法及后续问题独立维护于 [frank 文档表达式](../frank/quickstart.md)；数值运算与类型名称的确认结果见 [Q22—Q23](../frank/questions.md#q22)，混合运算的待细化内容见 [Q24](../frank/questions.md#q24)。

完整填写记录：[第一轮答复](references/author-answers-2026-10-18.md)、[第二轮答复](references/author-answers-2026-10-18-02.md)、[第三轮答复](references/author-answers-2026-10-18-03.md)、[第四轮答复](references/author-answers-2026-10-19.md)。

## 已记录的决定

### Q00

**规范维护位置**

在当前项目的 `docs/standards/` 维护，FCP 系列位于 `fcp/`。

### Q01

**变量前缀**

- 数字常量的 `#` 可加可不加。
- `$` 对外接口前缀可选。
- `##temp` 表示不跨函数的局部值，是可选建议。
- `#shared` 表示字段内跨方法共享，范围含义是规范要求。

已写入 [FCP 5](fcp-0005-variable-lifetimes.md) R06—R09。

**补充答复原文：** `##temp` 表示不跨函数为可选建议，`#shared` 表示可跨方法、限字段内使用为规范要求。

### Q02

**按角色区分存储**

第一轮确认独立 storage ID 作为建议。随后在 Q14 比较新的协作布局，并确认采用 `module:class`。

当前布局统一见 [FCP 3](fcp-0003-fields-storage.md)。

### Q03

**接口中字段值与子字段的冲突**

选择 A：接口发生 NBT 形状冲突时，使用 `value` 保存字段自身的值。协作时，接口数据通常由所属字段的方法管理。

按当前布局更新示例：

```mcfunction
data modify storage demo:item abc set value {value:1,damage:2}
```

`demo:item abc.damage` 通常由 `demo:item/...` 读写，其他字段通过接口方法使用。

已写入 [FCP 3](fcp-0003-fields-storage.md) R04、R10。

**答复原文：** A。但是在协作的时候，demo:io item.damage一般是不会被内部的function demo:item/xxx以外的其他函数调用的

### Q04

**私有方法内部调用普通方法**

私有方法通常只嵌套调用私有方法，避免调用普通方法和上层逻辑。确需嵌套普通方法时，外层共享值仍可使用，修改计入私有方法的副作用。

原例中，`a → __b → c` 将 `#a demo` 从 1 改为 2。返回后 `a` 可以读取 2，无须因嵌套调用而将该共享值视为未知。

已写入 [FCP 5](fcp-0005-variable-lifetimes.md) R03、R10、R11。

**答复原文：** 私有方法内部一般不允许调用普通方法，只能私有套私有。`__b`的含义就是告诉你这个方法是公共调用，确保安全的，因此一般不在`__b`里调用其他上层逻辑。如果一定要套，#a demo还是视为未被销毁，`__b`产生的修改视为副作用。

### Q05

**私有方法读取共享值**

选择 A：同字段私有方法可以按内部约定读取调用者的共享值，不要求单独声明输入。

已写入 [FCP 4](fcp-0004-function-contracts.md) R06 和 [FCP 5](fcp-0005-variable-lifetimes.md)。

**答复原文：** A

### Q06

**变量栈职责**

变量栈负责存放需要隔离的调用状态，具体操作由开发者决定。后续会话明确使用 `ins`：它是 compound 列表，每项内部与 storage 根目录使用相同规则。

已写入 [FCP 3](fcp-0003-fields-storage.md) 和 [FCP 5](fcp-0005-variable-lifetimes.md)。

### Q07

**继承访问、入口角色与别名**

- `character.knight` 可以调用 `character` 的私有方法。
- 自动方法可以同时承担私有入口。
- 纯转发别名的返回值、执行结果和其他副作用需要完全等价。

已写入 [FCP 6](fcp-0006-special-names.md)。

### Q08

**继承冲突的分支名称**

`default` 或 `dummy` 由字段或项目选择，在布局文档中注明，作为建议。

已写入 [FCP 3](fcp-0003-fields-storage.md)。

### Q09

**目录深度**

深度建议面向手写文件。宏穷举原则上放第三层，第四层用于让第三层更易浏览。大型分支模块和生成器可以例外。

已写入 [FCP 2](fcp-0002-naming.md) 和 [FCP 7](fcp-0007-source-dialects.md)。

### Q10

**attr.txt 登记**

规范对 `attr.txt` 不作要求。

已写入 [FCP 4](fcp-0004-function-contracts.md)。

### Q11

**游戏版本基线**

以 Minecraft Java 1.15+ 为基线。特定功能的版本条件见 [FCP 7](fcp-0007-source-dialects.md)。

### Q12

**提案形式与可读性**

采用 Python PEP 风格：文档头、独立编号、类型和状态，以及摘要、动机、规范、设计理由等正文部分。

来源与讨论集中在独立文档，正文保留规则、理由和示例。

### Q13

**ins 的含义**

当前统一使用 `ins`，取代旧名 `stack`。它是 compound 列表，形如 `[{...}, {...}]`，每个 compound 内部与 storage 根目录使用完全相同的规则，见 [FCP 3](fcp-0003-fields-storage.md#存储归属)。

### Q14

**协作存储布局**

已确认采用 `module:class`：

```text
storage demo:damage temp
storage demo:damage data
storage demo:damage ins
storage demo:damage stat
```

storage ID 的归属命名为规范要求；标准角色布局为建议（SHOULD），开发者可以按需添加自定义内容（MAY）。具体定义见 [FCP 3](fcp-0003-fields-storage.md) R11、R12。

后续会话取消 `io` 推荐角色；`temp` 用于临时交换，`data` 用于跨 tick 保存的动态数据，`ins` 为 compound 列表，`stat` 用于全静态数据。

**会话确认原文：** 那就module:class吧

角色优先布局与字段优先布局的原始讨论保存在[第二轮答复](references/author-answers-2026-10-18-02.md)。

## FCP 9 的第三轮答复

### Q15

**如何区分 frank 表达式与自然语言？**

已确认：可以直接混写自然语言和 frank 表达式。自动识别失败的内容保留为说明，不参与检查；疑似表达式笔误给出提示，明确要求检查的表达式解析失败时仍报告错误。后续会话取消三引号及块注释，仅保留 `#` 显式注释；多行说明直接分行书写，或逐行加 `#`。

第三轮答复原先还允许 `//` 注释；后续会话要求删除歧义用法，当前 `//` 只表示整除。

检查范围见 [FCP 9](fcp-0009-frank-expressions.md) R01，注释写法见 [frank](../frank/quickstart.md) 的[注释与换行](../frank/lexical.md#注释)。

### Q16

**名称定义、相等关系与调用前后的值**

已确认采用类 Python 写法：`=` 给值起名，`==` 描述相等；输入名称保留调用前的值，输出位置读取调用返回后的值。

名称定义见 frank 的[名称定义](../frank/expressions.md#名称定义)，头文档取值时机见 [FCP 9](fcp-0009-frank-expressions.md) R05。**答复原文：** 类python写法可以

### Q17

**正则表达式的匹配范围与方言**

第三轮答复希望正则可以内嵌于表达式；第四轮答复要求先搁置正则，当前规范不定义相关语法。

暂缓决定见 [Q21](../frank/questions.md#q21)，原 FCP 9 R11、R12 的编号保留，不复用。

**答复原文：** 正则表达式我希望可以内嵌于表达式中

### Q18

**类型声明与自定义类型**

已确认：

- `x = storage(a:b 12)` 与 `any x = storage(a:b 12)` 等价。
- 可以声明 `int`、`real`、`complex`、`quaternion` 等类型。矩阵统一使用 `ndarray`，类型列表的后续调整见 [frank Q23](../frank/questions.md#q23)。
- 可以通过 `add_type` 注册自定义类型，检查函数接收一个值并返回 `bool`。
- `py` 与 `python` 等价，均支持括号形式及直接接 Python 表达式的形式。
- `py_def(...)` 可以包含多行定义，末尾表达式给出检查函数。

已写入 [frank](../frank/quickstart.md) 的[类型补充与自定义检查](../frank/types.md)。完整代码保留于[第三轮答复](references/author-answers-2026-10-18-03.md)；规范示例将正整数谓词中的 `a % 1` 修正为 `x % 1`。

类型布局与 NBT 的答复见 Q20，数值运算的补充答复见 [Q22](../frank/questions.md#q22)。

### Q19

**逻辑运算符、括号与换行**

已确认保留 `and`、`or`、`not` 及原有优先级，同时接受等价的 `&&`、`||`、`!`。括号内续行，续行推荐缩进四个空格。

已写入 [frank](../frank/quickstart.md) 的[括号与换行](../frank/lexical.md#括号与换行)、[运算优先级与逻辑条件](../frank/expressions.md#运算优先级)。

## frank 语言的第四轮答复

### Q20

**类型的存储布局与数值实现**

已确认：不提供复数和四元数的默认布局；使用 `minecraft_int` 表达游戏整数；NBT 使用 nbtlib。已写入 [frank](../frank/quickstart.md) 的[类型补充与自定义检查](../frank/types.md)。矩阵类型的后续调整见 [frank Q23](../frank/questions.md#q23)。

答复原文保存在[第四轮答复](references/author-answers-2026-10-19.md)。溢出运算及 `real` 精度已由后续 [Q22](../frank/questions.md#q22) 确认。

### Q21

**正则匹配范围与具体方言**

**答复原文：** 正则表达式先不要，到后面再说

已撤下当前规范中的正则语法、示例及整串匹配默认，后续再讨论。决定记录见 [frank Q21](../frank/questions.md#q21)。

## frank 语言的后续答复

### Q22

`minecraft_int` 的运算行为和 `real` 精度见 [frank Q22](../frank/questions.md#q22)。后续语言问题统一在该处维护。

相关概念：[核心概念](../core-concepts.md)。
