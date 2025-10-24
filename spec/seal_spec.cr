require "./spec_helper"

describe Seal do
    describe "Arithmetic Operations" do
        it "performs addition" do
            result = run_seal("£5+3;")
            result.should eq("8\n")
        end

        it "performs subtraction" do
            result = run_seal("£10-4;")
            result.should eq("6\n")
        end

        it "performs multiplication" do
            result = run_seal("£6*7;")
            result.should eq("42\n")
        end

        it "performs division" do
            result = run_seal("£15/3;")
            result.should eq("5\n")
        end

        it "performs modulo" do
            result = run_seal("£17~5;")
            result.should eq("2\n")
        end
    end

    describe "Variables" do
        it "assigns and prints variables" do
            result = run_seal("x=42;%x;")
            result.should eq("42\n")
        end

        it "defaults uninitialized variables to 0" do
            result = run_seal("%y;")
            result.should eq("0\n")
        end

        it "performs compound assignment" do
            result = run_seal("x=10;x+=5;%x;")
            result.should eq("15.0\n")
        end

        it "increments with ++" do
            result = run_seal("x=5;x++;%x;")
            result.should eq("6\n")
        end

        it "increments with ¬" do
            result = run_seal("x=5;x¬;%x;")
            result.should eq("6\n")
        end

        it "decrements with --" do
            result = run_seal("x=5;x--;%x;")
            result.should eq("4\n")
        end
    end

    describe "Comparison Operators" do
        it "tests equality with ==" do
            result = run_seal("£5==5;£5==3;")
            result.should eq("1\n0\n")
        end

        it "tests equality with |" do
            result = run_seal("£5|5;£5|3;")
            result.should eq("1\n0\n")
        end

        it "tests inequality" do
            result = run_seal("£5!=3;£5!=5;")
            result.should eq("1\n0\n")
        end

        it "tests less than" do
            result = run_seal("£3<5;£5<3;")
            result.should eq("1\n0\n")
        end

        it "tests greater than" do
            result = run_seal("£5>3;£3>5;")
            result.should eq("1\n0\n")
        end
    end

    describe "Negation Operator" do
        it "negates zero to one" do
            result = run_seal("£!0;")
            result.should eq("1\n")
        end

        it "negates non-zero to zero" do
            result = run_seal("£!5;£!1;")
            result.should eq("0\n0\n")
        end

        it "works with expressions" do
            result = run_seal("£!15~15;£!16~3;")
            result.should eq("1\n0\n")
        end
    end

    describe "Ternary Operator" do
        it "returns true branch when condition is true" do
            result = run_seal("£5>3?10:20;")
            result.should eq("10\n")
        end

        it "returns false branch when condition is false" do
            result = run_seal("£3>5?10:20;")
            result.should eq("20\n")
        end

        it "handles nested ternaries" do
            result = run_seal("x=7;£x>10?1:x>5?2:3;")
            result.should eq("2\n")
        end

        it "works with strings" do
            result = run_seal("£5|5?\"yes\":\"no\";")
            result.should eq("yes\n")
        end
    end

    describe "While Loops" do
        it "executes loop while condition is true" do
            result = run_seal("i=0;@(i<3){£i;i++;}")
            result.should eq("0\n1\n2\n")
        end

        it "doesn't execute when condition is initially false" do
            result = run_seal("i=5;@(i<3){£i;i++;}")
            result.should eq("")
        end
    end

    describe "Repeat Loops" do
        it "repeats block N times" do
            result = run_seal("r3{\"Hi\";}")
            result.should eq("Hi\nHi\nHi\n")
        end

        it "provides _ variable with iteration number" do
            result = run_seal("r5{£_;}")
            result.should eq("1\n2\n3\n4\n5\n")
        end

        it "evaluates count expression" do
            result = run_seal("n=2;r n*2{£_;}")
            result.should eq("1\n2\n3\n4\n")
        end
    end

    describe "Print Operations" do
        it "prints strings" do
            result = run_seal("\"Hello\";")
            result.should eq("Hello\n")
        end

        it "prints expressions with £" do
            result = run_seal("£5+3;")
            result.should eq("8\n")
        end

        it "prints variables with %" do
            result = run_seal("x=42;%x;")
            result.should eq("42\n")
        end

        it "prints without newline with :" do
            result = run_seal(":\"A\";:\"B\";\"C\";")
            result.should eq("ABC\n")
        end
    end

    describe "FizzBuzz" do
        it "generates correct FizzBuzz output for 1-15" do
            code = "r15{£!_~15?\"FizzBuzz\":!_~3?\"Fizz\":!_~5?\"Buzz\":_;}"
            result = run_seal(code)
            expected = "1\n2\nFizz\n4\nBuzz\nFizz\n7\n8\nFizz\nBuzz\n11\nFizz\n13\n14\nFizzBuzz\n"
            result.should eq(expected)
        end
    end

    describe "Prime Function" do
        it "identifies prime numbers" do
            result = run_seal("£p(7);£p(4);£p(2);")
            result.should eq("1\n0\n1\n")
        end
    end
end

def run_seal(code : String) : String
    lexer = Seal::Lexer.new(code)
    tokens = lexer.tokenize
    parser = Seal::Parser.new(tokens)
    program = parser.parse
    
    io = IO::Memory.new
    interpreter = Seal::Interpreter.new(io)
    interpreter.execute(program)
    io.to_s
end
