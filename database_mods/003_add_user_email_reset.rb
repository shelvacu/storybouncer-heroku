Sequel.migration do
  change do
    alter_table(:users) do
      add_column :reset, String, :default => nil
    end
  end
end
