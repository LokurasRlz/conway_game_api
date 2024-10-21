class Board < ApplicationRecord
  has_many :generations, dependent: :destroy

  # Save the initial generation when the board is created
  after_create :save_initial_generation

  def next_generation
    current_state = generations.last.state
    next_state = compute_next_state(current_state)
    generations.create!(state: next_state, step: generations.count)
  end

  def state_at_step(step)
    generations.find_by(step: step)
  end

  def final_state(max_steps)
    max_steps.times do
      break if stable_state?

      next_generation
    end

    stable_state? ? generations.last.state : { error: "Board did not reach a stable state" }
  end

  private

  def save_initial_generation
    generations.create!(state: initial_state, step: 0)
  end

  # Implement Conway's Game of Life rules
  #
  def compute_next_state(current_state)
    #     Rules of Conway's Game of Life:
    #
    # A live cell with fewer than 2 live neighbors dies (underpopulation).
    # A live cell with 2 or 3 live neighbors survives to the next generation.
    # A live cell with more than 3 live neighbors dies (overpopulation).
    # A dead cell with exactly 3 live neighbors becomes a live cell (reproduction).
    #
    # Steps:
    #
    # Parse the current state from a string format into a 2D array.
    # Apply the Game of Life rules to compute the next generation.
    # Convert the resulting state back into a string for storage.


    board = parse_state(current_state)
    rows = board.size
    cols = board[0].size

    next_board = Array.new(rows) { Array.new(cols) }

    (0...rows).each do |r|
      (0...cols).each do |c|
        # live_neighbors = count_live_neighbors(board, r, c)
        live_neighbors = live_neighbor_count(board, r, c)
        next_board[r][c] = cell_next_state(board[r][c], live_neighbors)

        # if board[r][c] == 1
        #   # Live cell rules
        #   next_board[r][c] = live_neighbors.between?(2, 3) ? 1 : 0
        # else
        #   # Dead cell rules
        #   next_board[r][c] = live_neighbors == 3 ? 1 : 0
        # end
      end
    end

    convert_state_to_string(next_board)
  end

  # Determines the next state of a cell based on its current state and live neighbors
  def cell_next_state(current_state, live_neighbors)
    if current_state == 1
      live_neighbors.between?(2, 3) ? 1 : 0 # Live cell dies unless it has 2 or 3 neighbors
    else
      live_neighbors == 3 ? 1 : 0 # Dead cell becomes live if exactly 3 neighbors
    end
  end

  # Parse the state from a string into a 2D array
  def parse_state(state_string)
    state_string.split("\n").map { |row| row.split("").map(&:to_i) }
  end

  # Convert the state from a 2D array back to a string
  def convert_state_to_string(board)
    board.map { |row| row.join("") }.join("\n")
  end

  # Count live neighbors of a cell at (row, col)
  def count_live_neighbors(board, row, col)
    neighbors = [ -1, 0, 1 ]
    rows = board.length
    cols = board[0].length

    live_neighbors = 0

    neighbors.each do |i|
      neighbors.each do |j|
        next if i == 0 && j == 0

        new_row = row + i
        new_col = col + j

        if new_row >= 0 && new_row < rows && new_col >= 0 && new_col < cols
          live_neighbors += 1 if board[new_row][new_col] == 1
        end
      end
    end

    live_neighbors
  end

  # Optimized count of live neighbors
  def live_neighbor_count(board, row, col)
    rows, cols = board.size, board[0].size
    deltas = [ -1, 0, 1 ]

    neighbors = deltas.product(deltas) - [ [ 0, 0 ] ] # All surrounding cells except itself
    neighbors.sum do |dx, dy|
      r, c = row + dx, col + dy
      r.between?(0, rows - 1) && c.between?(0, cols - 1) && board[r][c] == 1 ? 1 : 0
    end
  end

  def stable_state?
    generations.count >= 2 && generations.last.state == generations.second_to_last.state
  end
end
