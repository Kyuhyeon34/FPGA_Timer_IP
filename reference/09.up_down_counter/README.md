# [원본] 09.up_down_counter (비교용)

**수정하지 않은 원본 그대로입니다.** 11.stopwatch(`/src`)에서 무엇이 바뀌었는지 비교할 때 보세요.

| 원본 (이 폴더) `09.upcounter.srcs/sources_1/new/` | 11.stopwatch `src/` | 관계 |
|---|---|---|
| `tick_generator.v` | `tick_generator.v` | 그대로 재사용 |
| `btn_debounce10ms.v` | `btn_debounce10ms.v` | DEBOUNCE_LIMIT 파라미터 전달 추가 |
| `fnd_controller.v` | `fnd_controller.v` | dot, circle 애니메이션 추가 |
| `main_controller.v` | `main_controller.v` | 새로 작성 (엣지 검출 방식만 참고) |
| `top.v` | `top.v` | 구조 참고, 모듈 추가 |
| `constrs_1/imports/p10/basys3_1010111_detect.xdc` | `basys3_stopwatch.xdc` | sw 핀 제거 |
| - | `stopwatch_fsm.v`, `stopwatch_counter.v`, `watch_counter.v`, `tb_top.v` | 신규 |

비교 예 : `git diff --no-index reference/09.up_down_counter/09.upcounter.srcs/sources_1/new/fnd_controller.v src/fnd_controller.v`
