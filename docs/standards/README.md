# Frankenstein 数据包开发约定

适用于 Minecraft Java 1.15+ 的 MCFunction / Beet / Bolt 数据包，目的是让数据包好读、好合作，规则也能交给工具检查。

约定分两部分：

- [Frankenstein 通用协作规范](core.md)：包与包之间怎样不冲突、怎样互相调用。任何包都可以采用，五分钟能读完。
- [Frankenstein 项目规范](#frankenstein-项目规范)：本项目的包内写法。其他项目可以不用，满足通用规范即可。还在完善中。

碰到不熟悉的词，查[术语表](glossary.md)。

## 目录

```text
README.md        入口
core.md          通用协作规范      C1–C22
glossary.md      术语表
style/           项目规范
  naming.md        命名与函数路径   N1–N23
  storage.md       类与存储布局     S1–S16
  variables.md     变量与调用边界   V1–V14
  function-docs.md 函数头文档       D1–D16
frank/           头文档表达式语言参考
drafts/          待讨论的补充内容，定稿后并入上面的文档
.ref/            收集的他人规范与习惯对照
.archive/        旧 FCP 文档、新旧条款对照
```

## Frankenstein 项目规范

目标版本为最新正式版，具体版本号写在各项目的 README 中。

```text
fn:ray/cast                           主包 fn 的方法；附属包用 fn.<包名>
fn:ray/cast/                          同一方法的空名入口写法，包内二选一
#fn:ray/cast                          封装接口：本项目用函数标签
demo:character/update                 方法：<module>:<class>/<method>
demo:character/update/read_input      中间过程：只给 update 用
demo:character/__validate             私有方法：类内共享
demo:character/__tick__               自动方法：由 tick 标签调用
demo:character.knight/update          继承类 character.knight

storage demo:io character             接口输入输出和回调期间的数据；storage ID 写角色，路径从类名开始
storage demo:temp|data|ins|stat character   临时 | 跨 tick | 变量栈 | 静态
score character.damage demo           假玩家：<class>.<项> @ <module>
score @s demo.character.health        执行者：@s @ <module>.<class>.<项>
tag @s add demo.character.knight      实体 tag 以 <module> 开头

pos.x        接口变量，当前 tick 有效
pos.__a      类内变量，只给 pos 类用
pos.__n__    跨 tick 变量
#a           临时变量，调用其他方法后失效；#temp_a 也是
16           常量，放在 <module> 记分项上，假名即数值
```

```mcfunction
#> demo:character/hurt
#   从执行者的生命值中扣除伤害。
# @output
#   return(bool)
# @usage
#   data modify storage demo:io character.damage set value 3
#   execute as @p run function demo:character/hurt
```

详细规则在 [style/](style/) 里。刚开始用时，先看[函数头文档](style/function-docs.md)，其他篇遇到问题再查。

### 初始化

本项目使用 [Lantern Load](https://github.com/LanternMC/load)。库的初始化函数加进 `#load:pre_load`，普通包加进 `#load:load`。每个包在 `load.status` 记分项上登记版本，假名用包的命名空间，分数为 `主×1000000 + 次×1000 + 修订`，只写记分板，不另存 storage：

```mcfunction
scoreboard players set fn load.status 1004002     # 1.4.2
```

### 世界实体

所有包共用下面这组世界实体，放在主世界 `29999968 0 12648432` 所在的常加载区块（区块坐标 `1874998 790527`）。这个位置在世界边界内侧，离 Bookshelf 的 `-30000000 1600` 很远，不会重叠。坐标没有在游戏中验证过：

```mcfunction
forceload add 29999968 12648432
```

| UUID | 用途 |
| --- | --- |
| `c0ffee-0-0-0-0` | 临时召唤，函数运行完就删；跨维度时用它 |
| `c0ffee-0-0-0-1` | 主世界 marker |
| `c0ffee-0-0-0-2` | 主世界 item_display |
| `c0ffee-0-0-0-3` | 主世界 text_display |
| `c0ffee-0-0-0-4` | 主世界雪球，UUID 转发器：把 UUID 写进 `Owner`，再 `execute on origin` |

### 玩家事件

本项目统一提供下面这些事件标签，其他包可以往里添加函数（见 N18）：

```text
#fn:player/__join__        # 进入世界，含首次
#fn:player/__first_join__  # 首次进入
#fn:player/__rejoin__      # 退出后再次进入
#fn:player/__leave__       # 退出；检测代价较大
#fn:player/__death__
#fn:player/__respawn__
```

玩家 ID 和 UUID 的用法由各子项目决定。

### frank.txt 中的项目声明

frank.txt 本身属于[通用协作规范](core.md#franktxt)。项目规范在其中额外使用以下声明：

```text
# 采用项目规范
style frankenstein

# 额外的常量记分项，假名不受 V6 限制
const demo.const

# 额外的角色；io、temp、data、ins、stat 内置，不用声明
special class

# 其他库定义、本包只往里登记的记分项，不受 V5 限制
extern load.status
```

没有 `style frankenstein` 这一行时，`const`、`special`、`extern` 不生效。接口清单和版本号写在 `api.txt`，见通用协作规范 C5、C12。

## 规则怎么读

| 用语 | 含义 |
| --- | --- |
| 必须／不得 | 采用本约定时要遵守 |
| 应该／不应 | 默认做法，有理由可以偏离 |

检查分 3 级，在 `frank.txt` 或检查工具的命令参数中设置，命令参数优先；都没设置时为 2 级：

| 等级 | 报告什么 |
| --- | --- |
| 1 宽松 | 违反“必须／不得”报错；违反“应该／不应”只给提示 |
| 2 正常 | 1 级全部，违反“应该／不应”和缺少应有的说明改为警告 |
| 3 严格 | 2 级全部，加上更细的文档要求 |

规则后的〔检测 N〕表示工具从第 N 级开始报告这条规则。诊断信息直接引用编号，比如 `C1`、`N2`。编号一旦发布就不再复用；规则删掉后编号空着。

## 其他约定

- 版本：通用协作规范的基线为 1.15+，项目规范以最新正式版为目标。storage 1.15 起；宏和 `return` 1.20.2 起；1.21 起目录 `functions/`、`tags/functions/` 改为单数。
- 代码块：`mcfunction` 是可运行的原版命令；`text` 是逻辑记法，不能直接运行；`frank` 是头文档表达式。尖括号 `<module>` 是占位符。
- 含 Bolt 等扩展语法的源码不当作原版命令示例。生成的函数由构建工具命名，不受命名规则约束。
- 项目采用本约定时，在自己的 README 写明采用的文档、版本（提交）和偏离之处。

## 旧文档

[.archive/](.archive/) 保存本约定的前身 FCP 系列、旧术语表和过期的 quickstart.html，内容已并入上述文档，仅供核对。新旧条款编号的对应见 [rule-mapping.md](.archive/rule-mapping.md)，讨论记录在 [.archive/fcp/questions.md](.archive/fcp/questions.md) 和 [.archive/fcp/references/](.archive/fcp/references/)。归档文件内部的链接可能已失效。
