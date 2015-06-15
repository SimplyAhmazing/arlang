{
    function convertToEnglishNum(str) { // I know this is misnomer...
        return Number( str.replace(/[٠١٢٣٤٥٦٧٨٩]/g, function(d) {
            return d.charCodeAt(0) - 1632;
        }).replace(/[۰۱۲۳۴۵۶۷۸۹]/g, function(d) {
            return d.charCodeAt(0) - 1776;
        }) );
    }

    function node(type, value) {
        return { type: type, val: value};
    }
}


start
  = exprs:Expressions* { return node("Program", exprs) }

Atom "Atom"
  = Number
  / String
  /*/ Boolean*/
  / Identifier


Alphabet
  = [\u0600-\u065F\u066A-\u06FF]


Argument "Argument"
  //= InvocationExpression
  = Atom
  / "(" Whitespace* !AssignmentExpression expr:Expression Whitespace* ")" { return expr }

Arguments "Arguments"
  = Whitespace+ invoExpr:InvocationExpression { return invoExpr }
  / Whitespace+ atom:Atom { return atom }


AssignmentExpression "AssignmentExpression"
  = id:Identifier Whitespace* "=" Whitespace* rhs:RHS { return node("AssignmentExpression", [id, rhs]) }


ArithmeticOperator "ArithmeticOperator"
  = [\/÷] { return node("DivisionOperator", "/") }
  / [*×] { return node("MultiplicationOperator", "*") }
  / "+" { return node("AdditionOperator", "+") }
  / "-" { return node("SubtractionOperator", "-") }


BinaryOperator "BinaryOperator"
  = ArithmeticOperator
  // LogicalOperator


Block "Block"
  = "{" WhitespaceOrNewLine* exprs:Expressions* WhitespaceOrNewLine* "}" { return node("Block", exprs) }

Boolean "Boolean"
  = "true" { return node("Boolean", true) }
  / "false" { return node("Boolean", false) }


Char "Char"
  = (Digits / Alphabet / Symbol / Whitespace / NewLine)


Digit "Digit"
 = [\u0660-\u0669]

Digits "Digits"
 = digits:Digit+ { return convertToEnglishNum(digits.join("")) };


Expression "Expression"
  = AssignmentExpression
  / opExpr:OperatorExpression { return opExpr }
  / InvocationExpression
  / "(" Whitespace* expr:Expression Whitespace* ")" { return expr }
  / Atom


ExpressionTerminator
  = [;\n]


Expressions "Expressions"
  = Whitespace* expr:Expression? Whitespace* ExpressionTerminator Whitespace* { return expr }


Identifier "Identifier"
  = first:("_" / Alphabet) rest:("_" / Alphabet / Digit)* { return node("Identifier", first + rest.join("")) }


Integer "Integer"
  = digits:(("+"/"-")?Digits) { return parseInt(digits.join(""), 10) }


Float "Float"
  = float:(("+"/"-")?Digits "," Digits) { return parseFloat(float.join("")) }


NewLine
  = [\n]


Number "Number"
  = float:Float { return node("Number", float) }
  / int:Integer { return node("Integer", int) }

/*operatorAssignment "operatorAssignment"*/
/*  = Whitespace* id:Identifier */


Symbol "Symbol"
  = [!@#$%\^&*()\-_=\+\[\]\{\}\|;:'.,<>/?\\`~]


String "String"
  = "\"" chars:Char* "\"" { return node("String", chars.join("")) }


Identifiers "Identifiers"
  = Whitespace+ id:Identifier { return id }


InvocationExpression "InvocationExpression"
  = ftn:Identifier args:Arguments* { return node('InvocationExpression', [ftn].concat(args)) }


OperatorExpression "OperatorExpression"
  = arg1:Argument Whitespace* restOpExpr:RestOfBinaryOperatorExpression+ {
        return node("OperatorExpression", [arg1].concat(restOpExpr[0]))
    }
  / unaryLogicalOp:UnaryLogicalOp expr:Argument Whitespace* rest:RestOfBinaryOperatorExpression* {
        return node("UnaryLogicalOperation", [unaryLogicalOp, expr].concat(rest))
    }


RestOfBinaryOperatorExpression "RestOfBinaryOperatorExpression"
  = binaryOp:BinaryOperator Whitespace* arg2:Expression {
    if (Array.isArray(arg2.val) && (arg2.type !== "InvocationExpression")) {
        return [binaryOp].concat(arg2.val);
    }
    return [binaryOp, arg2];
  }


RHS "RHS"
  = block:Block { return block }
  / opExpr:OperatorExpression { return opExpr }
  / invExpr:InvocationExpression { return invExpr }
  / atom:Atom { return atom }


UnaryLogicalOp "UnaryLogicalOp"
  = "!"


Whitespace "Whitespace"
  = [ \t]


WhitespaceOrNewLine "WhitespaceOrNewLine"
  = Whitespace
  / NewLine
