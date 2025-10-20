module Pillar
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
        property operand : Variable

        def initialize(@operator : String, @operand : Variable)
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

    class Program < ASTNode
        property statements : Array(Stmt)

        def initialize(@statements : Array(Stmt))
        end
    end
end
