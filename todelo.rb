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
	CSV.foreach("todos.csv") do |row|
		todos << Todo.new(contents: row[0], rating: row[1])
	end
	random_index1 = Random.new.rand(1..(todos.length-1))
	random_index2 = Random.new.rand(1..(todos.length-1))
	while random_index1 == random_index2
		random_index2 = Random.new.rand(1..(todos.length-1))
	end
	return [todos[random_index1], todos[random_index2]]
end

def compare(todo1, todo2)
	p "Which of the following is more important?"
	p "1: #{todo1.contents}"
	p "2: #{todo2.contents}"
	response = gets.chomp.to_i
	k_factor = 25
	if response == 1
		winner_expected = 1.0 / (1.0 + (10 ** ((todo2.rating.to_f - todo1.rating.to_f) / 400.0)))
		winner_change = k_factor.to_f * (1.0 - winner_expected.to_f)
		p todo1.rating = (todo1.rating.to_i + winner_change).to_i

		loser_expected = 1.0 / (1.0 + (10 ** ((todo1.rating.to_f - todo2.rating.to_f) / 400.0)))
		loser_change = k_factor.to_f * (1.0 - loser_expected.to_f)
		p todo2.rating = (todo2.rating.to_i - loser_change).to_i
	else
		winner_expected = 1.0 / (1.0 + (10 ** ((todo1.rating.to_f - todo2.rating.to_f) / 400.0)))
		winner_change = k_factor.to_f * (1.0 - winner_expected.to_f)
		p todo1.rating = (todo2.rating.to_i + winner_change).to_i

		loser_expected = 1.0 / (1.0 + (10 ** ((todo2.rating.to_f - todo1.rating.to_f) / 400.0)))
		loser_change = k_factor.to_f * (1.0 - loser_expected.to_f)
		p todo1.rating = (todo1.rating.to_i - loser_change).to_i
	end
end

def save_todos
	
	todos_csv = CSV.open("todos.csv", "wb", headers: true, return_headers: false) do |csv|
		csv << ["contents", "rating"]
		$todos.each do |todo|
			csv << [todo.contents, todo.rating]
		end
	end	
end

def create_or_update_todos
	# ask user to create new todo or rate current todos
	p "Push 1 for create new todo; push 2 to rate current todos."
	option = gets.chomp.to_i

	if option == 1
		p "What do is your todo?"
		p todo_contents = gets.chomp
		# later add an option for how important it is; maybe 1, 2, or 3
		p todo = Todo.new(contents: todo_contents)
		# CSV.open("todos.csv", "a+") do |csv|
		# 	csv << [todo_contents, todo.rating]
		# end
		p 'about to p todo'
		p todo
		$todos << todo
	elsif option == 2
		# start ranking todos
		while true
			p todos_to_compare = return_two_todos
			compare(todos_to_compare[0], todos_to_compare[1])
			break
		end
		save_todos
	end
end

def create_or_open_todos_file
	$todos = []
	if File.exist?("todos.csv")
		p "todos.csv already exists, so we'll be adding todos to that."
		CSV.foreach("todos.csv") do |row|
			$todos << Todo.new(contents: row[0], rating: row[1])
		end
	else
		todos_csv = CSV.open("todos.csv", "wb", headers: true, return_headers: false) do |csv|
			csv << ["contents", "rating"]
		end
	end
end

def show_todos
	p "Here are the contents and ratings of your current todos..."
	CSV.foreach("todos.csv") do |row|
		p row
	end	
end

create_or_open_todos_file
create_or_update_todos
show_todos





































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