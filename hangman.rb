require "json"

class Dictionary

	def initialize
		@dictionary = File.readlines"5desk.txt"
		@modified_dictionary = get_appropriate_words(@dictionary)
	end

	#makes a modified dictionary that includes all the words
	#that are 5 to 12 characters long from the dictionary file
	def get_appropriate_words(dictionary)
		new_dictionary = []
		dictionary.each do |word|
			word.gsub!("\r\n","")
			if word.length >= 5 and word.length <= 12
				new_dictionary << word
			end
		end
		new_dictionary
	end

	#returns a random word from the modified dictionary
	def random_word
		number = rand(@modified_dictionary.length)
		@modified_dictionary[number]
	end
end

class Game

	def initialize
		@dictionary = Dictionary.new
		clear_screen
		menu
	end

	#clears the screen
	def clear_screen
		system "clear" or system "cls"
	end

	#displays the main menu, takes input, acts accordingly
	def menu
		puts "--------"
		puts "Hangman!"
		puts "--------"
		puts "Main Menu"
		puts ""
		puts "Enter one of the following:"
		puts "New"
		if @blank_word_array
			puts "Resume"
			puts "Save"
		end
		puts "Load"
		puts "Quit"
		puts ""
		input = gets.chomp.downcase 
		case input
		when 'new'
			clear_screen
			set_game_variables
			game_engine
		when 'resume'
			clear_screen
			game_engine
		when 'save'
			to_json
			clear_screen
			puts ">Game saved<"
			menu
		when 'load'
			from_json
			clear_screen
			puts ">Game loaded<"
			game_engine
		when 'quit'
			abort(">Exiting game<")
		else
			clear_screen
			error
			menu
		end
	end


	#sets are the variables that a used throughout one game
	def set_game_variables
		word = @dictionary.random_word
		@answer_array = word.split('')
		@blank_word_array = []
		word.length.times do 
			@blank_word_array << "_"
		end
		@guess_counter = 6
		@incorrect_array = []
	end

	#loads a previously saved game's variables 
	def from_json
		data = JSON.load File.read("save.json")
		@answer_array = data["answer_array"]
		@blank_word_array = data["blank_word_array"]
		@guess_counter = data["guess_counter"]
		@incorrect_array = data["incorrect_array"]
	end		


	#asks the user for a letter, and then checks the user's input
	#to make sure it is valid
	def get_input
		good_input = false
		until good_input
			puts ""
			puts "Enter a letter or enter 'Menu' to open the Main Menu"
			input = gets.chomp
			if @incorrect_array.include?(input) or @blank_word_array.include?(input)
				puts "You already guessed '#{input}'"
			elsif input.downcase == "menu"
					clear_screen
					menu
			elsif input.length > 1
				puts "You can't guess more than one letter at a time"
			elsif input == ''
							
			else
				good_input = true
			end
		end
		input
	end

	#checks to see if the answer includes the user's guess and adds 
	#that guess to the proper location in the blank_word_array
	def check_for_guess(input)
		have_input = false
		array_counter = 0
		@answer_array.each do |letter|
			if letter.downcase == input.downcase
				@blank_word_array[array_counter] = letter
				have_input = true
			end
			array_counter += 1
		end
		unless have_input
			@incorrect_array << input
			@guess_counter -= 1
			puts "There aren't any '#{input}'s"
		end
	end

	#shows guesses left, incorrect guesses, and the answer so far
	def show_current_info
		puts "--------"
		puts "Hangman!"
		puts "--------"
		puts "Wrong guesses left: #{@guess_counter}"
		puts "Answer does not inlcude: "
		puts @incorrect_array.join(', ')
		puts ""
		puts "--------------------"
		puts @blank_word_array.join(' ')
		puts "--------------------"
	end

	#ends the game whether the user wins a loses
	def end_of_game
		puts ""
		if @guess_counter == 0
			puts "Sorry, but you are out of guesses!"
			puts "The answer is '#{@answer_array.join}'"
		else
			puts "Yes! You are correct! The answer is '#{@answer_array.join}'!"
			puts "Good job!"
		end
	end

	#askes if the user would like to play again
	def play_again
		puts ""
		puts "Would you like to play again? Press 'Y' to start a new game, or 'N' to quit."
		input = gets.chomp.upcase
		if input == 'Y'
			clear_screen
			set_game_variables
			game_engine
		elsif input == 'N'
			abort(">Exiting game<")
		else
			error
			play_again
		end
	end

	def error
		puts "*********************"
		puts "<ERROR> Invalid input"
		puts "*********************"
	end


	def to_json
		File.write("save.json", JSON.dump({
			:answer_array => @answer_array,
			:blank_word_array => @blank_word_array,
			:guess_counter => @guess_counter,
			:incorrect_array => @incorrect_array
			}))
	end

	def game_engine
		while @blank_word_array.include?("_") and @guess_counter > 0
			show_current_info
			input = get_input
			check_for_guess(input)
			clear_screen
		end
		show_current_info
		end_of_game
		play_again
	end
end

game = Game.new
