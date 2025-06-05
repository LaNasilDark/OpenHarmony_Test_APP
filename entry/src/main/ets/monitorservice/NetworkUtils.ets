import hilog from '@ohos.hilog';

const TAG: string = 'NetworkUtils';
const DOMAIN: number = 0x0001;

/**
 * 网络工具类
 * 提供网络相关的辅助功能
 */
export class NetworkUtils {
  
  /**
   * 检查IP地址是否有效
   * @param ip IP地址字符串
   * @returns 是否有效
   */
  static isValidIP(ip: string): boolean {
    const ipPattern = /^(\d{1,3}\.){3}\d{1,3}$/;
    if (!ipPattern.test(ip)) {
      return false;
    }
    
    const parts = ip.split('.');
    return parts.every(part => {
      const num = parseInt(part);
      return num >= 0 && num <= 255;
    });
  }

  /**
   * 获取网络类型描述
   * @param networkType 网络类型
   * @returns 网络类型描述
   */
  static getNetworkTypeDescription(networkType: number): string {
    switch (networkType) {
      case 1:
        return 'WiFi';
      case 2:
        return '移动网络';
      case 3:
        return '以太网';
      default:
        return '未知网络';
    }
  }

  /**
   * 格式化网络速度
   * @param bytes 字节数
   * @returns 格式化后的速度字符串
   */
  static formatNetworkSpeed(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes} B/s`;
    } else if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(2)} KB/s`;
    } else {
      return `${(bytes / (1024 * 1024)).toFixed(2)} MB/s`;
    }
  }

  /**
   * 计算子网掩码对应的CIDR前缀长度
   * @param netmask 子网掩码
   * @returns CIDR前缀长度
   */
  static calculateCIDR(netmask: string): number {
    try {
      const parts = netmask.split('.');
      let cidr = 0;
      
      for (const part of parts) {
        const num = parseInt(part);
        const binary = num.toString(2);
        cidr += (binary.match(/1/g) || []).length;
      }
      
      return cidr;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to calculate CIDR: ${JSON.stringify(error)}`);
      return 24; // 默认返回24
    }
  }

  /**
   * 检查是否为私有IP地址
   * @param ip IP地址
   * @returns 是否为私有IP
   */
  static isPrivateIP(ip: string): boolean {
    if (!this.isValidIP(ip)) {
      return false;
    }
    
    const parts = ip.split('.').map(part => parseInt(part));
    const firstOctet = parts[0];
    const secondOctet = parts[1];
    
    // 10.0.0.0 - 10.255.255.255
    if (firstOctet === 10) {
      return true;
    }
    
    // 172.16.0.0 - 172.31.255.255
    if (firstOctet === 172 && secondOctet >= 16 && secondOctet <= 31) {
      return true;
    }
    
    // 192.168.0.0 - 192.168.255.255
    if (firstOctet === 192 && secondOctet === 168) {
      return true;
    }
    
    return false;
  }
}
