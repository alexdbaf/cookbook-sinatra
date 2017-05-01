require_relative "recipes.rb"
require 'csv'

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

  def save
    CSV.open(@csv_file_path, 'w') do |csv|
      @cookbook.each do |recipe|
        csv << [recipe.name, recipe.description]
      end
    end
  end

  private

  def load
    @csv_options = { col_sep: ',', quote_char: '"' }
    CSV.foreach(@csv_file_path, @csv_options) do |row|
      @cookbook << Recipe.new(row[0], row[1])
    end
  end
end
