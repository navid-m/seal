module Seal
    enum TokenType
        STRING
        NUMBER
        IDENTIFIER
        PLUS
        MINUS
        MULTIPLY
        DIVIDE
        MODULO
        ASSIGN
        PLUS_ASSIGN
        MINUS_ASSIGN
        MULTIPLY_ASSIGN
        DIVIDE_ASSIGN
        INCREMENT
        DECREMENT
        PERCENT
        POUND
        DOLLAR
        SEMICOLON
        COMMA
        LPAREN
        RPAREN
        LBRACE
        RBRACE
        AT
        R
        LESS_THAN
        GREATER_THAN
        LESS_EQUAL
        GREATER_EQUAL
        EQUAL
        NOT_EQUAL
        COLON
        QUESTION
        BANG
        NEWLINE
        EOF
    end

    class Token
        property type : TokenType
        property value : String
        property line : Int32

        def initialize(@type : TokenType, @value : String, @line : Int32)
        end
    end

    class Lexer
        @input : String
        @pos : Int32
        @line : Int32
        @current_char : Char?

        def initialize(@input : String)
            @pos = 0
            @line = 1
            @current_char = @input.size > 0 ? @input[0] : nil
        end

        def advance
            @pos += 1
            if @pos < @input.size
                @current_char = @input[@pos]
            else
                @current_char = nil
            end
        end

        def peek(offset = 1) : Char?
            peek_pos = @pos + offset
            if peek_pos < @input.size
                @input[peek_pos]
            else
                nil
            end
        end

        def skip_whitespace
            while @current_char && @current_char.in?(' ', '\t', '\r')
                advance
            end
        end

        def read_string : String
            result = ""
            advance 
            
            while @current_char && @current_char != '"'
                if @current_char != nil
                    result += @current_char.as(Char).to_s
                end
                advance
            end
            
            advance
            result
        end

        def read_number : String
            result = ""
            while @current_char && @current_char.as(Char).ascii_number?
                result += @current_char.as(Char)
                advance
            end
            result
        end

        def read_identifier : String
            result = ""
            while @current_char && (@current_char.as(Char).ascii_letter? || @current_char.as(Char).ascii_number? || @current_char.as(Char) == '_')
                result += @current_char.as(Char)
                advance
            end
            result
        end

        def tokenize : Array(Token)
            tokens = [] of Token

            while @current_char
                skip_whitespace
                break unless @current_char
                case @current_char
                when '"'
                tokens << Token.new(TokenType::STRING, read_string, @line)
                when '\n'
                tokens << Token.new(TokenType::NEWLINE, "\n", @line)
                @line += 1
                advance
                when ','
                tokens << Token.new(TokenType::COMMA, ",", @line)
                advance
                when '¬'
                    tokens << Token.new(TokenType::INCREMENT, "¬", @line)
                    advance
                when '+'
                if peek == '+'
                    advance
                    advance
                    tokens << Token.new(TokenType::INCREMENT, "++", @line)
                elsif peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::PLUS_ASSIGN, "+=", @line)
                else
                    tokens << Token.new(TokenType::PLUS, "+", @line)
                    advance
                end
                when '-'
                if peek == '-'
                    advance
                    advance
                    tokens << Token.new(TokenType::DECREMENT, "--", @line)
                elsif peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::MINUS_ASSIGN, "-=", @line)
                else
                    tokens << Token.new(TokenType::MINUS, "-", @line)
                    advance
                end
                when '*'
                if peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::MULTIPLY_ASSIGN, "*=", @line)
                else
                    tokens << Token.new(TokenType::MULTIPLY, "*", @line)
                    advance
                end
                when '/'
                if peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::DIVIDE_ASSIGN, "/=", @line)
                else
                    tokens << Token.new(TokenType::DIVIDE, "/", @line)
                    advance
                end
                when '='
                if peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::EQUAL, "==", @line)
                else
                    tokens << Token.new(TokenType::ASSIGN, "=", @line)
                    advance
                end
                when '%'
                    tokens << Token.new(TokenType::PERCENT, "%", @line)
                    advance
                when ';'
                    tokens << Token.new(TokenType::SEMICOLON, ";", @line)
                    advance
                when ':'
                    tokens << Token.new(TokenType::COLON, ":", @line)
                    advance
                when '£'
                    tokens << Token.new(TokenType::POUND, "£", @line)
                    advance
                when '('
                    tokens << Token.new(TokenType::LPAREN, "(", @line)
                    advance
                when ')'
                    tokens << Token.new(TokenType::RPAREN, ")", @line)
                    advance
                when '$'
                    tokens << Token.new(TokenType::DOLLAR, "$", @line)
                    advance
                when '@'
                    tokens << Token.new(TokenType::AT, "@", @line)
                    advance
                when 'r'
                    tokens << Token.new(TokenType::R, "r", @line)
                    advance
                when '{'
                    tokens << Token.new(TokenType::LBRACE, "{", @line)
                    advance
                when '}'
                    tokens << Token.new(TokenType::RBRACE, "}", @line)
                    advance
                when '~'
                    tokens << Token.new(TokenType::MODULO, "~", @line)
                    advance
                when '|'
                    tokens << Token.new(TokenType::EQUAL, "|", @line)
                    advance
                when '?'
                    tokens << Token.new(TokenType::QUESTION, "?", @line)
                    advance
                when '<'
                if peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::LESS_EQUAL, "<=", @line)
                else
                    tokens << Token.new(TokenType::LESS_THAN, "<", @line)
                    advance
                end
                when '>'
                if peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::GREATER_EQUAL, ">=", @line)
                else
                    tokens << Token.new(TokenType::GREATER_THAN, ">", @line)
                    advance
                end
                when '!'
                if peek == '='
                    advance
                    advance
                    tokens << Token.new(TokenType::NOT_EQUAL, "!=", @line)
                else
                    tokens << Token.new(TokenType::BANG, "!", @line)
                    advance
                end
                else
                if @current_char.as(Char).ascii_number?
                    tokens << Token.new(TokenType::NUMBER, read_number, @line)
                elsif @current_char.as(Char).ascii_letter? || @current_char.as(Char) == '_'
                    tokens << Token.new(TokenType::IDENTIFIER, read_identifier, @line)
                else
                    advance
                end
                end
            end

            tokens << Token.new(TokenType::EOF, "", @line)
            tokens
        end
    end
end
