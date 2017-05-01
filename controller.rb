require_relative "cookbook.rb"
require_relative "recipes.rb"
require 'csv'


require 'fatsecret'
FatSecret.init("3808973e9a654b9f8241056aad578a91","0d11a349851d4a05a13534314d85d1db")


class Controller
  def initialize(cookbook)
    @cookbook = cookbook
  end

  def list
    # Ask the list of all recipes
    cookbook = @cookbook.all
    # Pass the list of all recipes to the view
    @view.display_all(cookbook)
  end

  def create
    # Get recipe's name
    recipe_name = @view.ask_user_for_name
    # Get the recipes description from the user
    description = @view.ask_user_for_description
    # Create the new recipe
    new_recipe = Recipe.new(recipe_name, description)
    # Add the new recipe to the repo
    @cookbook.add_recipe(new_recipe)
  end

  def destroy
    # Display the list of recipes
    list
    # Get the recipe's id from the user
    index = @view.ask_user_for_index
    # Find the right recipe in my repo
    @cookbook.remove_recipe(index)
  end

  def save
    @cookbook.save
    @view.saved
  end

  def searchrecipe
    # We ask the user which food does he want in its recipe
    food = @view.ask_user_for_food
    # We are searching for a recipe containing the food
    search_result = FatSecret.search_recipes(food, 5)
    # We are storing the recipe description with an index number
    id_index = {}
    search_result["recipes"]["recipe"].each_with_index do |recipe, index|
       id_index[index + 1] = recipe["recipe_id"]
      end
    # We are storing the descriptions into an array that we will display to the user
    descriptions = search_result["recipes"]["recipe"].map do |recipe|
      recipe["recipe_description"]
      end
    # We are asking the user for the index of the recipe he wants and makes it corresponds to a recipe ID
    choosen_recipe = FatSecret.recipe(id_index[@view.user_select_recipe(descriptions)])
    # We are creating the new recipe
    @calories = choosen_recipe["recipe"]["serving_sizes"]["serving"]["calories"]
    recipe_name = choosen_recipe["recipe"]["recipe_name"]
    description = choosen_recipe["recipe"]["recipe_description"]
    new_recipe = Recipe.new(recipe_name, description )
    # Add the new recipe to the repo
    @cookbook.add_recipe(new_recipe)
  end
end
