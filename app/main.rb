# Uncomment this block to pass the first stage

ALLOWED_COMMANDS = Set.new(['exit'])

# Wait for user input
loop do
  $stdout.write("$ ")
  tokens = gets.chomp.split(" ")
  tokens.each do |token|
    if ALLOWED_COMMANDS.include?(token)
      if token == 'exit'
        exit 0
      end
    else
      $stdout.write("#{tokens[0]}: command not found")
    end
  end
  $stdout.write("\n")
end