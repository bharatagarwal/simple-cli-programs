require 'pry'

SUITS = ['Hearts', 'Diamonds', 'Spades', 'Clubs']
VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10',
          'Jack', 'Queen', 'King', 'Ace']

WINNING_VALUE = 31
DEALER_THRESHOLD = WINNING_VALUE - 4

def prompt(msg)
  puts "=> #{msg}"
end

def initialize_deck
  SUITS.product(VALUES).shuffle
end

def human_readable_cards(cards)
  cards.map do |card|
    "'#{card[1]} of #{card[0]}'"
  end
end

def joinor(arr, separator = ', ', joining_word = 'and')
  arr.reduce("") do |sentence, val|
    sentence += joining_word + ' ' if val == arr.last && arr.size != 1
    sentence += val.to_s
    separator = ' ' if arr.size == 2 || val == arr[arr.size - 2]
    sentence += separator unless val == arr.last
    sentence
  end
end

def total(cards)
  values = cards.map { |card| card[1] }

  sum = 0
  values.each do |value|
    sum += if value == 'Ace'
             11
           elsif value.to_i == 0 # Jack, Queen or King
             10
           else
             value.to_i
           end
  end

  values.select { |value| value == 'Ace' }.count.times do
    sum -= 10 if sum > WINNING_VALUE
  end

  sum
end

def busted?(total_value)
  total_value > WINNING_VALUE
end

def detect_result(player, dealer)
  if player[:total] > WINNING_VALUE
    :player_busted
  elsif dealer[:total] > WINNING_VALUE
    :dealer_busted
  elsif dealer[:total] < player[:total]
    :player
  elsif dealer[:total] > player[:total]
    :dealer
  else
    :tie
  end
end

def update_score(player, dealer)
  winner = detect_result(player, dealer)
  if [:player, :dealer_busted].include?(winner)
    player[:score] += 1
  elsif [:dealer, :player_busted].include?(winner)
    dealer[:score] += 1
  end
end

def five_wins_reached?(dealer, player)
  player[:score] == 5 || dealer[:score] == 5
end

def overall_winner(player, dealer)
  if player[:score] == 5
    'Player'
  elsif dealer[:score] == 5
    'Dealer'
  end
end

def grand_output(player, dealer)
  puts "=============="
  prompt "Dealer has #{joinor(dealer[:cards_display])} for" \
         " a total of: #{dealer[:total]}"
  prompt "Player has #{joinor(player[:cards_display])} for" \
         " a total of: #{player[:total]}"
  puts "=============="
end

# rubocop:disable Metrics/MethodLength
def display_result(player, dealer)
  result = detect_result(player, dealer)

  case result
  when :player_busted
    puts
    prompt "You busted! Dealer wins."
  when :dealer_busted
    puts
    prompt "Dealer busted! Player wins."
  when :player
    puts
    prompt "You win!"
  when :dealer
    puts
    prompt "Dealer wins!"
  when :tie
    puts
    prompt "It's a tie!"
  end

  grand_output(player, dealer)
end
# rubocop:enable Metrics/MethodLength

def play_again?
  answer = ''
  loop do
    prompt "Do you want to play again? (y or n)"
    answer = gets.chomp

    if ['y', 'n'].include?(answer.downcase)
      break
    else
      prompt "Please choose between 'y or n'"
    end
  end
  answer.downcase == 'y'
end

player = {
  score: 0
}

dealer = {
  score: 0
}

loop do
  system 'clear'
  prompt "Welcome to Whatever-One!"
  prompt "For this iteration, winning value is #{WINNING_VALUE}."
  puts

  # initialize vars
  deck = initialize_deck

  # resetting player and dealer cards and totals.
  player[:cards] = []
  player[:total] = 0

  dealer[:total] = 0
  dealer[:cards] = []

  # initialize deal
  2.times do
    player[:cards] << deck.pop
    dealer[:cards] << deck.pop
  end

  player[:total] = total(player[:cards])
  dealer[:total] = total(dealer[:cards])

  player[:cards_display] = human_readable_cards(player[:cards])
  dealer[:cards_display] = human_readable_cards(dealer[:cards])

  prompt "SCORE Player: #{player[:score]}, Dealer: #{dealer[:score]}"
  prompt "First to get to five wins is the overall winner."
  puts
  prompt "Dealer has #{dealer[:cards_display][0]} and ?"
  prompt "You have: #{joinor(player[:cards_display])}"
  prompt "Your total is: #{player[:total]}"

  # player turn
  loop do
    loop do
      prompt "Would you like to (h)it or (s)tay?"
      player[:turn] = gets.chomp.downcase
      break if ['h', 's'].include?(player[:turn])
      prompt "Sorry, you must enter 'h' or 's'."
    end

    if player[:turn] == 'h'
      prompt "You chose to hit!"

      player[:cards] << deck.pop
      player[:cards_display] = human_readable_cards(player[:cards])

      prompt "You got #{player[:cards_display].last}"
      prompt "Your cards are now: #{joinor(player[:cards_display])}"
      player[:total] = total(player[:cards])
      prompt "Your total is now: #{player[:total]}"
    end

    break if player[:turn] == 's' || busted?(player[:total])
  end

  if busted?(player[:total])
    update_score(player, dealer)

    display_result(player, dealer)

    break if five_wins_reached?(player, dealer)
    play_again? ? next : break
  else
    prompt "You stayed at #{player[:total]}"
  end

  # dealer turn
  puts
  prompt "Dealer turn..."
  prompt "Dealer had #{dealer[:cards_display][0]} and ?"

  loop do
    break if dealer[:total] >= DEALER_THRESHOLD

    puts
    prompt "Dealer hits!"

    dealer[:cards] << deck.pop
    dealer[:cards_display] = human_readable_cards(dealer[:cards])
    prompt "Dealer got #{dealer[:cards_display].last}"

    dealer[:total] = total(dealer[:cards])
    prompt "Dealer's cards are now: #{joinor(dealer[:cards_display])}"
    prompt "Dealer total is now: #{dealer[:total]}"
  end

  if busted?(dealer[:total])
    update_score(player, dealer)

    display_result(player, dealer)

    break if five_wins_reached?(player, dealer)
    play_again? ? next : break
  else
    prompt "Dealer stays at #{dealer[:total]}"
  end

  # both player and dealer stay - compare cards
  update_score(player, dealer)

  display_result(player, dealer)

  break if five_wins_reached?(player, dealer)
  break unless play_again?
end

if five_wins_reached?(player, dealer)
  prompt "#{overall_winner(player, dealer)} is the overall winner" \
         " after reaching five wins."
end

prompt "Thank you for playing Whatever-One" \
       " (with winning value of #{WINNING_VALUE}). Goodbye!"
