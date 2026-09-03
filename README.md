<div align="center">

# 📘 단어장

**매일 조금씩, 오래 남는 단어장.**

서버도 로그인도 없이 기기 안에서만 단어를 모으고, SM-2 간격 반복 알고리즘이 각 단어를 얼마나 잘
기억했는지에 따라 다음 복습일을 자동으로 잡아주는 개인용 Flutter 단어장 앱입니다.

[![Flutter](https://img.shields.io/badge/Flutter-Material%203-2537B1?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-2537B1?style=for-the-badge)](#지원-플랫폼)
[![Storage](https://img.shields.io/badge/Storage-Hive%20(로컬)-2537B1?style=for-the-badge)](#기술-스택)

|            SM-2             |            0            |               2               |
| :--------------------------: | :----------------------: | :-----------------------------: |
| 간격 반복 복습 알고리즘 | 서버 · 로그인 필요 없음 | 지원 플랫폼 (모바일 · 웹) |

</div>

---

## ✦ 핵심 기능

| 기능 | 설명 |
| --- | --- |
| **단어 CRUD** | 단어 · 뜻 · 예문을 추가/수정/삭제하고, 검색과 카테고리 필터로 바로 찾을 수 있어요. |
| **카테고리** | TOEIC, 일상 회화처럼 주제별 폴더로 단어를 묶어 필요한 세트만 골라 학습해요. |
| **플래시카드 학습** | 카드를 탭해서 뜻을 확인하는 학습 모드예요. |
| **복습 스케줄링 (SRS)** | "다시 / 애매해요 / 알아요" 3단계 평가로 SM-2가 다음 복습일을 자동 계산해요. |

## ✦ 기술 스택

**프레임워크 · 상태 관리**

![Flutter](https://img.shields.io/badge/Flutter-2537B1?style=flat-square) ![Material 3](https://img.shields.io/badge/Material%203-2537B1?style=flat-square) ![provider](https://img.shields.io/badge/provider-2537B1?style=flat-square)

**저장소 · 플랫폼**

![hive](https://img.shields.io/badge/hive-2537B1?style=flat-square) ![hive_flutter](https://img.shields.io/badge/hive__flutter-2537B1?style=flat-square) ![Android](https://img.shields.io/badge/Android-2537B1?style=flat-square) ![iOS](https://img.shields.io/badge/iOS-2537B1?style=flat-square) ![Web](https://img.shields.io/badge/Web-2537B1?style=flat-square)

로컬 저장소는 `hive`/`hive_flutter`를 사용해 모바일·웹 모두에서 별도 서버 없이 동작합니다.

### 검증 완료

![analyze](https://img.shields.io/badge/flutter%20analyze-이슈%200건-2537B1?style=flat-square) ![test](https://img.shields.io/badge/flutter%20test-6%2F6%20통과-2537B1?style=flat-square) ![build](https://img.shields.io/badge/flutter%20build%20web-성공-2537B1?style=flat-square)

## ✦ 시작하기

```bash
flutter pub get
flutter run                 # 연결된 기기/에뮬레이터에서 실행
flutter run -d chrome       # 웹으로 실행
```

### 모델 변경 시

`Word`, `WordCategory`에 `@HiveField`를 추가/변경했다면 Hive 어댑터를 다시 생성해야 해요.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 테스트

```bash
flutter analyze
flutter test
```

## ✦ 프로젝트 구조

```
lib/
  models/       # Word, WordCategory (Hive 모델)
  data/         # WordRepository — Hive 박스 CRUD
  services/     # SrsService — SM-2 간격 반복 알고리즘
  providers/    # WordProvider — 앱 상태 (ChangeNotifier)
  screens/      # 화면 (단어 목록, 추가/수정, 카테고리, 플래시카드)
  widgets/      # 재사용 위젯
  theme/        # 앱 테마
```

<div align="center">

---

Flutter · Material 3 · Hive 기반 개인 단어장 — 서버 없음 · 기기 로컬 저장

</div>
