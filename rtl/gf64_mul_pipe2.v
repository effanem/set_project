module gf64_mul_pipe2 (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_in,
    input  wire [63:0] a,
    input  wire [63:0] b,
    output reg         valid_out,
    output reg  [127:0] product
);

    integer i;

    // Stage 1 registers
    reg [127:0] stage1_sum;
    reg [63:0]  a_reg;
    reg [63:0]  b_reg;
    reg         valid_s1;

    // Temporary combinational accumulators
    reg [127:0] stage1_next;
    reg [127:0] stage2_next;

    // -------------------------
    // Stage 1: first 32 terms
    // -------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stage1_sum <= 0;
            a_reg      <= 0;
            b_reg      <= 0;
            valid_s1   <= 0;
        end else begin

            valid_s1 <= valid_in;
            a_reg    <= a;
            b_reg    <= b;

            stage1_next = 0;   // blocking

            if (valid_in) begin
                for (i = 0; i < 32; i = i + 1) begin
                    if (b[i])
                        stage1_next = stage1_next ^ ({64'b0, a} << i);
                end
            end

            stage1_sum <= stage1_next;  // register once
        end
    end


    // -------------------------
    // Stage 2: remaining 32 terms
    // -------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product   <= 0;
            valid_out <= 0;
        end else begin

            valid_out <= valid_s1;

            stage2_next = stage1_sum;   // start from stage1 result

            if (valid_s1) begin
                for (i = 32; i < 64; i = i + 1) begin
                    if (b_reg[i])
                        stage2_next = stage2_next ^ ({64'b0, a_reg} << i);
                end
            end

            product <= stage2_next;
        end
    end

endmodule
