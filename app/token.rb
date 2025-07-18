class Token
  WORD = 0
  public_constant :WORD

  STRINGIFIED_WORD = 1
  public_constant :STRINGIFIED_WORD
  
  COMMAND = 2
  public_constant :COMMAND

  EMPTY_STRING = 3
  public_constant :EMPTY_STRING

  BLANK_SPACE = 4
  public_constant :BLANK_SPACE

  STRINGIFIED_COMMAND = 5
  public_constant :STRINGIFIED_COMMAND

  STDOUT_REDIRECT_WRITE = 6
  public_constant :STDOUT_REDIRECT_WRITE

  STDERR_REDIRECT_WRITE = 7
  public_constant :STDERR_REDIRECT_WRITE

  STDOUT_REDIRECT_APPEND = 8
  public_constant :STDOUT_REDIRECT_APPEND

  STDERR_REDIRECT_APPEND = 9
  public_constant :STDERR_REDIRECT_APPEND

  ALLOWED_TYPES = [
    WORD,
    STRINGIFIED_WORD,
    COMMAND,
    EMPTY_STRING,
    BLANK_SPACE,
    STRINGIFIED_COMMAND,
    STDOUT_REDIRECT_WRITE,
    STDERR_REDIRECT_WRITE,
    STDOUT_REDIRECT_APPEND,
    STDERR_REDIRECT_APPEND,
  ]
  private_constant :ALLOWED_TYPES

  attr_reader :value
  attr_reader :type

  def initialize(value, type)
    raise(StandardError, 'Unknown token type') unless ALLOWED_TYPES.include?(type)

    @type = type
    @value = value
  end

  def is_word?
    @type == WORD
  end

  def is_stringified?
    @type == STRINGIFIED_WORD
  end

  def is_command?
    @type == COMMAND
  end

  def is_empty?
    @type == EMPTY_STRING
  end

  def is_blank_space?
    @type == BLANK_SPACE
  end

  def is_stringified_command?
    @type == STRINGIFIED_COMMAND
  end

  def is_stdout_redirect_write?
    @type == STDOUT_REDIRECT_WRITE
  end

  def is_stderr_redirect_write?
    @type == STDERR_REDIRECT_WRITE
  end

  def is_stdout_redirect_append?
    @type == STDOUT_REDIRECT_APPEND
  end

  def is_stderr_redirect_append?
    @type == STDERR_REDIRECT_APPEND
  end
end