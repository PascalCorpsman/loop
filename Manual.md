# Manual

This document tries to give a short introduction into the language Loop, for any further introduction read the [wikipedia](https://en.wikipedia.org/wiki/LOOP_(programming_language)) article or the book [Theoretische Informatik - kurz gefasst](https://link.springer.com/book/9783827418241)

Best way to define the language is by giving its pseudo-formal Extended Backus–Naur Form (EBNF):

| Lexical Elements | | |
|--- | --- | --- |
| \<letter>     | ::= | "A" ... "Z" \| "a" ... "z" \| "_"
| \<digit>      | ::= | "0" \| ... \| "9"
| \<integer>    | ::= | \<digit> { \<digit> }
| \<identifier> | ::= | \<letter> { \<letter> \| \<digit> }
| \<variable>   | ::= | "X"\<integer> \| "x"\<integer>
| \<operand>    | ::= | "+" \| "-"

| Comments | | |
|--- | --- | --- |
| \<comment>      | ::= | {\<line_comment> \| \<block_comment>}
| \<line_comment> | ::= | "//" { <any_char_except_newline> } 
| \<block_comment>| ::= | "{" { <any_char_except_}> } "}" <br> "\(\*" { <any_char_except_\*)> \*\)

For better readability the \<comment> sections are not explicit listed in the following structs. A comment can stand on "every position", as they are dropped before compiling.

| Program Structure | | |
|--- | --- | --- |
| \<program>         | ::= | \<procedure>
| \<procedure>       | ::= | "Procedure" \<identifier> ";" <br> { \<var_declaration> } <br> "Begin" <br> \<statement_list> <br> "End;"
| \<var_declaration> | ::= | "Var" \<variable_list> ";"
| \<variable_list>   | ::= | \<variable> { "," \<variable> }

| Statements | | |
|--- | --- | --- |
| \<statement_list> | ::= | { \<statement> }
| \<statement>      | ::= | \<assignment> <br> \| \<loop_statement>
| \<assignment>     | ::= | \<variable> ":=" \<expression> ";"
| \<expression>     | ::= | \<constant> <br> \| \<variable> <br> \| \<variable> \<operand> \<integer>
| \<constant>       | ::= | \<integer> \| "Get"
| \<loop_statement> | ::= | "Loop" \<variable> "Do"<br> \<statement_list> <br>"End;"

Given the above definition you can write a simple Loop program like this:

```pascal
(******************************************************************************)
(* This is a sample program for the Loop interpreter                          *)
(******************************************************************************)

Procedure Adder;
{
 X0 is not needed to be declared as it is the "result" of the program, and 
 therefore always available.    
}
Var X1, X2; // uses 2 separate variables
Begin
  x1 := Get; // Read the variables from the user interface
  x2 := Get;
  x0 := x1; // init X0 with X1, so we need to do the loop thing only for X2 ;)
  Loop x2 Do
    x0 := x0 + 1;
  End;
End;
```

The Loop interpreter can be tweaked optionally in the "Extended Options" settings. This does not enhance the Loop language as all enhancements can be reduced to "pure" Loop, but speeds up the execution time. For example the above given code can be reduced to:

```pascal
Procedure Adder;
Var X1, X2; // uses 2 separate variables
Begin
  x1 := Get; // Read the variables from the user interface
  x2 := Get;
  x0 := x1 + x2;
End;
```
With "fully" set enhancements the following rules change to, will be extended with:

| Lexical Elements | | |
|--- | --- | --- |
| \<operand>    | ::= | "+" \| "-" \| "^-" \| "*" \| "Mod" \| "Div"
| \<variable>   | ::= | \<identifier>

| Program Structure | | |
|--- | --- | --- |
| \<procedure>          | ::= | "Procedure" \<identifier> ";" <br> { \<var_declaration> \| \<function> } <br> "Begin" <br> \<statement_list> <br> "End;"
| \<function>           | ::= | "Function" \<identifier> "("{\<parameter_list>} ");" <br> "Begin" <br> \<fun_statement_list> <br> "End;"
| \<fun_statement_list> | ::= | { \<statement> \| \<fun_assignment>}
| \<fun_assignment>     | ::= | "result :=" \<fun_expression> ";"
| \<fun_expression>     | ::= | \<constant> <br> \| \<variable> <br> \| \<variable> \<operand> \<integer>
| \<assignment>         | ::= | \<variable> ":=" \<expression> ";" <br> \| \<variable> ":=" \<fun_call> ";"
| \<fun_call>           | ::= | \<identifier>"("\<parameter_list>");"
| \<expression>         | ::= | \<constant> <br> \| \<variable> <br> \| \<arith_expression>
| \<parameter_list>     | ::= | ε \|  \<variable> {"," \<variable>}
| \<statement>          | ::= | \<assignment> <br> \| \<loop_statement> <br> \| \<if_statement>
| \<if_statement>       | ::= | "if" \<expression> "Then" <br> \<statement_list> <br> [ "Else" \<statement_list> ] <br> "End;" |
| \<arith_expression>   | ::= | \<arith_expression> \<operand> \<arith_expression> <br> \| "(" \<arith_expression> ")"

Here is a further example what is possible with this excentions:

```Pascal
(*
 * This application Does not calculate any usefull thing, it just
 * demonstrates, what the Loop interpreter is capable of Doing;)
 *)
Procedure Sample;
  
Var x1, x2, x4, Var5;
  
  Function Modulo(v1, v2);
  Var z;
  Begin
    z := 0;
    result := v1 Mod v2 + z;
  End;
  
Begin
  x1 := Get;
  x2 := ( x1 - 3 ) * 1;
  x4 := x1 ^- x2;
  Var5 := Modulo(x4, x2);
  Var5 := Var5 + 5;
  If Var5 = 0 Then
    x4 := 1;
  Else
    x4 := x4 Div x1;
  End;
  x0 := 0;
  Loop x4 Do
    x0 := x0 + 1;
  End;
End;

```
