# 问题与答复

更新日期：2026-10-19。

Q00—Q19 的答复已写入对应提案。答复未指定的数值布局、匹配方式和引擎细节集中记录为 Q20—Q21，供后续补充。

完整填写记录：[第一轮答复](references/author-answers-2026-10-18.md)、[第二轮答复](references/author-answers-2026-10-18-02.md)、[第三轮答复](references/author-answers-2026-10-18-03.md)。

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

当前布局统一见 [FCP 3](fcp-0003-fields-storage.md) 和 [FCP 8](fcp-0008-module-storage.md)。

### Q03

**接口中字段值与子字段的冲突**

选择 A：接口发生 NBT 形状冲突时，使用 `value` 保存字段自身的值。协作时，接口数据通常由所属字段的方法管理。

按 Q14 的布局更新示例：

```mcfunction
data modify storage demo:item io set value {value:1,damage:2}
```

`demo:item io.damage` 通常由 `demo:item/...` 读写，其他字段通过接口方法使用。

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

变量栈只负责存放，具体操作由开发者决定。

已写入 [FCP 3](fcp-0003-fields-storage.md) 和 [FCP 5](fcp-0005-variable-lifetimes.md)。

### Q07

**继承访问、入口角色与别名**

- `character.knight` 可以调用 `character` 的私有方法。
- 自动方法可以同时承担私有入口。
- 纯转发别名的返回值、执行结果和其他副作用需要完全等价。

已写入 [FCP 6](fcp-0006-special-names.md)。

### Q08

**父类型分支名称**

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

`ins` 是 `stack` 的遗留同义词。新文统一使用 `stack`，见 [FCP 3](fcp-0003-fields-storage.md)。

### Q14

**协作存储布局**

已确认采用 `module:class`：

```text
storage demo:damage io
storage demo:damage data
storage demo:damage stack
```

storage ID 的归属命名为规范要求；标准角色布局为建议（SHOULD），开发者可以按需添加自定义内容（MAY）。具体定义见 [FCP 3](fcp-0003-fields-storage.md) R11、R12，比较和迁移说明见 [FCP 8](fcp-0008-module-storage.md)。

**会话确认原文：** 那就module:class吧

角色优先布局与字段优先布局的原始讨论保存在[第二轮答复](references/author-answers-2026-10-18-02.md)。

## FCP 9 的第三轮答复

### Q15

**如何区分 frank 表达式与自然语言？**

已确认：需要形式化检查时，可以混写自然语言和 frank 表达式。frank 片段中，`#` 开始单行注释，三引号或 `/* ... */` 表示多行注释。

第三轮答复原先还允许 `//` 注释；后续会话要求删除歧义用法，当前 `//` 只表示整除。

已写入 [FCP 9](fcp-0009-frank-expressions.md) R01、R16。

### Q16

**名称定义、相等关系与调用前后的值**

已确认采用类 Python 写法：`=` 给值起名，`==` 描述相等；输入名称保留调用前的值，输出位置读取调用返回后的值。

已写入 [FCP 9](fcp-0009-frank-expressions.md) R04、R05。**答复原文：** 类python写法可以

### Q17

**正则表达式的匹配范围与方言**

已确认正则可以内嵌于表达式；可以用模式参与匹配条件，再与其他条件组合。已写入 [FCP 9](fcp-0009-frank-expressions.md) R11。

匹配范围、匹配标志及具体方言未在答复中指定，后续问题见 Q21。

**答复原文：** 正则表达式我希望可以内嵌于表达式中

### Q18

**类型声明与自定义类型**

已确认：

- `x = storage(a:b 12)` 与 `any x = storage(a:b 12)` 等价。
- 可以声明 `int`、`real`、`complex`、`quaternion`、`mat3`、`mat4` 等类型。
- 可以通过 `add_type` 注册自定义类型，检查函数接收一个值并返回 `bool`。
- `py` 与 `python` 等价，均支持括号形式及直接接 Python 表达式的形式。
- `py_def(...)` 可以包含多行定义，末尾表达式给出检查函数。

已写入 [FCP 9](fcp-0009-frank-expressions.md) R17—R19。完整代码保留于[第三轮答复](references/author-answers-2026-10-18-03.md)；规范示例将正整数谓词中的 `a % 1` 修正为 `x % 1`。

类型的具体布局及其与游戏数值行为的关系见 Q20。

### Q19

**逻辑运算符、括号与换行**

已确认保留 `and`、`or`、`not` 及原有优先级，同时接受等价的 `&&`、`||`、`!`。括号内续行，续行推荐缩进四个空格。

已写入 [FCP 9](fcp-0009-frank-expressions.md) R07—R10。

## 待补充

### Q20

**类型的存储布局与数值实现**

当前处理：类型描述数学含义，具体存储布局由字段或类型适配约定说明；未说明时，检查器报告无法检查。标量运算仍保留数学语义草案。

待补充：是否提供复数、四元数和矩阵的默认分量名称、顺序或 NBT 布局？不提供
`int` 的范围、`real` 的精度和游戏整数溢出如何约定？minecraft_int
Python 检查函数接收的值如何从 NBT 映射？使用nbtlib


### Q21

**正则匹配范围与具体方言**

当前处理：正则可内嵌表达式，模式可以给值起名并参与逻辑组合；示例暂按整串匹配解释。

待补充：是否确定采用整串匹配？正则表达式先不要，到后面再说
是否需要独立的子串检索形式？匹配标志和正则方言采用哪一种？
