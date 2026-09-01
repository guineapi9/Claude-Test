# 단어장 (Wordbook)

Flutter로 만든 개인용 단어장 앱입니다. 기기에만 데이터를 저장하며, 서버나 로그인 없이 바로 사용할 수 있어요.

## 주요 기능

- **단어 CRUD**: 단어, 뜻, 예문을 추가/수정/삭제하고 검색할 수 있어요.
- **카테고리**: 단어를 주제별 카테고리(폴더)로 묶어 관리할 수 있어요.
- **플래시카드 학습**: 카드를 넘기며 단어를 암기하는 학습 모드예요.
- **복습 스케줄링(SRS)**: SM-2 간격 반복 알고리즘으로, 각 단어를 얼마나 잘 기억했는지에 따라 다음 복습일을 자동으로 계산해요. 플래시카드에서 "다시 / 애매해요 / 알아요"를 선택하면 그 결과가 반영돼요.

## 기술 스택

- Flutter (Material 3), 상태 관리는 `provider`
- 로컬 저장소는 `hive`/`hive_flutter` (모바일·웹 모두 지원, 별도 서버 불필요)

## 지원 플랫폼

모바일(Android/iOS)과 웹을 대상으로 합니다.

## 시작하기

```bash
flutter pub get
flutter run                # 연결된 기기/에뮬레이터에서 실행
flutter run -d chrome       # 웹으로 실행
```

## 모델 변경 시

`Word`, `WordCategory`에 `@HiveField`를 추가/변경했다면 Hive 어댑터를 다시 생성해야 해요.

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 테스트

```bash
flutter analyze
flutter test
```

## 프로젝트 구조

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
