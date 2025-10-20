# By Navid M
# GPL-3.0 - NM (C) 2025

require "./lexer"
require "./parser"
require "./interpreter"

module Pillar
    VERSION = "0.1.0"
  
    if ARGV.size < 1
        puts "Wrong argument count"
        exit(1)
    end
  
    begin
        content = File.read(ARGV[0] + ".p")
        lexer = Lexer.new(content)
        tokens = lexer.tokenize
        parser = Parser.new(tokens)
        program = parser.parse
        interpreter = Interpreter.new
        interpreter.execute(program)
        
    rescue ex : File::NotFoundError
        puts "No such file exists: #{ARGV[0]}.p"
    rescue ex : Exception
        puts "Error: #{ex.message}"
    end
end
