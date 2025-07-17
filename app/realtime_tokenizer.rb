# require 'pry'
require './app/token.rb'
require 'io/console'

class RealtimeTokenizer
  def initialize
    @main_tokens_ary = TokenAry.new
    @work_tokens_ary = TokenAry.new(parent: @main_tokens_ary)
    @main_tokens_ary.add(@work_tokens_ary)
  end

  def intrepret_user_input_in_real_time
    @input = +'$ '
    @current_token = +''
    work_tokens_ary = @work_tokens_ary
    STDIN.raw do
      loop do
        current_character = STDIN.getc
        
        if current_character == "\r"
          add_token_and_reset(work_tokens_ary)
          print("\r\n")
          @input << current_character
          break
        elsif current_character == "\t"
          autocompleted_token = builtin_trie_for_usage.autocomplete(@current_token).first
          initial_token = @current_token
          @current_token = autocompleted_token

          output = "#{@current_token[initial_token.size..]} "
          print(output)
          @input << output
          add_token_and_reset(work_tokens_ary)
        elsif current_character == '\\'
          @input << current_character
          print(current_character)
          new_character = STDIN.getc
          if new_character == ' '
            @input << new_character
            print(new_character)
            add_token_and_reset(work_tokens_ary) unless @current_token.empty?

            @current_token = ' '
            add_token_and_reset(work_tokens_ary)
          else
            @current_token += new_character
          end
        elsif current_character == "'"
          @input << current_character
          print(current_character)
          add_token_and_reset(work_tokens_ary) unless @current_token.empty?

          @current_token = "'#{consume_until("'")}'"
          add_token_and_reset(work_tokens_ary)
        elsif current_character == '"'
          @input << current_character
          print(current_character)
          add_token_and_reset(work_tokens_ary) unless @current_token.empty?

          @current_token = '"' + consume_until('"') + '"'
          add_token_and_reset(work_tokens_ary)
        elsif current_character == ' '
          @input << current_character
          print(current_character)
          add_token_and_reset(work_tokens_ary)
        elsif current_character == "\u007F"
          if @input.size > 2
            @input.chop!
            @current_token = @current_token[0..-2]
            print("\r\e[K")
            print(@input)
          end
        else
          @input << current_character
          print(current_character)
          @current_token += current_character
        end
      end
    end 

    @main_tokens_ary
  end

private
  def builtin_trie_for_usage
    @builtin_trie ||= AutocompletionTrie.new.tap do |trie|
      TokenAry::BUILTINS.each do |token|
        trie.add(token)
      end
    end
  end

  def consume_until(character)
    token = +''
    prev_character = nil
    loop do
      current_character = STDIN.getc
      @input << current_character
      print(current_character)
      if current_character == '\\'
        next_character = STDIN.getc
        @input << new_character
        print(new_character)
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
    if (current_token[0] == "'" && current_token[-1] == "'" && current_token.size > 1) ||
        (current_token[0] == '"' && current_token[-1] == '"' && current_token.size > 1)
      word_or_stringified_command_based_on_string(token_ary)
    elsif current_token.empty?
      Token::EMPTY_STRING
    elsif current_token == ' '
      Token::BLANK_SPACE
    elsif current_token == '>' || current_token == '1>'
      Token::STDOUT_REDIRECT_WRITE
    elsif current_token == '2>'
      Token::STDERR_REDIRECT_WRITE
    elsif current_token == '>>' || current_token == '1>>'
      Token::STDOUT_REDIRECT_APPEND
    elsif current_token == '2>>'
      Token::STDERR_REDIRECT_APPEND
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
