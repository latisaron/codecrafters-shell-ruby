# require 'pry'

class TokenAry
  BUILTINS = Set.new(['exit', 'echo', 'type', 'pwd'])
  private_constant :BUILTINS

  attr_reader :list
  attr_reader :ignore_newline

  def initialize(parent: nil)
    @list = []
    @parent = parent
  end

  def add(token)
    @list << token
  end

  def size
    @list.size
  end

  def interpret_and_run
    has_chained_commands = @list.count { |element| element.is_a?(TokenAry)} > 1

    if has_chained_commands
      run_chained_commands_mumbojumbo
    else
      if @list[0].is_a?(TokenAry)
        @list[0].interpret_and_run
      else
        set_stdout_redirection_if_applicable
        set_stderr_redirection_if_applicable
        run_based_on_command_token(@list[0])
        reset_output_redirections
      end
    end
  end
  
  def parent
    @parent&.parent || @parent
  end

private

  def set_stdout_redirection_if_applicable
    @tmp_stdout = $stdout.dup
    if index = @list.find_index(&:is_stdout_redirect?)
      if redirect_target = @list[index+1]
        $stdout.reopen(redirect_target.value, 'w')
        bubble_up_ignore_newline
        @list.delete_at(index+1)
        @list.delete_at(index)
      end
    end
  end

  def set_stderr_redirection_if_applicable
    @tmp_stderr = $stderr.dup
    if index = @list.find_index(&:is_stderr_redirect?)
      if redirect_target = @list[index+1]
        $stderr.reopen(redirect_target.value, 'w')
        @list.delete_at(index+1)
        @list.delete_at(index)
      end
    end
  end

  def reset_output_redirections
    $stdout.reopen @tmp_stdout
    $stderr.reopen @tmp_stderr
  end

  def bubble_up_ignore_newline(value = true)
    @ignore_newline = true
    parent.instance_variable_set(:@ignore_newline, @ignore_newline)
  end

  def run_based_on_command_token(command_token)
    case command_token.value
    when 'exit'
      exit_builtin
    when 'echo'
      echo_builtin
    when 'type'
      type_builtin
    when 'pwd'
      pwd_builtin
    when 'cd'
      cd_builtin
    else
      random_command(command_token)
    end
  end

  def path_included(command)
    ENV['PATH'].split(':').each do |path|
      full_path = Pathname.new(path) + command
      return full_path.to_s if File.exist?(full_path) && File.executable?(full_path)
    end
    nil
  end

  def exit_builtin
    exit 0
  end

  def token_value(item)
    if item.is_stringified?
      item.value[1..-2]  
    else
      item.value
    end
  end

  def echo_builtin
    new_string = +''
    previous_type = nil
    previous_value = nil
    @list[1..].each do |item|
      item_value = token_value(item)
      new_string +=
        if previous_type.nil?
          item_value
        elsif previous_type == Token::STRINGIFIED_WORD
          item_value
        elsif previous_type == Token::STRINGIFIED_WORD && previous_value.empty?
          item_value
        elsif previous_type == Token::BLANK_SPACE
          item_value
        elsif item.is_empty?
          ''
        elsif item.is_stringified? && item_value.empty?
          ''
        elsif item.is_blank_space?
          ' '
        else
          " #{item_value}"
        end
      previous_type = item.type
      previous_value = item_value
    end
    $stdout.write(new_string)
  end

  def type_builtin
    @list[1..].each do |token|
      arg = token.value
      if BUILTINS.include?(arg)
        $stdout.write("#{arg} is a shell builtin")
      elsif path = path_included(arg)
        $stdout.write("#{arg} is #{path}")
      elsif arg.empty?
        $stdout.write('specify an argument for type builtin')
      else
        $stdout.write("#{arg}: not found")
      end
      $stdout.write("\n") 
    end
    bubble_up_ignore_newline
  end

  def pwd_builtin
    $stdout.write("#{Dir.pwd}")
  end

  def cd_builtin
    arg = @list[1].value || '.'
    arg = "#{ENV['HOME']}#{arg[1..]}" if arg[0] == '~'
    
    if Dir.exist?(arg)
      Dir.chdir(arg)
      bubble_up_ignore_newline
    else
      $stdout.write("cd: #{arg}: No such file or directory")
    end
  end

  def random_command(token_obj)
    token_without_quotes = 
      if token_obj.is_stringified_command?
        token_obj.value[1..-2]
      else
        token_obj.value
      end

    current_token = token_obj.value

    if path_included(token_without_quotes)
      output = `#{current_token} #{@list[1..].map(&:value).join(' ')}`.rstrip
      $stdout.write(output)
    else
      $stdout.write("#{current_token}: command not found")
    end
  end
end
