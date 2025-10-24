require "./ast"
require "./lexer"

module Seal
    class Parser
        @tokens : Array(Token)
        @pos : Int32
        
        def initialize(@tokens : Array(Token))
            @pos = 0
        end
        
        def current_token : Token
            @tokens[@pos]
        end
        
        def peek_token(offset = 1) : Token
            pos = @pos + offset
            if pos < @tokens.size
                @tokens[pos]
            else
                @tokens[-1]
            end
        end
        
        def advance
            @pos += 1 if @pos < @tokens.size - 1
        end
        
        def expect(type : TokenType) : Token
            token = current_token
            if token.type != type
                raise "Expected #{type}, got #{token.type} at line #{token.line}"
            end
            advance
            token
        end
    
        def skip_newlines
            while current_token.type == TokenType::NEWLINE
                advance
            end
        end
    
        def parse : Program
            statements = [] of Stmt
            skip_newlines
            while current_token.type != TokenType::EOF
                stmt = parse_statement
                statements << stmt if stmt
                skip_newlines
            end
            Program.new(statements)
        end
    
        def parse_statement : Stmt?
            skip_newlines
            case current_token.type
            when TokenType::AT
                return parse_while_loop
            when TokenType::R
                return parse_repeat_loop
            when TokenType::T
                return parse_thread_spawn
            when TokenType::COLON
                advance
                expr = parse_expression
                stmt = PrintNoNewline.new(expr)
                consume_statement_end
                return stmt
            when TokenType::STRING
                expr = parse_expression
                stmt = PrintStmt.new(expr)
                consume_statement_end
                return stmt
            when TokenType::PERCENT
                advance
                variables = [] of String
                variables << expect(TokenType::IDENTIFIER).value
                while current_token.type == TokenType::COMMA
                    advance
                    variables << expect(TokenType::IDENTIFIER).value
                end
                stmt = PrintVariable.new(variables)
                consume_statement_end
                return stmt
            when TokenType::POUND
                advance
                expr = parse_expression
                stmt = PrintExpression.new(expr)
                consume_statement_end
                return stmt
            when TokenType::IDENTIFIER
                name = current_token.value
                advance
                case current_token.type
                when TokenType::LEFT_SHIFT
                    advance
                    expr = parse_expression
                    stmt = ArrayAppend.new(name, expr)
                    consume_statement_end
                    return stmt
                when TokenType::POUND
                    advance
                    stmt = Assignment.new(name, ArrayLiteral.new([] of Expr))
                    consume_statement_end
                    return stmt
                when TokenType::ASSIGN
                    advance
                    expr = parse_expression
                    stmt = Assignment.new(name, expr)
                    consume_statement_end
                    return stmt
                when TokenType::PLUS_ASSIGN, TokenType::MINUS_ASSIGN, 
                    TokenType::MULTIPLY_ASSIGN, TokenType::DIVIDE_ASSIGN
                    op = current_token.value
                    advance
                    expr = parse_expression
                    stmt = CompoundAssignment.new(name, op, expr)
                    consume_statement_end
                    return stmt
                when TokenType::INCREMENT, TokenType::DECREMENT
                    op = current_token.value
                    advance
                    stmt = IncrementDecrement.new(name, op)
                    consume_statement_end
                    return stmt
                else
                    consume_statement_end
                    return nil
                end
            else
                advance
                return nil
            end
        end
    
        def consume_statement_end
            if current_token.type == TokenType::SEMICOLON
            elsif current_token.type == TokenType::NEWLINE
                advance
            end
        end
    
        def parse_while_loop : Stmt
            expect(TokenType::AT)
            expect(TokenType::LPAREN)
            condition = parse_expression
            expect(TokenType::RPAREN)
            expect(TokenType::LBRACE)
            
            body = [] of Stmt
            skip_newlines
            while current_token.type != TokenType::RBRACE && current_token.type != TokenType::EOF
                stmt = parse_statement
                body << stmt if stmt
                skip_newlines
            end
            
            expect(TokenType::RBRACE)
            WhileLoop.new(condition, body)
        end
    
        def parse_repeat_loop : Stmt
            expect(TokenType::R)
            count = parse_expression
            expect(TokenType::LBRACE)
            
            body = [] of Stmt
            skip_newlines
            while current_token.type != TokenType::RBRACE && current_token.type != TokenType::EOF
                stmt = parse_statement
                body << stmt if stmt
                skip_newlines
            end
            
            expect(TokenType::RBRACE)
            RepeatLoop.new(count, body)
        end
    
        def parse_thread_spawn : Stmt
            expect(TokenType::T)
            expect(TokenType::LBRACE)
            
            body = [] of Stmt
            skip_newlines
            while current_token.type != TokenType::RBRACE && current_token.type != TokenType::EOF
                stmt = parse_statement
                body << stmt if stmt
                skip_newlines
            end
            
            expect(TokenType::RBRACE)
            ThreadSpawn.new(body)
        end
    
        def parse_expression : Expr
            parse_ternary
        end
    
        def parse_ternary : Expr
            expr = parse_comparison
            
            if current_token.type == TokenType::QUESTION
                advance
                true_expr = parse_comparison
                expect(TokenType::COLON)
                false_expr = parse_ternary
                return TernaryOp.new(expr, true_expr, false_expr)
            end
            
            expr
        end
    
        def parse_comparison : Expr
            left = parse_unary
            while current_token.type.in?(TokenType::LESS_THAN, TokenType::GREATER_THAN, 
                                         TokenType::LESS_EQUAL, TokenType::GREATER_EQUAL,
                                         TokenType::EQUAL, TokenType::NOT_EQUAL)
                op = current_token.value
                advance
                right = parse_unary
                left = BinaryOp.new(left, op, right)
            end
            left
        end
    
        def parse_unary : Expr
            if current_token.type == TokenType::BANG
                advance
                operand = parse_unary
                return UnaryOp.new("!", operand)
            end
            parse_additive
        end
    
        def parse_additive : Expr
            left = parse_multiplicative
            while current_token.type.in?(TokenType::PLUS, TokenType::MINUS)
                op = current_token.value
                advance
                right = parse_multiplicative
                left = BinaryOp.new(left, op, right)
            end
            left
        end
    
        def parse_multiplicative : Expr
            left = parse_primary
            while current_token.type.in?(TokenType::MULTIPLY, TokenType::DIVIDE, TokenType::MODULO)
                op = current_token.value
                advance
                right = parse_primary
                left = BinaryOp.new(left, op, right)
            end
            left
        end
    
        def parse_primary : Expr
            case current_token.type
            when TokenType::LBRACKET
                advance
                elements = [] of Expr
                if current_token.type != TokenType::RBRACKET
                    elements << parse_expression
                    while current_token.type == TokenType::COMMA
                        advance
                        elements << parse_expression
                    end
                end
                expect(TokenType::RBRACKET)
                ArrayLiteral.new(elements)
            when TokenType::BACKSLASH
                advance
                if current_token.type == TokenType::DOLLAR
                    advance
                    if current_token.type == TokenType::MULTIPLY
                        advance
                        count_expr = parse_expression
                        ArrayCollectInput.new(count_expr, true)
                    elsif current_token.type == TokenType::STRING
                        prompt = current_token.value
                        advance
                        FloatInput.new(prompt)
                    else
                        FloatInput.new
                    end
                elsif current_token.type == TokenType::STRING
                    prompt = current_token.value
                    advance
                    StringInput.new(prompt)
                else
                    StringInput.new
                end
            when TokenType::S
                advance
                expect(TokenType::LPAREN)
                duration = parse_expression
                expect(TokenType::RPAREN)
                Sleep.new(duration)
            when TokenType::Q
                advance
                expect(TokenType::LPAREN)
                value = parse_expression
                expect(TokenType::RPAREN)
                SquareRoot.new(value)
            when TokenType::STRING
                value = current_token.value
                advance
                StringLiteral.new(value)
            when TokenType::NUMBER
                value_str = current_token.value
                advance
                if value_str.includes?('.')
                    FloatLiteral.new(value_str.to_f)
                else
                    NumberLiteral.new(value_str.to_i)
                end
            when TokenType::IDENTIFIER
                name = current_token.value
                advance
                if current_token.type == TokenType::LPAREN
                    advance
                    arguments = [] of Expr
                    if current_token.type != TokenType::RPAREN
                        arguments << parse_expression
                        while current_token.type == TokenType::COMMA
                            advance
                            arguments << parse_expression
                        end
                    end
                    expect(TokenType::RPAREN)
                    FunctionCall.new(name, arguments)
                elsif current_token.type == TokenType::LBRACKET
                    advance
                    index = parse_expression
                    expect(TokenType::RBRACKET)
                    ArrayIndex.new(Variable.new(name), index)
                else
                    Variable.new(name)
                end
            when TokenType::LPAREN
                advance
                expr = parse_expression
                expect(TokenType::RPAREN)
                expr
            when TokenType::DOLLAR
                advance
                if current_token.type == TokenType::MULTIPLY
                    advance
                    count_expr = parse_expression
                    ArrayCollectInput.new(count_expr, false)
                elsif current_token.type == TokenType::STRING
                    prompt = current_token.value
                    advance
                    Input.new(prompt)
                else
                    Input.new
                end
            else
                raise "Unexpected token #{current_token.type} at line #{current_token.line}"
            end
        end
    end
end
