WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +     # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +     # columns
                [[1, 5, 9], [3, 5, 7]]                  # diagonals

INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'Ø'
GO_FIRST = 'choose'

score = {
  'Player' => 0,
  'Computer' => 0
}

def prompt(msg)
  puts "=> #{msg}"
end

def choose_starter
  if GO_FIRST == 'Player'
    'Player'
  elsif GO_FIRST == 'Computer'
    'Computer'
  elsif GO_FIRST == 'choose'
    input_starter.capitalize
  end
end

def input_starter
  starter = ''
  loop do
    system 'clear'
    puts "Who goes first? Player or Computer"
    starter = gets.chomp.downcase
    break if ['player', 'computer'].include?(starter)
    puts "Sorry, please enter a valid choice."
  end

  starter
end

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def display_board(brd, score)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts "First to reach a score of 5 is the overall winner."
  puts "SCORE Player: #{score['Player']} Computer: #{score['Computer']}"
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}  "
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}  "
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}  "
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = ' ' }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == ' ' }
end

def joinor(arr, separator = ', ', joining_word = 'or')
  arr.reduce("") do |sentence, num|
    sentence += joining_word + ' ' if num == arr.last && arr.size != 1
    sentence += num.to_s
    separator = ' ' if arr.size == 2
    sentence += separator unless num == arr.last
    sentence
  end
end

def player_places_piece!(brd) # should mutate board
  square = ''
  options = joinor(empty_squares(brd))
  loop do
    prompt "Choose a square #{options}:"
    square = gets.chomp.to_i # 'string'.to_i => 0
    break if empty_squares(brd).include?(square)
    prompt "Sorry that's not a valid choice"
  end

  brd[square] = PLAYER_MARKER
end

def find_at_risk_square(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 2 &&
       brd.values_at(*line).count(COMPUTER_MARKER) == 0
      risk_square = line.select do |ln|
        brd[ln] != PLAYER_MARKER
      end
      return risk_square.first
    end
  end

  nil
end

def comp_at_risk?(brd)
  !!find_at_risk_square(brd)
end

def find_winning_opportunity(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 0 &&
       brd.values_at(*line).count(COMPUTER_MARKER) == 2
      opportunity_square = line.select do |ln|
        brd[ln] != COMPUTER_MARKER
      end
      return opportunity_square.first
    end
  end

  nil
end

def comp_has_opportunity?(brd)
  !!find_winning_opportunity(brd)
end

def computer_places_piece!(brd)
  if comp_has_opportunity?(brd)
    brd[find_winning_opportunity(brd)] = COMPUTER_MARKER
  elsif comp_at_risk?(brd)
    brd[find_at_risk_square(brd)] = COMPUTER_MARKER
  elsif ![PLAYER_MARKER, COMPUTER_MARKER].include?(brd[5])
    brd[5] = COMPUTER_MARKER
  else
    square = empty_squares(brd).sample
    brd[square] = COMPUTER_MARKER
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def update_score(brd, scr)
  winner = detect_winner(brd)
  if winner
    scr[winner] += 1
  end
end

def five_wins_reached?(scr)
  scr['Player'] == 5 || scr['Computer'] == 5
end

def overall_winner(scr)
  scr.key(5)
end

def place_piece!(board, current_player)
  if current_player == 'Player'
    player_places_piece!(board)
  elsif current_player == 'Computer'
    computer_places_piece!(board)
  end
end

def alternate_player(current_player)
  if current_player == 'Player'
    'Computer'
  elsif current_player == 'Computer'
    'Player'
  end
end

starter = choose_starter

loop do
  board = initialize_board
  current_player = starter

  loop do
    display_board(board, score)
    place_piece!(board, current_player)

    current_player = alternate_player(current_player)
    break if someone_won?(board) || board_full?(board)
  end

  update_score(board, score)
  display_board(board, score)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"
  else
    prompt "It's a tie!"
  end

  break if five_wins_reached?(score)

  answer = ''
  loop do
    prompt "Play again? (y or n)"
    answer = gets.chomp

    if ['y', 'n'].include?(answer.downcase)
      break
    else
      prompt "Please choose between 'y or n'"
    end
  end
  break if answer.downcase == 'n'
end

if five_wins_reached?(score)
  prompt "Overall winner is #{overall_winner(score)}."
end

prompt "Thanks for playing Tic Tac Toe. Goodbye!"
