module Api
  class UsersController < ApplicationController
    before_action :authenticate_user, except: [:create]
    before_action :find_user, except: %i[index create]

    def index
      @users = User.order(:id).page(params[:page]).decorate
    end

    def create
      @form = RegistrationForm.new(user_create_params)
      if @form.save
        render status: :created
      else
        render status: :bad_request
      end
    end

    def show; end

    def update
      if current_user == @user
        @form = UserUpdatingForm.new(user_update_params)
        @form.user = @user

        if @form.save
          render :create, status: :ok
        else
          render :create, status: :bad_request
        end
      else
        head :forbidden
      end
    end

    def destroy
      if current_user == @user
        @user.destroy

        head :ok
      else
        head :forbidden
      end
    end

    private

    def user_create_params
      params.require(:user).permit(:username, :email, :password, :first_name, :last_name, :patronymic)
    end

    def user_update_params
      params.require(:user).permit(:password, :first_name, :last_name, :patronymic)
    end

    def find_user
      @user = User.find_by!(id: params[:id]).decorate
    end
  end
end
