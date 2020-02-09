class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def center_unmarked?
    @squares[5].unmarked?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def winning_opportunity?(marker)
    !!find_winning_square(marker)
  end

  def find_winning_square(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      squares.map!(&:marker)

      if squares.count(marker) == 2 &&
         squares.count(Square::INITIAL_MARKER) == 1

        opportunity_square = line.select do |index|
          @squares[index].unmarked?
        end
        return opportunity_square.first

      end
    end

    nil
  end

  def under_risk?(marker)
    !!find_at_risk_square(marker)
  end

  def find_at_risk_square(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      squares.map!(&:marker)

      if squares.count(marker) == 0 &&
         squares.count(Square::INITIAL_MARKER) == 1

        opportunity_square = line.select do |index|
          @squares[index].unmarked?
        end

        return opportunity_square.first
      end
    end

    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(array)
    markers = array.select(&:marked?).map(&:marker)
    return false if markers.size != 3
    markers.uniq.size == 1
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def unmarked?
    @marker == INITIAL_MARKER
  end

  def marked?
    @marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end
end

class Player
  attr_reader :marker, :name
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end
end

class Human < Player
  def initialize
    set_name
    super(choose_marker)
  end

  def set_name
    loop do
      puts "What's your name?"
      @name = gets.chomp
      break if @name.empty? == false && @name.squeeze != ' '
      puts "Sorry, you must enter a value."
    end

    puts
  end

  def choose_marker
    marker = ''
    loop do
      puts "What would you like to use as your marker?"
      marker = gets.chomp
      break if marker.length == 1 && marker.squeeze != ' '
      puts
      puts "Please enter a single character marker."
    end

    puts
    marker
  end

  def move(board)
    puts
    puts "Choose a square from #{joinor(board.unmarked_keys, ', ', 'or')}: "
    square = nil

    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Please enter a valid number."
    end

    board[square] = marker
  end

  private

  def joinor(array, separator = ', ', joining_word = 'or')
    array.reduce("") do |sentence, num|
      sentence += joining_word + ' ' if num == array.last && array.size != 1
      sentence += num.to_s
      separator = ' ' if array.size == 2
      sentence += separator unless num == array.last
      sentence
    end
  end
end

class Computer < Player
  def initialize(marker)
    set_name
    super(marker)
  end

  def set_name
    loop do
      puts "What's the computer's name?"
      @name = gets.chomp
      break if @name.empty? == false && @name.squeeze != ' '
      puts
      puts "Sorry, you must enter a value."
    end
  end

  def move(board)
    if board.winning_opportunity?(marker)
      board[board.find_winning_square(marker)] = marker
    elsif board.under_risk?(marker)
      board[board.find_at_risk_square(marker)] = marker
    elsif board.center_unmarked?
      board[5] = marker
    else
      board[board.unmarked_keys.sample] = marker
    end
  end
end

class TTTGame
  MAX_WINS = 3
  FIRST_TO_MOVE = :choose # can also be :player, :computer
  COMPUTER_MARKER = 'Ø'

  attr_reader :board, :human, :computer

  def initialize
    clear
    display_welcome_message
    @board = Board.new
    @human = Human.new
    @computer = Computer.new(COMPUTER_MARKER)
    @first_mover = identify_first_mover
    @current_marker = @first_mover.marker
  end

  def play
    clear

    loop do
      display_board
      single_game_loop
      display_result
      update_score
      break if winning_score_reached? || play_again? == false
      reset
    end

    display_overall_winner if winning_score_reached?
    display_goodbye_message
  end

  private

  def single_game_loop
    loop do
      current_player_moves(board)
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def identify_first_mover
    if FIRST_TO_MOVE == :choose
      choose_first_mover
    elsif FIRST_TO_MOVE == :player
      @human
    elsif FIRST_TO_MOVE == :computer
      @computer
    end
  end

  def choose_first_mover
    choice = ''
    puts

    loop do
      puts "Do you want to go first? (y/n)"
      choice = gets.chomp.downcase
      break if ['y', 'n'].include?(choice)
      puts
      puts "Please enter 'y' or 'n' to indicate your choice."
    end

    if choice == 'y'
      @human
    else
      @computer
    end
  end

  def update_score
    case board.winning_marker
    when human.marker then human.score += 1
    when computer.marker then computer.score += 1
    end
  end

  def winning_score_reached?
    human.score == MAX_WINS || computer.score == MAX_WINS
  end

  def display_overall_winner
    puts
    if human.score == MAX_WINS
      puts "#{human.name} has #{MAX_WINS} wins and is the overall winner."
    elsif computer.score == MAX_WINS
      puts "#{computer.name} has #{MAX_WINS} wins and is the overall winner."
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts "-----------------------"
    puts
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear
    system 'clear'
  end

  def display_board
    display_header
    board.draw
  end

  def display_header
    puts "You're a #{human.marker}. Computer is a #{computer.marker}"
    puts "SCORE #{human.name}: #{human.score}" \
         " #{computer.name}: #{computer.score}"
    puts
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_result
    clear_screen_and_display_board
    puts
    case board.winning_marker
    when human.marker then puts "You won!"
    when computer.marker then puts "Computer won!"
    else puts "It's a tie."
    end
  end

  def play_again?
    answer = nil
    loop do
      puts
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      puts if answer == 'n'
      break if %w[y n].include?(answer)
      puts "Please enter either 'y' or 'n'"
    end

    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = @first_mover.marker
    clear
  end

  def current_player_moves(board)
    if human_turn?
      human.move(board)
      @current_marker = computer.marker
    else
      computer.move(board)
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
  end
end

tictactoe = TTTGame.new
tictactoe.play
