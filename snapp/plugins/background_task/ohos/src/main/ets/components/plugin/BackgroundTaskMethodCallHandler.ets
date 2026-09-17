import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { common, wantAgent, WantAgent } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'BackgroundTask';

/**
 * 处理来自 Dart 侧 MethodChannel 的 start/stop 调用。
 * start：申请 audioPlayback 长时任务（退后台持续播放 + 通知栏播放条）；
 * stop：释放长时任务。
 */
export class BackgroundTaskMethodCallHandler implements MethodCallHandler {
  private readonly context: common.Context;
  private agent: WantAgent | null = null;

  constructor(context: common.Context) {
    this.context = context;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'start':
        this.startBackground().then(() => {
          result.success(null);
        });
        break;
      case 'stop':
        this.stopBackground().then(() => {
          result.success(null);
        });
        break;
      default:
        result.notImplemented();
    }
  }

  private async startBackground(): Promise<void> {
    try {
      if (this.agent === null) {
        this.agent = await wantAgent.getWantAgent({
          wants: [
            {
              bundleName: 'com.sx.whitenoise',
              abilityName: 'EntryAbility',
            },
          ],
          actionType: wantAgent.OperationType.START_ABILITY,
          requestCode: 0,
          actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
        });
      }
      await backgroundTaskManager.startBackgroundRunning(
        this.context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        this.agent,
      );
      hilog.info(0x0000, TAG, 'background running started');
    } catch (e) {
      const err = e as Error;
      hilog.error(0x0000, TAG, 'start background failed: %{public}s | detail: %{public}s',
        JSON.stringify(e), err.message);
    }
  }

  private async stopBackground(): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context);
      hilog.info(0x0000, TAG, 'background running stopped');
    } catch (e) {
      hilog.error(0x0000, TAG, 'stop background failed: %{public}s', JSON.stringify(e));
    }
  }
}