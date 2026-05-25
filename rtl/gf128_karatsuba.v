 
// gf128_karatsuba.v
// Karatsuba-based 128x128 polynomial multiplier over GF(2)
// Produces full 256-bit polynomial product (NO modulo reduction)

module gf128_karatsuba (
    input  wire [127:0] a,
    input  wire [127:0] b,
    output wire [255:0] product
);

    // Split inputs into high and low 64-bit halves
    wire [63:0] a_lo = a[63:0];
    wire [63:0] a_hi = a[127:64];
    wire [63:0] b_lo = b[63:0];
    wire [63:0] b_hi = b[127:64];

    // Intermediate Karatsuba products
    wire [127:0] p0;  // a_lo * b_lo
    wire [127:0] p2;  // a_hi * b_hi
    wire [127:0] p1;  // (a_lo ^ a_hi) * (b_lo ^ b_hi)

    // Instantiate 64-bit GF multipliers
    gf64_mul u_p0 (
        .a(a_lo),
        .b(b_lo),
        .product(p0)
    );

    gf64_mul u_p2 (
        .a(a_hi),
        .b(b_hi),
        .product(p2)
    );

    gf64_mul u_p1 (
        .a(a_lo ^ a_hi),
        .b(b_lo ^ b_hi),
        .product(p1)
    );

    // Karatsuba recombination
    // middle = p1 ^ p0 ^ p2
    wire [127:0] middle = p1 ^ p0 ^ p2;

    // Final 256-bit product
    assign product =
          ({128'b0, p0})              // p0
        ^ ({64'b0, middle, 64'b0})    // middle << 64
        ^ ({p2, 128'b0});             // p2 << 128

endmodule
