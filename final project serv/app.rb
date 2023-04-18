require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions

db = SQLite3::Database.new("db/database.db")
db.results_as_hash = true



get '/' do
    if !session[:logged_in]
        redirect '/login'
    else
        @admin = db.execute("SELECT username FROM users WHERE id = ?", 22)
        @username1 = db.execute("SELECT username FROM users WHERE id = ?", session[:id])
        if  @username1 == @admin
            @notes = db.execute("SELECT * FROM ((relation INNER JOIN notes ON relation.notes_id = notes.id) INNER JOIN genres ON relation.genre_id2 = genres.id)") 
            @notes2 = db.execute("SELECT * FROM ((relation INNER JOIN notes ON relation.notes_id = notes.id) INNER JOIN genres ON relation.genre_id = genres.id)") 
          
          
          
          
          
            # @boom = db.execute("SELECT genre_id2 from relation where notes_id = ?", session[:id])
           # @boom = db.execute("SELECT * FROM (INNER JOIN genres ON relation.genre_id = genres.id)")
           # @genre2 = db.execute("SELECT genre FROM genres Where id = ?", @boom)
           p @genre2
           
 

            p @notes2.length

            for o in @notes2
                p o
            end
            p @genre2
            slim(:notes)
        else
            @notes2 = db.execute("SELECT * FROM ((relation INNER JOIN notes ON relation.notes_id = notes.id) INNER JOIN genres ON relation.genre_id2 = genres.id) WHERE author_id = ?", session[:id]) 
            @notes = db.execute("SELECT * FROM  ((relation INNER JOIN notes ON relation.notes_id = notes.id) INNER JOIN genres ON relation.genre_id = genres.id) WHERE author_id = ?", session[:id])
  
           
   
           
 
           
      
            slim(:notes)
        end
        
    end
end

post '/notes' do
    content = params[:content]
    genre_id = params[:genre_id]
    genre_id2 = params[:genre_id2]
    name = params[:name]

    db.execute("INSERT INTO notes (content, name, author_id) VALUES (?, ?, ?)", content, name, session[:id])
    notes_id = db.execute("SELECT id FROM notes ORDER BY id DESC LIMIT 1")  

    db.execute("INSERT INTO relation (genre_id, genre_id2, notes_id) VALUES (?, ?, ?)", genre_id,  genre_id2, notes_id[0]["id"])

    

    redirect '/'
end

get '/logout' do
    session.delete(:logged_in)
    session.delete(:id)
    session.delete(:username)

    redirect '/'
end

get('/delete/:id') do
    id = params[:id]

    db.execute("DELETE FROM notes WHERE id = ?", id)

    redirect '/'
end



post "/updates/:id" do
    content = params[:content]
    genre_id = params[:genre_id]
    genre_id2 = params[:genre_id2]

    name = params[:name]
    id = params[:id]
 

    db.execute("UPDATE notes SET content = ? WHERE id = ?",content, id )
    db.execute("UPDATE notes SET name = ? WHERE id = ?",name, id )
    db.execute("UPDATE relation SET genre_id = ? WHERE notes_id = ?",genre_id, id )
    db.execute("UPDATE relation SET genre_id2 = ? WHERE notes_id = ?",genre_id2, id )


    redirect '/'
end

get '/update/:id/:name/:content/:genre_id/:genre_id2' do
    content = params[:content]
    genre_id = params[:genre_id]
    genre_id2 = params[:genre_id2]
    name = params[:name]
    id = params[:id]





    session[:todoId] = id

    @name = name 
    @content = content
    @genre_id = genre_id
    @genre_id2 = genre_id2
   
   

    slim(:update, locals: {id: session[:todoId]})
   
end

get '/login' do
    slim(:login)
end

get '/signup' do
    slim(:signup)
end

post '/signup' do
    username = params[:username]
    password = params[:password]
    password_repeat = params[:password_repeat]

    if password != password_repeat
       redirect "/signup"
      
    else 
        db.execute("INSERT INTO users (username, password) VALUES (?, ?)", username, BCrypt::Password.create(password))

        redirect '/login'

    end

   
end

post '/login' do
    username = params[:username]
    password = params[:password]
    @username = params[:username]

    result = db.execute("SELECT id, password FROM users WHERE username = ?", username)
    
    if result.length == 0
        redirect '/login'

    else 
        print(result)
        print(password)
    
        print(result.first["password"])
    
        hashed_pass = BCrypt::Password.new(result.first["password"])
    
        print(hashed_pass)
    
        if hashed_pass == password
            session[:id] = result.first["id"]
            session[:username] = username
            session[:logged_in] = true
        end
    
        redirect '/'
        
    end

end
