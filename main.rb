require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack/contrib'
require "securerandom"

$json = 'json/note.json'

def json_file
  $json_info = open($json) do |file|
    JSON.load(file)
  end
end

$notes = $json_info['notes']

def find_id(id)
  $notes.find do |note|
    note["id"] == id
  end
end

def update_json(new_notes)
  File.open("json/note.json", 'r+') do |file|
    JSON.dump({"notes" => new_notes}, file)
  end
end

def add_note(note)
  update_json($notes << note)
end

def delete(id)
  update_json($notes.delete_if { |note| note["id"] == id })
end

def edit_note(patch)
  new_notes = $notes.each_with_object([]) do |note, array|
    if note["id"] == patch["id"]
      note["title"] = patch["title"]
      note["content"] = patch["content"]
    end
    array << note
  end
  update_json(new_notes)
end

get "/" do
  @notes = $notes
  erb :index
end

get "/add" do
  erb :new
end

get "/note/:id" do |id|
  @note = find_id(id)
  erb :show
end

post "/new" do
  if !params[:title].match(/\A\R|\A\z/)
    add_note(
    "id" => SecureRandom.uuid,
    "title" => params[:title],
    "content" => params[:content]
    )
    end
    redirect '/'
    erb :index
end

delete '/note/:id' do |id|
  delete(id)
  redirect '/'
  erb :index
end

get '/note/edit/:id' do |id|
  @note = find_id(id)
  erb :edit
end

patch '/note/editing/:id' do |id|
  edit_note(
    "id" => id,
    "title" => params[:title],
    "content" => params[:content]
  )
  redirect '/'
  erb :index
end
