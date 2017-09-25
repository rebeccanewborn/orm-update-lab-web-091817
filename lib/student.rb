require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade)
    @id = nil
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    persisted? ? update : insert
  end

  def insert
    sql = <<-SQL
      INSERT INTO students (name, grade) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    sql = <<-SQL
      SELECT*FROM students WHERE name = ?
    SQL
    student = DB[:conn].execute(sql, self.name)[0]
    @id = student[0]
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, grade, id)
  end

  def persisted?
    !!@id
  end

  def self.create(name, grade)
    new(name, grade).tap {|student| student.save }
  end

  def self.new_from_db(row)
    student = new(row[1], row[2]).tap {|student|
      student.id = row[0]}
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    new_from_db(row)
  end



end
