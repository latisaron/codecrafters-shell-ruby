# require 'pry'
require 'pathname'
require 'strscan'

require './app/token.rb'
require './app/token_ary.rb'


def consume_until(character)
  token = +''
  loop do
    current_character = @scanner.getch
    break if current_character == character || current_character.nil?

    token += current_character
  end
  return token
end

def token_type(token_ary, current_token)
  if @current_token[0] == "'" || @current_token[0] == '"'
    1
  elsif @current_token.empty?
    3
  else
    word_or_command_based_on_size(token_ary)
  end
end

def add_token_and_reset(token_ary)
  token_obj = Token.new(
    @current_token,
    token_type(token_ary, @current_token)  
  )
  token_ary.add(token_obj)

  @current_token = +''
end

def word_or_command_based_on_size(token_ary)
  token_ary.size.zero? ? 2 : 0
end

# Wait for user input
loop do
  $stdout.write("$ ")
  @ignore_newline = false
  @scanner = StringScanner.new(gets.chomp)

  main_tokens_ary = TokenAry.new
  work_tokens_ary = TokenAry.new
  main_tokens_ary.add(work_tokens_ary)

  @current_token = +''
  loop do
    current_character = @scanner.getch
    if current_character.nil?
      add_token_and_reset(work_tokens_ary)
      break
    elsif current_character == "'"
      @current_token = "'#{consume_until("'")}'"
      add_token_and_reset(work_tokens_ary)
    elsif current_character == '"'
      @current_token = '"' + consume_until('"') + '"'
      add_token_and_reset(work_tokens_ary)
    elsif current_character == ' '
      add_token_and_reset(work_tokens_ary)
    else
      @current_token += current_character
    end
  end

  main_tokens_ary.interpret_and_run

  $stdout.write("\n") unless main_tokens_ary.ignore_newline
end
