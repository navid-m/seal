require "./ast"

module Seal
    alias Value = Int32 | Float64 | String | Array(Value)

    class Interpreter
        @variables : Hash(String, Value)
        @output : IO
        @threads : Array(Fiber)

        def initialize(@output : IO = STDOUT)
            @variables = {} of String => Value
            @threads = [] of Fiber
        end

        def execute(program : Program)
            program.statements.each do |stmt|
            execute_statement(stmt)
            end
            until @threads.all? { |f| f.dead? }
                Fiber.yield
                sleep Time::Span.new(nanoseconds:10_000_000)
            end
        end

        def execute_statement(stmt : Stmt)
            case stmt
            when PrintStmt
            value = evaluate_expression(stmt.expression)
            if value.is_a?(Array)
                value.each { |v| @output.puts v }
            else
                @output.puts value
            end
            when PrintExpression
            value = evaluate_expression(stmt.expression)
            if value.is_a?(Array)
                value.each { |v| @output.puts v }
            else
                @output.puts value
            end
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
            
            if (current.is_a?(Int32) || current.is_a?(Float64)) && (value.is_a?(Int32) || value.is_a?(Float64))
                c = current.is_a?(Float64) ? current : current.to_f
                v = value.is_a?(Float64) ? value : value.to_f
                result = case stmt.operator
                when "+="
                c + v
                when "-="
                c - v
                when "*="
                c * v
                when "/="
                c / v
                else
                raise "Unknown compound assignment operator: #{stmt.operator}"
                end
                @variables[stmt.variable] = result
            else
                raise "Compound assignment requires numeric operands"
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
            count_val = evaluate_expression(stmt.count)
            count = if count_val.is_a?(Int32)
                count_val
            elsif count_val.is_a?(Float64)
                count_val.to_i
            else
                raise "Repeat count must be a number"
            end
            count.times do |i|
                @variables["_"] = i + 1
                stmt.body.each do |body_stmt|
                    execute_statement(body_stmt)
                end
            end
            when ThreadSpawn
            thread_vars = @variables.dup
            fiber = spawn do
                saved_vars = @variables
                @variables = thread_vars
                stmt.body.each do |body_stmt|
                execute_statement(body_stmt)
                end
                @variables = saved_vars
            end
            @threads << fiber
            when ArrayAppend
            value = evaluate_expression(stmt.value)
            if !@variables.has_key?(stmt.array_name)
                @variables[stmt.array_name] = [value] of Value
            else
                existing = @variables[stmt.array_name]
                if existing.is_a?(Array)
                    new_array = [] of Value
                    existing.each { |v| new_array << v }
                    new_array << value
                    @variables[stmt.array_name] = new_array
                else
                    raise "Cannot append to non-array variable: #{stmt.array_name}"
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
            when FloatLiteral
            expr.value
            when Variable
            @variables[expr.name]? || 0
            when ArrayLiteral
            elements = [] of Value
            expr.elements.each do |elem|
                elements << evaluate_expression(elem)
            end
            elements
            when ArrayIndex
            array_val = evaluate_expression(expr.array)
            index_val = evaluate_expression(expr.index)
            if array_val.is_a?(Array) && index_val.is_a?(Int32)
                array_val[index_val]? || 0
            else
                raise "Invalid array indexing"
            end
            when UnaryOp
            operand = evaluate_expression(expr.operand)
            if operand.is_a?(Int32) || operand.is_a?(Float64)
                case expr.operator
                when "!"
                    (operand == 0 || operand == 0.0) ? 1 : 0
                else
                    raise "Unknown unary operator: #{expr.operator}"
                end
            else
                raise "Unary operations only supported on numbers"
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
            elsif (left.is_a?(Int32) || left.is_a?(Float64)) && (right.is_a?(Int32) || right.is_a?(Float64))
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
                    l = left.is_a?(Float64) ? left : left.to_f
                    r = right.is_a?(Float64) ? right : right.to_f
                    
                    case expr.operator
                    when "+"
                    l + r
                    when "-"
                    l - r
                    when "*"
                    l * r
                    when "/"
                    l / r
                    when "~"
                    l % r
                    when "<"
                    l < r ? 1 : 0
                    when ">"
                    l > r ? 1 : 0
                    when "<="
                    l <= r ? 1 : 0
                    when ">="
                    l >= r ? 1 : 0
                    when "==", "|"
                    l == r ? 1 : 0
                    when "!="
                    l != r ? 1 : 0
                    else
                    raise "Unknown binary operator: #{expr.operator}"
                    end
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
            when FloatInput
            if expr.prompt
                @output.print expr.prompt
                @output.flush
            end
            input = gets
            if input
                input.strip.to_f? || 0.0
            else
                0.0
            end
            when SquareRoot
            value = evaluate_expression(expr.value)
            if value.is_a?(Int32)
                Math.sqrt(value.to_f)
            elsif value.is_a?(Float64)
                Math.sqrt(value)
            else
                raise "Square root requires numeric value"
            end
            when ArrayCollectInput
            count_val = evaluate_expression(expr.count)
            count = if count_val.is_a?(Int32)
                count_val
            elsif count_val.is_a?(Float64)
                count_val.to_i
            else
                raise "Array collection count must be a number"
            end
            
            array = [] of Value
            count.times do
                if expr.is_float
                    input = gets
                    value = input ? (input.strip.to_f? || 0.0) : 0.0
                    array << value
                else
                    input = gets
                    value = input ? (input.strip.to_i? || 0) : 0
                    array << value
                end
            end
            array
            else
            raise "Unknown expression type"
            end
        end

        def call_function(name : String, arguments : Array(Expr)) : Value
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
            when "sd", "d"
                if arguments.size == 1
                    value = evaluate_expression(arguments[0])
                    if value.is_a?(Array)
                        calculate_std_dev(value)
                    else
                        raise "Function #{name} expects array argument"
                    end
                elsif arguments.size == 2 && name == "d"
                    a = evaluate_expression(arguments[0])
                    b = evaluate_expression(arguments[1])
                    if a.is_a?(Int32) && b.is_a?(Int32)
                        [a // b, a % b] of Value
                    else
                        raise "Function d expects integer arguments"
                    end
                else
                    raise "Function #{name} expects 1 argument for stddev or 2 for divmod"
                end
            else
                raise "Unknown function: #{name}"
            end
        end
        
        def calculate_std_dev(arr : Array(Value)) : Float64
            return 0.0 if arr.empty?
            
            nums = arr.map do |v|
                case v
                when Int32
                    v.to_f
                when Float64
                    v
                else
                    raise "Array must contain only numbers"
                end
            end
            
            mean = nums.sum / nums.size
            variance = nums.map { |n| (n - mean) ** 2 }.sum / nums.size
            Math.sqrt(variance)
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
