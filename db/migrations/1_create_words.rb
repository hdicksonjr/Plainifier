Sequel.migration do
		up do 
			DB.create_table :words do
			primary_key :id
			String :name
		end
	end

	down do
		drop_table :words
	end
end

