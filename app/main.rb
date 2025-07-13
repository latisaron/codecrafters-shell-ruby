# require 'pry'
require 'pathname'

# Uncomment this block to pass the first stage
BUILTINS = Set.new(['exit', 'echo', 'type', 'pwd'])

def consume(iterator)
  [].tap do |ary|
    loop do
      begin
        ary << iterator.next
      rescue StopIteration
        break
      end
    end
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

def echo_builtin
  $stdout.write(consume(@token_iterator).join(' '))
end

def type_builtin
  arg = @token_iterator.next rescue ''
  if BUILTINS.include?(arg)
    $stdout.write("#{arg} is a shell builtin")
  elsif path = path_included(arg)
    $stdout.write("#{arg} is #{path}")
  elsif arg.empty?
    $stdout.write('specify an argument for type builtin')
  else
    $stdout.write("#{arg}: not found")
  end
end

def pwd_builtin
  $stdout.write("#{Dir.pwd}")
end

def random_command(current_token)
  path = path_included(current_token)
  if path
    output = `#{current_token} #{consume(@token_iterator).join(' ')}`.rstrip
    $stdout.write(output)
  else
    $stdout.write("#{current_token}: command not found")
  end
end

# Wait for user input
@write_newline = false
loop do
  $stdout.write("$ ")
  @token_iterator = gets.chomp.enum_for(:split, ' ', -1)
  loop do
    current_token = @token_iterator.next()
    begin
      if current_token == 'exit'
        exit_builtin
      elsif current_token == 'echo'
        echo_builtin
      elsif current_token == 'type'
        type_builtin
      elsif current_token == 'pwd'
        pwd_builtin
      else
        random_command(current_token)
        break
      end
    rescue StopIteration
      break
    end
  end
  $stdout.write("\n")
end