require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack/contrib'
require "securerandom"

def json_file
  json = 'json/note.json'
  json_info = open(json) do |file|
    JSON.load(file)
  end
  notes = json_info['notes']
end

def find_id(id)
  json_file.find do |note|
    note["id"] == id
  end
end

def update_json(new_notes)
  File.open("json/note.json", 'r+') do |file|
    JSON.dump({"notes" => new_notes}, file)
  end
end

def new_note(note)
  update_json(json_file << note)
end

def delete_note(id)
  update_json(json_file.delete_if { |note| note["id"] == id })
end

def edit_note(patch)
  new_notes = json_file.each_with_object([]) do |note, array|
    if note["id"] == patch["id"]
      note["title"] = patch["title"]
      note["content"] = patch["content"]
    end
    array << note
  end
  update_json(new_notes)
end

get "/" do
  @notes = json_file
  erb :index
end

get "/new" do
  erb :new
end

get "/note/:id" do |id|
  @note = find_id(id)
  erb :show
end

post "/create" do
  # if no title then display new memo1 or something
  if !params[:title].match(/\A\R|\A\z/)
    new_note(
    "id" => SecureRandom.uuid,
    "title" => params[:title],
    "content" => params[:content]
    )
    end
    redirect '/'
    erb :index
end

delete '/note/:id' do |id|
  delete_note(id)
  redirect '/'
  erb :index
end

get '/note/edit/:id' do |id|
  @note = find_id(id)
  erb :edit
end

patch '/note/update/:id' do |id|
  edit_note(
    "id" => id,
    "title" => params[:title],
    "content" => params[:content]
  )
  redirect '/'
  erb :index
end
