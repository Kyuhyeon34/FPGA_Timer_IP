`timescale 1ns / 1ps

// [신규] 10번 FSM 형식(상태 레지스터 / 다음 상태 / 출력)으로 새로 작성

// 스톱워치 FSM : STOP / RUN / ANIM(circle 애니메이션)
//   STOP --btnC--> RUN --btnC--> STOP
//   STOP --5초 동안 버튼 없음--> ANIM
//   ANIM --btnC--> RUN,  ANIM --다른 버튼--> STOP (애니메이션 중지 + 해당 기능 수행)
module stopwatch_fsm #(parameter IDLE_TIME = 500) (   // 10ms x 500 = 5초
    input clk,
    input reset,
    input tick_10ms,
    input mode,              // 1: 스톱워치 모드
    input btn_L,
    input btn_C,
    input btn_R,
    output run,
    output clear,
    output anim,
    output reg [3:0] anim_step  // 애니메이션 위치 0~11
    );

    localparam [1:0] STOP = 2'd0,
                     RUN  = 2'd1,
                     ANIM = 2'd2;

    reg [1:0] curr_state, next_state;
    reg [9:0] r_idle_cnt;
    reg [3:0] r_anim_cnt;

    wire w_btn_any = btn_L | btn_C | btn_R;

    // ---- 상태 레지스터
    always @(posedge clk, posedge reset) begin
        if (reset) curr_state <= STOP;
        else       curr_state <= next_state;
    end

    // ---- 다음 상태 결정
    always @(*) begin
        case (curr_state)
        STOP: begin
            if (mode && btn_C)                  next_state = RUN;
            else if (r_idle_cnt == IDLE_TIME-1) next_state = ANIM;
            else                                next_state = STOP;
        end
        RUN: begin
            if (mode && btn_C) next_state = STOP;
            else               next_state = RUN;
        end
        ANIM: begin
            if (mode && btn_C)       next_state = RUN;
            else if (w_btn_any || !mode) next_state = STOP;
            else                     next_state = ANIM;
        end
        default: next_state = STOP;
        endcase
    end

    // ---- 출력
    assign run   = (curr_state == RUN);
    assign anim  = (curr_state == ANIM);
    assign clear = mode && btn_R && (curr_state != RUN);   // 멈춰 있을 때만 clear

    // ---- 무입력 시간 카운트 (스톱워치 모드 + STOP 상태에서만)
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_idle_cnt <= 0;
        end else if (curr_state != STOP || !mode || w_btn_any) begin
            r_idle_cnt <= 0;
        end else if (tick_10ms) begin
            r_idle_cnt <= r_idle_cnt + 1;
        end
    end

    // ---- 애니메이션 위치 : 100ms(10ms x 10)마다 한 칸 이동
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_anim_cnt <= 0;
            anim_step  <= 0;
        end else if (curr_state != ANIM) begin
            r_anim_cnt <= 0;
            anim_step  <= 0;
        end else if (tick_10ms) begin
            if (r_anim_cnt == 9) begin
                r_anim_cnt <= 0;
                anim_step  <= (anim_step == 11) ? 0 : anim_step + 1;
            end else begin
                r_anim_cnt <= r_anim_cnt + 1;
            end
        end
    end

endmodule
