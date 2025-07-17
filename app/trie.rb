  require 'pry'
class TrieNode
  AUTOCOMPLETION_LIMIT = 1
  private_constant :AUTOCOMPLETION_LIMIT

  attr_reader :tree
  attr_accessor :is_word

  def initialize(is_word:, tree: {}, parent: nil, value: nil)
    @parent = parent
    @is_word = is_word
    @tree = tree
    @value = value
  end

  def autocomplete_from_self
    autocompletion_ary = []
    iteratively_autocomplete_from_self(@tree, autocompletion_ary)
  
    autocompletion_ary.map(&:word_from_self_path)
  end

  def word_from_self_path
    return '' if @value.nil?

    "#{@parent&.word_from_self_path}#{@value}"
  end

private

  def iteratively_autocomplete_from_self(tree, initial_ary)
    tree.each do |_, children_trie_node|
      initial_ary << children_trie_node if children_trie_node.is_word

      return if initial_ary.size == AUTOCOMPLETION_LIMIT
    end

    tree.each do |_, children_trie_node|
      iteratively_autocomplete_from_self(children_trie_node.tree, initial_ary)

      return if initial_ary.size == AUTOCOMPLETION_LIMIT
    end
  end
end

class AutocompletionTrie
  def initialize
    @root = TrieNode.new(is_word: false)
  end

  def add(value)
    iterative_adding(@root, value)
  end

  def autocomplete(value)
    return [''] if value.empty? || value.nil?

    current_character_iter = value.enum_for(:chars)
    trie_node = @root
    loop do
      begin
        current_character = current_character_iter.next
        trie_node = trie_node.tree[current_character]
      rescue StopIteration
        break
      end
    end

    trie_node.autocomplete_from_self
  end

private

  def iterative_adding(root, value)
    character = value[0]
    is_end_of_word = value[1].nil?

    root.tree[character] ||= TrieNode.new(
      is_word: false,
      tree: root.tree[character] || {},
      parent: root,
      value: character  
    )
    root.tree[character].is_word ||= is_end_of_word

    return if is_end_of_word

    iterative_adding(root.tree[character], value[1..])
  end 
end
