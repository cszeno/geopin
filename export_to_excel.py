#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
从ARB文件导出到Excel文件
适用于Flutter多语言项目
"""

import json
import os
import pandas as pd
import sys
from datetime import datetime

def extract_arb_content(file_path):
    """
    提取ARB文件的内容
    
    参数:
        file_path: ARB文件路径
    
    返回:
        dict: ARB文件内容的字典
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = json.load(file)
            return content
    except Exception as e:
        print(f"读取文件 {file_path} 时出错: {e}")
        sys.exit(1)

def get_arb_files(directory):
    """
    获取目录中的所有ARB文件
    
    参数:
        directory: 目录路径
    
    返回:
        list: ARB文件路径列表和对应的语言代码
    """
    arb_files = []
    try:
        for file in os.listdir(directory):
            if file.endswith('.arb'):
                # 假设文件名格式为 app_语言代码.arb
                lang_code = file.split('_')[1].split('.')[0]
                arb_files.append((os.path.join(directory, file), lang_code))
        return arb_files
    except Exception as e:
        print(f"获取ARB文件时出错: {e}")
        sys.exit(1)

def extract_translatable_entries(arb_dict):
    """
    从ARB字典中提取可翻译的条目
    
    参数:
        arb_dict: ARB文件内容的字典
    
    返回:
        dict: 可翻译的条目字典
    """
    translatable = {}
    metadata = {}
    
    for key, value in arb_dict.items():
        # 跳过以@开头的元数据条目
        if key.startswith('@'):
            if key != '@@locale':  # 保存除 @@locale 外的元数据
                metadata[key] = value
            continue
            
        # 保存可翻译的文本
        translatable[key] = value
        
    return translatable, metadata

def create_excel(template_file, arb_files, output_file):
    """
    创建Excel文件，以模板文件为基础，添加其他语言的翻译
    
    参数:
        template_file: 模板ARB文件路径
        arb_files: 所有ARB文件的路径和语言代码列表
        output_file: 输出的Excel文件路径
    """
    # 读取模板文件
    template_content = extract_arb_content(template_file)
    template_lang = template_content.get('@@locale', 'unknown')
    translatable_template, metadata = extract_translatable_entries(template_content)
    
    # 准备DataFrame
    df_data = []
    
    # 提取所有语言的翻译
    translations = {}
    for file_path, lang_code in arb_files:
        content = extract_arb_content(file_path)
        translatable, _ = extract_translatable_entries(content)
        translations[lang_code] = translatable
    
    # 创建行数据
    for key, template_value in translatable_template.items():
        row = {'key': key, template_lang: template_value}
        
        # 添加其他语言的翻译
        for lang, trans in translations.items():
            if lang != template_lang:
                row[lang] = trans.get(key, '')
                
        # 添加描述（如果存在）
        if f'@{key}' in metadata:
            if 'description' in metadata[f'@{key}']:
                row['description'] = metadata[f'@{key}']['description']
        
        df_data.append(row)
    
    # 创建DataFrame
    columns = ['key', template_lang]
    columns.extend([lang for lang in translations.keys() if lang != template_lang])
    if any('description' in row for row in df_data):
        columns.append('description')
    
    df = pd.DataFrame(df_data, columns=columns)
    
    # 保存到Excel
    try:
        df.to_excel(output_file, index=False)
        print(f"已成功导出到 {output_file}")
    except Exception as e:
        print(f"导出到Excel时出错: {e}")
        sys.exit(1)

def main():
    """主函数"""
    # 默认路径
    arb_dir = 'lib/core/i18n/l10n'
    template_file = f'{arb_dir}/app_zh.arb'
    
    # 检查目录是否存在
    if not os.path.exists(arb_dir):
        print(f"错误: 目录 {arb_dir} 不存在")
        sys.exit(1)
    
    # 检查模板文件是否存在
    if not os.path.exists(template_file):
        print(f"错误: 模板文件 {template_file} 不存在")
        sys.exit(1)
    
    # 获取所有ARB文件
    arb_files = get_arb_files(arb_dir)
    
    # 创建输出目录（如果不存在）
    output_dir = 'translations'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # 生成带时间戳的输出文件名
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    output_file = f"{output_dir}/translations_{timestamp}.xlsx"
    
    # 创建Excel文件
    create_excel(template_file, arb_files, output_file)

if __name__ == "__main__":
    main() 