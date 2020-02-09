def prompt(message)
  Kernel.puts("=> #{message}")
end

def float?(num)
  !!Float(num)
rescue ArgumentError
  false
end

def integer?(num)
  !!Integer(num)
rescue ArgumentError
  false
end

def get_monthly_payment(loan_amount, annual_interest_rate,
                        duration, details)
  monthly_interest_rate = annual_interest_rate / 12

  details[:monthly_payment] = if monthly_interest_rate == 0
                                loan_amount / duration
                              else
                                loan_amount *
                                  ((monthly_interest_rate / 100) /
                                  (1 - (1 + (monthly_interest_rate / 100))**
                                  -duration))
                              end

  details[:monthly_payment] = details[:monthly_payment].round(2)
end

def get_payment_breakdown(loan_amount, duration, details)
  details[:monthly_principal] = (loan_amount / duration).round(2)

  details[:monthly_interest] = (details[:monthly_payment] -
  details[:monthly_principal]).round(2)

  details[:total_paid] = (details[:monthly_payment] * duration).round(2)
  details[:total_interest] = (details[:total_paid] - loan_amount).round(2)
end

loop do
  print `clear`
  prompt("Welcome to the Car Loan Calculator!")

  details = {}

  loan_amount = ''
  loop do
    prompt("What's the loan amount?")
    loan_amount = Kernel.gets().chomp().to_i
    # checking for amount being greater than zero,
    # v/s being equal to or greater than zero for interest rate.
    if float?(loan_amount)
      if Float(loan_amount) > 0
        loan_amount = Float(loan_amount)
        break
      else
        prompt("Sorry! Please enter a valid number.")
      end
    else
      prompt("Sorry! Please enter a valid number.")
    end
  end

  annual_interest_rate = ''
  loop do
    prompt("What's the annual interest rate? Enter 5.4 for 5.4%")
    annual_interest_rate = Kernel.gets.chomp()
    if float?(annual_interest_rate)
      if Float(annual_interest_rate) >= 0
        annual_interest_rate = Float(annual_interest_rate)
        break
      else
        prompt("Sorry! Please enter a valid number greater than or equal" \
        " to zero.")
      end
    elsif annual_interest_rate.match(/\%/)
      # parsing for when user enters % sign with interest rate
      annual_interest_rate.chomp!('%')
      if float?(annual_interest_rate) && Float(annual_interest_rate) >= 0
        annual_interest_rate = Float(annual_interest_rate)
        break
      end
    else
      prompt("Sorry! Please enter a valid number greater than or" \
        " equal to zero.")
    end
  end

  years = 0
  months = 0
  loop do
    prompt("What's the duration of the loan? (in years)")
    years = Kernel.gets().chomp()
    if integer?(years)
      if Integer(years) > 0
        years = Integer(years)
        break
      else
        prompt("Sorry! Please enter a valid positive integer.")
      end
    else
      prompt("Sorry! Please enter a valid positive integer.")
    end
  end

  loop do
    prompt("What's the duration of the loan? (in months)")
    months = Kernel.gets().chomp()
    if integer?(months)
      # using cover instead of range because of Rubocop's suggestion.
      if (0..12).cover?(Integer(months))
        months = Integer(months)
        break
      else
        prompt("Sorry! Please enter a valid integer between 0 and 12.")
      end
    else
      prompt("Sorry! Please enter a valid integer between 0 and 12.")
    end
  end

  months_total = years * 12 + months

  get_monthly_payment(loan_amount, annual_interest_rate,
                      months_total, details)

  get_payment_breakdown(loan_amount, months_total, details)

  prompt("Your monthly payment is #{details[:monthly_payment]}")
  prompt("Your monthly principal paid is #{details[:monthly_principal]}")
  prompt("Your monthly interest is " \
    "#{details[:monthly_interest]}")
  prompt("You pay #{details[:total_paid]} over " \
    " a period of #{months_total} months.")
  prompt("Your total interest paid is #{details[:total_interest]}")

  continue = ''
  loop do
    prompt("Do you want to do another calculation? (Y/N)")
    continue = Kernel.gets().chomp()

    if continue.downcase == 'y' || continue.downcase == 'n'
      break
    else
      puts "Please enter either Y or N."
    end
  end

  break unless continue.downcase == 'y'
end
