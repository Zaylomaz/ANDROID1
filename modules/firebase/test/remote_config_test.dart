import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () async {
    final version_1_0_50 = await AppConfigTools.needUpdate(
      minimumVersion: '1.0.50',
      currentPackageVersion: '2.0.0',
    );
    final version_1_2_50 = await AppConfigTools.needUpdate(
      minimumVersion: '1.2.50',
      currentPackageVersion: '2.0.0',
    );
    final version_1_12_0 = await AppConfigTools.needUpdate(
      minimumVersion: '1.12.0',
      currentPackageVersion: '2.0.0',
    );
    final version_2_0_0 = await AppConfigTools.needUpdate(
      minimumVersion: '2.0.0',
      currentPackageVersion: '2.0.0',
    );
    final version_2_0_2 = await AppConfigTools.needUpdate(
      minimumVersion: '2.0.2',
      currentPackageVersion: '2.0.0',
    );
    final version_2_1_0 = await AppConfigTools.needUpdate(
      minimumVersion: '2.1.0',
      currentPackageVersion: '2.0.0',
    );
    expect(version_1_0_50, false);
    expect(version_1_2_50, false);
    expect(version_1_12_0, false);
    expect(version_2_0_0, false);
    expect(version_2_0_2, true);
    expect(version_2_1_0, true);
  });
}
