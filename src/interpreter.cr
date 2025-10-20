require "./ast"

module Pillar
    alias Value = Int32 | String

    class Interpreter
        @variables : Hash(String, Int32)

        def initialize
            @variables = {} of String => Int32
        end

        def execute(program : Program)
            program.statements.each do |stmt|
            execute_statement(stmt)
            end
        end

        def execute_statement(stmt : Stmt)
            case stmt
            when PrintStmt
            value = evaluate_expression(stmt.expression)
            puts value
            when PrintVariable
            stmt.variables.each do |var_name|
                value = @variables[var_name]? || 0
                puts value
            end
            when Assignment
            value = evaluate_expression(stmt.expression)
            if value.is_a?(Int32)
                @variables[stmt.variable] = value
            else
                raise "Cannot assign non-integer value to variable"
            end
            when CompoundAssignment
            current = @variables[stmt.variable]? || 0
            value = evaluate_expression(stmt.expression)
            
            if value.is_a?(Int32)
                result = case stmt.operator
                when "+="
                current + value
                when "-="
                current - value
                when "*="
                current * value
                when "/="
                current // value
                else
                raise "Unknown compound assignment operator: #{stmt.operator}"
                end
                @variables[stmt.variable] = result
            else
                raise "Cannot perform compound assignment with non-integer value"
            end
            when IncrementDecrement
            current = @variables[stmt.variable]? || 0
            result = case stmt.operator
            when "++"
                current + 1
            when "--"
                current - 1
            else
                raise "Unknown increment/decrement operator: #{stmt.operator}"
            end
            @variables[stmt.variable] = result
            end
        end

        def evaluate_expression(expr : Expr) : Value
            case expr
            when StringLiteral
            expr.value
            when NumberLiteral
            expr.value
            when Variable
            @variables[expr.name]? || 0
            when BinaryOp
            left = evaluate_expression(expr.left)
            right = evaluate_expression(expr.right)
            
            if left.is_a?(Int32) && right.is_a?(Int32)
                case expr.operator
                when "+"
                left + right
                when "-"
                left - right
                when "*"
                left * right
                when "/"
                left // right
                else
                raise "Unknown binary operator: #{expr.operator}"
                end
            else
                raise "Binary operations only supported on integers"
            end
            else
            raise "Unknown expression type"
            end
        end
    end
end
