# frozen_string_literal: true

class ReactionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_reaction, only: %i[update destroy]

  def create
    reaction = current_user.reactions.build(reaction_params.merge(snippet_id: params[:snippet_id]))

    if reaction.save
      render json: { reaction: }, status: :ok
    else
      render json: { errors: reaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @reaction.update(reaction_params)
      render json: { reaction: @reaction }, status: :ok
    else
      render json: { errors: reaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @reaction.destroy
    render json: {}, status: :ok
  end

  private

  def set_reaction
    @reaction = current_user.reactions.find(params[:id])
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end
end
