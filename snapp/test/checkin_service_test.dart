import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snapp/services/checkin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DateTime fixed(int y, int m, int d) => DateTime(y, m, d);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('checkIn 记录今天并持久化，重启后恢复', () async {
    final service = CheckinService(clock: () => fixed(2026, 9, 17));
    await service.load();
    expect(service.checkedToday, isFalse);
    expect(service.streak, 0);

    await service.checkIn();
    expect(service.checkedToday, isTrue);
    expect(service.streak, 1);

    // 新实例（模拟重启）从存储恢复
    final restored = CheckinService(clock: () => fixed(2026, 9, 17));
    await restored.load();
    expect(restored.checkedToday, isTrue);
    expect(restored.dates, contains('2026-09-17'));
  });

  test('checkIn 今日已签幂等，不重复记录', () async {
    final service = CheckinService(clock: () => fixed(2026, 9, 17));
    await service.checkIn();
    await service.checkIn();
    expect(service.dates, {'2026-09-17'});
  });

  test('streak 连续多天正确向前计数', () async {
    final service = CheckinService(clock: () => fixed(2026, 9, 17));
    await service.checkIn();
    // 补签昨天与前天
    service.dates.addAll({'2026-09-16', '2026-09-15'});
    expect(service.streak, 3);

    // 前天缺 → 只从昨天连续 2 天
    service.dates.remove('2026-09-15');
    expect(service.streak, 2);
  });

  test('streak 今天未签时以昨天为基准（今天断签不计）', () async {
    final service = CheckinService(clock: () => fixed(2026, 9, 17));
    service.dates.addAll({'2026-09-16', '2026-09-15'});
    expect(service.checkedToday, isFalse);
    expect(service.streak, 2);
  });

  test('日期格式化与解析往返一致', () {
    expect(CheckinService.dateKey(fixed(2026, 9, 5)), '2026-09-05');
    expect(
      CheckinService.dateKey(CheckinService.parseDate('2026-09-05')),
      '2026-09-05',
    );
  });

  test('checkIn 触发 notifyListeners，未变更不触发', () async {
    final service = CheckinService(clock: () => fixed(2026, 9, 17));
    var notified = 0;
    service.addListener(() => notified++);

    await service.checkIn();
    expect(notified, 1);

    await service.checkIn(); // 幂等，不通知
    expect(notified, 1);
  });
}
