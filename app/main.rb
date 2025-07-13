# Uncomment this block to pass the first stage


# Wait for user input
loop do
  $stdout.write("$ ")
  tokens = gets.chomp.split(" ")
  $stdout.write("#{tokens[0]}: command not found")
  
  $stdout.write("\n")
end