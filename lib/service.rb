class Service
  class << self

    def load_services
      path = File.expand_path("../services/*.rb", __FILE__)
      Dir[path].each { |lib| require(lib) }
    end

    def services
      @services ||= []
    end

    def schema
      @schema ||= []
    end

    def string(*attrs)
      add_to_schema :string, attrs
    end

    def password(*attrs)
      add_to_schema :password, attrs
    end

    def boolean(*attrs)
      add_to_schema :boolean, attrs
    end

    def white_listed
      @white_listed ||= []
    end

    def white_list(*attrs)
      attrs.each do |attr|
        white_listed << attr.to_s
      end
    end

    def add_to_schema(type, attrs)
      attrs.each do |attr|
        schema << [type, attr.to_sym]
      end
    end

    def title(value = nil)
      if value
        @title = value
      else
        @title ||= begin
          hook = name.dup
          hook.sub! /.*:/, ''
          hook
        end
      end
    end

    def hook_name(value = nil)
      if value
        @hook_name = value
      else
        @hook_name ||= begin
          hook = name.dup
          hook.downcase!
          hook.sub! /.*:/, ''
          hook
        end
      end
    end

    def url(value = nil)
      if value
        @url = value
      else
        @url
      end
    end

    def category(value = nil)
      if value
        @category = value
      else
        @category
      end
    end

    def logo_url(value = nil)
      if value
        @logo_url = value
      else
        @logo_url
      end
    end

    def authenticate_with(value = nil)
      if value
        @authenticate_with = value
      else
        @authenticate_with
      end
    end

    def inherited(svc)
      Service.services << svc
      super
    end

    def call(data: {})
      new(data: data).call
    end
  end

  attr_reader :data

  def initialize(data: {})
    @data = data || {}
  end

  def call
    msg = "#{title} is not callable"
    raise NotImplementedError.new msg
  end

  class Error < StandardError
    attr_reader :original_exception
    def initialize(message, original_exception=nil)
      original_exception = message if message.kind_of?(Exception)
      @original_exception = original_exception
      super(message)
    end
  end

  class ConfigurationError < Error
  end

  class MissingError < Error
  end

  def raise_config_error(msg = "Invalid configuration")
    raise ConfigurationError, msg
  end

  def raise_missing_error(msg = "Remote endpoint not found")
    raise MissingError, msg
  end
end