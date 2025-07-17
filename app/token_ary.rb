# require 'pry'
require 'open3'

class TokenAry
  BUILTINS = Set.new(['exit', 'echo', 'type', 'pwd'])
  public_constant :BUILTINS

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

    results = []
    if has_chained_commands
      run_chained_commands_mumbojumbo
    else
      if @list[0].is_a?(TokenAry)
        results += @list[0].interpret_and_run
      else
        results += run_based_on_command_token(@list[0])
      end
    end
    results
  end
  
  def parent
    @parent&.parent || @parent
  end

private

  def set_stdout_redirect_write_if_applicable
    if index = @list.find_index(&:is_stdout_redirect_write?)
      if redirect_target = @list[index+1]
        @tmp_stdout = [redirect_target.value, 'w']
        @list.delete_at(index+1)
        @list.delete_at(index)
      end
    end
  end

  def set_stderr_redirect_write_if_applicable
    if index = @list.find_index(&:is_stderr_redirect_write?)
      if redirect_target = @list[index+1]
        @tmp_stderr = [redirect_target.value, 'w']
        @list.delete_at(index+1)
        @list.delete_at(index)
      end
    end
  end

  def set_stdout_redirect_append_if_applicable
    if index = @list.find_index(&:is_stdout_redirect_append?)
      if redirect_target = @list[index+1]
        @tmp_stdout = [redirect_target.value, 'a']
        @list.delete_at(index+1)
        @list.delete_at(index)
      end
    end
  end

  def set_stderr_redirect_append_if_applicable
    if index = @list.find_index(&:is_stderr_redirect_append?)
      if redirect_target = @list[index+1]
        @tmp_stderr = [redirect_target.value, 'a']
        @list.delete_at(index+1)
        @list.delete_at(index)
      end
    end
  end

  def run_based_on_command_token(command_token)
    set_stdout_redirect_write_if_applicable
    set_stderr_redirect_write_if_applicable
    set_stdout_redirect_append_if_applicable
    set_stderr_redirect_append_if_applicable

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
    [result_for("#{new_string}\n", 0)]
  end

  def type_builtin
    @list[1..].map do |token|
      arg = token.value
      if BUILTINS.include?(arg)
        result_for("#{arg} is a shell builtin\n", 0)
      elsif path = path_included(arg)
        result_for("#{arg} is #{path}\n", 0)
      elsif arg.empty?
        result_for('specify an argument for type builtin\n', 2)
      else
        result_for("#{arg}: not found\n", 2)
      end
    end
  end

  def pwd_builtin
    [result_for("#{Dir.pwd}\n", 0)]
  end

  def cd_builtin
    arg = @list[1].value || '.'
    arg = "#{ENV['HOME']}#{arg[1..]}" if arg[0] == '~'
    
    result =
      if Dir.exist?(arg)
        Dir.chdir(arg)
        result_for('', 0)
      else
        result_for("cd: #{arg}: No such file or directory\n", 2)
      end
    [result]
  end

  def random_command(token_obj)
    token_without_quotes = 
      if token_obj.is_stringified_command?
        token_obj.value[1..-2]
      else
        token_obj.value
      end

    current_token = token_obj.value

    result =
      if path_included(token_without_quotes)
        execution_string = "#{current_token} #{@list[1..].map(&:value).join(' ')}"

        stdout_str, stderr_str, status = Open3.capture3(execution_string)

        if status.success?
          result_for(stdout_str, 0)
        else
          result_for(stderr_str, status)
        end
      else
        result_for("#{current_token}: command not found\n", 2)
      end
    [result]
  end

  def result_for(output, status)
    [output, status, @tmp_stdout.dup, @tmp_stderr.dup]
  end
end
