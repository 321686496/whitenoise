import { common } from '@kit.AbilityKit';
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    // 供 background_task 插件取用：长时任务 API 需传 UIAbilityContext，
    // 传应用级 context 会触发 401 参数校验失败。
    AppStorage.setOrCreate<common.UIAbilityContext>('entryContext', this.context);
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }
}