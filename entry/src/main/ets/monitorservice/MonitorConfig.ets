/**
 * 监控配置类
 * 管理监控服务的各种配置参数
 */
export class MonitorConfig {
  // 监控间隔时间（毫秒）
  static readonly MONITOR_INTERVAL: number = 30000; // 30秒
  
  // UDP广播端口
  static readonly BROADCAST_PORT: number = 8888;
  
  // 广播地址
  static readonly BROADCAST_ADDRESS: string = '255.255.255.255';
  
  // 本地绑定地址
  static readonly LOCAL_BIND_ADDRESS: string = '0.0.0.0';
  
  // 消息类型定义
  static readonly MESSAGE_TYPES = {
    DEVICE_STATUS: 'device_status',
    HEARTBEAT: 'heartbeat',
    NETWORK_CHANGE: 'network_change'
  } as const;
  
  // 日志配置
  static readonly LOG_CONFIG = {
    DOMAIN: 0x0001,
    TAG_PREFIX: 'Monitor'
  } as const;
  
  // 重试配置
  static readonly RETRY_CONFIG = {
    MAX_RETRIES: 3,
    RETRY_DELAY: 1000 // 1秒
  } as const;
  
  // 网络配置
  static readonly NETWORK_CONFIG = {
    DEFAULT_NETMASK: '255.255.255.0',
    DEFAULT_GATEWAY: '0.0.0.0',
    TIMEOUT: 5000 // 5秒超时
  } as const;
  
  // 设备信息配置
  static readonly DEVICE_CONFIG = {
    SOURCE_NAME: 'harmonyos_monitor',
    VERSION: '1.0.0'
  } as const;
}
