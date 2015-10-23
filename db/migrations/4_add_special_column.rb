Sequel.migration do

  up do
    add_column :words, :special, TrueClass, :default => false
  end 

  down do
    drop_column :words, :special
  end

end
