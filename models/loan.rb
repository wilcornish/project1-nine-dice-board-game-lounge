require_relative('../db/sql_runner.rb')
require_relative('./customer.rb')
require_relative('./game.rb')

class Loan

  attr_reader( :id, :game_id, :customer_id, :returned, :day_borrowed)

  def initialize( options )
    @id = options['id'].to_i if options['id']
    @customer_id = options['customer_id']
    @game_id = options['game_id']
    @returned = false
    @day_borrowed = options['day_borrowed']
  end

  def return_game
    @returned = true
  end

  def save()
    sql = "INSERT INTO loans
    (
      customer_id,
      game_id,
      returned,
      day_borrowed
    )
    VALUES
    (
      $1, $2, $3, $4
    )
    RETURNING id"
    values = [@customer_id, @game_id, @returned, @day_borrowed]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def update()
    sql = "UPDATE loans
      SET (customer_id, game_id, returned, day_borrowed)
      = ($1, $2, $3, $4)
      WHERE ID = $5"
    values = [@customer_id, @game_id, @returned, @day_borrowed, @id]
    SqlRunner.run()
  end

  def self.all()
    sql = "SELECT * FROM loans"
    results = SqlRunner.run( sql )
    return results.map {|loan| Loan.new( loan )}
  end

  def game()
    sql = "SELECT * FROM games
    WHERE id = $1"
    values = [@game_id]
    results = SqlRunner.run(sql, values)
    return Game.new(results.first)
  end

  def customer()
    sql = "SELECT * FROM customers
    WHERE id = $1"
    values = [@customer_id]
    results = SqlRunner.run(sql, values)
    return Customer.new(results.first)
  end

  def self.check_out(customer, game)
    if (customer.existing_loans?() && game.avaliable?()) == true
      new_loan = Loan.new({
        'customer_id' => customer.id(),
        'game_id' => game.id(),
        'day_borrowed' => "day"
        })
      new_loan.save
    elsif customer.existing_loans?() == false
      return "Customer has borrowed game already"
    else
      return "Game is already loaned"
    end
  end

  def self.check_in(game)
    game.increment()
    game.update()
    sql = "SELECT * FROM loans WHERE game_id = $1"
    values = [game.id()]
    loans = SqlRunner.run(sql, values)
    p loans.first
    to_return = loans.map {|loan| Loan.new( loans )}
    sql = "UPDATE loans
          SET returned = true
          WHERE id = $1;"
    values = [to_return.id()]
    SqlRunner.run(sql, values)
  end

  def return_legion()
   @returned = true
   sql = "UPDATE deployments
         SET returned = true
         WHERE id = $1;"
   values = [@id]
   SqlRunner.run(sql, values)
 end

  def self.delete_all()
    sql = "DELETE FROM loans"
    SqlRunner.run(sql)
  end

  def self.destroy(id)
    sql = "DELETE FROM loans
    WHERE id = $1"
    values = [id]
    SqlRunner.run(sql, values)
  end




end
