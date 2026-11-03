# 类型补充与自定义检查

类型用于补充说明数据的含义，按需要填写。只需列出数据位置时，使用[常用写法](expressions.md)即可。

## 类型声明

可以在名称前写明类型。省略类型等价于 `any`，不额外约束该值的类型。以下两种写法等价，分别独立使用：

```frank
x = storage(a:b 12)
```

```frank
any x = storage(a:b 12)
```

`any` 仅省略类型限制。检查器仍按已知的值或类型判断运算是否适用；不适用的运算仍报错。

## 内置类型

支持数学类型、全部 NBT 类型，以及 Python、NumPy 中的类型。常用写法如下，不逐一列举：

| 类型或写法 | 含义 |
| --- | --- |
| `any` | 不额外限制值的类型 |
| `int` | 数学意义上的精确整数 |
| `real` | 数学意义上的精确实数，包括整数 |
| `bool`、`str`（`string`） | 布尔值、字符串；`str` 与 `string` 等价 |
| `float`、`complex` | Python 浮点数、复数 |
| `list`、`tuple`、`dict` 等 | Python 容器类型 |
| `float32`、`float64`、`int32`、`int64` 等 | NumPy 数值类型 |
| `ndarray` | NumPy 数组，也用于描述矩阵；形状和元素类型按需说明 |
| `quaternion` | 四元数 |
| `minecraft_*` | 对应 NBT 类型，如 `minecraft_byte`、`minecraft_int`、`minecraft_list`、`minecraft_int_array` |

语义相同的类型共用名称。NumPy 类型名无冲突时可省略 `np.`，如 `float32` 与 `np.float32` 等价；嵌入 Python 时仍使用 Python 的名称写法。

`int`、`real` 按精确数学值解释；Python、NumPy 类型沿用各自的精度和运算规则；`minecraft_*` 完整遵循对应的游戏规则。具体运算见[数值运算](expressions.md#数值运算)，尚未明确的混合运算见 [Q24](questions.md#q24)。

`minecraft_` 后接 NBT 类型名的小写下划线形式。检查 NBT 数据时，核对具体的标签类型；记分板整数也可用 `minecraft_int` 描述。类型声明不自动转换数据。复数和四元数如何存为 NBT，由项目说明。

## 自定义类型

已有类型不足以说明项目中的数据格式时，可以再定义自己的类型。以下 Python 写法用于为自定义类型提供可选的工具检查。

使用 `add_type 类型名 检查函数` 注册自定义类型，注册后才能用于类型声明。类型名遵守[名称规则](lexical.md#名称)。同一检查环境中，类型名不得重复注册，也不得覆盖内置类型及其别名。

```frank
add_type positive_integer py(lambda x: x > 0 and x % 1 == 0)
positive_integer n = storage(a:b n)
```

上例的检查函数只针对数值输入，判断它是否为正整数。需要支持其他输入时，由检查函数自行判断；返回的布尔值表示输入是否符合类型。

`py` 与 `python` 等价，可以带括号，也可以直接接一个 Python 表达式。以下是同一定义的替代写法，分别独立使用：

```frank
add_type positive_integer python(lambda x: x > 0 and x % 1 == 0)
```

```frank
add_type positive_integer py lambda x: x > 0 and x % 1 == 0
```

```frank
add_type positive_integer python lambda x: x > 0 and x % 1 == 0
```

不带括号时，`py` 或 `python` 后直到当前逻辑行结束的内容都按 Python 表达式解析。带括号时，括号内按 Python 语法解析。两种形式均不使用 [frank](quickstart.md) 的运算符规则。

需要多行定义时，使用 `py_def(...)`。最后一个表达式必须得到一个能接收待检查值的函数：

```frank
add_type tensor py_def(
    def f(data):
        return isinstance(data, list) and all(
            isinstance(value, (int, float)) for value in data
        )
    f
)
tensor t = storage(a:b tensor)
```

这个示例将 `tensor` 自定义为一维数值 list；其他维度、元素类型和结构可以自行定义。`isinstance` 写法也接受下节所述的 nbtlib 数值标签和列表。

## Python 检查函数

自定义类型检查函数接收一个待检查值，并返回 Python `bool`。`True` 表示符合类型，`False` 表示不符合；不把其他返回值按真假值自动转换。

Python 代码按 Python 语法书写，不使用 frank 的运算符别名、注释或数据位置写法。工具在注册类型时取得检查函数，在检查具体值时调用它；这些代码不在 Minecraft 中执行。

定义或调用失败、返回值不是 Python `bool` 时，报告检查函数错误。无法运行 Python、缺少依赖或缺少待检查值时，报告未检查，不判为类型不符合。

## NBT 与 nbtlib

NBT 数据使用 [nbtlib](https://github.com/vberlier/nbtlib) 解析。向 Python 检查函数传入读取位置所对应的 nbtlib 标签对象，保留标签类型，不隐式转为普通 `dict`、`list`、`int` 或 `float`。

例如，NBT 的 `Int`、`String`、`List`、`Compound` 分别保留为 nbtlib 的对应对象。检查函数可以按需读取或转换。记分板值本身不是 NBT 标签，使用 Python `int` 传入。

检查环境应说明 Python、nbtlib 及所用 NumPy 的版本、可用名称及项目自定义的类型适配。依赖缺失时，按未检查处理。

