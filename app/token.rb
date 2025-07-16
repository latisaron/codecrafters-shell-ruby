class Token
  ALLOWED_TYPES = [
    0, # word
    1, # stringified word
    2, # command
    3, # blank_space
  ]
  private_constant :ALLOWED_TYPES

  attr_reader :value
  attr_reader :type

  def initialize(value, type)
    raise(StandardError, 'Unknown token type') unless ALLOWED_TYPES.include?(type)

    @type = type
    @value =
      if is_stringified?
        value[1..-2]
      else
        value
      end
  end

  def is_stringified?
    @type == 1
  end

  def is_empty?
    @type == 3
  end
end