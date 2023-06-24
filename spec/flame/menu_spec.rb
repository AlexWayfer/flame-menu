# frozen_string_literal: true

describe Flame::Menu do
	include Rack::Test::Methods

	# rubocop:disable Lint/ConstantDefinitionInBlock
	# rubocop:disable RSpec/LeakyConstantDeclaration
	module Test
		module Cabinet
			class Controller < Flame::Controller
				include Flame::Menu

				MENU_ITEMS = [
					[
						:requests,
						[
							:available,
							[
								:performed,
								%i[completed not_completed].freeze
							].freeze,
							:archive
						].freeze
					].freeze,
					:clients,
					[
						:offers,
						%i[actual selected].freeze
					].freeze
				].freeze

				PERMISSION = nil

				def authenticated_account
					request.get_header('HTTP_AUTHENTICATED_ACCOUNT')
				end

				protected

				def available?(controller = self.class)
					return false unless authenticated_account
					return true if controller::PERMISSION.nil?

					authenticated_account.split(',').include? controller::PERMISSION.to_s
				end

				def server_error(error)
					puts error, error.backtrace
					super
				end

				private

				def render_menu
					## It's inside a class!
					# rubocop:disable RSpec/InstanceVariable
					@menu.available.map { |item| path_to item.controller }.join(',')
					# rubocop:enable RSpec/InstanceVariable
				end
			end

			class IndexController < Cabinet::Controller
				def index; end
			end

			class ControllerOutsideMenu < Cabinet::Controller
				def index; end
			end

			class ControllerOutsideMenuWithPermissionCheck < Cabinet::Controller
				PERMISSION = :available_requests

				def index; end
			end

			module Requests
				class Controller < Cabinet::Controller
				end

				class IndexController < Requests::Controller
					def index; end
				end

				class AvailableController < Requests::Controller
					PERMISSION = :available_requests

					def index
						render_menu
					end
				end

				module Performed
					class Controller < Requests::Controller
					end

					class IndexController < Performed::Controller
						def index; end
					end

					class CompletedController < Performed::Controller
						PERMISSION = :completed_requests

						def index
							render_menu
						end
					end

					class NotCompletedController < Performed::Controller
						PERMISSION = :not_completed_requests

						def index
							render_menu
						end
					end
				end

				class ArchiveController < Requests::Controller
					PERMISSION = :archive_requests

					def index
						render_menu
					end
				end
			end

			class ClientsController < Cabinet::Controller
				PERMISSION = :clients

				def index; end
			end

			module Offers
				class Controller < Cabinet::Controller
				end

				class IndexController < Offers::Controller
					def index; end
				end

				class ActualController < Offers::Controller
					PERMISSION = :actual_offers

					def index; end
				end

				class SelectedController < Offers::Controller
					PERMISSION = :selected_offers

					def index; end
				end
			end
		end

		## Test Application
		class Application < Flame::Application
			mount :cabinet do
				mount :controller_outside_menu
				mount :controller_outside_menu_with_permission_check

				mount :requests do
					mount :available

					mount :performed do
						mount :completed
						mount :not_completed
					end

					mount :archive
				end

				mount :clients

				mount :offers do
					mount :actual
					mount :selected
				end
			end
		end
	end
	# rubocop:enable Lint/ConstantDefinitionInBlock
	# rubocop:enable RSpec/LeakyConstantDeclaration

	def app
		Test::Application
	end

	before do
		header 'Authenticated-Account', permissions.join(',')
		get path
	end

	shared_examples 'correct redirect' do |permissions, location|
		context "with '#{permissions}' permissions" do
			let(:permissions) { Array(permissions) }

			it 'is redirect' do
				expect(last_response).to be_redirect
			end

			it "redirects to #{location}" do
				expect(last_response['Location']).to eq(location)
			end
		end
	end

	shared_examples 'does not redirect' do |permissions|
		context "with '#{permissions}' permissions" do
			let(:permissions) { [permissions] }

			it 'does not redirect' do
				expect(last_response).to be_ok
			end
		end
	end

	describe 'requests to /cabinet' do
		let(:path) { '/cabinet' }

		include_examples(
			'correct redirect', 'archive_requests', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'available_requests', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet/clients'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'actual_offers', '/cabinet/offers'
		)
	end

	describe 'requests to /cabinet/controller_outside_menu' do
		let(:path) { '/cabinet/controller_outside_menu' }

		include_examples 'does not redirect'
	end

	describe(
		'requests to /cabinet/controller_outside_menu_with_permission_check'
	) do
		let(:path) { '/cabinet/controller_outside_menu_with_permission_check' }

		include_examples('correct redirect', '', '/cabinet')

		include_examples('does not redirect', 'available_requests')
	end

	describe 'requests to /cabinet/requests' do
		let(:path) { '/cabinet/requests' }

		include_examples(
			'correct redirect', 'archive_requests', '/cabinet/requests/archive'
		)
		include_examples(
			'correct redirect', 'available_requests', '/cabinet/requests/available'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet'
		)
		include_examples(
			'correct redirect', 'actual_offers', '/cabinet'
		)
	end

	describe 'requests to /cabinet/requests/available' do
		let(:path) { '/cabinet/requests/available' }

		include_examples(
			'correct redirect', 'archive_requests', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet/requests'
		)

		include_examples(
			'does not redirect', 'available_requests'
		)
	end

	describe 'requests to /cabinet/requests/performed' do
		let(:path) { '/cabinet/requests/performed' }

		include_examples(
			'correct redirect',
			'completed_requests',
			'/cabinet/requests/performed/completed'
		)

		include_examples(
			'correct redirect', 'archive_requests', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet/requests'
		)
	end

	describe 'requests to /cabinet/requests/performed/not_completed' do
		let(:path) { '/cabinet/requests/performed/not_completed' }

		include_examples(
			'correct redirect', 'completed_requests', '/cabinet/requests/performed'
		)

		include_examples(
			'correct redirect', 'archive_requests', '/cabinet/requests/performed'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet/requests/performed'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet/requests/performed'
		)

		include_examples(
			'does not redirect', 'not_completed_requests'
		)
	end

	describe 'requests to /cabinet/requests/archive' do
		let(:path) { '/cabinet/requests/archive' }

		include_examples(
			'correct redirect', 'available_requests', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet/requests'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet/requests'
		)

		include_examples(
			'does not redirect', 'archive_requests'
		)
	end

	describe 'requests to /cabinet/clients' do
		let(:path) { '/cabinet/clients' }

		include_examples(
			'correct redirect', 'available_requests', '/cabinet'
		)
		include_examples(
			'correct redirect', 'available_requests,selected_offers', '/cabinet'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet'
		)

		include_examples(
			'does not redirect', 'clients'
		)
	end

	describe 'requests to /cabinet/offers' do
		let(:path) { '/cabinet/offers' }

		include_examples(
			'correct redirect', 'archive_requests', '/cabinet'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet'
		)
		include_examples(
			'correct redirect', 'clients,selected_offers', '/cabinet/offers/selected'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet/offers/selected'
		)
		include_examples(
			'correct redirect',
			'archive_requests,selected_offers',
			'/cabinet/offers/selected'
		)
	end

	describe 'requests to /cabinet/offers/actual' do
		let(:path) { '/cabinet/offers/actual' }

		include_examples(
			'correct redirect', 'archive_requests', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'clients,selected_offers', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'selected_offers', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'archive_requests,selected_offers', '/cabinet/offers'
		)

		include_examples(
			'does not redirect', 'actual_offers'
		)
	end

	describe 'requests to /cabinet/offers/selected' do
		let(:path) { '/cabinet/offers/selected' }

		include_examples(
			'correct redirect', 'available_requests', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'clients', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'clients,actual_offers', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'actual_offers', '/cabinet/offers'
		)
		include_examples(
			'correct redirect', 'available_requests,actual_offers', '/cabinet/offers'
		)

		include_examples(
			'does not redirect', 'selected_offers'
		)
	end
end
