VALID_CHOICES = %w(rock paper scissors lizard spock)
VALID_SHORTENED = %w(r p x l s)

details = {
  player: {
    score: 0,
    winner: false
  },
  computer: {
    score: 0,
    winner: false
  }
}

def prompt(message)
  Kernel.puts("=> #{message}")
end

def valid_long?(choice)
  VALID_CHOICES.include?(choice)
end

def valid_short?(choice)
  VALID_SHORTENED.include?(choice)
end

def convert_to_long(choice)
  VALID_CHOICES[VALID_SHORTENED.find_index(choice)]
end

def win?(first, second)
  if first == 'rock'
    (second == 'lizard' || second == 'scissors')
  elsif first == 'paper'
    (second == 'rock' || second == 'spock')
  elsif first == 'scissors'
    (second == 'paper' || second == 'lizard')
  elsif first == 'lizard'
    (second == 'spock' || second == 'paper')
  elsif first == 'spock'
    (second == 'rock' || second == 'scissors')
  end
end

def assign_results(player, computer, details)
  details[:player][:winner] = false
  details[:computer][:winner] = false

  if win?(player, computer)
    details[:player][:winner] = true
  elsif win?(computer, player)
    details[:computer][:winner] = true
  end
end

def display_results(details)
  if details[:player][:winner]
    prompt("You won!")
  elsif details[:computer][:winner]
    prompt("Computer won!")
  else
    prompt("It's a tie!")
  end
end

def compute_score(player, computer, details)
  if win?(player, computer)
    details[:player][:score] += 1
  elsif win?(computer, player)
    details[:computer][:score] += 1
  end
end

def grand_winner_yet?(details)
  if details[:player][:score] == 5
    true
  elsif details[:computer][:score] == 5
    true
  else
    false
  end
end

def get_grand_winner(details)
  if details[:player][:score] == 5
    'You are'
  elsif details[:computer][:score] == 5
    'The Computer is'
  end
end

grand_winner = nil

loop do
  print `clear`
  puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  puts "First person to reach 5 wins is the grand winner."
  puts "The scores are: "
  puts "Player: #{details[:player][:score]}" \
    " Computer: #{details[:computer][:score]}"

  choice = ''
  loop do
    prompt("Choose one: #{VALID_CHOICES.join(', ')}")
    prompt("Shortened: #{VALID_SHORTENED.join(',      ')}")
    choice = Kernel.gets().chomp()

    if valid_long?(choice)
      break
    elsif valid_short?(choice)
      choice = convert_to_long(choice)
      break
    else
      prompt("That's not a valid choice.")
    end
  end

  computer_choice = VALID_CHOICES.sample()

  Kernel.puts("You chose: #{choice}; Computer chose: #{computer_choice}")

  assign_results(choice, computer_choice, details)

  display_results(details)

  compute_score(choice, computer_choice, details)

  if grand_winner_yet?(details) == false
    puts "Press any key to proceed"
    gets
  else
    grand_winner = get_grand_winner(details)
  end

  break if grand_winner_yet?(details)
end

prompt("Thank you for playing. #{grand_winner} the Grand Winner!")
