# frozen_string_literal: true

class ReactionsController < ApplicationController
  before_action :set_reaction, only: %i[update destroy]

  def create
    reaction = current_user.reactions.build(snippet_id: params[:snippet_id], **reaction_params)

    if reaction.save
      redirect_back fallback_location: "/"
    else
      redirect_back fallback_location: "/", alert: reaction.errors.full_messages[0].to_s
    end
  end

  def update
    if @reaction.update(reaction_params)
      redirect_back fallback_location: "/"
    else
      redirect_back fallback_location: "/", alert: reaction.errors.full_messages[0].to_s
    end
  end

  def destroy
    @reaction.destroy
    redirect_back fallback_location: "/"
  end

  private

  def set_reaction
    @reaction = current_user.reactions.find(params[:id])
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end
end
