import connection from '@ohos.net.connection';
import socket from '@ohos.net.socket';
import hilog from '@ohos.hilog';
import { NetworkUtils } from './NetworkUtils';
import { MonitorConfig } from './MonitorConfig';

const TAG: string = `${MonitorConfig.LOG_CONFIG.TAG_PREFIX}Manager`;
const DOMAIN: number = MonitorConfig.LOG_CONFIG.DOMAIN;

/**
 * 网络信息接口
 */
interface NetworkInfo {
  interfaceName: string;
  ipAddress: string;
  netmask: string;
  gateway: string;
  isActive: boolean;
}

/**
 * 设备状态接口
 */
interface DeviceStatus {
  timestamp: number;
  networkInterfaces: NetworkInfo[];
  isOnline: boolean;
}

/**
 * 监控管理器
 * 负责设备状态监控和网络信息收集
 */
export class MonitorManager {
  private isMonitoring: boolean = false;
  private monitorTimer: number | null = null;
  private broadcastSocket: socket.UDPSocket | null = null;
  private readonly MONITOR_INTERVAL: number = MonitorConfig.MONITOR_INTERVAL;
  private readonly BROADCAST_PORT: number = MonitorConfig.BROADCAST_PORT;

  constructor() {
    hilog.info(DOMAIN, TAG, 'MonitorManager constructor');
  }

  /**
   * 开始监控
   */
  async startMonitoring(): Promise<void> {
    if (this.isMonitoring) {
      hilog.warn(DOMAIN, TAG, 'Monitoring is already running');
      return;
    }

    hilog.info(DOMAIN, TAG, 'Starting monitoring...');
    this.isMonitoring = true;

    try {
      // 初始化UDP广播套接字
      await this.initBroadcastSocket();
      
      // 启动定时监控
      this.startPeriodicMonitoring();
      
      hilog.info(DOMAIN, TAG, 'Monitoring started successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to start monitoring: ${JSON.stringify(error)}`);
      this.isMonitoring = false;
    }
  }

  /**
   * 停止监控
   */
  stopMonitoring(): void {
    hilog.info(DOMAIN, TAG, 'Stopping monitoring...');
    
    this.isMonitoring = false;
    
    // 清除定时器
    if (this.monitorTimer !== null) {
      clearInterval(this.monitorTimer);
      this.monitorTimer = null;
    }
    
    // 关闭UDP套接字
    if (this.broadcastSocket) {
      this.broadcastSocket.close();
      this.broadcastSocket = null;
    }
    
    hilog.info(DOMAIN, TAG, 'Monitoring stopped');
  }

  /**
   * 初始化UDP广播套接字
   */
  private async initBroadcastSocket(): Promise<void> {
    try {
      this.broadcastSocket = socket.constructUDPSocketInstance();
        // 绑定到本地端口
      await this.broadcastSocket.bind({ 
        address: MonitorConfig.LOCAL_BIND_ADDRESS, 
        port: this.BROADCAST_PORT 
      });
      
      // 启用广播
      await this.broadcastSocket.setExtraOptions({
        broadcast: true,
        reuseAddress: true
      });
      
      hilog.info(DOMAIN, TAG, 'UDP broadcast socket initialized');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize UDP socket: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  /**
   * 启动定时监控
   */
  private startPeriodicMonitoring(): void {
    // 立即执行一次监控
    this.performMonitoring();
    
    // 设置定时器
    this.monitorTimer = setInterval(() => {
      if (this.isMonitoring) {
        this.performMonitoring();
      }
    }, this.MONITOR_INTERVAL);
  }

  /**
   * 执行监控任务
   */
  private async performMonitoring(): Promise<void> {
    try {
      // 收集设备状态信息
      const deviceStatus = await this.collectDeviceStatus();
      
      // 广播设备状态
      await this.broadcastDeviceStatus(deviceStatus);
      
      hilog.info(DOMAIN, TAG, `Monitoring completed at ${new Date().toISOString()}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Monitoring failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 收集设备状态信息
   */
  private async collectDeviceStatus(): Promise<DeviceStatus> {
    const networkInterfaces = await this.getNetworkInterfaces();
    const isOnline = networkInterfaces.some(nic => nic.isActive);
    
    return {
      timestamp: Date.now(),
      networkInterfaces: networkInterfaces,
      isOnline: isOnline
    };
  }
  /**
   * 获取网络接口信息
   */
  private async getNetworkInterfaces(): Promise<NetworkInfo[]> {
    try {
      // 获取默认网络信息
      const defaultNet = await connection.getDefaultNet();
      const netCapabilities = await connection.getNetCapabilities(defaultNet);
      const connectionProperties = await connection.getConnectionProperties(defaultNet);
      
      const ipAddress = connectionProperties.linkAddresses?.[0]?.address?.address || '0.0.0.0';      const gateway = connectionProperties.routeList?.[0]?.gateway?.address || MonitorConfig.NETWORK_CONFIG.DEFAULT_GATEWAY;
      const netmask = MonitorConfig.NETWORK_CONFIG.DEFAULT_NETMASK;
      
      // 使用NetworkUtils验证IP地址
      const isValidIP = NetworkUtils.isValidIP(ipAddress);
      const isPrivateIP = NetworkUtils.isPrivateIP(ipAddress);
      const cidr = NetworkUtils.calculateCIDR(netmask);
      
      hilog.info(DOMAIN, TAG, `Network Info - IP: ${ipAddress}, Valid: ${isValidIP}, Private: ${isPrivateIP}, CIDR: /${cidr}`);
      
      const networkInfo: NetworkInfo = {
        interfaceName: connectionProperties.interfaceName || 'unknown',
        ipAddress: ipAddress,
        netmask: netmask,
        gateway: gateway,
        isActive: netCapabilities?.netCaps?.includes(connection.NetCap.NET_CAPABILITY_INTERNET) || false
      };
      
      return [networkInfo];
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get network interfaces: ${JSON.stringify(error)}`);
        // 返回默认的网络信息
      return [{
        interfaceName: 'unknown',
        ipAddress: MonitorConfig.NETWORK_CONFIG.DEFAULT_GATEWAY,
        netmask: MonitorConfig.NETWORK_CONFIG.DEFAULT_NETMASK,
        gateway: MonitorConfig.NETWORK_CONFIG.DEFAULT_GATEWAY,
        isActive: false
      }];
    }
  }

  /**
   * 广播设备状态
   */
  private async broadcastDeviceStatus(deviceStatus: DeviceStatus): Promise<void> {
    if (!this.broadcastSocket) {
      hilog.warn(DOMAIN, TAG, 'Broadcast socket not initialized');
      return;
    }

    try {      const message = JSON.stringify({
        type: MonitorConfig.MESSAGE_TYPES.DEVICE_STATUS,
        data: deviceStatus,
        source: MonitorConfig.DEVICE_CONFIG.SOURCE_NAME,
        version: MonitorConfig.DEVICE_CONFIG.VERSION,
        timestamp: new Date().toISOString()
      });

      // 广播到指定地址
      await this.broadcastSocket.send({
        data: message,
        address: {
          address: MonitorConfig.BROADCAST_ADDRESS,
          port: this.BROADCAST_PORT
        }
      });

      hilog.info(DOMAIN, TAG, `Broadcasted device status: ${message.substring(0, 100)}...`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to broadcast device status: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取监控状态
   */
  isMonitoringActive(): boolean {
    return this.isMonitoring;
  }
}
