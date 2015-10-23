Sequel.migration do

  up do
    add_column :usages, :lemma_id, Integer, :default => nil
    add_column :usages, :alternative_id, Integer, :default => nil
  end
  
  down do
    drop_column :usages, :lemma_id
    drop_column :usages, :alternative_id
  end

end
