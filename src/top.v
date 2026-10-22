`timescale 1ns / 1ps

// [신규] 09번 top 구조(debouncer → controller → fnd)를 바탕으로 모듈 추가
//        INPUT_FREQ / DEBOUNCE_LIMIT 파라미터 : 시뮬레이션 때 시간 단축용

// 분초시계 + 스톱워치
//   btnL : 모드 전환 (분초시계 <-> 스톱워치)
//   btnC : 스톱워치 RUN / STOP
//   btnR : 스톱워치 CLEAR (STOP 상태에서)
//   btnU : reset
module top #(
    parameter INPUT_FREQ     = 100_000_000,
    parameter DEBOUNCE_LIMIT = 20'd999_999
    )(
    input clk,
    input reset,
    input [2:0] btn,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0]  w_clean_btn;
    wire        w_tick_1ms, w_tick_10ms;
    wire        w_btn_L, w_btn_C, w_btn_R;
    wire        w_mode;
    wire        w_run, w_clear, w_anim;
    wire [3:0]  w_anim_step;
    wire [5:0]  w_min, w_sec, w_sw_sec;
    wire [6:0]  w_sw_cs;
    wire        w_dot;
    wire [13:0] w_fnd_data;
    wire        w_fnd_dot;

    btn_debouncer #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn),
        .clean_btn(w_clean_btn)
    );

    tick_generator #(.INPUT_FREQ(INPUT_FREQ), .TICK_Hz(1000)) u_tick_1ms(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1ms)
    );

    tick_generator #(.INPUT_FREQ(INPUT_FREQ), .TICK_Hz(100)) u_tick_10ms(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_10ms)
    );

    main_controller u_main_controller(
        .clk(clk),
        .reset(reset),
        .btn(w_clean_btn),
        .w_min(w_min),
        .w_sec(w_sec),
        .w_dot(w_dot),
        .sw_sec(w_sw_sec),
        .sw_cs(w_sw_cs),
        .btn_L(w_btn_L),
        .btn_C(w_btn_C),
        .btn_R(w_btn_R),
        .mode(w_mode),
        .fnd_data(w_fnd_data),
        .fnd_dot(w_fnd_dot)
    );

    stopwatch_fsm u_stopwatch_fsm(
        .clk(clk),
        .reset(reset),
        .tick_10ms(w_tick_10ms),
        .mode(w_mode),
        .btn_L(w_btn_L),
        .btn_C(w_btn_C),
        .btn_R(w_btn_R),
        .run(w_run),
        .clear(w_clear),
        .anim(w_anim),
        .anim_step(w_anim_step)
    );

    stopwatch_counter u_stopwatch_counter(
        .clk(clk),
        .reset(reset),
        .tick_10ms(w_tick_10ms),
        .run(w_run),
        .clear(w_clear),
        .cs(w_sw_cs),
        .sec(w_sw_sec)
    );

    watch_counter u_watch_counter(
        .clk(clk),
        .reset(reset),
        .tick_10ms(w_tick_10ms),
        .min(w_min),
        .sec(w_sec),
        .dot(w_dot)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1ms),
        .in_data(w_fnd_data),
        .dot(w_fnd_dot),
        .anim(w_anim),
        .anim_step(w_anim_step),
        .an(an),
        .seg(seg)
    );

    // LED : [0] 스톱워치 모드  [1] RUN  [2] 애니메이션
    assign led = {13'b0, w_anim, w_run, w_mode};

endmodule
