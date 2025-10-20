require "./ast"
require "./lexer"

module Pillar
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
            when TokenType::STRING
                expr = parse_expression
                stmt = PrintStmt.new(expr)
                consume_statement_end
                return stmt
            when TokenType::IDENTIFIER
                name = current_token.value
                advance
                case current_token.type
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
            if current_token.type == TokenType::COMMA || current_token.type == TokenType::NEWLINE
                advance
            end
        end
    
        def parse_expression : Expr
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
            while current_token.type.in?(TokenType::MULTIPLY, TokenType::DIVIDE)
                op = current_token.value
                advance
                right = parse_primary
                left = BinaryOp.new(left, op, right)
            end
            left
        end
    
        def parse_primary : Expr
            case current_token.type
            when TokenType::STRING
                value = current_token.value
                advance
                StringLiteral.new(value)
            when TokenType::NUMBER
                value = current_token.value.to_i
                advance
                NumberLiteral.new(value)
            when TokenType::IDENTIFIER
                name = current_token.value
                advance
                Variable.new(name)
            else
                raise "Unexpected token #{current_token.type} at line #{current_token.line}"
            end
        end
    end
end
