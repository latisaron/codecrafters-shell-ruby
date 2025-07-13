# Uncomment this block to pass the first stage
$stdout.write("$ ")

# Wait for user input
loop do
  tokens = gets.chomp.split(" ")
  puts "#{tokens[0]}: command not found"
end