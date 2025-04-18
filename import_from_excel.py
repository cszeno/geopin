#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
从Excel文件导入到ARB文件
适用于Flutter多语言项目
"""

import json
import os
import pandas as pd
import sys
from datetime import datetime
import argparse

def read_excel_file(file_path):
    """
    读取Excel文件内容
    
    参数:
        file_path: Excel文件路径
    
    返回:
        DataFrame: Excel文件内容
    """
    try:
        df = pd.read_excel(file_path)
        return df
    except Exception as e:
        print(f"读取Excel文件 {file_path} 时出错: {e}")
        sys.exit(1)

def read_arb_file(file_path):
    """
    读取ARB文件内容
    
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
        print(f"读取ARB文件 {file_path} 时出错: {e}")
        sys.exit(1)

def write_arb_file(file_path, content, backup=True):
    """
    写入ARB文件
    
    参数:
        file_path: ARB文件路径
        content: 要写入的内容（字典）
        backup: 是否备份原文件
    """
    try:
        # 备份原文件
        if backup and os.path.exists(file_path):
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            backup_path = f"{file_path}.{timestamp}.bak"
            with open(file_path, 'r', encoding='utf-8') as src:
                with open(backup_path, 'w', encoding='utf-8') as dest:
                    dest.write(src.read())
            print(f"已备份原文件到 {backup_path}")
        
        # 写入新内容
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(content, file, ensure_ascii=False, indent=2)
            print(f"已成功写入文件 {file_path}")
    except Exception as e:
        print(f"写入ARB文件 {file_path} 时出错: {e}")
        sys.exit(1)

def update_arb_files(excel_file, arb_dir):
    """
    根据Excel文件更新ARB文件
    
    参数:
        excel_file: Excel文件路径
        arb_dir: ARB文件目录
    """
    # 读取Excel文件
    df = read_excel_file(excel_file)
    
    # 检查必须的列
    if 'key' not in df.columns:
        print("错误: Excel文件必须包含'key'列")
        sys.exit(1)
    
    # 获取所有语言代码（排除'key'和'description'列）
    langs = [col for col in df.columns if col not in ['key', 'description']]
    if not langs:
        print("错误: Excel文件没有包含任何语言列")
        sys.exit(1)
    
    # 处理每种语言
    for lang in langs:
        arb_file = os.path.join(arb_dir, f"app_{lang}.arb")
        
        # 检查ARB文件是否存在
        if not os.path.exists(arb_file):
            print(f"注意: 创建新的ARB文件 {arb_file}")
            arb_content = {"@@locale": lang}
        else:
            arb_content = read_arb_file(arb_file)
        
        # 更新翻译
        updated = False
        for _, row in df.iterrows():
            key = row['key']
            if pd.isna(row[lang]) or row[lang] == '':
                continue  # 跳过空翻译
            
            # 如果翻译内容有变化，更新它
            if key not in arb_content or arb_content[key] != row[lang]:
                arb_content[key] = row[lang]
                updated = True
                
                # 如果有描述且元数据项不存在，添加描述到元数据
                if 'description' in df.columns and not pd.isna(row['description']):
                    if f'@{key}' not in arb_content:
                        arb_content[f'@{key}'] = {"description": row['description']}
                    elif 'description' not in arb_content[f'@{key}']:
                        arb_content[f'@{key}']['description'] = row['description']
        
        # 如果有更新，写入ARB文件
        if updated:
            write_arb_file(arb_file, arb_content)
        else:
            print(f"没有更新 {arb_file}，内容未变")

def validate_file_exists(file_path):
    """
    验证文件是否存在
    
    参数:
        file_path: 文件路径
        
    返回:
        str: 文件路径（如果文件存在）
    """
    if not os.path.exists(file_path):
        print(f"错误: 文件 {file_path} 不存在")
        sys.exit(1)
    return file_path

def validate_dir_exists(dir_path):
    """
    验证目录是否存在
    
    参数:
        dir_path: 目录路径
        
    返回:
        str: 目录路径（如果目录存在）
    """
    if not os.path.exists(dir_path) or not os.path.isdir(dir_path):
        print(f"错误: 目录 {dir_path} 不存在")
        sys.exit(1)
    return dir_path

def main():
    """主函数"""
    # 解析命令行参数
    parser = argparse.ArgumentParser(description='从Excel导入翻译到ARB文件')
    parser.add_argument('--excel', default='', help='Excel文件路径')
    parser.add_argument('--arb-dir', default='lib/core/i18n/l10n', help='ARB文件目录')
    args = parser.parse_args()
    
    # 如果未指定Excel文件，提示用户选择
    excel_file = args.excel
    if not excel_file:
        # 查找translations目录下的Excel文件
        translations_dir = 'translations'
        if os.path.exists(translations_dir) and os.path.isdir(translations_dir):
            excel_files = [os.path.join(translations_dir, f) for f in os.listdir(translations_dir) 
                          if f.endswith('.xlsx') and os.path.isfile(os.path.join(translations_dir, f))]
            
            if excel_files:
                # 按修改时间排序，最新的在前面
                excel_files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
                
                print("找到以下Excel文件:")
                for i, file in enumerate(excel_files):
                    mtime = datetime.fromtimestamp(os.path.getmtime(file)).strftime('%Y-%m-%d %H:%M:%S')
                    print(f"{i+1}. {file} (修改时间: {mtime})")
                
                try:
                    choice = int(input("请选择要导入的文件 (输入数字): "))
                    if 1 <= choice <= len(excel_files):
                        excel_file = excel_files[choice-1]
                    else:
                        print("无效的选择")
                        sys.exit(1)
                except ValueError:
                    print("无效的输入")
                    sys.exit(1)
            else:
                print(f"在 {translations_dir} 目录下未找到Excel文件")
                excel_file = input("请输入Excel文件路径: ")
        else:
            excel_file = input("请输入Excel文件路径: ")
    
    # 验证文件和目录是否存在
    excel_file = validate_file_exists(excel_file)
    arb_dir = validate_dir_exists(args.arb_dir)
    
    # 更新ARB文件
    update_arb_files(excel_file, arb_dir)
    
    print("翻译导入完成！")

if __name__ == "__main__":
    main() 