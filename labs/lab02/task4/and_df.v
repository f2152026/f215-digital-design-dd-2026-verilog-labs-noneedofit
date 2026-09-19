// and_df.v
module and_df (
  input  a,
  input  b,
  output y
);

  assign #2 y = a & b;

endmodule