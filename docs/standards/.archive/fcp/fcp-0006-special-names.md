# FCP 6 — 特殊名称与可见性

```text
FCP: 6
Title: 特殊名称与可见性
Author: 待署名
Status: Draft
Type: Standards Track
Created: 18-Oct-2026
Minecraft-Version: 1.15+
Requires: 1, 2, 3
```

## 摘要

特殊名称标记自动入口、私有方法和长期变量。标记按需要使用；私有方法可由哪些函数调用，按所属字段及继承关系确定。

## 动机

仅看函数路径时，调用入口和内部辅助方法可能难以区分。少量统一标记可以帮助阅读和调用。

## 规范

### 标记形式

**FCP-0006-R01 · 可以：** 使用以下标记说明方法或变量的用途。

| 示例 | 含义 |
| --- | --- |
| `__tick__` | 自动方法：前后双下划线 |
| `__validate` | 私有方法：前面双下划线 |
| `pos.__count__` | 跨 tick 全局变量：类名前缀，变量名前后双下划线 |

这些标记是命名约定。调用函数时，仍使用完整的函数资源位置。

相关概念：[自动方法](../core-concepts.md#自动方法)、[私有方法](../core-concepts.md#私有方法)、[长期状态](../core-concepts.md#长期状态)。

### 名称冲突与别名

**FCP-0006-R02 · 必须：** 同一字段内，比较同类对象的名称时，先去掉特殊标记。去掉后同名的对象不得分别表示不同功能，例如 `tick` 与 `__tick__`。

**FCP-0006-R03 · 可以：** 同名的普通方法和特殊方法互为别名，其中一个只转发调用另一个。两者的返回值、命令执行结果和其他副作用必须等价。

```text
demo:character/__tick__ → demo:character/tick
```

实现转发时，按目标游戏版本处理返回值和命令执行结果，相关版本见 [FCP 7](fcp-0007-source-dialects.md)。

相关概念：[别名](../core-concepts.md#别名)。

### 自动方法

**FCP-0006-R04 · 应该：** 自动方法标记用于预期由游戏机制、标签分发或手工入口调用的方法。

常见入口包括 load、tick、实体 tick、随机 tick、进度奖励，以及聊天框中的命令、测试和调试入口。

```text
__load__    # load 标签入口
__tick__    # tick 标签入口
__etick__   # entity tick
__rtick__   # random tick
__5tick0__  # 五 tick 周期中余数为 0 的入口
__5tick2__  # 五 tick 周期中余数为 2 的入口
```

调用方负责按周期或随机方式调用这些入口。入口名称中可以添加表达用途的前缀或后缀。例如，`__oh_no_42tick11__` 表示调用方的 tick 计数除以 42、余数为 11 时调用的入口，`oh_no` 是前缀。

相关概念：[自动方法](../core-concepts.md#自动方法)。

### 私有方法与中间过程

**FCP-0006-R05 · 必须：** 方法独占的中间过程只供该方法调用。

**FCP-0006-R06 · 应该：** 多个方法需要同一中间过程时，将它提取为字段内的私有方法。

**FCP-0006-R07 · 不应：** 字段外直接调用该字段的私有方法。继承字段属于允许的调用范围。

```text
demo:character/create                 # 对外方法
demo:character/update                 # 对外方法
demo:character/create/validate        # 仅 create 使用
demo:character/__validate             # character 内的方法可共享
demo:character.knight/update          # 可调用 character/__validate
```

自动方法也可以同时承担私有入口，由所属字段说明其用途和调用范围。

私有方法供字段内的方法共享，通常只调用其他私有方法。类内变量和调用副作用的规则见 [FCP 5](fcp-0005-variable-lifetimes.md)。

相关概念：[私有方法](../core-concepts.md#私有方法)、[中间过程](../core-concepts.md#中间过程)、[继承](../core-concepts.md#继承)。

### 长期变量

**FCP-0006-R08 · 必须：** 跨 tick 全局变量使用 `<class>.__<name>__` 命名，保留类名前缀，并用双下划线包围变量名。变量名按用途选择。

例如，`pos.__g__`、`pos.__count__`、`pos.__last_tick__` 都符合此形式。假设 `demo` 记分板已创建：

```mcfunction
scoreboard players add pos.__count__ demo 1
```

这里的 `pos.__count__` 是跨 tick 保留的计数值，按 `pos` 类的接口约定维护。它仍是全局接口变量；前后双下划线表示跨 tick，不表示类内私有。tick 边界见 [FCP 5](fcp-0005-variable-lifetimes.md#tick-边界)。

相关概念：[长期状态](../core-concepts.md#长期状态)。

## 设计理由

只供一个方法使用的过程放在该方法目录下，供多个方法共享的过程放在字段目录下。继承字段可以复用父字段的私有方法。特殊标记帮助表达这些关系，保持名称简短。
