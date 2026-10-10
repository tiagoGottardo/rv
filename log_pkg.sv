package log_pkg;

  localparam string GREEN = "\033[32m";
  localparam string RED   = "\033[31m";
  localparam string RESET = "\033[0m";

  task automatic pass(input string test_name);
    $display("%s[PASS] %s%s", GREEN, test_name, RESET);
  endtask

  task automatic fail(input string test_name, input string details);
    $display("%s[FAIL] %s | %s%s", RED, test_name, details, RESET);
    $fatal(1, "test failed");
  endtask

endpackage
