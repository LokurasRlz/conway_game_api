class Api::V1::BoardsController < ApplicationController
  before_action :set_board, only: [ :show, :next_state, :state_at_step, :final_state ]

  def create
    board = Board.new(board_params)
    if board.save
      render json: { id: board.id }, status: :created
    else
      render json: { errors: board.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @board.generations.first.state
  end

  def next_state
    @board.next_generation
    render json: @board.generations.last.state
  end

  def state_at_step
    generation = @board.state_at_step(params[:step].to_i)
    if generation
      render json: generation.state
    else
      render json: { error: "Step not found" }, status: :not_found
    end
  end

  def final_state
    result = @board.final_state(params[:max_steps].to_i)
    render json: result
  end

  private

  def set_board
    @board = Board.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Board not found" }, status: :not_found
  end

  def board_params
    params.require(:board).permit(:initial_state, :rows, :cols)
  end
end
