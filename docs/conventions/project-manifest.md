# 项目清单约定

每个 `projects/` 直接子目录使用 `project.json` 记录项目 ID、组件和目标。
这是当前目录调整采用的最小元数据约定，统一构建器尚未实现；
现有 Beet 和 CI 不会读取此文件。构建器实现时可以按实际需要扩展。

## 字段

| 字段 | 含义 |
| --- | --- |
| `id` | 工作区内唯一的项目 ID；复制模板后修改 |
| `components` | 组件 ID 到组件声明的映射 |
| `components.<id>.type` | 非空类型字符串；当前示例有 `datapack`、`resourcepack`、`world`、`web` |
| `components.<id>.source` | 相对清单所在目录的源目录；必须位于项目内部 |
| `targets` | 目标名称到目标声明的映射 |
| `targets.<name>.components` | 此目标选择的组件 ID 列表；只引用本项目已声明的组件 |

`source` 指向维护的源目录，不保证其中内容可以直接压缩发布。
例如数据包组件可以包含 `beet.json` 和 `src/`，资源包组件可以直接包含
`pack.mcmeta` 和 `assets/`，网页组件可以包含静态页面或前端框架源码；
对应处理步骤留待构建器定义。

`type` 是开放的类型标识，不是限定 Minecraft 内容的枚举。新增服务或工具时，
可以声明 `service`、`tool` 等类型，并在项目说明中记录用途和运行方式。
声明类型不会自动提供相应的构建、运行或部署能力。

目标中的组件列表只声明选择范围，不表示构建顺序。
当前约定没有实现模块依赖解析、跨项目引用、版本解析、文件合并或发行版打包。
不根据目录名推断这些行为，也不将未声明的参考文件自动纳入目标。

## 示例

```json
{
  "id": "example-map",
  "components": {
    "logic": {"type": "datapack", "source": "datapack"},
    "visuals": {"type": "resourcepack", "source": "resourcepack"},
    "level": {"type": "world", "source": "world"},
    "site": {"type": "web", "source": "web"}
  },
  "targets": {
    "datapack": {"components": ["logic"]},
    "map": {"components": ["logic", "visuals", "level"]},
    "website": {"components": ["site"]}
  }
}
```

组件 ID 与组件类型分开，同一项目可以声明多个同类型组件。
项目目录名、项目 ID 和包内命名空间也不要求相同；命名空间及兼容版本由项目明确记录。
示例中的 `website` 与 `map` 分别选择内容，网页不会自动加入地图目标。
运行时、依赖和实际构建命令保存在组件自身配置与项目说明中，目前不增加通用执行命令字段。
