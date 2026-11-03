# 核心概念

本页集中说明 FCP 和 frank 文档中的术语。各章末尾的“相关概念”链接到这里；具体要求仍见对应规范。

## 字段与关系

### 模块

组织字段的命名单位，在数据包约定中用 Minecraft 命名空间表示。例如，`demo:player` 中的 `demo` 是模块名。见 [FCP 3：存储归属](fcp/fcp-0003-fields-storage.md#存储归属)。

### 字段

也称“类”，是一组命名和数据格式的约定，其数据按需存放在 storage、记分板、实体或方块中。例如，`player` 字段可以约定玩家等级等数据的名称及含义。见 [FCP 3](fcp/fcp-0003-fields-storage.md#字段)。

### 属性

对象的一部分数据。例如，`pos.x` 表示位置的 x 分量，回答“对象有什么数据”。见 [FCP 3：属性与继承](fcp/fcp-0003-fields-storage.md#属性与继承)。

### 继承

用更具体的类型细分已有类型。例如，`character` 表示角色，`character.knight` 表示骑士这一种完整的角色类型。这里 `character` 是父字段或父类型，`character.knight` 是继承字段或继承类型。见 [FCP 3：属性与继承](fcp/fcp-0003-fields-storage.md#属性与继承)。

### 子字段与字段值

子字段是字段下进一步划分的字段，例如 `item.tool` 中的 `tool`。子字段表示属性还是继承，由字段约定决定。字段值指字段自身保存的值。存储布局发生冲突时，见 [FCP 3：NBT 路径冲突](fcp/fcp-0003-fields-storage.md#nbt-路径冲突)。

### 继承冲突

父类型与继承类型的数据对同一 NBT 节点要求不同类型的情况，属于 NBT 路径冲突。处理方式和示例见 [FCP 3](fcp/fcp-0003-fields-storage.md#nbt-路径冲突)。

## 方法与调用

### 方法

属于某个字段的函数。例如，`demo:player/update` 是 `player` 字段的 `update` 方法。方法内部可以继续拆分中间过程。见 [FCP 2：函数路径](fcp/fcp-0002-naming.md#函数路径)。

### 接口

调用者与函数之间约定的调用方式、输入、输出及其他使用要求。作为调用入口提供的函数称为接口函数，也称接口方法；“对外”表示面向调用者，不限于另一个数据包。见 [FCP 4](fcp/fcp-0004-function-contracts.md#头文档)。

### 普通调用

调用普通方法时，按该方法的输入接口传值。调用前的 `#a`、`##a` 类临时变量在返回后失效，接口变量仍按各自约定处理。调用所属方法的中间过程不属于调用其他方法。见 [FCP 5](fcp/fcp-0005-variable-lifetimes.md#普通调用)。

### 中间过程

由某个方法独占、只供该方法调用的辅助函数，例如 `demo:player/update/check_state`。进一步拆分出的过程也称子过程。多个方法需要共享时，提取为私有方法。见 [FCP 6](fcp/fcp-0006-special-names.md#私有方法与中间过程)。

### 私有方法

供所属字段及其继承字段内部使用的方法，例如 `demo:player/__validate`。同类私有方法可以按内部约定读取类内变量，但不保留调用者的临时变量。方法的调用范围见 [FCP 6](fcp/fcp-0006-special-names.md#私有方法与中间过程)；变量范围见 [FCP 5](fcp/fcp-0005-variable-lifetimes.md#私有调用)。

### 自动方法

预期由游戏机制、标签分发或手工入口调用的方法，也称自动入口，例如 `__load__`、`__tick__`。自动方法也可以承担私有入口，具体角色由字段说明。见 [FCP 6](fcp/fcp-0006-special-names.md#自动方法)。

### 别名

同一方法的另一个名称，通过一层转发实现。两者的返回值、命令执行结果和其他副作用保持等价。这里指方法别名；类型别名和运算符别名分别按相应文档解释。见 [FCP 6](fcp/fcp-0006-special-names.md#名称冲突与别名)。

### 嵌套调用

一个调用尚未结束时，又在内部调用其他方法。多次调用需要占用同一数据位置时，可用变量栈隔离状态；具体调用规则见 [FCP 5](fcp/fcp-0005-variable-lifetimes.md#递归与嵌套调用)。

## 数据范围与存储

### 临时变量

用于方法内计算和交换的值。`#a` 可供所属方法及其中间过程使用，调用其他方法后失效；`##a` 是强制临时变量，调用任意函数后失效。两者均在当前 tick 结束后失效，不要求实际清空数据。见 [FCP 5](fcp/fcp-0005-variable-lifetimes.md#普通调用)。

### 类内变量

作为类内部接口、供同类方法共享的变量，写作 `<class>.__<name>`，例如 `pos.__a`。只允许所属类的方法及其中间过程读写，当前 tick 内有效。见 [FCP 5：变量用途](fcp/fcp-0005-variable-lifetimes.md#变量用途)。

### 接口值

按接口约定读写的变量值。对外接口变量使用类名或 `<class>.<name>`，例如 `pos`、`pos.x`；类内部接口使用类内变量。普通接口变量当前 tick 内有效，跨 tick 全局变量写作 `pos.__count__` 等形式。见 [FCP 5：变量用途](fcp/fcp-0005-variable-lifetimes.md#变量用途)。

### 变量栈

为每次调用分别保存数据，避免多次调用互相覆盖。可使用字段 storage 下的 `ins` 列表，每项保存一份调用数据，内部规则与 storage 根目录相同。保存、恢复及列表操作由开发者决定。见 [FCP 3](fcp/fcp-0003-fields-storage.md#存储归属)、[FCP 5](fcp/fcp-0005-variable-lifetimes.md#递归与嵌套调用)。

### 长期状态

需要跨 tick 保存的数据。跨 tick 全局变量保留类名前缀，用双下划线包围变量名，写作 `<class>.__<name>__`，例如 `pos.__count__`；变量名不固定。storage 中的长期数据也可按用途保存在 `data`、`stat` 等位置。见 [FCP 5](fcp/fcp-0005-variable-lifetimes.md#tick-边界)、[FCP 6](fcp/fcp-0006-special-names.md#长期变量)。

### 存储角色

字段内部按用途划分的数据区域：`temp` 用于临时交换，`data` 用于跨 tick 保存的动态数据，`ins` 为 compound 列表，每项内部与根目录使用相同规则，`stat` 用于全静态数据。这些是推荐布局，也可以添加其他内容。见 [FCP 3：存储归属](fcp/fcp-0003-fields-storage.md#存储归属)。

## 函数文档与 frank

### 头文档

mcfunction 文件开头，以 `#> ` 开始的一组连续注释，用于说明函数。起始行称为函数标识行；后续内容按需要填写。见 [FCP 4](fcp/fcp-0004-function-contracts.md#头文档)和[快速入门](frank/quickstart.md#如何开始)。

### 文档字段

头文档中由 `@名称` 标签与下方内容组成的说明块，例如 `@input`。它与前文表示数据约定的“字段”含义不同。`input`、`output`、`usage`、`limitation`、`side_effect` 是保留字段名，其他名称用于自定义字段。见 [FCP 4](fcp/fcp-0004-function-contracts.md#保留字段与扩展)。

### 副作用

除输出以外的状态变化，例如函数还会移除执行者的某个 tag。可以写入说明或 `@side_effect`。见 [FCP 4](fcp/fcp-0004-function-contracts.md#保留字段与扩展)。

### frank 表达式

用于函数文档的统一、简洁的伪代码写法，首先供人阅读，也便于按需进行形式化检查。见 [frank 快速入门](frank/quickstart.md)。

### 数据位置

数据存放位置的表达方式，例如 `score(@s demo.health)`、`storage(demo:player level)`。单独列出位置也称位置声明，不要求给它起名或赋值。见 [frank：数据位置](frank/expressions.md#数据位置)。

### 逻辑记法

在规范中描述位置、路径或调用关系的简写，例如 `score player.level demo`。这些写法用于说明；可运行命令使用 mcfunction 语法，frank 表达式使用括号形式。见 [FCP 7：文档约定](fcp/fcp-0007-source-dialects.md#文档约定)。

### 名称与取值时机

用 `名称 = 表达式` 给值起名，名称始终表示起名时的值。头文档中，`@input`、`@limitation` 读取调用前的数据，`@output`、`@side_effect` 读取调用返回后的数据。已定义的名称可在后续文档字段中使用。见 [frank：名称定义](frank/expressions.md#名称定义)、[FCP 9](fcp/fcp-0009-frank-expressions.md#名称与取值时机)。

### 形式化检查

由工具检查表达式的语法、类型或条件等内容，是 frank 的可选用途。检查通过只说明已检查的内容满足相应要求，不能代替未检查部分的结论。见 [frank：形式化检查](frank/checking.md)。

### 自动识别

工具尝试将文档内容解析为 frank 表达式，括号内的多行内容合在一起解析。解析失败时，内容保留为说明；明确指定需要检查的表达式解析失败时，报告错误。见 [frank：自动识别与明确检查](frank/checking.md#自动识别与明确检查)。

### 类型声明

在名称前补充数据类型。内置类型可以直接使用；自定义类型通过 `add_type` 注册，可用 Python 检查函数判断值是否符合要求。具体类型名和检查函数写法见 [frank：类型补充与自定义检查](frank/types.md)。
