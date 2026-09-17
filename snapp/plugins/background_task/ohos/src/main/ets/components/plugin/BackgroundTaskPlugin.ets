import { FlutterPlugin, FlutterPluginBinding, MethodChannel } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { BackgroundTaskMethodCallHandler } from './BackgroundTaskMethodCallHandler';

/** 声栖后台长时任务插件（channel: com.snapp.background）。 */
export default class BackgroundTaskPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;
  private methodCallHandler: BackgroundTaskMethodCallHandler | null = null;

  getUniqueClassName(): string {
    return 'BackgroundTaskPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    const appContext: common.Context = binding.getApplicationContext();
    // 优先使用 UIAbilityContext（由 EntryAbility 写入），否则 401 参数校验失败。
    const abilityContext: common.UIAbilityContext | undefined = AppStorage.get<common.UIAbilityContext>('entryContext');
    const context: common.Context = abilityContext !== undefined ? abilityContext : appContext;
    this.methodCallHandler = new BackgroundTaskMethodCallHandler(context);
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'com.snapp.background');
    this.channel.setMethodCallHandler(this.methodCallHandler);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.methodCallHandler = null;
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
  }
}