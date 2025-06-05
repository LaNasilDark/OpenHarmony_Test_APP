import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import hilog from '@ohos.hilog';

const TAG: string = 'IndexPage';
const DOMAIN: number = 0x0001;

@Entry
@Component
struct Index {
  @State message: string = 'HarmonyOS 监控应用';
  @State serviceStatus: string = '服务未启动';
  @State isServiceRunning: boolean = false;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  build() {
    Column({ space: 20 }) {
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      Text(this.serviceStatus)
        .fontSize(16)
        .fontColor(this.isServiceRunning ? Color.Green : Color.Red)
        .textAlign(TextAlign.Center)

      Button(this.isServiceRunning ? '停止监控服务' : '启动监控服务')
        .width(200)
        .height(50)
        .backgroundColor(this.isServiceRunning ? Color.Red : Color.Blue)
        .onClick(() => {
          if (this.isServiceRunning) {
            this.stopMonitorService();
          } else {
            this.startMonitorService();
          }
        })

      Text('功能说明：')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 40 })

      Text('• 后台监控设备网络状态\n• 定期广播设备信息\n• 收集网络接口数据\n• 简化版Python监控脚本功能')
        .fontSize(14)
        .fontColor(Color.Gray)
        .textAlign(TextAlign.Start)
        .width('90%')
    }
    .height('100%')
    .width('100%')
    .padding(20)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 启动监控服务
   */
  private async startMonitorService(): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'Starting monitor service...');
      
      const want: Want = {
        bundleName: this.context.abilityInfo.bundleName,
        abilityName: 'MonitorServiceExtension'
      };

      await this.context.startServiceExtensionAbility(want);
      
      this.isServiceRunning = true;
      this.serviceStatus = '监控服务已启动';
      
      hilog.info(DOMAIN, TAG, 'Monitor service started successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to start monitor service: ${JSON.stringify(error)}`);
      this.serviceStatus = '启动服务失败';
    }
  }

  /**
   * 停止监控服务
   */
  private async stopMonitorService(): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'Stopping monitor service...');
      
      const want: Want = {
        bundleName: this.context.abilityInfo.bundleName,
        abilityName: 'MonitorServiceExtension'
      };

      await this.context.stopServiceExtensionAbility(want);
      
      this.isServiceRunning = false;
      this.serviceStatus = '监控服务已停止';
      
      hilog.info(DOMAIN, TAG, 'Monitor service stopped successfully');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to stop monitor service: ${JSON.stringify(error)}`);
      this.serviceStatus = '停止服务失败';
    }
  }
}