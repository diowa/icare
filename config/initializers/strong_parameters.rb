# frozen_string_literal: true
Mongoid::Document.send(:include, ActiveModel::ForbiddenAttributesProtection)
