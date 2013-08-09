require 'spec_helper'

describe CASino::SessionsController do
  describe 'GET "new"' do
    it 'calls the process method of the LoginCredentialRequestor' do
      CASino::Processors::LoginCredentialRequestor.any_instance.should_receive(:process)
      get :new
    end
  end

  describe 'POST "create"' do
    it 'calls the process method of the LoginCredentialAcceptor' do
      CASino::Processors::LoginCredentialAcceptor.any_instance.should_receive(:process) do
        @controller.render nothing: true
      end
      post :create
    end
  end

  describe 'POST "validate_otp"' do
    it 'calls the process method of the SecondFactorAuthenticatonAcceptor' do
      CASino::Processors::SecondFactorAuthenticationAcceptor.any_instance.should_receive(:process) do
        @controller.render nothing: true
      end
      post :validate_otp
    end
  end

  describe 'GET "logout"' do
    it 'calls the process method of the Logout processor' do
      CASino::Processors::Logout.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params.should == controller.params
        cookies.should == controller.cookies
        user_agent.should == request.user_agent
      end
      get :logout
    end
  end

  describe 'GET "index"' do
    it 'calls the process method of the SessionOverview processor' do
      CASino::Processors::TwoFactorAuthenticatorOverview.any_instance.should_receive(:process)
      CASino::Processors::SessionOverview.any_instance.should_receive(:process)
      get :index
    end
  end

  describe 'DELETE "destroy"' do
    let(:id) { '123' }
    let(:tgt) { 'TGT-foobar' }
    it 'calls the process method of the SessionOverview processor' do
      request.cookies[:tgt] = tgt
      CASino::Processors::SessionDestroyer.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params[:id].should == id
        cookies[:tgt].should == tgt
        user_agent.should == request.user_agent
        @controller.render nothing: true
      end
      delete :destroy, id: id
    end
  end

  describe 'GET "destroy_others"' do
    it 'calls the process method of the OtherSessionsDestroyer' do
      CASino::Processors::OtherSessionsDestroyer.any_instance.should_receive(:process) do
        @controller.render nothing: true
      end
      get :destroy_others
    end
  end
end
