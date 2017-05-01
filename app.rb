require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require_relative 'cookbook'    # You need to create this file!
require_relative "recipes.rb"
require 'csv'

csv_file   = File.join(__dir__, 'recipes.csv')
cookbook   = Cookbook.new(csv_file)

# controller = Controller.new(cookbook)


configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  erb :index, :layout => :layout
end

get '/about' do
  erb :about
end

get '/list' do
  cookbook.all
  # Pass the list of all recipes to the view
  # @view.display_all(cookbook)
  erb :display_all, :locals => {cookbook: cookbook}
end

get '/create' do
  erb :create
end

post "/createSubmit" do
  recipe_name = params["name"]
  # Get the recipes description from the user
  description = params["description"]
  # Create the new recipe
  new_recipe = Recipe.new(recipe_name, description)
  # Add the new recipe to the repo
  cookbook.add_recipe(new_recipe)
  redirect "/list"
end

get '/destroy/:i' do
  cookbook.remove_recipe(params["i"].to_i)
  redirect "/list"
end


class Cookbook # CookbookRepository
  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
    @cookbook = []
    load
    # save
  end

  def all
    return @cookbook
  end

  def add_recipe(recipe)
    @cookbook << recipe
    CSV.open(@csv_file_path, 'w') do |csv|
      @cookbook.each do |recip|
        csv << [recip.name, recip.description]
      end
    end
  end

  def remove_recipe(index)
    @cookbook.delete_at(index)
    CSV.open(@csv_file_path, 'w') do |csv|
      @cookbook.each do |recipe|
        csv << [recipe.name, recipe.description]
      end
    end
  end

  # def save
  #   CSV.open(@csv_file_path, 'w') do |csv|
  #     @cookbook.each do |recipe|
  #       csv << [recipe.name, recipe.description]
  #     end
  #   end
  # end

  private

  def load
    @csv_options = { col_sep: ',', quote_char: '"' }
    CSV.foreach(@csv_file_path, @csv_options) do |row|
      @cookbook << Recipe.new(row[0], row[1])
    end
  end
end

class Recipe

  def initialize(name, description)
    @name = name
    @description = description
  end

end







