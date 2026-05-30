# 每日任务 - Daily Task App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build](https://github.com/Swimteam0/daily-task-app/actions/workflows/build.yml/badge.svg)](https://github.com/Swimteam0/daily-task-app/actions)

> 一款帮助用户培养自律习惯的安卓端每日任务App，通过打卡、等级、段位等激励机制提升坚持完成任务的动力。

## 功能特性

- **任务管理** - 创建每日重复任务或单日任务，支持自定义重复日
- **打卡系统** - 一键打卡，记录每次完成时间
- **等级系统** - 基于累计打卡次数，从初心者到不朽共10个等级
- **段位系统** - 基于连续打卡天数，从黑铁到王者共8个段位
- **数据统计** - 打卡率图表、日历热力图、连续天数追踪
- **专注模式** - 计时专注，记录打断次数
- **通知提醒** - 自定义时间提醒打卡
- **深色模式** - 支持浅色/深色/跟随系统三种主题
- **纯本地存储** - 无需联网，无需注册，数据全部存在本地

## 下载安装

### 方式一：直接下载 APK（推荐）

1. 前往 [Releases](https://github.com/Swimteam0/daily-task-app/releases) 页面
2. 下载最新版本的 APK 文件：

| 文件名 | 说明 | 适用设备 |
|--------|------|----------|
| `app-arm64-v8a-release.apk` | ARM64 版本 | 大多数现代手机（推荐） |
| `app-armeabi-v7a-release.apk` | ARM 版本 | 较旧的手机 |
| `app-x86_64-release.apk` | x86_64 版本 | 模拟器/少数设备 |
| `app-release.apk` | 通用版本 | 所有设备（文件较大） |

3. 在手机上打开下载的 APK 文件
4. 如果提示"未知来源"，请在设置中允许安装未知来源应用
5. 安装完成后即可使用

### 方式二：从源码构建

```bash
# 1. 克隆仓库
git clone https://github.com/Swimteam0/daily-task-app.git
cd daily-task-app

# 2. 安装依赖
flutter pub get

# 3. 运行（连接手机或启动模拟器后）
flutter run

# 4. 构建 APK
flutter build apk --release --split-per-abi
```

构建完成后，APK 文件位于 `build/app/outputs/flutter-apk/` 目录。

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter 3.x | 跨平台UI框架 |
| Dart 3.x | 编程语言 |
| Provider | 状态管理 |
| sqflite | 本地SQLite数据库 |
| fl_chart | 数据图表 |
| flutter_local_notifications | 本地通知 |

## 项目结构

```
lib/
├── main.dart               # 应用入口
├── app.dart                # App配置（主题、路由、导航）
├── constants/              # 常量定义
├── models/                 # 数据模型
├── providers/              # 状态管理
├── database/               # 数据库操作
├── screens/                # 页面
├── widgets/                # 可复用组件
├── services/               # 服务层
└── utils/                  # 工具函数
```

## 等级系统

| 等级 | 名称 | 图标 | 所需打卡次数 |
|------|------|------|-------------|
| 1 | 初心者 | 🌱 | 0次 |
| 2 | 坚持者 | 🌿 | 10次 |
| 3 | 勤勉者 | 🌳 | 30次 |
| 4 | 执着者 | ⭐ | 60次 |
| 5 | 自律者 | 🌙 | 100次 |
| 6 | 领悟者 | ☀️ | 150次 |
| 7 | 大师 | 🌟 | 220次 |
| 8 | 宗师 | 👑 | 300次 |
| 9 | 传奇 | 💎 | 400次 |
| 10 | 不朽 | 🔱 | 500次 |

## 段位系统

| 段位 | 名称 | 图标 | 所需连续天数 |
|------|------|------|-------------|
| 1 | 黑铁 | ⚫ | 1天 |
| 2 | 青铜 | 🟤 | 3天 |
| 3 | 白银 | ⚪ | 7天 |
| 4 | 黄金 | 🟡 | 14天 |
| 5 | 铂金 | 🔵 | 21天 |
| 6 | 钻石 | 💠 | 30天 |
| 7 | 星耀 | ✨ | 45天 |
| 8 | 王者 | 🏆 | 60天 |

## 开发

```bash
# 安装依赖
flutter pub get

# 运行分析
flutter analyze

# 运行测试
flutter test

# 构建 APK
flutter build apk --release --split-per-abi
```

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证

本项目基于 MIT 许可证开源 - 详见 [LICENSE](LICENSE) 文件
