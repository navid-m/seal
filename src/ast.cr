module Seal
    abstract class ASTNode
    end

    abstract class Expr < ASTNode
    end

    class StringLiteral < Expr
        property value : String

        def initialize(@value : String)
        end
    end

    class NumberLiteral < Expr
        property value : Int32

        def initialize(@value : Int32)
        end
    end

    class FloatLiteral < Expr
        property value : Float64

        def initialize(@value : Float64)
        end
    end

    class Variable < Expr
        property name : String

        def initialize(@name : String)
        end
    end

    class BinaryOp < Expr
        property left : Expr
        property operator : String
        property right : Expr

        def initialize(@left : Expr, @operator : String, @right : Expr)
        end
    end

    class UnaryOp < Expr
        property operator : String
        property operand : Expr

        def initialize(@operator : String, @operand : Expr)
        end
    end

    class FunctionCall < Expr
        property name : String
        property arguments : Array(Expr)

        def initialize(@name : String, @arguments : Array(Expr))
        end
    end

    class Input < Expr
        property prompt : String?

        def initialize(@prompt : String? = nil)
        end
    end

    class TernaryOp < Expr
        property condition : Expr
        property true_expr : Expr
        property false_expr : Expr

        def initialize(@condition : Expr, @true_expr : Expr, @false_expr : Expr)
        end
    end

    abstract class Stmt < ASTNode
    end

    class PrintStmt < Stmt
        property expression : Expr

        def initialize(@expression : Expr)
        end
    end

    class Assignment < Stmt
        property variable : String
        property expression : Expr

        def initialize(@variable : String, @expression : Expr)
        end
    end

    class CompoundAssignment < Stmt
        property variable : String
        property operator : String
        property expression : Expr

        def initialize(@variable : String, @operator : String, @expression : Expr)
        end
    end

    class IncrementDecrement < Stmt
        property variable : String
        property operator : String

        def initialize(@variable : String, @operator : String)
        end
    end

    class PrintVariable < Stmt
        property variables : Array(String)

        def initialize(@variables : Array(String))
        end
    end

    class PrintExpression < Stmt
        property expression : Expr

        def initialize(@expression : Expr)
        end
    end

    class PrintNoNewline < Stmt
        property expression : Expr

        def initialize(@expression : Expr)
        end
    end

    class WhileLoop < Stmt
        property condition : Expr
        property body : Array(Stmt)

        def initialize(@condition : Expr, @body : Array(Stmt))
        end
    end

    class RepeatLoop < Stmt
        property count : Expr
        property body : Array(Stmt)

        def initialize(@count : Expr, @body : Array(Stmt))
        end
    end

    class ThreadSpawn < Stmt
        property body : Array(Stmt)

        def initialize(@body : Array(Stmt))
        end
    end

    class Sleep < Expr
        property duration : Expr

        def initialize(@duration : Expr)
        end
    end

    class StringInput < Expr
        property prompt : String?

        def initialize(@prompt : String? = nil)
        end
    end

    class FloatInput < Expr
        property prompt : String?

        def initialize(@prompt : String? = nil)
        end
    end

    class SquareRoot < Expr
        property value : Expr

        def initialize(@value : Expr)
        end
    end

    class Program < ASTNode
        property statements : Array(Stmt)

        def initialize(@statements : Array(Stmt))
        end
    end
end
