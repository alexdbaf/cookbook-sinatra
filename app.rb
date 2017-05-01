require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require_relative 'cookbook'    # You need to create this file!
require_relative "recipes.rb"
require 'csv'
require "fatsecret"
FatSecret.init("3808973e9a654b9f8241056aad578a91","0d11a349851d4a05a13534314d85d1db")


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

get '/search' do
  if !params["q"].nil?
    food = params["q"]
    # We are searching for a recipe containing the food
    search_result = FatSecret.search_recipes(food, 5)
    # We are storing the recipe description withpa an index number
    id_index = {}
    @q = food
    search_result["recipes"]["recipe"].each_with_index do |recipe, index|
       id_index[index] = recipe["recipe_id"]
      end
    # We are storing the descriptions into an array that we will display to the user
    descriptions = search_result["recipes"]["recipe"].map do |recipe|
      recipe["recipe_description"]
      end
    @recipe_image = search_result["recipes"]["recipe"].map do |recipe|
        recipe["recipe_image"]
      end

    @id_index = id_index
    @description = descriptions
    # We are asking the user for the index of the recipe he wants and makes it corresponds to a recipe ID
      if !params["id"].nil?
        choosen_recipe = FatSecret.recipe(id_index[params["id"].to_i])
        # # We are creating the new recipe
        # calories = choosen_recipe["recipe"]["serving_sizes"]["serving"]["calories"]
        recipe_name = choosen_recipe["recipe"]["recipe_name"]
        description = choosen_recipe["recipe"]["recipe_description"]
        new_recipe = Recipe.new(recipe_name, description )
        # Add the new recipe to the repo
        cookbook.add_recipe(new_recipe)
        redirect "/list"
      end
  else
    @id_index = []
    @description = []
  end
  erb :search
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


  # def searchrecipe
  #   # We ask the user which food does he want in its recipe
  #   food = @view.ask_user_for_food
  #   # We are searching for a recipe containing the food
  #   search_result = FatSecret.search_recipes(food, 5)
  #   # We are storing the recipe description with an index number
  #   id_index = {}
  #   search_result["recipes"]["recipe"].each_with_index do |recipe, index|
  #      id_index[index + 1] = recipe["recipe_id"]
  #     end
  #   # We are storing the descriptions into an array that we will display to the user
  #   descriptions = search_result["recipes"]["recipe"].map do |recipe|
  #     recipe["recipe_description"]
  #     end
  #   # We are asking the user for the index of the recipe he wants and makes it corresponds to a recipe ID
  #   choosen_recipe = FatSecret.recipe(id_index[@view.user_select_recipe(descriptions)])
  #   # We are creating the new recipe
  #   @calories = choosen_recipe["recipe"]["serving_sizes"]["serving"]["calories"]
  #   recipe_name = choosen_recipe["recipe"]["recipe_name"]
  #   description = choosen_recipe["recipe"]["recipe_description"]
  #   new_recipe = Recipe.new(recipe_name, description )
  #   # Add the new recipe to the repo
  #   @cookbook.add_recipe(new_recipe)
  # end
