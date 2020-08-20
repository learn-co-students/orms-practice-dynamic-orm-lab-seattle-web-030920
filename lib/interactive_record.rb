require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def initialize(hash={})
        hash.each { |property, value|
            self.send("#{property}=", value)
        }
    end

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = "PRAGMA table_info (#{self.table_name})"
        hash=DB[:conn].execute(sql)
        hash.map{|column| column["name"]}
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.select{|col| self.send("#{col}")}.join(", ")
    end

    def values_for_insert
        columns= self.class.column_names.select{|col| self.send("#{col}")}
        columns.map{|col| "'#{self.send("#{col}")}'"}.join(", ")
    end

    def save
        sql= "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name (name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
        DB[:conn].execute(sql)
    end

    def self.find_by (attribute_hash)
        key=""
        value=""
        attribute_hash.each do |k,v| 
            key=k
            value=v
        end
        formatted_value = value.class == Fixnum ? value : "'#{value}'"
        sql = "SELECT * FROM #{self.table_name} WHERE #{key}= #{formatted_value}"
        DB[:conn].execute(sql)
    end
  
end