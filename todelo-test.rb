require "csv"

class Todo
	attr_accessor :rating, :contents

	# allows user to set an initial rating of the todo
	# eventually we could bucket them into 3 quantiles
	def initialize(attributes = {})
		attributes.each do |key, value|
			instance_variable_set("@#{key}", value)
		end
		rating
	end

	def rating
		@rating ||= 1000		
	end
end

def return_two_todos
	todos = []
	CSV.foreach("todos3.csv") do |row|
		todos << Todo.new(contents: row[0], rating: row[1])
	end
	random_index1 = Random.new.rand(1..(todos.length)) - 1
	random_index2 = Random.new.rand(1..(todos.length)) - 1
	while random_index1 == random_index2
		random_index2 = Random.new.rand(1..(todos.length)) - 1
	end
	return [todos[random_index1], todos[random_index2]]
end

def compare(todo1, todo2)
	p "Which of the following is more important?"
	p "1: #{todo1.contents} with a current rating of #{todo1.rating}"
	p "2: #{todo2.contents} with a current rating of #{todo2.rating}"
	# response = gets.chomp.to_i
	todo1.contents > todo2.contents ? response = 1 : response = 2
	k_factor = 25
	p "response is #{response}"
	if response == 1
		p "winner_expected"
		p winner_expected = 1.0 / (1.0 + (10 ** ((todo2.rating.to_f - todo1.rating.to_f) / 400.0)))
		p "loser_expected"
		p loser_expected = 1.0 / (1.0 + (10 ** ((todo1.rating.to_f - todo2.rating.to_f) / 400.0)))
		
		# 0 for losses, 0.5 for draw (equal priority importance), and 1 for a win
		p "winner_change"
		p winner_change = k_factor.to_f * (1.0 - winner_expected.to_f)
		p "loser_change"
		p loser_change = k_factor.to_f * (0 - loser_expected.to_f)

		p "new todo1.rating"
		p todo1.rating = (todo1.rating.to_i + winner_change).to_i
		p "new todo2.rating"
		p todo2.rating = (todo2.rating.to_i + loser_change).to_i

		$todos[todo2.contents] = todo2.rating
		$todos[todo1.contents] = todo1.rating
		save_todos
	else
		p "winner_expected"
		p winner_expected = 1.0 / (1.0 + (10 ** ((todo1.rating.to_f - todo2.rating.to_f) / 400.0)))
		p "loser_expected"
		p loser_expected = 1.0 / (1.0 + (10 ** ((todo2.rating.to_f - todo1.rating.to_f) / 400.0)))

		# 0 for losses, 0.5 for draw (equal priority importance), and 1 for a win
		p "winner_change"
		p winner_change = k_factor.to_f * (1.0 - winner_expected.to_f)
		p "loser_change"
		p loser_change = k_factor.to_f * (0 - loser_expected.to_f)

		p "new todo1.rating"
		p todo1.rating = (todo1.rating.to_i + loser_change).to_i
		p "new todo2.rating"
		p todo2.rating = (todo2.rating.to_i + winner_change).to_i

		$todos[todo1.contents] = todo1.rating
		$todos[todo2.contents] = todo2.rating
		save_todos
	end
end

def save_todos
	todos_csv = CSV.open("todos3.csv", "wb", headers: true, return_headers: false) do |csv|
		$todos.each do |content, rating|
			csv << [content, rating]
		end
	end	
end

def create_or_update_todos
	# ask user to create new todo or rate current todos
	p "Push 1 for create new todo; push 2 to rate current todos; push 3 to see list of todos."
	option = gets.chomp.to_i

	if option == 1
		while true
			p "What do is your todo?"
			todo_contents = gets.chomp
			# later add an option for how important it is; maybe 1, 2, or 3
			todo = Todo.new(contents: todo_contents)
			if !$todos[todo.contents] 
				$todos[todo.contents] = todo.rating
			end
			save_todos
		end
	elsif option == 2
		# start ranking todos
		while true
			todos_to_compare = return_two_todos
			compare(todos_to_compare[0], todos_to_compare[1])
			save_todos
		end
	elsif option == 3
		show_todos
	else
		abort("Exiting program")
	end
end

def create_or_open_todos_file
	$todos = {}
	if File.exist?("todos3.csv")
		p "todos3.csv already exists, so we'll be adding todos to that."
		CSV.foreach("todos3.csv") do |row|
			$todos[row[0]] = row[1]
		end
	else
		todos_csv = CSV.open("todos3.csv", "wb", headers: true, return_headers: false) do |csv|
		end
	end
	# create_or_update_todos
end

def show_todos
	p "Here are the contents and ratings of your current todos..."
	CSV.foreach("todos3.csv") do |row|
		p row
	end
	create_or_open_todos_file	
end

# creates a todo for each letter of the alphabet with the default rating
def create_alphabet_of_todos
	$todos = {}
	('a'..'z').to_a.each do |letter|
		todo = Todo.new(contents: letter)
		if !$todos[todo.contents] 
			$todos[todo.contents] = todo.rating
		end
	end
	save_todos	
end

def rate_alphabet_todos
	create_or_open_todos_file
	todos_to_compare = return_two_todos
	compare(todos_to_compare[0], todos_to_compare[1])
	save_todos
end

def how_many_out_of_order
	count = 0
	$todos = {}
	todo_rating_arr = []
	if File.exist?("todos3.csv")
		p "todos3.csv already exists, so we'll be adding todos to that."
		CSV.foreach("todos3.csv") do |row|
			csv_letter = row[0]
			rating = row[1]
			$todos[csv_letter] = rating.to_i
			todo_rating_arr << rating.to_i
		end
	end
	# ('a'..'y').to_a.each_with_index do |letter, index|
	# 	count += 1 if $todos[letter] < $todos[letter.next]
	# end
	# count += 1 if $todos['y'] < $todos['z']
	p todo_rating_arr
	count = num_swaps(todo_rating_arr)
	p "The number of letters out of order is #{count}."
end

def num_swaps(arr)
	# uses bubble_sort
  # out_of_order = arr.length
  swaps = 0
  until arr == arr.sort
  	# p arr
  	arr.each_with_index do |val, i|
  		if i != arr.length - 1
  			p "val, i, arr[i], arr[i+1]"
  			p val, i, arr[i], arr[i+1]
	  		if val > arr[i+1] 
	  			arr[i] = arr[i+1]
	  			arr[i+1] = val
	  			p arr
  				swaps += 1
	  		end
	  	end
  	end
  end
  # p swaps
  return swaps
end

def generate_array
	arr = []
	100.times do |i|
		arr << rand(100)
		# arr << i
	end
	# arr.reverse!
	arr	
end

def get_avg_swaps(iterations)
	num_swaps = []
	iterations.times do
		arr = generate_array
		num_swaps << num_swaps(arr)
	end
	p num_swaps

	sum = 0
	num_swaps.each do |val|
		sum += val
	end
	avg = sum / num_swaps.length
	p "avg = #{avg}"	
end


### THIS DOES STUFF!
# create_or_open_todos_file

# run this (creat_alphabet_of_todos) once to create alphabet of todos
create_alphabet_of_todos
1000.times do
	rate_alphabet_todos
end

how_many_out_of_order

# get_avg_swaps(100)


### Things to do
# X make it so duplicate todos don't reset rating 
# X make it so after viewing todos, the program doesn't exit
# X fix it such that the letter a gets rated properly.
# X create todos with a to z and run compare method 100 times to and then see how ordered things are
# figure out metric to determine how out of order things are!
  # bubble_sort / num_swaps?








































# https://en.wikipedia.org/wiki/Elo_rating_system#Mathematical_details
def match(winner, loser)
	k_factor = 25
	winner_expected = 1.0 / (1.0 + (10 ** ((loser[:rating].to_f - winner[:rating].to_f) / 400.0)))
	p winner_change = k_factor.to_f * (1.0 - winner_expected.to_f)
	winner[:rating] = (winner[:rating] + winner_change).to_i
end

# 100.times do
# 	match(player1, player2)
# 	p player1[:rating]
# end