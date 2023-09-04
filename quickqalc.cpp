#include <cstdlib>
#include <cstring>
#include <iostream>
#include <libqalculate/Calculator.h>
#include <libqalculate/includes.h>

extern "C" {
// Re-export free because  strings need to be in the heap to be returned to lua,
// so they must be freed from there.
void freeStr(const char *ptr) { std::free((void *)ptr); }
void init();
const char *calculate(const char *expr, int timeout);
// TODO: setPrintOptions
// TODO: setEvaluationOptions
}

using std::string;

/***********\
   Globals
\***********/

// Determines how the given string is evaluated. Configure via
// setEvaluationOptions
EvaluationOptions evalOpts;

// Used to return strings to lua. Configured via setPrintOptions
PrintOptions printOpts;

/* Creates the calculator object and loads config.
 * Make sure this method is called before anything else!
 */
void init() {
  // TODO: Take in arguments for config. Take from M.setup
  //       Look at lua.h for interop.
  new Calculator();

  // CALCULATOR->loadExchangeRates();

  CALCULATOR->loadGlobalDefinitions();
  CALCULATOR->loadLocalDefinitions();
}

/* Calculates the given expression and returns the result.
 * Will unlocalize expressions.
 */
const char *calculate(const char *expr, int timeout) {
  MathStructure result;
  /// docs: https://qalculate.github.io/reference/classCalculator.html#aad255f32d52139e947800037115a30a6
  CALCULATOR->calculate(&result, CALCULATOR->unlocalizeExpression(expr),
                        timeout, evalOpts);

  string out = CALCULATOR->print(result, timeout, printOpts);

  // The string should be free()d in lua using ffi.
  return strdup(out.c_str());
}
