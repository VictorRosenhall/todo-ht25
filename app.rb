require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'



# Funktion för att prata med databasen
# Exempel på användning: db.execute('SELECT * FROM todos')
def db
  return @db if @db

  @db = SQLite3::Database.new(DB_PATH)
  @db.results_as_hash = true

  return @db
end

# Routen /
get('/') do

  slim(:index)
end

get('/todos') do
  db = SQLite3::Database.new("db/todos.db")
  #ge oss hashes ist för arrayer [{}, {}, {}]
  db.results_as_hash = true

  #Använd SQL för att kommunicera med db och också hämta allt från db

  query=params[:q]

  if query && !query.empty?
    @todos = db.execute("SELECT * FROM todos WHERE name LIKE ?", "%#{query}%")
  else 
    @todos = db.execute("SELECT * FROM todos")
  end
  slim(:index)
end

post('/todos/:id/delete') do
  db = SQLite3::Database.new('db/todos.db') # koppling till databasen
  #extrahera id för att få rätt frukt
  denna_ska_bort = params[:id]
  #ta bort från db
  db.execute("DELETE FROM todos WHERE id = ?", [denna_ska_bort])
  redirect('/todos')
end

get('/todos/:id/edit') do
  db = SQLite3::Database.new("db/todos.db")
  db.results_as_hash = true

  id = params[:id].to_i
  @todo = db.execute("SELECT * FROM todos WHERE id = ?", [id]).first

  slim(:edit)
end

post('/todos/:id/update') do
  db = SQLite3::Database.new("db/todos.db")

  id = params[:id].to_i
  name = params[:name]
  description = params[:description]

  db.execute("UPDATE todos SET name=?, description=? WHERE id=?", [name, description, id])

  redirect('/todos')
end

post('/todos') do
  db = SQLite3::Database.new("db/todos.db")
  name = params[:q]
  description = params[:description]
  db.execute("INSERT INTO todos (name, description) VALUES (?, ?)", [name, description])
  redirect('/todos')
end
