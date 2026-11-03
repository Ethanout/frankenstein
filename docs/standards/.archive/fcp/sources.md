# 来源与修订记录

整理日期：2026-10-18。原始路径以共同父目录 `__mc/` 为参照。

## 文字材料

| 来源 | 原始位置 | 快照 |
| --- | --- | --- |
| Wiki 语言规范 | `underline_wiki/language/语言规范.md`，340 行 | [原文](references/wiki-language-original.md) |
| GameCore 约定 | `GameCore/gamecore/src/data/规范.md`，14 行 | [原文](references/gamecore-conventions-original.md) |
| 作者第一轮答复 | 本项目问题文档，2026-10-18 首次填写的版本 | [完整答复](references/author-answers-2026-10-18.md) |
| 作者第二轮答复 | PEP 形式重写后补充填写的版本 | [完整答复](references/author-answers-2026-10-18-02.md) |
| 作者第三轮答复 | FCP 9 首稿 Q15—Q19 的填写版本 | [完整答复](references/author-answers-2026-10-18-03.md) |
| 作者第四轮答复 | Q20—Q21 的填写版本，2026-10-19 | [完整答复](references/author-answers-2026-10-19.md) |
| 会话确认 | 2026-10-18：“那就module:class吧” | [Q14 决定](questions.md#q14) |
| u.math 头文档示例 | `D:/重要的资料/mc本体游戏/.minecraft/versions/1.21.5-Fabric 0.16.13/saves/数据包测试/datapacks/umath/src/data/umath/readme.md` | 未保存快照，仅参考 [frank 表达式](../frank/quickstart.md)写法 |

Wiki 是本次拆分的主要文字依据，GameCore 约定和项目源码用于对照。作者已回答的内容优先写入正文，后续讨论见[问题与答复](questions.md)。

## Wiki 到提案的映射

行号指 Wiki 快照。

| 原文行号 | 内容 | 提案 |
| --- | --- | --- |
| 2—6 | 约定用途与建议性定位 | [FCP 1](fcp-0001-process.md) |
| 8—16 | 命名原则与概念目录 | [FCP 2](fcp-0002-naming.md)、[FCP 3](fcp-0003-fields-storage.md) |
| 18—61 | 字段、位置、函数层级与 tag 前缀 | FCP 2、FCP 3 |
| 63—94 | 属性、继承与位置映射 | FCP 3 |
| 96—180 | 字段值与子字段、value、继承冲突 | FCP 3 |
| 182—196 | 特殊标记、冲突与别名 | [FCP 6](fcp-0006-special-names.md) |
| 198—224 | 自动入口与分发 | FCP 6 |
| 226—245 | 中间过程与私有方法 | FCP 6 |
| 249—254 | 长期变量 | FCP 6 |
| 256—275 | 头文档与输入只读 | [FCP 4](fcp-0004-function-contracts.md) |
| 277—339 | 临时值、调用边界与变量栈 | [FCP 5](fcp-0005-variable-lifetimes.md) |

## 作者答复的处理

| 问题 | 写入正文的结论 |
| --- | --- |
| Q00 | 当前项目 `docs/standards/` 为维护位置 |
| Q01 | 数字常量的 `#`、对外接口的 `$` 可选；`##` 是可选局部标记，`#` 的字段内共享范围为规范要求 |
| Q02 | 第一轮建议按角色分 storage；后由 Q14 的 module:class 布局接替 |
| Q03 | 接口形状冲突使用 value；数据通常由所属字段方法管理 |
| Q04 | 私有方法通常只嵌套私有方法；例外嵌套普通方法时，外层共享值仍有效，修改算副作用 |
| Q05 | 同字段私有方法可以按内部约定读取共享值，省略单独输入声明 |
| Q06 | `ins` 保存调用状态，列表项沿用根目录规则，具体操作由开发者决定 |
| Q07 | 继承字段可访问父字段私有方法；入口角色可重叠；别名语义完全等价 |
| Q08 | 分支名由字段或项目选择并说明，属于建议 |
| Q09 | 深度建议针对手写文件；第三层优先，第四层用于分组；大型模块和生成器可例外 |
| Q10 | 不要求 attr.txt |
| Q11 | 游戏版本基线为 1.15+ |
| Q12 | 改为 PEP 风格，精简正文和保留意见 |
| Q13 | 后续确认使用 ins，取代旧名 stack；每个 compound 内部与根目录使用相同规则 |
| Q14 | 确认采用 module:class；storage 归属命名为规范要求，标准角色布局为建议（SHOULD），可以添加自定义内容（MAY） |

作者说明数字常量添加 `#` 的动机是性能。正文据此保留两种命名选择；性能动机记录在此。

## GameCore 旧约定

| 原文行号 | 内容 | 处理 |
| --- | --- | --- |
| 1—5 | `##`、`#`、普通名、`$` 的范围分类 | 按两轮答复写入 FCP 5；数字和 `$` 可选，`##` 可选，`#` 范围为规范要求 |
| 7—10 | objective 名称与 attr.txt | 命名实例保留；登记文件按 Q10 处理 |
| 12—14 | 单个 storage 下的数据布局 | 当前布局按 Q14 统一为 module:class |

## 源码观察

| 来源 | 路径与行号 | 用于对照的内容 |
| --- | --- | --- |
| GC-LOAD | `GameCore/gamecore/src/data/gc/function/__load__.mcfunction`，7—28 | storage 角色路径、常量与 ID |
| GC-MODIFY | `GameCore/gamecore/src/data/gc/function/data/modify.mcfunction`，1—16 | 头文档、调用示例、接口与实现入口 |
| GC-PERF | `GameCore/gamecore/src/data/gc/function/uuid/this_name.mcfunction`，1—6 | @perf 与 @usage |
| MG-LOAD | `MinerGame/src/data/mg/function/__load__.mcfunction`，1—21 | objective、常量、tag 与 mg:io |
| MG-MAIN | `MinerGame/src/data/mg/function/item/--main.mcfunction`，1—17、45—51 | 读写接口、导入、聚合源码 |
| MG-ITEM | `MinerGame/src/data/mg/function/item/__etick__.mcfunction`，3—6、50—92 | 临时拷贝与回写时机 |
| MG-CALLBACK | `MinerGame/src/data/mg/function/item/set_callbacks.mcfunction`，1—27 | 资源生成与运行期宏 |
| MG-MODULE | `MinerGame/src/data/mg/modules/generic.bolt`，1—10 | Bolt 模块、数据读取与命令拼接 |
| MG-TICK | `MinerGame/src/data/mg/function/__tick__.mcfunction`，1—6 | 标签入口与分发顺序 |

另读取两个项目的顶层 Beet、Spyglass 配置，以及 GameCore 嵌套的 Beet 配置。源码方言和版本说明见 [FCP 7](fcp-0007-source-dialects.md)。

本次验证范围为文档结构、引用和快照完整性。

## 编辑记录

- 按作者补充，`minecraft_*` 扩展为全部 NBT 类型，补入 Python 和 NumPy 类型；语义相同的类型复用名称，NumPy 类型无名称冲突时省略 `np.`，如 `float32`。删除专用矩阵类型，改用 `ndarray`，形状和元素类型按需说明。明确 NBT 标签与数学值、宿主类型的区别；尚未明确的 NBT 算术上下文及跨类型提升另列为 frank Q24。
- 按作者 Q22 答复，涉及 `minecraft_int` 等 Minecraft 类型的运算完整模拟游戏内部机制，覆盖溢出、取整、除法及余数；`real` 表示数学意义上的精确实数。同步类型、运算和检查规则，将 Q22 归入已确认决定；检查器不支持相应游戏机制或无法精确判定时，仍报告未检查。
- 按作者修订，取消头文档中自然语言说明与 `@usage` 至少提供一项的要求；说明和字段按需填写。
- 按作者补充，frank 允许直接混写自然语言说明，取消三引号及块注释，只保留 `#` 显式注释。为避免漏检，补充自动识别失败时保留原文、不参与检查，疑似表达式错误给出提示，明确要求检查的片段解析失败时仍报错，跨行表达式按整体处理等规则。同步快速入门和头文档示例；嵌入 Python 仍按 Python 自身规则处理。
- 按作者反馈，frank 文档从辅助编写说明的最简单格式讲起：先列数据位置，再按需添加说明、名称、类型和条件。入口和常用写法不再沿用程序语言参考手册的阅读顺序；保留字、运算细节、Python 扩展及检查器要求作为后续查阅内容，既有语义不变。
- 按作者要求，将 frank 作为独立语言在 [docs/frank/](../frank/quickstart.md) 维护，参考 Python Language Reference 和 The Rust Reference 的主题组织方式，分为词法、表达式、类型与 Python 扩展、可选检查及问题记录。FCP 9 改为“frank 在函数文档中的使用”，保留头文档衔接规则及原条款迁移索引。
- 第四轮答复确认不提供复数、四元数和矩阵默认布局，加入 `minecraft_int`，NBT 使用 nbtlib。按“正则表达式先不要”的答复撤下当前正则规则和示例，原 R11、R12 暂缓。未明确的溢出运算及 `real` 精度单列为 frank Q22；完整答复已保存快照。
- 按作者要求，从 FCP 4 删除“中间过程”一节。相关内容已由 [FCP 6](fcp-0006-special-names.md#私有方法与中间过程) R05、R06 规定，统一在该处维护；原 FCP-0004-R05 停用，不复用编号，其余条款编号不变。
- 按作者补充，FCP 4 建议最小化文档：通常只写说明或 `@usage`，参数较多或输入输出不易说明时再补充字段。frank 首先供人阅读，其次供机器检查，以统一、简洁、清晰的伪代码为目标；需要编写伪代码时优先使用 frank，不为机器检查增加不必要的复杂度，形式化检查始终可选。FCP 9 明确语法与检查器条款的适用条件，并将完整检查示例标为按需选用。
- 第三轮答复写入 FCP 9：注释、类 Python 的名称定义、正则内嵌、可选类型、自定义 Python 检查函数，以及逻辑运算符别名。后续按会话要求取消 `//` 注释，保留其整除含义。原始答复另存快照，正整数谓词中的 `a` 笔误在规范中修正为参数 `x`。
- 按作者要求，将 FCP 4 的输入、输出、限制示例改为 frank 表达式，自然语言补充写作注释；原版命令和 `@usage` 继续使用 mcfunction。
- Q15—Q19 的答复已归档；答复尚未明确的类型布局、数值实现及正则细节集中为 Q20—Q21。
- 按作者补充，FCP 4 R14 允许在同一字段中混写自然语言和 frank 表达式，用表达式描述希望进入形式化检查的内容；FCP 9 补充混写示例，随后按 Q15 答复加入注释写法。
- 按作者修订，FCP 4 R12 仅针对 `@input`、`@output`、`@limitation`，根据可读性和编写成本选用 frank 表达式；其余情况使用自然语言或伪代码，取消对副作用和自定义字段的优先使用建议。
- 按作者要求，将 frank 表达式独立为 FCP 9，FCP 4 保留使用建议及独立位置写法的引用。新增括号换行、逻辑组合、正则、调用前后值与检查结果的首轮设计；这些方案尚待评审，问题集中记录为 Q15—Q19。
- 参考 u.math README，为 FCP 4 补充 frank 表达式的基本示例：给值起名、直接列出数据位置、描述取值条件。按作者确认，`score(@s xx)` 可以独立使用，不要求写赋值关系；其余语法与语义仍待补充。
- 按作者补充，FCP 4 收录完整函数头文档格式：接口函数必须提供，其他函数可选；字段标签与内容成对出现。明确五个保留字段、填写建议和可运行示例要求，为 frank 表达式预留语法与语义说明。
- 系列统一命名为 FCP（Frankenstein Convention Proposals，Frankenstein 约定提案），供本项目及自愿采用的项目使用；同步目录、文件名、条款前缀和引用，保留原提案数字编号与条款序号。
- 拆分主题，保留已有提案编号与条款 ID。
- 新增 FCP 0 索引和 FCP 8 模块存储草案。
- 将条款表改为正文，统一文档头、类型和状态。
- FCP 1 的提案流程、FCP 4 的接口信息建议、FCP 7 的文档建议由本次整理补充。
- 第二轮答复明确私有方法的共享输入、嵌套调用与副作用；FCP 5 的普通调用规则区分过程临时值和字段共享值。
- 按 Q14 及随后会话确认，将 FCP 3 的 storage ID 规则改为 module:class；同步修改位置表、接口示例和版本说明中的位置记法。后续按作者要求，将标准角色布局保留为 R11（SHOULD），新增 R12（MAY）允许自定义路径及内容，并同步 FCP 8 和答复记录。
- FCP 8 改为记录所选布局的设计理由、方案比较和迁移对照；问题文档中的 Q00—Q14 均已有答复。
- 原文 `__ritck__` 与后文 `__rtick__` 不一致，正文按 random tick 的含义使用后者。
- 按作者补充，保留 R01 描述字段归属，新增 FCP-0003-R13（SHOULD）规定对应数据在不同位置的语义、单位和类型一致，并增加手持物品自定义数据与 marker 实体 data 的示例。
- R01 保留一条规则、一组玩家等级的位置示例及必要说明，删除额外定义和教程式展开，完整读写命令集中在 R13；补充箱子物品的 block 示例，将 NBT 特殊字符说明放到后面，并同步 R09 和 FCP 8 的表述。
- 按会话确认，假玩家记分板位置使用 `score 数据项.字段 模块`，例如 `score level.player demo`；同步位置表、读写命令、接口值、临时值和长期值示例，区分假玩家与执行者记分板的命名。
- 按作者补充，R01、R13 中的不同位置表示按需选用的存储形式。函数可选定一种临时输入形式，长期数据通常使用一种存储形式；删除 R13 中的工作副本和复制命令，保留位置及语义、类型约定。
- 按作者最新约定，取消 `io` 推荐角色；保留 `temp`、跨 tick 动态数据 `data` 和全静态数据 `stat`，将 `stack` 改为 `ins`。`ins` 是 compound 列表，每项内部与根目录使用相同规则；同步存储布局、核心概念和 frank 示例。
- 按作者确认，记分板名称改为字段在前：`score class.abc demo`、`score @s demo.class.abc`。FCP 2 新增方法名显式说明修改目标的建议，以及 `modify_<target>`、`<source>_to_<target>` 和位置类型简写的可选约定。
- 2026-10-20，按作者补充，R13 改为保持语义一致，允许存储类型、单位和缩放比例不同，并说明换算规则；删除对应 NBT 数值必须使用 `int` 的限制，补充记分板缩放定点数示例。

## 快照校验

以下 SHA-256 对应保存时的原始字节：

| 快照 | SHA-256 |
| --- | --- |
| Wiki 原文 | `8AC0301E9AB846E39EAAEFAD382DF3965ED53C433467A5C1F3674D6D0B1831A1` |
| GameCore 约定 | `290071A1067278D7F7EBE153BECBAAAE8FA96D62A679C641B073E522038D52DC` |
| 作者第一轮答复 | `8AC37F351638C9AA37B65DD3CCFA7484475CA7279A5975925D2A67EC8F21B839` |
| 作者第二轮答复 | `8A5D1E84E13F10AB6B481CCD534CF0171581C1C2B5717ECA0ABF463E601E0978` |
| 作者第三轮答复 | `6EBDBAE271E29BA64E498E601506E359E3DC70C0F500A8F52D46A74D6F93D963` |
| 作者第四轮答复 | `BB35BCADC23C7D746ABA64B9B19F43024D5A821B3F7AF8863087BC2DAF858367` |

作者答复快照保留填写时的原始相对链接。查阅当前提案使用本页及问题文档中的链接。

## 文档形式参考

- [Python Language Reference](https://docs.python.org/3/reference/index.html)、[The Rust Reference](https://doc.rust-lang.org/reference/)：frank 文档初稿曾参考其主题划分，后按作者反馈改为从最简文档写法讲起。
- [PEP 1](https://peps.python.org/pep-0001/)：文档头、提案类型与状态。
- [PEP 8](https://peps.python.org/pep-0008/)：以说明、理由和示例展开风格约定。
- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)：规范用语的要求强度。

相关概念：[核心概念](../core-concepts.md)。
