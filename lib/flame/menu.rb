# frozen_string_literal: true

require 'gorilla_patch/namespace'
require 'gorilla_patch/inflections'

module Flame
	## Menu for controllers
	module Menu
		def self.included(root_controller)
			const_setting =
				->(ctrl) { ctrl.const_set(:MENU_ITEMS_ROOT_CONTROLLER, ctrl) }

			if root_controller.is_a?(Class)
				const_setting.call(root_controller)
			else
				root_controller.define_singleton_method(:included, &const_setting)
			end
		end

		using GorillaPatch::Namespace

		def initialize(*args)
			super
			@menu = Menu.new(self)
		end

		protected

		def execute(action)
			redirection = @menu.redirection_for(action)
			redirection ? redirect(redirection.controller) : super
		end

		## Class for Item as controller
		class Item
			attr_reader :key, :controller, :parent

			def initialize(key, controller, parent)
				@key = key
				@controller = controller
				@parent = parent
			end

			def current_controller
				(@current_controller if defined?(@current_controller)) ||
					parent.current_controller
			end

			def available
				@available ||= Array(available? ? self : nil)
			end

			def available?
				current_controller.send(:available?, controller)
			end

			def current?
				if current_controller.class.const_defined?(:MENU_ITEM_KEY)
					current_controller.class::MENU_ITEM_KEY == key
				else
					current_controller.instance_of?(controller)
				end
			end

			alias current_itself? current?

			def current
				self if current_itself?
			end

			def ancestors
				@ancestors ||= [parent, *parent&.ancestors].flatten.compact
			end

			## Class for Item with subitems
			class WithSubitems < self
				def initialize(
					key, controller, subitems = [], parent = nil, current_controller = nil
				)
					super(key, controller, parent)
					@subitems = subitems.map { |item| initialize_item(*item) }
					@current_controller = current_controller
				end

				def available
					@available ||= @subitems.select(&:available?)
				end

				def available?
					available.any?
				end

				def current
					@current ||= @subitems.find(&:current?)&.current || super
				end

				def current?
					## Probably need to be:
					# !current.nil? || super
					## https://gitlab.key-g.com/gettransport/site/merge_requests/123#note_60004
					!current.nil?
				end

				private

				using GorillaPatch::Inflections

				def initialize_item(key, subitems = [])
					controller = find_item_controller key

					if subitems.any?
						Item::WithSubitems.new(key, controller, subitems, self)
					else
						Item.new(key, controller, self)
					end
				end

				def find_item_controller(key)
					namespace = Object.const_get(@controller.deconstantize)
					class_name = key.to_s.camelize
					namespace.const_get(
						%W[
							#{class_name}Controller #{class_name}::IndexController
						].find(
							-> { raise "Can't find controller #{class_name} for #{namespace}" }
						) { |const_name| namespace.const_defined?(const_name) }
					)
				end
			end
		end

		## Menu adds menu-specific methods to item WithSubitems
		class Menu < Item::WithSubitems
			def initialize(current_controller)
				root_controller = current_controller.class::MENU_ITEMS_ROOT_CONTROLLER
				index_controller =
					Object.const_get(root_controller.deconstantize)::IndexController

				super(
					:root,
					index_controller, root_controller::MENU_ITEMS,
					nil, current_controller
				)
			end

			def redirection_for(action)
				if current
					return current.parent unless current.available?
					return unless current.is_a?(WithSubitems) && action == :index

					current.available.first
				else
					self unless current_controller.send(:available?)
				end
			end
		end
	end
end
