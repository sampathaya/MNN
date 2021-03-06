require 'spec_helper'

describe Admin::LanguagesController do
  
  describe "Not Logged in users" do
    describe "GET index" do
      it "redirects to the login page" do
        get :index
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
  
  describe "Logged in users" do
    before (:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin_user]
      @user = FactoryGirl.create(:admin_user)
      @role = FactoryGirl.create(:role_admin)
      @user.roles << @role
      sign_in @user
    end
    
    describe "Existing Language" do
      before (:each) do
        @language = FactoryGirl.create(:language)
      end
      describe "GET index" do
        it "Should Show @languages array" do
          get :index
          expect(assigns(:languages)).to eq([@language])
        end
      end
      describe "GET show" do
        it "Should Show @language" do
          get :show, id: @language.id
          expect(assigns(:language)).to eq(@language)
        end
      end
      describe "GET edit" do
        it "Should have @language" do
          get :edit, id: @language.id
          expect(assigns(:language)).to eq(@language)
        end
        it "Should have @language not as new record" do
          get :edit, id: @language.id
          expect(assigns(:language)).not_to be_new_record
        end
      end
    end

    describe "New Language Record" do
      describe "GET new" do
        it "Should show new language page" do
          get :new
          expect(assigns(:language)).not_to be_nil
        end
        it "Should show new language page" do
          get :new
          expect(assigns(:language)).to be_new_record
        end
      end
    end
    
  end
end
