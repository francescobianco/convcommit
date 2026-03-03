
# Respects https://no-color.org and --no-color flag.
# Call convcommit_color_init once at startup (after arg parsing).
# Then use cc_* functions to get ANSI sequences; they return empty
# strings when color is disabled, so callers need no conditionals.

convcommit_color_init() {
  if [ -n "${NO_COLOR:-}" ] || [ "${TERM:-}" = "dumb" ] || [ "${CONVCOMMIT_NO_COLOR:-0}" = "1" ]; then
    CONVCOMMIT_COLOR=0
  else
    CONVCOMMIT_COLOR=1
  fi
}

_cc() { [ "${CONVCOMMIT_COLOR:-1}" = "1" ] && printf '%b' "$1"; }

cc_reset()  { _cc '\033[0m'; }
cc_bold()   { _cc '\033[1m'; }
cc_dim()    { _cc '\033[2m'; }
cc_green()  { _cc '\033[38;2;166;227;161m'; }   # #a6e3a1
cc_blue()   { _cc '\033[38;2;137;180;250m'; }   # #89b4fa
cc_yellow() { _cc '\033[38;2;249;226;175m'; }   # #f9e2af
cc_mauve()  { _cc '\033[38;2;203;166;247m'; }   # #cba6f7
cc_red()    { _cc '\033[38;2;243;139;168m'; }   # #f38ba8
cc_teal()   { _cc '\033[38;2;148;226;213m'; }   # #94e2d5
cc_text()   { _cc '\033[38;2;205;214;244m'; }   # #cdd6f4
cc_gray()   { _cc '\033[38;2;88;91;112m'; }     # #585b70
