// tb.v
// Self-checking testbench for alu.
// Tests add and sub with fixed operands (toggling op), and sub with
// several different operand pairs, checking every result against an
// independently computed expected value.

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] expected;
  integer errors;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  task check;
    begin
      #5;
      if (t_op == 0)
        expected = t_a + t_b;
      else
        expected = t_a - t_b;

      if (t_result !== expected) begin
        $display("FAIL at time %0t: a=%d b=%d op=%b -> got result=%d expected=%d",
                  $time, t_a, t_b, t_op, t_result, expected);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;

    // same operand pair, toggle op -- catches sensitivity-list bug
    t_a = 5; t_b = 3; t_op = 0; check;
    t_op = 1; check;

    // operands change too
    t_a = 7; t_b = 2; t_op = 0; check;
    t_op = 1; check;

    // several more subtraction pairs -- catches blocking/non-blocking bug
    t_a = 9;  t_b = 9;  t_op = 1; check;
    t_a = 10; t_b = 4;  t_op = 1; check;
    t_a = 15; t_b = 1;  t_op = 1; check;
    t_a = 1;  t_b = 1;  t_op = 1; check;

    // a few more additions for good measure
    t_a = 3;  t_b = 4;  t_op = 0; check;
    t_a = 12; t_b = 3;  t_op = 0; check;

    if (errors == 0)
      $display("All checks passed.");
    else
      $display("%0d error(s) found.", errors);

    $finish;
  end

  initial
    $monitor($time, " a=%d b=%d op=%b | result=%d", t_a, t_b, t_op, t_result);

endmodule