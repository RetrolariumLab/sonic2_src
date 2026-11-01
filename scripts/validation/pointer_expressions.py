"""Resolve numeric AS constants without evaluating assembler code or ROM labels."""

import ast
from dataclasses import dataclass
import operator
import re
from scripts.build.source_asm import statements


@dataclass(frozen=True)
class Resolution:
    values: frozenset = frozenset()
    symbolic: bool = False
    unresolved: bool = False


def qualify(expression, scope):
    expression = re.sub(r"\.[wl]$", "", expression.strip(), flags=re.I)
    return re.sub(r"(?<![\w.])\.[A-Za-z_][\w.]*", lambda match: (scope or "") + match[0], expression)


def constant_definitions(text):
    result = {}
    for number, label, scope, operation, arguments in statements(text):
        if label and not label.startswith("@") and operation in {"equ", "=", ":=", "set"}:
            name = label.casefold()
            value = qualify(arguments, scope)
            result.setdefault(name, [])
            if value not in result[name]:
                result[name].append(value)
    return result


def merge_constants(*collections):
    result = {}
    for collection in collections:
        for name, values in collection.items():
            target = result.setdefault(name.casefold(), [])
            for value in values:
                if value not in target:
                    target.append(value)
    return result


class Resolver:
    def __init__(self, constants):
        self.constants = constants
        self.cache = {}

    def resolve(self, expression, active=frozenset()):
        expression = re.sub(r"\.[wl]$", "", expression.strip(), flags=re.I)
        expression = re.sub(r"\$([0-9a-f]+)", r"0x\1", expression, flags=re.I)
        expression = re.sub(r"(?<![\w)])%([01]+)", r"0b\1", expression)
        try:
            node = ast.parse(expression, mode="eval").body
        except (SyntaxError, ValueError):
            return Resolution(unresolved=True)
        if len(list(ast.walk(node))) > 128 or len(active) > 32:
            return Resolution(unresolved=True)
        return self.node(node, active)

    def node(self, node, active):
        if isinstance(node, ast.Constant) and type(node.value) is int:
            return self.bounded({node.value})
        if isinstance(node, ast.Name) or isinstance(node, ast.Attribute):
            name = ast.unparse(node).casefold()
            if name not in self.constants:
                return Resolution(symbolic=True)
            if name in active:
                return Resolution(unresolved=True)
            if name not in self.cache:
                parts = [self.resolve(value, active | {name}) for value in self.constants[name]]
                self.cache[name] = Resolution(
                    frozenset().union(*(part.values for part in parts)),
                    any(part.symbolic for part in parts),
                    any(part.unresolved for part in parts),
                )
            return self.cache[name]
        if isinstance(node, ast.UnaryOp):
            part = self.node(node.operand, active)
            function = {ast.UAdd: operator.pos, ast.USub: operator.neg, ast.Invert: operator.invert}.get(type(node.op))
            if function:
                return self.bounded({function(value) for value in part.values}, part.symbolic, part.unresolved)
        if isinstance(node, ast.BinOp):
            left, right = self.node(node.left, active), self.node(node.right, active)
            functions = {
                ast.Add: operator.add,
                ast.Sub: operator.sub,
                ast.Mult: operator.mul,
                ast.Div: operator.floordiv,
                ast.FloorDiv: operator.floordiv,
                ast.Mod: operator.mod,
                ast.BitAnd: operator.and_,
                ast.BitOr: operator.or_,
                ast.BitXor: operator.xor,
                ast.LShift: operator.lshift,
                ast.RShift: operator.rshift,
            }
            function = functions.get(type(node.op))
            if function:
                values = set()
                try:
                    for first in left.values:
                        for second in right.values:
                            if isinstance(node.op, (ast.LShift, ast.RShift)) and not 0 <= second <= 63:
                                raise ValueError("Unbounded shift")
                            values.add(function(first, second))
                            if len(values) > 64:
                                raise ValueError("Too many constant alternatives")
                except (ArithmeticError, ValueError):
                    return Resolution(symbolic=left.symbolic or right.symbolic, unresolved=True)
                return self.bounded(values, left.symbolic or right.symbolic, left.unresolved or right.unresolved)
        # Named assembler functions stay compiler expressions; numeric-only
        # unsupported aliases cannot silently become trusted pointer owners.
        symbolic = any(
            self.node(child, active).symbolic
            for child in ast.iter_child_nodes(node)
            if isinstance(child, (ast.Name, ast.Attribute))
        )
        return Resolution(symbolic=symbolic, unresolved=True)

    @staticmethod
    def bounded(values, symbolic=False, unresolved=False):
        if any(value.bit_length() > 64 for value in values):
            return Resolution(symbolic=symbolic, unresolved=True)
        return Resolution(frozenset(values), symbolic, unresolved)
