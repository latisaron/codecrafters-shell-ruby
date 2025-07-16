# require 'pry'
require 'pathname'
require 'strscan'

require './app/token.rb'
require './app/token_ary.rb'
require './app/tokenizer.rb'

# Wait for user input
loop do
  $stdout.write("$ ")

  user_input = gets.chomp

  tokenizer = Tokenizer.new(user_input)
  main_tokens_ary = tokenizer.tokenize

  main_tokens_ary.interpret_and_run

  $stdout.write("\n") unless main_tokens_ary.ignore_newline
end
