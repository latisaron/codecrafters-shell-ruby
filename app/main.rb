# Uncomment this block to pass the first stage
BUILTINS = Set.new(['exit', 'echo', 'type'])

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
  elsif arg.empty?
    $stdout.write('specify an argument for type builtin')
  else
    $stdout.write("#{arg}: not found")
  end
end

# Wait for user input
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
      else
        $stdout.write("#{current_token}: command not found")
        break
      end
    rescue StopIteration
      break
    end
  end
  $stdout.write("\n")
end