# require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        column_names = []
        sql="PRAGMA table_info('#{table_name}')"
        DB[:conn].execute(sql).map do |col|
            column_names << col["name"]
        end
        column_names.compact
    end

    def initialize (options={})
        options.map do |key, value|
            self.send("#{key}=", value)
        end
    end

    def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
        self.id=DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|col| col=='id'}.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.map do |col|
            values << "'#{send(col)}'" unless send(col).nil?
        end
        values.join(", ")
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name='#{name}'")
    end

    def self.find_by(attribute)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first}='#{attribute.values.first}'")
    end
  
end