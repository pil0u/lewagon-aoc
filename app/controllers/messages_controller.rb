# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_allowed_to_post, only: %i[index create]

  def index
    @message = Message.new(user: current_user)
    @messages = Message.order(created_at: :desc)
  end

  def create
    message = Message.new(
      content: helpers.restrictive_sanitize(message_params[:content]),
      user: current_user
    )

    unless @allowed_to_post
      redirect_to(messages_path, alert: "You already sent a message today")
      return
    end

    if message.save
      redirect_to messages_path, notice: "Your message was published"
    else
      redirect_to messages_path, alert: message.errors.full_messages[0].to_s
    end
  end

  private

  def set_allowed_to_post
    today = Time.now.getlocal("-05:00").beginning_of_day

    @allowed_to_post = current_user.messages.where("created_at > ?", today).count == 0
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
