Sequel.migration do
		up do 
			DB.create_table :tags do
			primary_key :id
			String :name
		end
	end

	down do
		drop_table :tags
	end
end
		puts "ran tags migration"
