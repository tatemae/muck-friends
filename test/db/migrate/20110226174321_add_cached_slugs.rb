class AddCachedSlugs < ActiveRecord::Migration
  def self.up
    add_column :contents, :cached_slug, :string
    add_index  :contents, :cached_slug
  end

  def self.down
    remove_column :contents, :cached_slug
  end
end