# require 'pry'
require './app/token.rb'

class Tokenizer
  def initialize(user_input)
    @scanner = StringScanner.new(user_input)
    @main_tokens_ary = TokenAry.new
    @work_tokens_ary = TokenAry.new(parent: @main_tokens_ary)
    @main_tokens_ary.add(@work_tokens_ary)
  end

  def tokenize
    @current_token = +''
    work_tokens_ary = @work_tokens_ary
    loop do
      current_character = @scanner.getch
      if current_character.nil?
        add_token_and_reset(work_tokens_ary)
        break
      elsif current_character == '\\'
        new_character = @scanner.getch
        if new_character == ' '
          add_token_and_reset(work_tokens_ary) unless @current_token.empty?

          @current_token = ' '
          add_token_and_reset(work_tokens_ary)
        else
          @current_token += new_character
        end
      elsif current_character == "'"
        add_token_and_reset(work_tokens_ary) unless @current_token.empty?

        @current_token = "'#{consume_until("'")}'"
        add_token_and_reset(work_tokens_ary)
      elsif current_character == '"'
        add_token_and_reset(work_tokens_ary) unless @current_token.empty?

        @current_token = '"' + consume_until('"') + '"'
        add_token_and_reset(work_tokens_ary)
      elsif current_character == ' '
        add_token_and_reset(work_tokens_ary)
      else
        @current_token += current_character
      end
    end

    @main_tokens_ary
  end

private

  def consume_until(character)
    token = +''
    prev_character = nil
    loop do
      current_character = @scanner.getch
      if current_character == '\\'
        next_character = @scanner.getch
        if next_character == character
          token += character
        elsif next_character == '\\'
          token += '\\'
        else
          token += current_character + next_character
        end
      else
        break if current_character == character || current_character.nil?

        token += current_character
      end
    end
    return token
  end

  def token_type(token_ary, current_token)
    if (@current_token[0] == "'" && current_token[-1] == "'" && current_token.size > 1) ||
        (@current_token[0] == '"' && current_token[-1] == '"' && current_token.size > 1)
      word_or_stringified_command_based_on_string(token_ary)
    elsif @current_token.empty?
      Token::EMPTY_STRING
    elsif @current_token == ' '
      Token::BLANK_SPACE
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
    token_ary.size.zero? ? Token::COMMAND : Token::WORD
  end

  def word_or_stringified_command_based_on_string(token_ary)
    token_ary.size.zero? ? Token::STRINGIFIED_COMMAND : Token::STRINGIFIED_WORD
  end
end
