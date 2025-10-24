require "./ast"

module Seal
    alias Value = Int32 | String

    class Interpreter
        @variables : Hash(String, Value)
        @output : IO

        def initialize(@output : IO = STDOUT)
            @variables = {} of String => Value
        end

        def execute(program : Program)
            program.statements.each do |stmt|
            execute_statement(stmt)
            end
            Fiber.yield
            sleep 0.1
        end

        def execute_statement(stmt : Stmt)
            case stmt
            when PrintStmt
            value = evaluate_expression(stmt.expression)
            @output.puts value
            when PrintExpression
            value = evaluate_expression(stmt.expression)
            @output.puts value
            when PrintNoNewline
            value = evaluate_expression(stmt.expression)
            @output.print value
            when PrintVariable
            stmt.variables.each do |var_name|
                value = @variables[var_name]? || 0
                @output.puts value
            end
            when Assignment
            value = evaluate_expression(stmt.expression)
            @variables[stmt.variable] = value
            when WhileLoop
            while true
                condition_value = evaluate_expression(stmt.condition)
                break unless condition_value.is_a?(Int32) && condition_value != 0
                stmt.body.each do |body_stmt|
                    execute_statement(body_stmt)
                end
            end
            when CompoundAssignment
            current = @variables[stmt.variable]? || 0
            value = evaluate_expression(stmt.expression)
            
            if current.is_a?(Int32) && value.is_a?(Int32)
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
                raise "Compound assignment requires integer operands"
            end
            when IncrementDecrement
            current = @variables[stmt.variable]? || 0
            if current.is_a?(Int32)
                result = case stmt.operator
                when "++", "¬"
                    current + 1
                when "--"
                    current - 1
                else
                    raise "Unknown increment/decrement operator: #{stmt.operator}"
                end
                @variables[stmt.variable] = result
            else
                raise "Increment/decrement requires integer variable"
            end
            when RepeatLoop
            count = evaluate_expression(stmt.count)
            if count.is_a?(Int32)
                count.times do |i|
                @variables["_"] = i + 1
                stmt.body.each do |body_stmt|
                    execute_statement(body_stmt)
                end
                end
            end
            when ThreadSpawn
            spawn do
                stmt.body.each do |body_stmt|
                execute_statement(body_stmt)
                end
            end
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
            when UnaryOp
            operand = evaluate_expression(expr.operand)
            if operand.is_a?(Int32)
                case expr.operator
                when "!"
                    operand == 0 ? 1 : 0
                else
                    raise "Unknown unary operator: #{expr.operator}"
                end
            else
                raise "Unary operations only supported on integers"
            end
            when BinaryOp
            left = evaluate_expression(expr.left)
            right = evaluate_expression(expr.right)
            
            if left.is_a?(String) || right.is_a?(String)
                case expr.operator
                when "+"
                left.to_s + right.to_s
                when "==", "|"
                left.to_s == right.to_s ? 1 : 0
                when "!="
                left.to_s != right.to_s ? 1 : 0
                else
                raise "Operator #{expr.operator} not supported for strings"
                end
            elsif left.is_a?(Int32) && right.is_a?(Int32)
                case expr.operator
                when "+"
                left + right
                when "-"
                left - right
                when "*"
                left * right
                when "/"
                left // right
                when "~"
                left % right
                when "<"
                left < right ? 1 : 0
                when ">"
                left > right ? 1 : 0
                when "<="
                left <= right ? 1 : 0
                when ">="
                left >= right ? 1 : 0
                when "==", "|"
                left == right ? 1 : 0
                when "!="
                left != right ? 1 : 0
                else
                raise "Unknown binary operator: #{expr.operator}"
                end
            else
                raise "Type mismatch in binary operation"
            end
            when FunctionCall
            call_function(expr.name, expr.arguments)
            when Input
            if expr.prompt
                print expr.prompt
                STDOUT.flush
            end
            input = gets
            if input
                input.strip.to_i? || 0
            else
                0
            end
            when TernaryOp
            condition = evaluate_expression(expr.condition)
            if condition.is_a?(Int32) && condition != 0
                evaluate_expression(expr.true_expr)
            else
                evaluate_expression(expr.false_expr)
            end
            when Sleep
            duration = evaluate_expression(expr.duration)
            if duration.is_a?(Int32)
                sleep duration.seconds
                0
            else
                raise "Sleep duration must be an integer"
            end
            when StringInput
            if expr.prompt
                @output.print expr.prompt
                @output.flush
            end
            input = gets
            input ? input.strip : ""
            else
            raise "Unknown expression type"
            end
        end

        def call_function(name : String, arguments : Array(Expr)) : Int32
            case name
            when "p"
                if arguments.size != 1
                    raise "Function p expects 1 argument, got #{arguments.size}"
                end
                value = evaluate_expression(arguments[0])
                if value.is_a?(Int32)
                    is_prime(value) ? 1 : 0
                else
                    raise "Function p expects integer argument"
                end
            else
                raise "Unknown function: #{name}"
            end
        end

        def is_prime(n : Int32) : Bool
            return false if n < 2
            return true if n == 2
            return false if n % 2 == 0
            
            i = 3
            while i * i <= n
                return false if n % i == 0
                i += 2
            end
            true
        end
    end
end
