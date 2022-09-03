# frozen_string_literal: true

class DaysController < ApplicationController
  def show
    @number = params[:number]
  end
end
