# require 'pry'
require 'pathname'
require 'strscan'

require './app/token.rb'
require './app/token_ary.rb'
require './app/tokenizer.rb'

def ensure_space_at_final(string)
  if string[-1] != "\n" && !string.empty?
    "#{string}\n"
  else
    string
  end
end

def output_results_list(results_list)
  results_list.each do |item|
    original_stdout = $stdout.dup
    original_stderr = $stderr.dup
    if item[0].is_a?(Array)
      output_results_list(results_list)
    else
      $stdout.reopen(item[2], 'w') unless item[2].nil?
      $stderr.reopen(item[3], 'w') unless item[3].nil?

      # binding.pry
      if item[1] == 0
        $stdout
      else
        $stderr
      end.write(ensure_space_at_final(item[0]))

      $stdout.reopen(original_stdout) unless item[2].nil?
      $stderr.reopen(original_stderr) unless item[2].nil?
    end
  end
end

# Wait for user input
loop do
  $stdout.write("$ ")

  user_input = gets.chomp

  tokenizer = Tokenizer.new(user_input)
  main_tokens_ary = tokenizer.tokenize

  results_list = main_tokens_ary.interpret_and_run
  output_results_list(results_list)
end
