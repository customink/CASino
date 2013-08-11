require 'spec_helper'

describe CASino::API::V1::TicketsController do

  describe "POST /cas/v1/tickets" do
    context "with correct credentials" do

      before do
        CASino::Processors::API::LoginCredentialAcceptor.any_instance.should_receive(:process) do
          @controller.user_logged_in_via_api "TGT-long-string"
        end

        post :create, params: {username: 'valid', password: 'valid'}
      end

      subject { response }
      its(:response_code) { should eq 201 }
      its(:location) { should eq 'http://test.host/cas/v1/tickets/TGT-long-string' }
    end

    context "with incorrect credentials" do

      before do
        CASino::Processors::API::LoginCredentialAcceptor.any_instance.should_receive(:process) do
          @controller.invalid_login_credentials_via_api
        end

        post :create, params: {username: 'invalid', password: 'invalid'}
      end

      subject { response }
      its(:response_code) { should eq 400 }
    end

    context "with a not allowed service" do

      before do
        CASino::Processors::API::LoginCredentialAcceptor.any_instance.should_receive(:process) do
          @controller.service_not_allowed_via_api
        end

        post :create, params: {username: 'example', password: 'example'}
      end

      subject { response }
      its(:response_code) { should eq 400 }
    end
  end

  describe "POST /cas/v1/tickets/{TGT id}" do

    context "with a valid TGT" do

      before do
        CASino::Processors::API::ServiceTicketProvider.any_instance.should_receive(:process).with('TGT-valid', kind_of(Hash), request.user_agent) do |ticket, params|
          params.should == controller.params
          @controller.granted_service_ticket_via_api 'ST-1-VALIDSERVICETICKET'
        end
        post :update, id: 'TGT-valid', service: 'http://example.org/'
      end

      subject { response }

      its(:response_code) { should eq 200 }
      its(:body) { should eq 'ST-1-VALIDSERVICETICKET' }
    end

    context "with an invalid TGT" do

      before do
        CASino::Processors::API::ServiceTicketProvider.any_instance.should_receive(:process).with('TGT-invalid', kind_of(Hash), request.user_agent) do |ticket, params|
          params.should == controller.params
          @controller.invalid_ticket_granting_ticket_via_api
        end
        post :update, id: 'TGT-invalid', service: 'http://example.org/'
      end

      subject { response }

      its(:response_code) { should eq 400 }

    end

    context "without a service" do

      before do
        CASino::Processors::API::ServiceTicketProvider.any_instance.should_receive(:process).with('TGT-valid', kind_of(Hash), request.user_agent) do |ticket, params|
          params.should == controller.params
          @controller.no_service_provided_via_api
        end
        post :update, id: 'TGT-valid'
      end

      subject { response }

      its(:response_code) { should eq 400 }

    end
  end

  describe "DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie" do
     before do
      CASino::Processors::API::Logout.any_instance.should_receive(:process).with('TGT-fdsjfsdfjkalfewrihfdhfaie', request.user_agent) do
        @controller.user_logged_out_via_api
      end
      post :destroy, id: 'TGT-fdsjfsdfjkalfewrihfdhfaie'
    end

    subject { response }

    its(:response_code) { should eq 200 }
  end

end
