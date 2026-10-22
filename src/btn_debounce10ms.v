`timescale 1ns / 1ps

// [원본] 09.up_down_counter/btn_debounce10ms.v
// [수정] DEBOUNCE_LIMIT 파라미터를 top에서 받아 하위 debouncer로 전달 (시뮬레이션 단축용)
//        그 외 동작은 원본과 동일, 주석만 정리

// 버튼 3개(L, C, R)를 각각 디바운싱
module btn_debouncer #(parameter DEBOUNCE_LIMIT = 20'd999_999) (   // [수정] 파라미터 추가
    input      clk,
    input      reset,
    input      [2:0] noisy_btn,  // raw noisy button input
    output     [2:0] clean_btn
);

    debouncer #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) u_btnL_debouncer (   // [수정] 파라미터 전달
    .clk(clk),
    .reset(reset),
    .noisy_btn(noisy_btn[0]),
    .clean_btn(clean_btn[0])
    );

    debouncer #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) u_btnC_debouncer (   // [수정] 파라미터 전달
    .clk(clk),
    .reset(reset),
    .noisy_btn(noisy_btn[1]),
    .clean_btn(clean_btn[1])
    );

    debouncer #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) u_btnR_debouncer (   // [수정] 파라미터 전달
    .clk(clk),
    .reset(reset),
    .noisy_btn(noisy_btn[2]),
    .clean_btn(clean_btn[2])
    );

endmodule

// 버튼 채터링 제거 : 입력이 10ms(100MHz x 1,000,000) 동안 같은 값이면 인정
module debouncer #(parameter DEBOUNCE_LIMIT = 20'd999_999) (
    input      clk,
    input      reset,
    input      noisy_btn,  // raw noisy button input
    output reg clean_btn
);
    reg [19:0] r_count;
    reg r_btn_state=0;

    // ---- 2단 D-FF 동기화기 : 비동기 입력 noisy_btn을 클럭 도메인에 동기화 (메타스테빌리티 방지)
    reg r_FF1, r_FF2;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_FF1 <= 0;
            r_FF2 <= 0;
        end else begin
            r_FF1 <= noisy_btn;     // r_FF1: 메타스테빌리티가 생길 수 있는 FF
            r_FF2 <= r_FF1;         // r_FF2: 안정된 신호
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_count <= 0;
            r_btn_state <= 0;
            clean_btn <= 0;
        end else if (r_FF2 == r_btn_state) begin  // 버튼 상태가 이전과 동일 (안정됨)
            r_count <= 0;
        end else begin
            if (r_count < DEBOUNCE_LIMIT)          // 바뀌었지만 아직 안정되지 않음
                r_count <= r_count + 1;
            else begin                             // 충분히 오래 유지됨(10ms)
                r_btn_state <= r_FF2;
                clean_btn <= r_FF2;
                r_count <= 0;
            end
        end
    end
endmodule
