require "csv"

class Todo
	attr_accessor :rating

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

if File.exist?("todos.csv")
	p "todos.csv already exists, so we'll be adding todos to that."
else
	todos_csv = CSV.open("todos.csv", "wb", headers: true, return_headers: false) do |csv|
	  csv << ["contents", "rating"]
	end
end

# ask user to create new todo or rate current todos
p "Push 1 for create new todo; push 2 to rate current todos."
option = gets.chomp.to_i

if option == 1
	p "What do is your todo?"
	todo_contents = gets.chomp
	# later add an option for how important it is; maybe 1, 2, or 3
	todo = Todo.new(contents: todo_contents)
	CSV.open("todos.csv", "a+") do |csv|
		csv << [todo_contents, todo.rating]
	end
end

if option == 2
	# start ranking todos
	todos = []
	while true
		CSV.foreach("todos.csv") do |row|
			todos << row
		end

		p todos[1..Random.new.rand(todos.length)-1]
		p todos[1..Random.new.rand(todos.length)-1]
		break
	end
end

p 'Here are the contents and ratings of your current todos...'
CSV.foreach("todos.csv") do |row|
	p row
end
























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