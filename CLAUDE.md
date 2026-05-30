# 每日任务 App - 项目指引文件

## 项目简介
一款帮助用户培养自律习惯的安卓端每日任务App，使用Flutter框架开发。

## 📚 文档索引

| 文档 | 路径 | 说明 |
|------|------|------|
| 项目需求文档 | [docs/01-项目需求文档.md](docs/01-项目需求文档.md) | 功能需求、等级/段位系统设计 |
| 技术架构文档 | [docs/02-技术架构文档.md](docs/02-技术架构文档.md) | 技术栈、目录结构、架构模式 |
| UI设计规范 | [docs/03-UI设计规范.md](docs/03-UI设计规范.md) | 颜色、字体、间距、页面布局 |
| 执行步骤 | [docs/04-执行步骤.md](docs/04-执行步骤.md) | 9个开发阶段详细步骤 |
| 数据库设计 | [docs/05-数据库设计.md](docs/05-数据库设计.md) | 5张数据表结构和SQL语句 |
| 开发日志 | [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) | 每日开发记录 |
| 项目说明 | [README.md](README.md) | 项目介绍、运行方法 |

## 🎯 当前开发阶段

**阶段0：文档编写与环境搭建** - 进行中

### 已完成
- [x] 项目需求文档
- [x] 技术架构文档
- [x] UI设计规范
- [x] 执行步骤文档
- [x] 数据库设计文档
- [x] 开发日志
- [x] README.md

### 待完成
- [ ] 安装Flutter SDK
- [ ] 安装Android SDK和JDK
- [ ] 配置Android模拟器或连接真机
- [ ] 验证Flutter环境正常

## 🔧 技术栈
- Flutter 3.x / Dart 3.x
- Provider (状态管理)
- SQLite / sqflite (本地数据库)
- flutter_local_notifications (通知)

## 📏 开发规范
- 代码遵循Flutter官方最佳实践
- 使用Provider进行状态管理
- 所有数据本地存储，无需联网
- 支持浅色/深色主题
- 页面使用Material Design风格