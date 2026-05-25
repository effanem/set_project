
// gf128_naive.v
// Naive 128x128 polynomial multiplier over GF(2)
// Produces full 256-bit polynomial product (NO reduction)

module gf128_naive (
    input  wire [127:0] a,
    input  wire [127:0] b,
    output reg  [255:0] product
);

    integer i;
    reg [255:0] shifted_a;

    always @(*) begin
        product = 256'b0;
        for (i = 0; i < 128; i = i + 1) begin
            if (b[i]) begin
                shifted_a = ({128'b0, a} << i);
                product = product ^ shifted_a;
            end
        end
    end

endmodule
