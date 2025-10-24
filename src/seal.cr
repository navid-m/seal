# Seal Programming Language
#
# By Navid M
# GPL-3.0 - NM (C) 2025

require "./lexer"
require "./parser"
require "./interpreter"

module Seal
    VERSION = "0.1.0"
end

if PROGRAM_NAME.includes?("seal")
    if ARGV.size < 1
        puts "Wrong argument count"
        exit(1)
    end
  
    begin
        content = File.read(ARGV[0] + ".sl")
        lexer   = Seal::Lexer.new(content)
        tokens  = lexer.tokenize
        parser  = Seal::Parser.new(tokens)
        program = parser.parse
        interpreter = Seal::Interpreter.new
        interpreter.execute(program)
    rescue ex : File::NotFoundError
        puts "No such file exists: #{ARGV[0]}.sl"
    rescue ex : Exception
        puts "Error: #{ex.message}"
    end
end
