// gf128_karatsuba_pipe_gf64.v
// 3-stage pipelined Karatsuba multiplier
// gf64 internally pipelined (2 stages)
// + 1 recombination stage
// Total latency = 3 cycles

module gf128_karatsuba_pipe_gf64 (
    input  wire         clk,
    input  wire         rst,
    input  wire         valid_in,
    input  wire [127:0] a,
    input  wire [127:0] b,
    output reg          valid_out,
    output reg  [255:0] result
);

    // ----------------------------------------------------
    // Split inputs
    // ----------------------------------------------------
    wire [63:0] a_lo = a[63:0];
    wire [63:0] a_hi = a[127:64];
    wire [63:0] b_lo = b[63:0];
    wire [63:0] b_hi = b[127:64];

    wire [63:0] a_mix = a_lo ^ a_hi;
    wire [63:0] b_mix = b_lo ^ b_hi;

    // ----------------------------------------------------
    // Outputs of pipelined gf64 multipliers
    // ----------------------------------------------------
    wire [127:0] p0;
    wire [127:0] p1;
    wire [127:0] p2;

    wire v0, v1, v2;

    // Three parallel pipelined multipliers (2-cycle each)
    gf64_mul_pipe2 mul_p0 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .a(a_lo),
        .b(b_lo),
        .valid_out(v0),
        .product(p0)
    );

    gf64_mul_pipe2 mul_p1 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .a(a_mix),
        .b(b_mix),
        .valid_out(v1),
        .product(p1)
    );

    gf64_mul_pipe2 mul_p2 (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .a(a_hi),
        .b(b_hi),
        .valid_out(v2),
        .product(p2)
    );

    // ----------------------------------------------------
    // Stage 3: Karatsuba recombination
    // ----------------------------------------------------
    // gf64 latency = 2 cycles
    // Recombination happens when v0=1
    // Total latency = 3 cycles
    // ----------------------------------------------------

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result    <= 0;
            valid_out <= 0;
        end else begin

            // Direct alignment (no extra delay)
            valid_out <= v0;

            if (v0) begin
                result <=
                      ({128'b0, p0})
                    ^ ({64'b0, (p1 ^ p0 ^ p2), 64'b0})
                    ^ ({p2, 128'b0});
            end

        end
    end

endmodule
