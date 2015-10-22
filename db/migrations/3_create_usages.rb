Sequel.migration do
	up do
			create_table :usages do
				primary_key :id
				Integer :word_id
				Integer :tag_id
				Integer :count, :default => 1
			end
	end

	down do
		drop_table :usages
	end
end
	puts "ran usages migration"
