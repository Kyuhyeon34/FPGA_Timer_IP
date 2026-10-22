`timescale 1ns / 1ps

// [신규] 09번 main_controller의 엣지 검출(r_prev_btn) 방식을 참고해 새로 작성
//        버튼 엣지 검출 + 모드 전환 + FND 데이터 선택

// 버튼 엣지 검출 + 모드(분초시계 / 스톱워치) 전환 + FND에 보낼 데이터 선택
module main_controller(
    input clk,
    input reset,
    input [2:0] btn,          // 디바운싱된 버튼 [0]:L [1]:C [2]:R
    input [5:0] w_min,        // 분초시계 분
    input [5:0] w_sec,        // 분초시계 초
    input       w_dot,        // 분초시계 dot (0.5초마다 토글)
    input [5:0] sw_sec,       // 스톱워치 초
    input [6:0] sw_cs,        // 스톱워치 1/100초
    output      btn_L,        // 버튼 눌린 순간 1클럭 펄스
    output      btn_C,
    output      btn_R,
    output reg  mode,         // 0: 분초시계  1: 스톱워치
    output [13:0] fnd_data,
    output      fnd_dot
    );

    // ---- 버튼 엣지 검출 : 이전 값이 0이고 현재 값이 1일 때만 1
    reg [2:0] r_prev_btn;

    always @(posedge clk, posedge reset) begin
        if (reset) r_prev_btn <= 0;
        else       r_prev_btn <= btn;
    end

    assign btn_L = btn[0] & ~r_prev_btn[0];
    assign btn_C = btn[1] & ~r_prev_btn[1];
    assign btn_R = btn[2] & ~r_prev_btn[2];

    // ---- btnL : 모드 전환
    always @(posedge clk, posedge reset) begin
        if (reset)      mode <= 0;
        else if (btn_L) mode <= ~mode;
    end

    // ---- FND 표시 데이터
    // 분초시계 : MM.SS  (dot 1초에 1번 깜박)
    // 스톱워치 : SS.cc  (dot 항상 켜짐)
    assign fnd_data = (mode) ? (sw_sec * 100 + sw_cs) : (w_min * 100 + w_sec);
    assign fnd_dot  = (mode) ? 1'b1 : w_dot;

endmodule
