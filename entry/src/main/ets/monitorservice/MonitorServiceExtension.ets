import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import Want from '@ohos.app.ability.Want';
import rpc from '@ohos.rpc';
import hilog from '@ohos.hilog';
import { MonitorManager } from './MonitorManager';

const TAG: string = 'MonitorService';
const DOMAIN: number = 0x0001;

/**
 * 监控服务扩展能力
 * 用于在后台运行设备监控功能
 */
export default class MonitorServiceExtension extends ServiceExtensionAbility {
  private monitorManager: MonitorManager | null = null;

  /**
   * 服务创建时调用
   * @param want - 启动参数
   */
  onCreate(want: Want): void {
    hilog.info(DOMAIN, TAG, 'MonitorServiceExtension onCreate');
    
    try {
      // 初始化监控管理器
      this.monitorManager = new MonitorManager();
      hilog.info(DOMAIN, TAG, 'MonitorManager initialized successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to initialize MonitorManager: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 服务启动时调用
   * @param want - 启动参数
   * @param startId - 启动ID
   */
  onRequest(want: Want, startId: number): void {
    hilog.info(DOMAIN, TAG, `MonitorServiceExtension onRequest, startId: ${startId}`);
    
    if (this.monitorManager) {
      // 启动监控功能
      this.monitorManager.startMonitoring();
    }
  }

  /**
   * 服务连接时调用
   * @param want - 连接参数
   * @returns 返回连接对象
   */
  onConnect(want: Want): rpc.RemoteObject | Promise<rpc.RemoteObject> {
    hilog.info(DOMAIN, TAG, 'MonitorServiceExtension onConnect');
    
    // 这里可以返回一个RPC代理对象供外部调用
    return null as any;
  }

  /**
   * 服务断开连接时调用
   * @param want - 断开连接参数
   */
  onDisconnect(want: Want): void {
    hilog.info(DOMAIN, TAG, 'MonitorServiceExtension onDisconnect');
  }

  /**
   * 服务销毁时调用
   */
  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'MonitorServiceExtension onDestroy');
    
    if (this.monitorManager) {
      // 停止监控功能
      this.monitorManager.stopMonitoring();
      this.monitorManager = null;
    }
  }
}
