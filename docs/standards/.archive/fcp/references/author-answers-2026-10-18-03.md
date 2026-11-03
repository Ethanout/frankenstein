# 问题与答复

更新日期：2026-10-18。

Q00—Q14 已有答复，结论已写入对应提案。Q15—Q19 是 FCP 9 首稿的待确认选择；其中的初稿方案用于评审，不视为作者已确认的决定。

完整填写记录：[第一轮答复](references/author-answers-2026-10-18.md)、[第二轮答复](references/author-answers-2026-10-18-02.md)。

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

## FCP 9 首稿待确认

### Q15

**如何区分 frank 表达式与自然语言？**

初稿方案：Markdown 用 `frank` 代码块明确标记；头文档由调用方配置指定字段或片段，不新增必填标签，也不强制把整个字段当成表达式。

已确认：需要形式化检查时，可以在同一字段中混写自然语言和 frank 表达式，用表达式写出需要检查的内容。

待确认：头文档混写表达式和说明时，是否需要统一的片段标记？
使用井号或双斜杠开头注释，使用三引号或/* */多行注释

### Q16

**名称定义、相等关系与调用前后的值**

初稿方案：`=` 只给文档中的值起名，`==` 描述相等；输入名称保留调用前的值，输出位置读取调用返回后的值。因此可以用 `score(x.math demo) == x * x` 描述原地求平方。

待确认：这种写法是否符合预期？是否还需要为指定输出值引入另一种写法？
类python写法可以

### Q17

**正则表达式的匹配范围与方言**

初稿方案：`name matches r"..."` 检查整个字符串；首稿只规定基础正则结构，不规定反向引用、环视或匹配标志。

待确认：是否采用整串匹配？是否需要子串检索、大小写标志或指定某个正则引擎的方言？
正则表达式我希望可以内嵌于表达式中


### Q18

**数学值与游戏数值的区别**

初稿方案：普通算术按精确数学值解释，不隐式模拟 32 位溢出；`//` 向下取整，`%` 与之配套。具体函数通过输入范围或显式转换约定处理游戏行为。

待确认：是否还要提供按记分板整数行为计算的形式，以表达截断、溢出或数值类型转换？
可以规定数据类型，如
x = storage(a:b 12)
any x = storage(a:b 12)
两者等价

另外
int n = storage(a:b n)
real x = storage(a:b x)
complex z = storage(a:b z)
quaternion q = storage(a:b q)
mat3 m = storage(a:b q)
mat4 m = storage(a:b q)

可以自己定义数据类型，定义方式可以是：
add_type tensor py_def(这里末尾是py的一个函数，输入一个值，返回bool)
add_type tensor py_def(
    def f(data):
        # 这里是检查张量的代码
    f
)
add_type positive_integer py(lambda x: x > 0 and a % 1 == 0)
add_type positive_integer python(lambda x: x > 0 and a % 1 == 0)
add_type positive_integer py lambda x: x > 0 and a % 1 == 0
add_type positive_integer python lambda x: x > 0 and a % 1 == 0

### Q19

**逻辑运算符、括号与换行**

初稿方案：使用 `and`、`or`、`not`，优先级为比较、`not`、`and`、`or`；只在括号内续行，续行推荐缩进四个空格。

待确认：是否保留这一套写法？是
是否需要同时接受 `&&`、`||`、`!` 等符号形式？是
