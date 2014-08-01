class ChatController < WebsocketRails::BaseController

    def user_connected
        p 'user connected'
        send_message :user_info, {:user => current_user.screen_name}
    end

    def incoming_message
        broadcast_message :new_messagee, {:user => current_user.screen_name, :text => message[:text]}
    end

    def action_message
        broadcast_message :action, {:user => message[:username], :action => message[:action]}
    end

    def user_disconnected
        p 'user disconnected'
    end
end
