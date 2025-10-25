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
        LBRACKET
        RBRACKET
        LEFT_SHIFT
        AT
        R
        T
        S
        Q
        BACKSLASH
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

    class Preprocessor
        ALIASES = {
            "@@" => "\\$*$",
        }

        BRACKET_PAIRS = {
            '(' => ')',
            ')' => '(',
            '[' => ']',
            ']' => '[',
            '{' => '}',
            '}' => '{',
            '<' => '>',
            '>' => '<',
        }

        def self.mirror_char(c : Char) : Char
            BRACKET_PAIRS[c]? || c
        end

        def self.process(source : String) : String
            result = source
            
            lines = result.lines
            lines = lines.map do |line|
                comment_pos = line.index("//")
                if comment_pos
                    line[0...comment_pos]
                else
                    line
                end
            end
            result = lines.join("\n")
            expanded = String::Builder.new
            i = 0
            while i < result.size
                if result[i] == '^'
                    chars = [] of Char
                    j = i - 1
                    while j >= 0 && chars.size < 2
                        unless result[j].whitespace?
                            chars << result[j]
                        end
                        j -= 1
                    end
                    
                    if chars.size == 2
                        expanded << mirror_char(chars[0])
                        expanded << mirror_char(chars[1])
                    end
                else
                    expanded << result[i]
                end
                i += 1
            end

            result = expanded.to_s

            ALIASES.each do |alias_str, replacement|
                result = result.gsub(alias_str, replacement)
            end
            
            result
        end
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
            if @current_char == '.'
                result += '.'
                advance
                while @current_char && @current_char.as(Char).ascii_number?
                    result += @current_char.as(Char)
                    advance
                end
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
                    if peek && (peek.as(Char).ascii_letter? || peek.as(Char) == '_')
                        tokens << Token.new(TokenType::IDENTIFIER, read_identifier, @line)
                    else
                        tokens << Token.new(TokenType::R, "r", @line)
                        advance
                    end
                when 't'
                    if peek && (peek.as(Char).ascii_letter? || peek.as(Char) == '_')
                        tokens << Token.new(TokenType::IDENTIFIER, read_identifier, @line)
                    else
                        tokens << Token.new(TokenType::T, "t", @line)
                        advance
                    end
                when 's'
                    if peek && (peek.as(Char).ascii_letter? || peek.as(Char) == '_')
                        tokens << Token.new(TokenType::IDENTIFIER, read_identifier, @line)
                    else
                        tokens << Token.new(TokenType::S, "s", @line)
                        advance
                    end
                when 'q'
                    if peek && (peek.as(Char).ascii_letter? || peek.as(Char) == '_')
                        tokens << Token.new(TokenType::IDENTIFIER, read_identifier, @line)
                    else
                        tokens << Token.new(TokenType::Q, "q", @line)
                        advance
                    end
{{ ... }}
                    tokens << Token.new(TokenType::BACKSLASH, "\\", @line)
                    advance
                when '`'
                    tokens << Token.new(TokenType::POUND, "`", @line)
                    advance
                when '{'
                    tokens << Token.new(TokenType::LBRACE, "{", @line)
                    advance
                when '}'
                    tokens << Token.new(TokenType::RBRACE, "}", @line)
                    advance
                when '['
                    tokens << Token.new(TokenType::LBRACKET, "[", @line)
                    advance
                when ']'
                    tokens << Token.new(TokenType::RBRACKET, "]", @line)
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
                elsif peek == '<'
                    advance
                    advance
                    tokens << Token.new(TokenType::LEFT_SHIFT, "<<", @line)
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
