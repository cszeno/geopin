import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geopin/core/i18n/app_localizations_extension.dart';

import '../../../../core/utils/app_logger.dart';


/// 日志查看页面
/// 显示应用的日志文件并提供分享和清理功能
class LogViewerPage extends StatefulWidget {
  /// 构造函数
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  List<File> _logFiles = [];
  String _currentLogContent = '';
  File? _selectedFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AppLogger.info('日志查看器页面初始化', loggerName: 'LogViewer');
    _loadLogFiles();
  }

  @override
  void dispose() {
    AppLogger.debug('日志查看器页面销毁', loggerName: 'LogViewer');
    super.dispose();
  }

  /// 加载日志文件列表
  Future<void> _loadLogFiles() async {
    setState(() {
      _isLoading = true;
    });
    
    AppLogger.debug('正在加载日志文件列表', loggerName: 'LogViewer');

    try {
      final files = await AppLogger.getLogFiles();
      AppLogger.debug('找到 ${files.length} 个日志文件', loggerName: 'LogViewer');
      
      setState(() {
        _logFiles = files;
        _isLoading = false;
        // 如果有日志文件，默认选择第一个（最新的）
        if (_logFiles.isNotEmpty) {
          _selectedFile = _logFiles.first;
          _loadLogContent(_selectedFile!);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppLogger.error('加载日志文件失败', error: e, loggerName: 'LogViewer');
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载日志文件失败: $e')),
        );
      }
    }
  }

  /// 加载选中的日志文件内容
  Future<void> _loadLogContent(File file) async {
    setState(() {
      _isLoading = true;
    });
    
    AppLogger.debug('正在加载日志文件: ${file.path}', loggerName: 'LogViewer');

    try {
      final content = await file.readAsString();
      AppLogger.debug('成功读取日志文件内容，大小: ${content.length} 字节', loggerName: 'LogViewer');
      
      setState(() {
        _currentLogContent = content;
        _selectedFile = file;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('读取日志文件内容失败', error: e, loggerName: 'LogViewer');
      setState(() {
        _currentLogContent = '无法读取日志文件: $e';
        _isLoading = false;
      });
    }
  }

  /// 清空所有日志
  Future<void> _clearAllLogs() async {
    AppLogger.info('尝试清空所有日志', loggerName: 'LogViewer');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空日志'),
        content: const Text('确定要清空所有日志文件吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppLogger.warning('用户确认清空所有日志', loggerName: 'LogViewer');
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await AppLogger.clearAllLogs();
        if (success) {
          AppLogger.info('成功清空所有日志', loggerName: 'LogViewer');
          // 重新加载日志文件
          await _loadLogFiles();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('日志已清空')),
            );
          }
        } else {
          throw Exception('清空日志失败');
        }
      } catch (e) {
        AppLogger.error('清空日志失败', error: e, loggerName: 'LogViewer');
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('清空日志失败: $e')),
          );
        }
      }
    } else {
      AppLogger.debug('用户取消清空日志操作', loggerName: 'LogViewer');
    }
  }

  /// 分享日志文件
  Future<void> _shareLogFile() async {
    if (_selectedFile == null) return;
    
    AppLogger.info('尝试分享日志文件: ${_selectedFile!.path}', loggerName: 'LogViewer');

    try {
      await Share.shareXFiles(
        [XFile(_selectedFile!.path)],
        subject: '应用日志 - ${_formatFileDate(_selectedFile!.path)}',
      );
      AppLogger.info('分享日志文件成功', loggerName: 'LogViewer');
    } catch (e) {
      AppLogger.error('分享日志文件失败', error: e, loggerName: 'LogViewer');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享日志失败: $e')),
        );
      }
    }
  }

  /// 从文件名中提取日期
  String _formatFileDate(String filePath) {
    final fileName = filePath.split('/').last;
    final dateMatch = RegExp(r'log_(\d{4}-\d{2}-\d{2})\.txt').firstMatch(fileName);
    
    if (dateMatch != null && dateMatch.groupCount >= 1) {
      return dateMatch.group(1) ?? '未知日期';
    }
    
    return '未知日期';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志查看器'),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogFiles,
            tooltip: '刷新日志列表',
          ),
          // 分享按钮
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _selectedFile != null ? _shareLogFile : null,
            tooltip: '分享当前日志',
          ),
          // 清空按钮
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _logFiles.isNotEmpty ? _clearAllLogs : null,
            tooltip: '清空所有日志',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 日志文件列表
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _logFiles.isEmpty
                      ? const Center(child: Text('没有找到日志文件'))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _logFiles.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final file = _logFiles[index];
                            final isSelected = _selectedFile?.path == file.path;
                            final date = _formatFileDate(file.path);
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ChoiceChip(
                                label: Text(date),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    AppLogger.debug('选择日志文件: $date', loggerName: 'LogViewer');
                                    _loadLogContent(file);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
                
                const Divider(),
                
                // 日志内容
                Expanded(
                  child: _selectedFile == null
                      ? Center(child: Text(context.l10n.selectLogFile))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            _currentLogContent.isEmpty
                                ? context.l10n.emptyLogFile
                                : _currentLogContent,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
} 