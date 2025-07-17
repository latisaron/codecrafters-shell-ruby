# require 'pry'
require 'pathname'
require 'strscan'

require './app/token.rb'
require './app/token_ary.rb'
require './app/realtime_tokenizer.rb'
require './app/trie.rb'

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
      $stdout.reopen(item[2][0], item[2][1]) unless item[2].nil?
      $stderr.reopen(item[3][0], item[3][1]) unless item[3].nil?

      if item[1] == 0
        $stdout
      else
        $stderr
      end.write(ensure_space_at_final(item[0]))

      $stdout.reopen(original_stdout) unless item[2].nil?
      $stderr.reopen(original_stderr) unless item[3].nil?
    end
  end
end

# Wait for user input
loop do
  $stdout.write("$ ")

  tokenizer = RealtimeTokenizer.new
  main_tokens_ary = tokenizer.intrepret_user_input_in_real_time


  results_list = main_tokens_ary.interpret_and_run

  output_results_list(results_list)
end

