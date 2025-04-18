# 多语言翻译工具

这是一组用于Flutter项目多语言管理的Python脚本，支持将ARB文件导出到Excel以便翻译，并将翻译后的Excel导回ARB文件。

## 功能特点

- 从ARB文件导出到Excel文件
- 从Excel文件导入到ARB文件
- 自动备份原ARB文件
- 支持多语言
- 保留ARB文件中的描述和元数据

## 安装依赖

在使用脚本前，请先安装必要的依赖库：

```bash
pip install -r requirements.txt
```

## 使用方法

### 导出ARB文件到Excel

```bash
python export_to_excel.py
```

执行后，脚本会：
1. 读取`lib/core/i18n/l10n`目录下的所有ARB文件
2. 以中文文件(`app_zh.arb`)为模板
3. 在`translations`目录下生成带时间戳的Excel文件

### 从Excel导入到ARB文件

```bash
python import_from_excel.py [--excel EXCEL_FILE_PATH] [--arb-dir ARB_DIR_PATH]
```

参数说明：
- `--excel`: Excel文件路径（可选，如不提供则会提示选择）
- `--arb-dir`: ARB文件目录（可选，默认为`lib/core/i18n/l10n`）

执行后，脚本会：
1. 读取指定的Excel文件
2. 更新ARB文件目录中对应语言的ARB文件
3. 自动备份原ARB文件

## 工作流程

1. 开发新功能时，添加中文文本到`app_zh.arb`文件
2. 运行`export_to_excel.py`生成Excel文件
3. 将Excel文件交给翻译团队进行翻译
4. 翻译完成后，运行`import_from_excel.py`导入翻译

## 注意事项

- 导入时会自动备份原ARB文件，备份文件名为`原文件名.时间戳.bak`
- Excel文件必须包含`key`列和至少一个语言列
- 可以添加`description`列来提供翻译说明
