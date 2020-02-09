class Deck
  SUITS = [:hearts, :spades, :clubs, :diamonds]
  VALUES = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

  attr_accessor :cards

  def initialize
    reset
  end

  def reset
    @cards = create_deck
  end

  def deal
    cards.delete(cards.sample)
  end

  private

  def create_deck
    cards = []
    SUITS.each do |suit|
      VALUES.each do |value|
        cards << Card.new(suit, value)
      end
    end
    cards
  end
end

class Card
  attr_reader :value, :suit, :numeric_value

  def initialize(suit, value)
    @suit = suit
    @value = value
    @numeric_value = determine_numeric_value
  end

  def to_s
    "#{value.to_s.capitalize} of #{suit.to_s.capitalize}"
  end

  private

  def determine_numeric_value
    case value
    when Integer                then value
    when :jack, :queen, :king   then 10
    when :ace                   then 11
    end
  end
end

class Participant
  attr_accessor :cards, :score

  def initialize
    reset_cards
    @score = 0
  end

  def cards_total
    total = 0
    cards.each do |card|
      total += card.numeric_value
      if card.numeric_value == 11 && total > 21
        total -= 10
      end
    end
    total
  end

  def busted?
    cards_total > 21
  end

  def reset_cards
    @cards = []
  end
end

class Player < Participant
  def display_cards
    puts "You have: #{cards[0...-1].join(', ')} and #{cards[-1]}"
    puts "Your total is: #{cards_total}."
  end
end

class Dealer < Participant
  def display_cards
    puts "The dealer has: #{cards[1..-1].join(', ')} and an unknown card"
  end

  def display_all_cards
    puts "The dealer has: #{cards[0...-1].join(', ')} and #{cards[-1]}"
    puts "The dealer's total is: #{cards_total}."
  end
end

class Game
  attr_reader :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    display_welcome_message
    loop do
      show_scores
      deal_card(player, 2)
      deal_card(dealer, 2)
      display_cards
      player_turn
      dealer_turn unless player.busted?
      show_result
      display_all_cards
      update_score
      break unless play_again?
      reset
    end
    display_goodbye_message
  end

  private

  def clear
    system('clear') || system('cls')
  end

  def display_welcome_message
    clear
    puts "Welcome to Twenty-One!"
    puts ''
    puts "Get as close as you can to 21 without busting to win!"
    puts ''
  end

  def display_goodbye_message
    puts "Thanks for playing Twenty-One! Goodbye!"
  end

  def deal_card(receiver, number_of_cards=1)
    number_of_cards.times { receiver.cards << deck.deal }
  end

  def display_cards
    puts ''
    player.display_cards
    puts ''
    dealer.display_cards
    puts ''
  end

  def display_all_cards
    puts ''
    player.display_cards
    puts ''
    dealer.display_all_cards
    puts ''
  end

  def player_turn
    answer = ''
    loop do
      loop do
        puts "Do you want to hit ('h') or stay ('s')?"
        answer = gets.chomp.downcase
        break if ['h', 's'].include?(answer)
        puts "Invalid answer. Please enter 'h' for hit or 's' for stay."
      end

      break if answer == 's'
      deal_card(player)
      break if player.busted?
      player.display_cards
    end
  end

  def dealer_turn
    while dealer.cards_total <= 17
      puts "The dealer chose to hit."
      deal_card(dealer)
    end
  end

  def update_score
    player_total = player.cards_total
    dealer_total = dealer.cards_total

    if player.busted?
      dealer.score += 1
    elsif dealer.busted?
      player.score += 1
    elsif dealer_total > player_total
      dealer.score += 1
    elsif player_total > dealer_total
      player.score += 1
    end
  end

  def show_scores
    puts " You: #{player.score} | Dealer: #{dealer.score}"
  end

  def show_result
    player_total = player.cards_total
    dealer_total = dealer.cards_total

    if player.busted?
      puts "You busted! The dealer won!"
    elsif dealer.busted?
      puts "The dealer busted! You won!"
    elsif player_total > dealer_total
      puts "You won!"
    elsif dealer_total > player_total
      puts "The dealer won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Do you want to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Invalid answer.  Please enter 'y' or 'n'."
    end
    answer == 'y'
  end

  def reset
    clear
    deck.reset
    player.reset_cards
    dealer.reset_cards
  end
end

Game.new.start