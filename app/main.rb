# Uncomment this block to pass the first stage
ALLOWED_COMMANDS = Set.new(['exit', 'echo'])

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

# Wait for user input
loop do
  $stdout.write("$ ")
  token_iterator = gets.chomp.enum_for(:split, ' ', -1)
  loop do
    current_token = token_iterator.next()
    begin
      if current_token == 'exit'
        exit 0
      elsif current_token == 'echo'
        $stdout.write(consume(token_iterator).join(' '))
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