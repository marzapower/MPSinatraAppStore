require 'sequel'

# The default database is placed in the db.sqlite file under the
# current folder. This can be changed via the DATABASE_URL
# environment variable
DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db.sqlite')

## Uncomment this line to erase the database for testing purposes
#DB.drop_table :purchase

unless DB.tables.include? :purchase
  DB.create_table :purchase do
    Date :bought_at
    Date :expires_at
    String :product_identifier
    String :device_id
  end
end