#!/usr/bin/env python3
"""
UDP广播监听器
用于测试HarmonyOS监控应用的UDP广播功能
"""

import socket
import json
import datetime
import threading
import sys

class UDPBroadcastListener:
    def __init__(self, port=8888):
        self.port = port
        self.running = False
        self.socket = None
        
    def start_listening(self):
        """开始监听UDP广播"""
        try:
            # 创建UDP套接字
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
            
            # 绑定到指定端口
            self.socket.bind(('', self.port))
            self.running = True
            
            print(f"开始监听UDP广播，端口: {self.port}")
            print("等待来自HarmonyOS监控应用的广播消息...")
            print("-" * 60)
            
            while self.running:
                try:
                    # 接收数据
                    data, addr = self.socket.recvfrom(4096)
                    
                    # 解析消息
                    message = data.decode('utf-8')
                    timestamp = datetime.datetime.now().strftime('%H:%M:%S')
                    
                    print(f"[{timestamp}] 收到来自 {addr[0]}:{addr[1]} 的消息:")
                    
                    try:
                        # 尝试解析JSON
                        json_data = json.loads(message)
                        self.format_device_status(json_data)
                    except json.JSONDecodeError:
                        print(f"原始消息: {message}")
                    
                    print("-" * 60)
                    
                except socket.timeout:
                    continue
                except Exception as e:
                    if self.running:
                        print(f"接收消息时出错: {e}")
                        
        except Exception as e:
            print(f"启动监听器失败: {e}")
        finally:
            if self.socket:
                self.socket.close()
    
    def format_device_status(self, data):
        """格式化设备状态信息"""
        print("📱 设备状态信息:")
        print(f"   消息类型: {data.get('type', 'unknown')}")
        print(f"   数据源: {data.get('source', 'unknown')}")
        print(f"   版本: {data.get('version', 'unknown')}")
        print(f"   时间戳: {data.get('timestamp', 'unknown')}")
        
        device_data = data.get('data', {})
        if device_data:
            print(f"   设备在线: {'是' if device_data.get('isOnline', False) else '否'}")
            print(f"   状态时间: {datetime.datetime.fromtimestamp(device_data.get('timestamp', 0) / 1000).strftime('%Y-%m-%d %H:%M:%S')}")
            
            # 网络接口信息
            interfaces = device_data.get('networkInterfaces', [])
            if interfaces:
                print("🌐 网络接口信息:")
                for i, interface in enumerate(interfaces):
                    print(f"   接口 {i+1}:")
                    print(f"      名称: {interface.get('interfaceName', 'unknown')}")
                    print(f"      IP地址: {interface.get('ipAddress', 'unknown')}")
                    print(f"      子网掩码: {interface.get('netmask', 'unknown')}")
                    print(f"      网关: {interface.get('gateway', 'unknown')}")
                    print(f"      状态: {'活跃' if interface.get('isActive', False) else '非活跃'}")
    
    def stop_listening(self):
        """停止监听"""
        self.running = False
        if self.socket:
            self.socket.close()

def main():
    """主函数"""
    print("HarmonyOS监控应用 - UDP广播监听器")
    print("用于接收和显示来自HarmonyOS设备的监控数据")
    print("按 Ctrl+C 停止监听")
    print("=" * 60)
    
    listener = UDPBroadcastListener()
    
    try:
        listener.start_listening()
    except KeyboardInterrupt:
        print("\n正在停止监听器...")
        listener.stop_listening()
        print("监听器已停止")
    except Exception as e:
        print(f"运行时出错: {e}")
        listener.stop_listening()

if __name__ == "__main__":
    main()
