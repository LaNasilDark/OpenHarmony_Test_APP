# HarmonyOS 设备监控应用

这是一个基于ArkTS开发的HarmonyOS后台监控应用，用于演示如何在HarmonyOS中实现后台服务和网络监控功能。

## 功能特性

### 核心功能
- **后台监控服务**: 基于Service Extension Ability实现的后台服务
- **网络状态监控**: 实时监控设备网络连接状态
- **UDP广播**: 定期广播设备状态信息
- **网络信息收集**: 收集IP地址、网关、子网掩码等网络配置信息

### 技术特点
- **异步编程**: 使用Promise和async/await处理异步操作
- **模块化设计**: 分离业务逻辑和工具类
- **配置管理**: 统一管理监控参数和配置
- **错误处理**: 完整的异常捕获和错误日志记录
- **单元测试**: 包含网络工具类的单元测试

## 项目结构

```
entry/src/main/ets/
├── entryability/          # 主应用能力
├── monitorservice/        # 监控服务模块
│   ├── MonitorServiceExtension.ets  # 服务扩展能力
│   ├── MonitorManager.ets           # 监控管理器
│   ├── NetworkUtils.ets             # 网络工具类
│   └── MonitorConfig.ets            # 配置管理
└── pages/
    └── Index.ets          # 主界面
```

## 与Python版本的对比

### Python版本 (monitor_run.py)
- 使用psutil库获取系统信息
- 直接操作网络配置
- 同步编程模型
- 系统级权限访问

### ArkTS版本 (HarmonyOS)
- 使用HarmonyOS网络API
- 受沙盒限制，权限受控
- 异步编程模型
- 应用级权限访问

## 使用方法

### 1. 编译和安装
```bash
# 在项目根目录下执行
hvigorw assembleHap
```

### 2. 启动监控服务
1. 打开应用
2. 点击"启动监控服务"按钮
3. 服务将在后台运行，每30秒广播一次设备状态

### 3. 查看日志
使用HiLog查看监控日志：
```bash
hdc hilog | grep Monitor
```

## 配置说明

### MonitorConfig.ets 配置项
- `MONITOR_INTERVAL`: 监控间隔时间（默认30秒）
- `BROADCAST_PORT`: UDP广播端口（默认8888）
- `BROADCAST_ADDRESS`: 广播地址（默认255.255.255.255）

### 权限配置
应用需要以下权限：
- `ohos.permission.INTERNET`: 网络访问权限
- `ohos.permission.GET_NETWORK_INFO`: 获取网络信息权限

## 测试

运行单元测试：
```bash
hvigorw testOhosTest
```

测试覆盖了NetworkUtils工具类的以下功能：
- IP地址有效性验证
- 私有IP地址识别
- CIDR计算
- 网络速度格式化
- 网络类型描述

## 限制和注意事项

1. **沙盒限制**: HarmonyOS应用运行在沙盒环境中，无法像Python脚本那样直接访问系统资源
2. **权限限制**: 某些网络操作需要特殊权限，普通应用可能无法获取
3. **后台运行**: 长时间后台运行可能受到系统电池优化策略影响
4. **网络API**: HarmonyOS的网络API相对有限，某些高级功能可能无法实现

## 扩展功能

可以考虑添加的功能：
- 设备信息收集（电池状态、存储空间等）
- 网络性能测试（延迟、带宽测试）
- 数据持久化存储
- Web服务接口
- 推送通知功能

## 开发环境

- DevEco Studio 4.0+
- HarmonyOS SDK API 10+
- ArkTS 4.0+

## 参考资料

- [HarmonyOS应用开发文档](https://developer.harmonyos.com/)
- [ArkTS语言规范](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-basic-syntax-overview-0000001531611153-V3)
- [Service Extension Ability开发指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/serviceextensionability-0000001427584712-V3)
