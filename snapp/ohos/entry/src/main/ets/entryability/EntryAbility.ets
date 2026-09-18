import { common } from '@kit.AbilityKit';
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    // 供 background_task 插件取用：长时任务 API 需传 UIAbilityContext，
    // 传应用级 context 会触发 401 参数校验失败。
    AppStorage.setOrCreate<common.UIAbilityContext>('entryContext', this.context);
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    // 修复引擎 context 接缝：just_audio_ohos 注册时向 'context' 写入了 applicationContext，
    // 而 createAVSession 需要 UIAbilityContext。registerWith 之后用 UIAbilityContext 覆盖之，
    // 使 MediaAvPlayer 以正确 context 创建 AVSession（通知栏播放条 + 后台播放）。
    AppStorage.setOrCreate<common.UIAbilityContext>('context', this.context);
  }
}