# Source style and the shared formatter

The project uses Retrolarium Kit's ASL house style and code formatters.
config/lint.json owns the source roots and dialect. The public lint and format
commands call scripts/validation/lint_project.py, which invokes Kit.

## Original AS syntax compatibility

The pinned Kit's ASL source discovery recognizes .s and .inc, while this
import uses .asm. Its current label lexer also omits uncolonized labels,
local and anonymous labels, dotted equates, and several AS declaration forms.
Formatting those forms directly can turn a label into an unknown instruction.
A synthetic assembly probe reproduces that failure.

scripts/validation/asm_style.py makes a disposable .s mirror under build/.
It presents each original AS label as a simple named colon label, asks
rltool lint --fix to normalize that mirror, and restores the exact original label
tokens. Instructions, operands, strings and branch references are never
substituted. Kit owns all whitespace and comment formatting. The adapter
checks that no nonblank line was added, removed or reordered by its label
restoration. No Kit or Core file is patched or vendored.

Lint changes no tracked file. Format applies the restored source and the
shared text/code formatters, then runs the same checks again. Tests check
that a synthetic program with equates, local and anonymous labels still
assembles to the same bytes, and that a second pass is idempotent. Every
preservation-source formatting change must also pass both full ROM identity
checks. The compatibility bridge can be removed when the pinned Kit natively
supports these AS forms and extensions.

The formatting-only commit is recorded in .git-blame-ignore-revs once made.
