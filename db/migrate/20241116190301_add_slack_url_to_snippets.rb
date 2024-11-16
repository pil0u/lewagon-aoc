class AddSlackUrlToSnippets < ActiveRecord::Migration[7.2]
  def change
    add_column :snippets, :slack_url, :string
  end
end
