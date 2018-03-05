// The root of any program
start : circuit subroutine* _NEWLINE* // Allow trailing newlines

circuit : "Inputs:" arity (gate _NEWLINE)* "Outputs:" arity

subroutine: _NEWLINE "Subroutine:" string _NEWLINE "Shape:" string _NEWLINE "Controllable:" SUB_CONTROL _NEWLINE circuit
SUB_CONTROL : "yes"
    | "no"
    | "classically"

// Wires and their types
// Note: Trailing comma is allowed to parse all example inputs (it is erroneous)
// See also: https://github.com/njross/optimizer/issues/1
arity : type_assignment ("," type_assignment)* ","? _NEWLINE
type_assignment : wire ":" TYPE
TYPE: "Qbit"
    | "Cbit"

// Gate control
control_app : controlled? NO_CONTROL?
?controlled : "with controls=[" wire_list "]"
NO_CONTROL : "with nocontrol"

// All gates
?gate : qgate
    | qrot
    | gphase
    | cnot
    | cgate
    | cswap
    | qprep
    | qunprep
    | qinit
    | cinit
    | qterm
    | cterm
    | qmeas
    | qdiscard
    | cdiscard
    | dterm
    | subroutine_call
    | comment

// Gate definitions
!inversion  : "*"? // Make sure the token does not get lost.
qgate       : "QGate[" string "]" inversion "(" wire ")" control_app
qrot        : "QRot[" string "," float "]" "(" wire ")"
gphase      : "Gphase() with t=" float control_app "with anchors=[" wire_list "]"
cnot        : "CNot(" wire ")" control_app
cgate       : "CGate[" string "]" inversion "(" wire_list ")" NO_CONTROL?
cswap       : "CSwap(" wire "," wire ")" control_app
qprep       : "QPrep(" wire ")" NO_CONTROL?
qunprep     : "QUnprep(" wire ")" NO_CONTROL?
qinit       : QINIT_STATE "(" wire ")" NO_CONTROL?
// for the lexer we cannot factor out a "0" or "1" string due to ambiguities with int
QINIT_STATE : "QInit0" | "QInit1"
cinit       :  CINIT_STATE "(" wire ")" NO_CONTROL?
CINIT_STATE : "CInit0" | "CInit1"
qterm       : QTERM_STATE "(" wire ")" NO_CONTROL?
QTERM_STATE : "QTerm0" | "QTerm1"
cterm       : CTERM_STATE "(" wire ")" NO_CONTROL?
CTERM_STATE : "CTerm0" | "CTerm1"
qmeas       : "QMeas(" wire ")"
qdiscard    : "QDiscard(" wire ")"
cdiscard    : "CDiscard(" wire ")"
dterm       : DTERM_STATE "(" wire ")"
DTERM_STATE : "DTerm0" | "DTerm1"
subroutine_call : "Subroutine" ["(x" int ")"] "[" string ", shape" string "]" inversion "(" wire_list ") -> (" wire_list ")" control_app
// Note: ] and ( have to be separate tokens for the lexer.
comment : "Comment[" string "]" "(" wire_string_list ")"
wire_string_list: wire ":" string ("," wire ":" string)*

// Wires are represented as integers.
wire : int
wire_list : wire ("," wire)*

// Newlines are significant
%import common.WS_INLINE -> WS
%ignore WS
%import common.CR
%import common.LF
_NEWLINE: (CR? LF)  // Only match a single newline
%import common.ESCAPED_STRING
string: ESCAPED_STRING
%import common.SIGNED_FLOAT
float : SIGNED_FLOAT
%import common.SIGNED_INT
int : SIGNED_INT
